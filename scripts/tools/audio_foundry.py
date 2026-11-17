#!/usr/bin/env python3
"""
ASHVALE: THE THIRTEENTH BELL — Original Audio Foundry
Generates:
  - 8 seamless 44.1 kHz stereo musical cues (64-88s) using expressive physical/additive synthesis
    with a cohesive "Thirteenth Bell / Elena" Leitmotif across all chapters.
  - 7 seamless 44.1 kHz stereo ambient beds (48s) with zero harsh hiss, zero buzzing,
    low-passed natural noise beds, and sparse organic nature events.
  - 24 crisp, natural 44.1 kHz SFX WAV assets (including 3 footstep variations).

Outputs OGG Vorbis (.ogg) via ffmpeg for Music & Ambience, and 16-bit WAV (.wav) for SFX.
"""

import math
import os
import subprocess
import sys
import wave
from pathlib import Path
import numpy as np

SR = 44100
TAU = 2.0 * math.pi

ROOT_DIR = Path(__file__).resolve().parents[2]
AUDIO_DIR = ROOT_DIR / "assets" / "audio"
MUSIC_DIR = AUDIO_DIR / "music"
AMBIENCE_DIR = AUDIO_DIR / "ambience"
SFX_DIR = AUDIO_DIR / "sfx"
PREVIEW_DIR = ROOT_DIR / "docs" / "audio_previews"


def ensure_dirs() -> None:
    for d in (MUSIC_DIR, AMBIENCE_DIR, SFX_DIR, PREVIEW_DIR):
        d.mkdir(parents=True, exist_ok=True)


def midi_to_hz(midi: float) -> float:
    return 440.0 * (2.0 ** ((midi - 69.0) / 12.0))


def _fft_lowpass(x: np.ndarray, cutoff_hz: float, sr: int = SR, slope: float = 2.0) -> np.ndarray:
    """Zero-phase smooth low-pass filter using rfft (never rings or clips)."""
    n = x.shape[0]
    if n < 8:
        return x
    freqs = np.fft.rfftfreq(n, d=1.0 / sr)
    spec = np.fft.rfft(x, axis=0)
    resp = 1.0 / (1.0 + (freqs / max(20.0, cutoff_hz)) ** (2.0 * slope))
    if x.ndim == 2:
        resp = resp[:, None]
    return np.fft.irfft(spec * resp, n=n, axis=0)


def _fft_bandpass(x: np.ndarray, lo_hz: float, hi_hz: float, sr: int = SR) -> np.ndarray:
    n = x.shape[0]
    if n < 8:
        return x
    freqs = np.fft.rfftfreq(n, d=1.0 / sr)
    spec = np.fft.rfft(x, axis=0)
    hp = (freqs / max(10.0, lo_hz)) ** 2 / (1.0 + (freqs / max(10.0, lo_hz)) ** 2)
    lp = 1.0 / (1.0 + (freqs / max(30.0, hi_hz)) ** 4)
    resp = hp * lp
    if x.ndim == 2:
        resp = resp[:, None]
    return np.fft.irfft(spec * resp, n=n, axis=0)


def build_hall_ir(duration_s: float = 2.6, bright_hz: float = 2600.0, seed: int = 101) -> np.ndarray:
    """Sculpts a lush, warm stereo concert hall impulse response with discrete early reflections."""
    rng = np.random.default_rng(seed)
    n = int(duration_s * SR)
    t = np.arange(n, dtype=np.float64) / SR
    ir = np.zeros((n, 2), dtype=np.float64)

    # Warm early stone/wood reflections
    early_taps = [
        (0.013, 0.42, 0.22),
        (0.021, 0.19, 0.39),
        (0.031, 0.31, 0.14),
        (0.043, 0.15, 0.28),
        (0.058, 0.22, 0.18),
        (0.074, 0.12, 0.17),
    ]
    for delay_s, gl, gr in early_taps:
        idx = int(delay_s * SR)
        if idx < n:
            ir[idx, 0] += gl
            ir[idx, 1] += gr

    # Smooth diffuse late tail with frequency-dependent air damping
    noise_l = rng.standard_normal(n)
    noise_r = rng.standard_normal(n)
    # Two-band decay: warm body lasts longer, highs fade smoothly
    lo_env = np.exp(-t / (duration_s * 0.42)) * (1.0 - np.exp(-t / 0.035))
    hi_env = np.exp(-t / (duration_s * 0.20)) * (1.0 - np.exp(-t / 0.025))

    tail_l = _fft_lowpass(noise_l, 950.0, slope=1.5) * lo_env * 0.65 + _fft_bandpass(noise_l, 800.0, bright_hz) * hi_env * 0.35
    tail_r = _fft_lowpass(noise_r, 950.0, slope=1.5) * lo_env * 0.65 + _fft_bandpass(noise_r, 800.0, bright_hz) * hi_env * 0.35

    ir[:, 0] += tail_l * 0.14
    ir[:, 1] += tail_r * 0.14
    ir = _fft_lowpass(ir, bright_hz, slope=1.5)

    # Normalize wet impulse energy cleanly
    energy = np.sqrt(np.sum(ir ** 2, axis=0)).mean()
    if energy > 1e-8:
        ir /= energy
    return ir


def apply_circular_reverb(dry: np.ndarray, ir: np.ndarray, wet_mix: float = 0.22) -> np.ndarray:
    """Applies stereo FFT circular convolution so tails wrap smoothly across loop boundaries."""
    n = dry.shape[0]
    m = ir.shape[0]
    ir_padded = np.zeros((n, 2), dtype=np.float64)
    copy_len = min(n, m)
    ir_padded[:copy_len] = ir[:copy_len]
    wet_l = np.fft.irfft(np.fft.rfft(dry[:, 0]) * np.fft.rfft(ir_padded[:, 0]), n=n)
    wet_r = np.fft.irfft(np.fft.rfft(dry[:, 1]) * np.fft.rfft(ir_padded[:, 1]), n=n)
    wet = np.column_stack((wet_l, wet_r))
    return dry * (1.0 - wet_mix * 0.35) + wet * wet_mix


def _pan_stereo(mono: np.ndarray, pan: float) -> np.ndarray:
    """Equal-power stereo panner (-1.0 left .. +1.0 right)."""
    p = max(-1.0, min(1.0, pan))
    angle = (p + 1.0) * (math.pi * 0.25)
    return np.column_stack((mono * math.cos(angle), mono * math.sin(angle)))


# ---------------------------------------------------------------------------
# Expressive Acoustic-Modeled Musical Instruments
# ---------------------------------------------------------------------------

def synth_felt_piano(freq: float, dur: float, vel: float = 0.75, rng=None) -> np.ndarray:
    """Warm felt upright/concert piano with soft hammer thump and string inharmonicity."""
    tail_s = 1.45
    total_dur = dur + tail_s
    n = int(total_dur * SR)
    t = np.arange(n, dtype=np.float64) / SR
    if rng is None:
        rng = np.random.default_rng(int(freq * 100))

    # Brightness drops exponentially over sustain; higher notes decay faster
    pitch_scale = max(0.35, min(1.6, 261.63 / max(45.0, freq)))
    b_inharm = 0.00028 * (freq / 261.63) ** 0.7

    partials = [
        (1, 1.00, 1.85 * pitch_scale),
        (2, 0.42 * (0.65 + 0.35 * vel), 1.35 * pitch_scale),
        (3, 0.18 * (0.50 + 0.50 * vel), 0.92 * pitch_scale),
        (4, 0.07 * vel, 0.62 * pitch_scale),
        (5, 0.03 * vel, 0.44 * pitch_scale),
    ]

    sig = np.zeros(n, dtype=np.float64)
    for k, amp, tau_s in partials:
        fk = freq * k * math.sqrt(1.0 + b_inharm * k * k)
        if fk > 6500.0:
            continue
        env_k = np.exp(-t / max(0.12, tau_s))
        # Subtle sympathetic shimmer via tiny unison detune on fundamental/2nd
        if k <= 2:
            sig += amp * env_k * (0.58 * np.sin(TAU * fk * t) + 0.42 * np.sin(TAU * (fk * 1.0008) * t + 0.35))
        else:
            sig += amp * env_k * np.sin(TAU * fk * t + 0.17 * k)

    # Felt hammer transient (warm thump < 650 Hz)
    hammer_n = min(n, int(0.028 * SR))
    if hammer_n > 8:
        h_noise = rng.standard_normal(hammer_n)
        h_noise = _fft_lowpass(h_noise, 550.0)
        h_env = np.exp(-np.arange(hammer_n) / (0.007 * SR)) * (1.0 - np.exp(-np.arange(hammer_n) / (0.0015 * SR)))
        sig[:hammer_n] += h_noise * h_env * 0.18 * vel

    # Attack & release envelope (smooth key damper on note-off)
    att = 1.0 - np.exp(-t / 0.0045)
    rel = np.ones(n, dtype=np.float64)
    off_idx = int(dur * SR)
    if off_idx < n:
        t_rel = t[off_idx:] - dur
        rel[off_idx:] = np.exp(-t_rel / (0.42 * min(1.3, pitch_scale)))
    # Anti-click fade out at end of buffer
    end_fade = min(n, int(0.08 * SR))
    rel[-end_fade:] *= np.linspace(1.0, 0.0, end_fade)

    sig *= att * rel * (0.28 * vel)
    # Natural stereo width like pianist perspective: bass slightly left, treble slightly right
    pan = max(-0.55, min(0.55, (freq - 320.0) / 700.0))
    return _pan_stereo(sig, pan)


def synth_harp(freq: float, dur: float, vel: float = 0.70, pan: float = 0.0) -> np.ndarray:
    """Delicate folk/concert harp with warm plucked finger bloom."""
    total_dur = max(dur, 0.4) + 1.8
    n = int(total_dur * SR)
    t = np.arange(n, dtype=np.float64) / SR
    pitch_scale = max(0.35, min(1.5, 330.0 / max(60.0, freq)))

    sig = (
        1.00 * np.exp(-t / (1.55 * pitch_scale)) * np.sin(TAU * freq * t)
        + 0.34 * np.exp(-t / (0.78 * pitch_scale)) * np.sin(TAU * 2.0 * freq * t + 0.4)
        + 0.11 * np.exp(-t / (0.42 * pitch_scale)) * np.sin(TAU * 3.0 * freq * t + 0.9)
        + 0.04 * np.exp(-t / (0.22 * pitch_scale)) * np.sin(TAU * 4.0 * freq * t + 1.2)
    )
    att = 1.0 - np.exp(-t / 0.0055)
    fade_n = min(n, int(0.10 * SR))
    sig *= att
    sig[-fade_n:] *= np.linspace(1.0, 0.0, fade_n)
    return _pan_stereo(sig * (0.22 * vel), pan)


def synth_celesta(freq: float, dur: float, vel: float = 0.55, pan: float = 0.15) -> np.ndarray:
    """Soft crystalline celesta tone without harsh metallic ringing."""
    total_dur = max(dur, 0.3) + 1.2
    n = int(total_dur * SR)
    t = np.arange(n, dtype=np.float64) / SR
    sig = (
        1.00 * np.exp(-t / 0.95) * np.sin(TAU * freq * t)
        + 0.20 / (1.0 + (2.0 * freq / 4600.0) ** 4) * np.exp(-t / 0.40) * np.sin(TAU * 2.0 * freq * t)
        + 0.045 / (1.0 + (4.0 * freq / 4600.0) ** 4) * np.exp(-t / 0.15) * np.sin(TAU * 4.0 * freq * t)
    )
    att = 1.0 - np.exp(-t / 0.007)
    fade_n = min(n, int(0.08 * SR))
    sig *= att
    sig[-fade_n:] *= np.linspace(1.0, 0.0, fade_n)
    return _pan_stereo(sig * (0.16 * vel), pan)


def synth_flute(freq: float, dur: float, vel: float = 0.65, pan: float = 0.08, rng=None) -> np.ndarray:
    """Airy wooden flute / bansuri with soft breath onset and expressive delayed vibrato."""
    tail_s = 0.32
    total_dur = dur + tail_s
    n = int(total_dur * SR)
    t = np.arange(n, dtype=np.float64) / SR
    if rng is None:
        rng = np.random.default_rng(int(freq * 37))

    # Delayed smooth vibrato
    vib_depth = 0.0065 * np.clip((t - 0.22) / 0.45, 0.0, 1.0)
    inst_freq = freq * (1.0 + vib_depth * np.sin(TAU * 5.1 * t))
    phase = TAU * np.cumsum(inst_freq) / SR

    lp1 = 1.0 / (1.0 + (freq / 3400.0) ** 3)
    lp2 = 1.0 / (1.0 + (2.0 * freq / 3400.0) ** 3)
    lp3 = 1.0 / (1.0 + (3.0 * freq / 3400.0) ** 3)
    sig = (
        1.00 * lp1 * np.sin(phase)
        + 0.24 * lp2 * np.sin(2.0 * phase + 0.3)
        + 0.06 * lp3 * np.sin(3.0 * phase + 0.7)
    )

    # Gentle breath chiff at onset + very faint continuous air
    breath_n = min(n, int(0.35 * SR))
    if breath_n > 16:
        b_clip = _fft_bandpass(rng.standard_normal(breath_n), max(280.0, freq * 0.75), min(3000.0, freq * 2.4))
        b_env = np.exp(-t[:breath_n] / 0.055) * (1.0 - np.exp(-t[:breath_n] / 0.008)) * 0.42
        sig[:breath_n] += b_clip * b_env

    # Expressive dynamic swell envelope
    att_s = min(0.14, dur * 0.25)
    att = np.sin(np.clip(t / max(0.02, att_s), 0.0, 1.0) * (math.pi * 0.5))
    rel = np.ones(n, dtype=np.float64)
    off_idx = int(dur * SR)
    if off_idx < n:
        rel[off_idx:] = np.exp(-(t[off_idx:] - dur) / 0.095)
    fade_n = min(n, int(0.04 * SR))
    rel[-fade_n:] *= np.linspace(1.0, 0.0, fade_n)

    swell = 0.88 + 0.14 * np.sin(np.clip(t / max(0.1, dur), 0.0, 1.0) * math.pi)
    return _pan_stereo(sig * att * rel * swell * (0.20 * vel), pan)


def synth_strings(
    freq: float,
    dur: float,
    vel: float = 0.65,
    pan: float = 0.0,
    solo: bool = False,
    attack_s: float = 0.18,
    rng=None,
) -> np.ndarray:
    """Warm bowed cello or stereo string ensemble with body resonance & natural vibrato."""
    tail_s = 0.55
    total_dur = dur + tail_s
    n = int(total_dur * SR)
    t = np.arange(n, dtype=np.float64) / SR
    if rng is None:
        rng = np.random.default_rng(int(freq * 53))

    voices = [(0.0, 1.0)] if solo else [(-0.0032, 0.36), (0.0, 0.44), (0.0034, 0.36)]
    out = np.zeros((n, 2), dtype=np.float64)

    att = np.sin(np.clip(t / max(0.04, attack_s), 0.0, 1.0) * (math.pi * 0.5))
    rel = np.ones(n, dtype=np.float64)
    off_idx = int(dur * SR)
    if off_idx < n:
        rel[off_idx:] = np.exp(-(t[off_idx:] - dur) / 0.22)
    fade_n = min(n, int(0.06 * SR))
    rel[-fade_n:] *= np.linspace(1.0, 0.0, fade_n)
    env = att * rel

    cutoff = 1650.0 if freq < 260.0 else 2200.0
    h_amps = [(1, 1.00, 0.0), (2, 0.52, 0.15), (3, 0.26, 0.30), (4, 0.13, 0.45), (5, 0.06, 0.60), (6, 0.025, 0.0)]
    h_weights = [(k, a / (1.0 + (k * freq / cutoff) ** 3.0), ph) for k, a, ph in h_amps]

    for idx_v, (detune, gain) in enumerate(voices):
        f_v = freq * (1.0 + detune)
        vib_delay = 0.28 if solo else 0.35
        vib = 0.0055 * np.clip((t - vib_delay) / 0.45, 0.0, 1.0) * np.sin(TAU * (4.7 + idx_v * 0.25) * t + idx_v * 1.1)
        phase = TAU * np.cumsum(f_v * (1.0 + vib)) / SR

        warm = np.zeros(n, dtype=np.float64)
        for k, w, ph in h_weights:
            if k * f_v < 6000.0:
                warm += w * np.sin(k * phase + ph)
        warm *= env
        v_pan = pan if solo else max(-0.85, min(0.85, pan + (idx_v - 1) * 0.26))
        out += _pan_stereo(warm * gain, v_pan)

    scale = 0.22 if solo else 0.18
    return out * (scale * vel)


def synth_french_horn(freq: float, dur: float, vel: float = 0.65, pan: float = -0.15) -> np.ndarray:
    """Noble muted orchestral French horn with warm filter-bloom envelope."""
    tail_s = 0.45
    total_dur = dur + tail_s
    n = int(total_dur * SR)
    t = np.arange(n, dtype=np.float64) / SR

    vib = 0.003 * np.clip((t - 0.35) / 0.4, 0.0, 1.0) * np.sin(TAU * 4.4 * t)
    phase = TAU * np.cumsum(freq * (1.0 + vib)) / SR

    bloom = np.sin(np.clip(t / max(0.15, dur), 0.0, 1.0) * math.pi)
    lp = lambda k: 1.0 / (1.0 + (k * freq / 1250.0) ** 3.0)
    sig = (
        1.0 * lp(1) * np.sin(phase)
        + 0.55 * lp(2) * np.sin(2.0 * phase)
        + 0.24 * lp(3) * np.sin(3.0 * phase)
        + bloom * (0.20 * lp(3) * np.sin(3.0 * phase) + 0.14 * lp(4) * np.sin(4.0 * phase) + 0.07 * lp(5) * np.sin(5.0 * phase))
    )

    att = np.sin(np.clip(t / 0.14, 0.0, 1.0) * (math.pi * 0.5))
    rel = np.ones(n, dtype=np.float64)
    off_idx = int(dur * SR)
    if off_idx < n:
        rel[off_idx:] = np.exp(-(t[off_idx:] - dur) / 0.18)
    fade_n = min(n, int(0.05 * SR))
    rel[-fade_n:] *= np.linspace(1.0, 0.0, fade_n)

    return _pan_stereo(sig * att * rel * (0.18 * vel), pan)


def synth_ceremonial_drum(freq: float = 65.0, dur: float = 0.9, vel: float = 0.70, pan: float = 0.0, rng=None) -> np.ndarray:
    """Deep ceremonial frame drum / soft timpani heartbeat with warm felt beater thud."""
    n = int(dur * SR)
    t = np.arange(n, dtype=np.float64) / SR
    if rng is None:
        rng = np.random.default_rng(77)

    pitch_sweep = freq * (1.0 + 0.45 * np.exp(-t / 0.045))
    phase = TAU * np.cumsum(pitch_sweep) / SR
    membrane = np.sin(phase) * np.exp(-t / 0.34) + 0.25 * np.sin(1.58 * phase) * np.exp(-t / 0.12)
    beater = _fft_lowpass(rng.standard_normal(n), 320.0) * np.exp(-t / 0.025) * 0.35
    sig = (membrane + beater) * (1.0 - np.exp(-t / 0.004))
    fade_n = min(n, int(0.05 * SR))
    sig[-fade_n:] *= np.linspace(1.0, 0.0, fade_n)
    return _pan_stereo(sig * (0.28 * vel), pan)


def synth_cathedral_bell(freq: float = 146.83, dur: float = 4.5, vel: float = 0.65, pan: float = 0.0) -> np.ndarray:
    """Warm resonant bronze bell with authentic hum, prime, minor-third tierce, quint & nominal."""
    n = int(dur * SR)
    t = np.arange(n, dtype=np.float64) / SR

    modes = [
        (0.50, 0.48, dur * 0.90),
        (1.00, 0.85, dur * 0.75),
        (1.189, 0.42, dur * 0.50),
        (1.498, 0.30, dur * 0.45),
        (2.00, 0.38, dur * 0.35),
        (2.51, 0.10, dur * 0.20),
    ]
    left = np.zeros(n, dtype=np.float64)
    right = np.zeros(n, dtype=np.float64)
    for ratio, amp, decay in modes:
        f_m = freq * ratio
        if f_m > 3400.0:
            continue
        rolloff = 1.0 / (1.0 + (f_m / 2400.0) ** 3.0)
        env = np.exp(-t / max(0.25, decay)) * (1.0 - np.exp(-t / 0.012)) * rolloff
        left += amp * env * np.sin(TAU * f_m * t)
        right += amp * env * np.sin(TAU * (f_m + 0.28 * ratio) * t + 0.25)

    bell = np.column_stack((left, right))
    fade_n = min(n, int(0.25 * SR))
    bell[-fade_n:] *= np.linspace(1.0, 0.0, fade_n)[:, None]
    # Apply requested pan blend softly
    w_l = 0.5 * (1.0 - pan * 0.5)
    w_r = 0.5 * (1.0 + pan * 0.5)
    return np.column_stack((bell[:, 0] * w_l + bell[:, 1] * (0.25 * w_l), bell[:, 1] * w_r + bell[:, 0] * (0.25 * w_r))) * (0.24 * vel)


# ---------------------------------------------------------------------------
# Musical Sequencer & Loop-Wrapping Renderer
# ---------------------------------------------------------------------------

def render_score(
    bars: int,
    beats_per_bar: int,
    bpm: float,
    events: list,
    ir: np.ndarray,
    wet_mix: float = 0.24,
    target_lufs_db: float = -18.5,
    seed: int = 42,
) -> np.ndarray:
    """
    Renders a list of musical events onto an exact seamlessly looping stereo track.
    events: list of tuples (bar_beat_float, instrument_str, midi_note, dur_beats, vel, pan)
    Tails extending past track end cleanly wrap around to bar 1 for zero-click loops.
    """
    rng = np.random.default_rng(seed)
    sec_per_beat = 60.0 / bpm
    total_beats = bars * beats_per_bar
    total_dur = total_beats * sec_per_beat
    n = int(round(total_dur * SR))
    dry = np.zeros((n, 2), dtype=np.float64)

    for ev in events:
        beat_pos, inst, midi, dur_beats, vel, pan = ev
        # Subtle human micro-timing (+-7ms) unless downbeat pulse drum
        jitter_s = 0.0 if inst == "drum" else float(rng.uniform(-0.007, 0.007))
        start_s = max(0.0, beat_pos * sec_per_beat + jitter_s)
        start_idx = int(round(start_s * SR)) % n
        freq = midi_to_hz(midi)
        dur_s = max(0.08, dur_beats * sec_per_beat)

        if inst == "piano":
            clip = synth_felt_piano(freq, dur_s, vel, rng=rng)
        elif inst == "harp":
            clip = synth_harp(freq, dur_s, vel, pan=pan)
        elif inst == "celesta":
            clip = synth_celesta(freq, dur_s, vel, pan=pan)
        elif inst == "flute":
            clip = synth_flute(freq, dur_s, vel, pan=pan, rng=rng)
        elif inst == "cello":
            clip = synth_strings(freq, dur_s, vel, pan=pan, solo=True, attack_s=0.14, rng=rng)
        elif inst == "strings":
            clip = synth_strings(freq, dur_s, vel, pan=pan, solo=False, attack_s=0.28, rng=rng)
        elif inst == "horn":
            clip = synth_french_horn(freq, dur_s, vel, pan=pan)
        elif inst == "drum":
            clip = synth_ceremonial_drum(freq, dur_s, vel, pan=pan, rng=rng)
        elif inst == "bell":
            clip = synth_cathedral_bell(freq, dur_s, vel, pan=pan)
        else:
            continue

        clen = clip.shape[0]
        # Circular wrap-add onto track buffer so every note's tail decays across the loop point
        if start_idx + clen <= n:
            dry[start_idx:start_idx + clen] += clip
        else:
            first = n - start_idx
            dry[start_idx:] += clip[:first]
            rem = clen - first
            wrap_len = min(rem, n)
            dry[:wrap_len] += clip[first:first + wrap_len]

    # Gentle high-frequency air smoothing + warm concert hall convolution (naturally circular)
    dry = _fft_lowpass(dry, 6800.0, slope=1.5)
    mix = apply_circular_reverb(dry, ir, wet_mix=wet_mix)

    # RMS / loudness normalization with strict true-peak safety ceiling (-2.0 dBTP = 0.794)
    rms = math.sqrt(float(np.mean(mix ** 2)) + 1e-12)
    rms_db = 20.0 * math.log10(rms)
    gain_db = target_lufs_db - rms_db
    gain = 10.0 ** (gain_db / 20.0)
    mix *= gain

    # Soft-clip limiter safety well below 0 dBFS (-2.0 dBTP ceiling)
    peak = float(np.max(np.abs(mix)))
    ceiling = 0.78
    if peak > ceiling:
        mix = np.tanh(mix / peak * 1.15) * ceiling / math.tanh(1.15)

    return mix


# ---------------------------------------------------------------------------
# Soundtrack Compositions (Cohesive Ashvale / Elena Leitmotif across 8 cues)
# Core Motif Degrees (relative to tonic): [0, +2, +3, +7, +5, +2, 0] (Minor/Dorian)
# Hopeful Major Transformation: [0, +2, +4, +7, +5, +2, 0]
# ---------------------------------------------------------------------------

def _add_arpeggio(events, bar, beats, chord_midis, inst, vel_base, pan, dur_beats=1.8):
    for i, b in enumerate(beats):
        m = chord_midis[i % len(chord_midis)]
        v = vel_base * (1.0 if i == 0 else (0.82 if i % 2 == 1 else 0.90))
        events.append((bar * 4.0 + b, inst, m, dur_beats, v, pan))


def _add_pad_chord(events, bar, chord_midis, inst, dur_beats, vel, pan=0.0):
    for j, m in enumerate(chord_midis):
        p = pan + (j - 1) * 0.14
        events.append((bar * 4.0, inst, m, dur_beats, vel * (0.95 if j == 0 else 0.78), p))


def compose_bellhaven() -> np.ndarray:
    """
    BELLHAVEN (72s @ 80 BPM = 24 bars in 4/4, D Minor -> F Major):
    Warm felt piano, gentle strings, soft woodwind flute echoes.
    Peaceful, nostalgic, slightly mysterious village dusk.
    """
    bpm = 80.0
    bars = 24
    events = []
    # 4-bar chord progressions: Dm9 -> Bbmaj7 -> Fmaj7 -> Asus4/A -> Dm9 -> Gm7 -> Bbmaj7 -> C6/A
    chords = [
        # A section (bars 0..7): Intro & Gentle Bellhaven Motif
        [50, 57, 62, 65], [46, 53, 58, 62], [41, 48, 57, 60], [45, 52, 57, 62],
        [50, 57, 62, 65], [43, 50, 55, 62], [46, 53, 58, 62], [45, 52, 57, 60],
        # B section (bars 8..15): Emotional Lift (F Major warmth + Elena motif)
        [41, 48, 57, 64], [48, 55, 60, 64], [50, 57, 62, 65], [46, 53, 58, 62],
        [43, 50, 58, 62], [45, 52, 57, 60], [46, 53, 58, 64], [45, 52, 57, 60],
        # C section (bars 16..23): Quiet reflection & homeward cadence (space to breathe)
        [50, 57, 62, 65], [46, 53, 58, 62], [43, 50, 55, 58], [45, 52, 57, 60],
        [50, 57, 60, 65], [46, 53, 58, 62], [45, 52, 57, 60], [50, 57, 62, 65],
    ]

    for b in range(bars):
        ch = chords[b]
        # Felt piano broken arpeggio (gentle rocking pattern, skipping bar 16 for breathing pause)
        if b != 16:
            arp_beats = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5]
            arp_notes = [ch[0], ch[1], ch[2], ch[3], ch[2], ch[1], ch[3], ch[2]]
            for pos, m in zip(arp_beats, arp_notes):
                events.append((b * 4.0 + pos, "piano", m, 1.15, 0.52 if pos in (0.0, 2.0) else 0.39, -0.15))
        else:
            events.append((b * 4.0, "piano", ch[0], 3.8, 0.58, -0.15))
            events.append((b * 4.0 + 1.0, "piano", ch[2], 2.8, 0.46, 0.05))

        # Warm strings enter gently every 2 bars from bar 4
        if b >= 4 and b % 2 == 0 and b != 16:
            vel_str = 0.42 if b < 8 else (0.56 if b < 16 else 0.36)
            _add_pad_chord(events, b, [ch[0], ch[1] + 12, ch[2]], "strings", 7.4, vel_str, 0.0)

    # Melodic phrases: The Bellhaven / Elena Leitmotif on Piano (A), Flute+Piano (B), Cello+Piano (C)
    mel_a = [
        # Bars 2-3 (motif answer)
        (2, 0.0, 74, 1.0, 0.72), (2, 1.0, 76, 1.0, 0.74), (2, 2.0, 77, 1.5, 0.78), (2, 3.5, 81, 0.5, 0.72),
        (3, 0.0, 79, 1.5, 0.76), (3, 1.5, 76, 1.0, 0.68), (3, 2.5, 74, 1.5, 0.64),
        # Bars 4-7 (full statement + sighing answer)
        (4, 0.0, 74, 1.0, 0.74), (4, 1.0, 76, 1.0, 0.76), (4, 2.0, 77, 1.5, 0.80), (4, 3.5, 81, 0.5, 0.76),
        (5, 0.0, 79, 1.5, 0.78), (5, 1.5, 77, 1.0, 0.72), (5, 2.5, 74, 1.5, 0.66),
        (6, 0.0, 70, 1.5, 0.70), (6, 1.5, 72, 1.0, 0.72), (6, 2.5, 74, 1.5, 0.75),
        (7, 0.0, 72, 2.5, 0.65),
    ]
    for bar_i, beat_i, m, d, v in mel_a:
        events.append((bar_i * 4.0 + beat_i, "piano", m, d, v, 0.12))

    # B section: warm flute leads over string bloom
    mel_b = [
        (8, 0.0, 77, 1.5, 0.68), (8, 1.5, 79, 1.0, 0.72), (8, 2.5, 81, 1.5, 0.76),
        (9, 0.0, 84, 1.5, 0.78), (9, 1.5, 81, 1.0, 0.72), (9, 2.5, 79, 1.5, 0.66),
        (10, 0.0, 81, 1.0, 0.74), (10, 1.0, 77, 1.5, 0.70), (10, 2.5, 74, 1.5, 0.66),
        (11, 0.0, 77, 2.0, 0.68), (11, 2.0, 74, 1.5, 0.60),
        (12, 0.0, 79, 1.5, 0.72), (12, 1.5, 77, 1.0, 0.68), (12, 2.5, 76, 1.5, 0.66),
        (13, 0.0, 74, 2.0, 0.68), (13, 2.0, 72, 1.5, 0.62),
        (14, 0.0, 70, 1.5, 0.65), (14, 1.5, 74, 1.5, 0.68), (14, 3.0, 76, 1.0, 0.64),
        (15, 0.0, 72, 3.0, 0.60),
    ]
    for bar_i, beat_i, m, d, v in mel_b:
        events.append((bar_i * 4.0 + beat_i, "flute", m, d, v, 0.14))
        if beat_i == 0.0:
            events.append((bar_i * 4.0, "cello", m - 24, 3.5, v * 0.68, -0.22))

    # C section: Solo cello + soft piano echo of motif -> peaceful resolution
    mel_c = [
        (17, 0.0, 62, 1.5, 0.64), (17, 1.5, 64, 1.0, 0.66), (17, 2.5, 65, 1.5, 0.70),
        (18, 0.0, 67, 2.0, 0.68), (18, 2.0, 65, 1.5, 0.62),
        (19, 0.0, 64, 2.5, 0.58),
        (20, 0.0, 74, 1.5, 0.62), (20, 1.5, 76, 1.0, 0.64), (20, 2.5, 77, 1.5, 0.66),
        (21, 0.0, 74, 2.0, 0.62), (21, 2.0, 70, 1.5, 0.56),
        (22, 0.0, 72, 2.5, 0.55),
        (23, 0.0, 74, 3.2, 0.52),
    ]
    for bar_i, beat_i, m, d, v in mel_c:
        inst = "cello" if bar_i < 20 else "piano"
        events.append((bar_i * 4.0 + beat_i, inst, m, d, v, -0.18 if inst == "cello" else 0.10))
    # Faint distant village chime on bar 0 & 16
    events.append((0.0, "celesta", 81, 2.5, 0.30, 0.35))
    events.append((64.0, "celesta", 86, 2.8, 0.28, 0.35))

    ir = build_hall_ir(2.4, bright_hz=2500.0, seed=11)
    return render_score(bars, 4, bpm, events, ir, wet_mix=0.26, target_lufs_db=-18.5, seed=101)


def compose_briarwood() -> np.ndarray:
    """
    BRIARWOOD (72s @ 80 BPM = 24 bars in 4/4, G Dorian / G Major):
    Delicate plucked harp, airy flutes, crystalline celesta, warm enchanting strings.
    """
    bpm = 80.0
    bars = 24
    events = []
    # Gm9 -> Ebmaj7 -> Cm9 -> Dsus4 -> Gm9 -> F6 -> Ebmaj7 -> D7sus4
    chords = [
        [43, 50, 55, 58, 62], [39, 46, 55, 58, 62], [48, 55, 58, 62, 67], [50, 57, 62, 65, 67],
        [43, 50, 55, 58, 62], [41, 48, 57, 60, 65], [39, 46, 55, 58, 62], [50, 57, 60, 67],
        # B section: dappled G Major light
        [43, 50, 59, 62, 66], [48, 55, 60, 64, 67], [45, 52, 59, 64, 67], [50, 57, 62, 66],
        [43, 50, 59, 62, 66], [47, 54, 59, 62, 66], [48, 55, 60, 64, 67], [50, 57, 62, 67],
        # C section: quiet misty glade
        [43, 50, 55, 62], [41, 48, 53, 60], [39, 46, 55, 58], [50, 57, 62, 65],
        [43, 50, 55, 62], [48, 55, 60, 67], [46, 53, 58, 62], [43, 50, 55, 62],
    ]

    for b in range(bars):
        ch = chords[b]
        # Flowing harp ripples
        pattern = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5]
        seq = [ch[0], ch[1], ch[2], ch[3], ch[-1], ch[3], ch[2], ch[1]]
        for idx, (pos, m) in enumerate(zip(pattern, seq)):
            if b in (16, 17) and idx >= 5:
                continue  # sparse breathing pause
            pan = -0.35 + (idx / 7.0) * 0.70
            vel = 0.56 if idx in (0, 4) else 0.42
            events.append((b * 4.0 + pos, "harp", m + 12 if idx >= 4 else m, 1.6, vel, pan))

        # Subtle celesta forest droplets on bars 0, 3, 6, 9, 13, 18, 22
        if b in (0, 3, 6, 9, 13, 18, 22):
            events.append((b * 4.0 + 2.0, "celesta", ch[-1] + 12, 1.2, 0.42, 0.32))
            events.append((b * 4.0 + 2.5, "celesta", ch[2] + 24, 1.2, 0.34, -0.28))

        if b >= 4 and b % 2 == 0:
            events.append((b * 4.0, "strings", ch[0], 7.2, 0.38 if b >= 16 else 0.46, -0.10))
            events.append((b * 4.0, "strings", ch[2] + 12, 7.2, 0.34 if b >= 16 else 0.42, 0.18))

    # Flute melody: Enchanted transformation of Ashvale motif in G
    flute_notes = [
        (2, 0.0, 79, 1.0, 0.68), (2, 1.0, 81, 1.0, 0.70), (2, 2.0, 82, 1.5, 0.74), (2, 3.5, 86, 0.5, 0.72),
        (3, 0.0, 84, 1.5, 0.72), (3, 1.5, 81, 1.0, 0.66), (3, 2.5, 79, 1.5, 0.60),
        (5, 0.0, 79, 1.0, 0.68), (5, 1.0, 81, 1.0, 0.72), (5, 2.0, 82, 1.5, 0.75), (5, 3.5, 84, 0.5, 0.70),
        (6, 0.0, 82, 1.5, 0.72), (6, 1.5, 79, 1.0, 0.66), (6, 2.5, 77, 1.5, 0.62),
        (8, 0.0, 79, 1.0, 0.72), (8, 1.0, 81, 1.0, 0.74), (8, 2.0, 83, 1.5, 0.78), (8, 3.5, 86, 0.5, 0.74),
        (9, 0.0, 84, 1.5, 0.74), (9, 1.5, 83, 1.0, 0.70), (9, 2.5, 79, 1.5, 0.66),
        (11, 0.0, 81, 1.5, 0.72), (11, 1.5, 79, 1.0, 0.68), (11, 2.5, 78, 1.5, 0.64),
        (12, 0.0, 79, 2.8, 0.66),
        (14, 0.0, 84, 1.5, 0.70), (14, 1.5, 83, 1.0, 0.68), (14, 2.5, 81, 1.5, 0.65),
        (15, 0.0, 79, 3.0, 0.58),
        (19, 0.0, 74, 1.5, 0.60), (19, 1.5, 77, 1.5, 0.64), (19, 3.0, 79, 1.0, 0.62),
        (20, 0.0, 79, 2.5, 0.58),
        (22, 0.0, 77, 1.5, 0.56), (22, 1.5, 74, 2.5, 0.52),
    ]
    for bar_i, beat_i, m, d, v in flute_notes:
        events.append((bar_i * 4.0 + beat_i, "flute", m, d, v, 0.06))

    ir = build_hall_ir(2.6, bright_hz=2800.0, seed=22)
    return render_score(bars, 4, bpm, events, ir, wet_mix=0.28, target_lufs_db=-19.0, seed=202)


def compose_floodmill() -> np.ndarray:
    """
    FLOODMILL (72s @ 66 BPM = 20 bars in 4/4, C Minor / Ab Major):
    Melancholic piano, expressive solo cello, restrained strings. Tragedy beneath still waters.
    """
    bpm = 66.7
    bars = 20
    events = []
    # Cm -> Abmaj7 -> Fm9 -> Gsus4 -> Cm -> Eb/G -> Abmaj7 -> G7sus4
    chords = [
        [36, 43, 48, 51, 55], [44, 51, 56, 60, 63], [41, 48, 53, 56, 63], [43, 50, 55, 60],
        [36, 43, 48, 51, 55], [43, 51, 55, 58, 63], [44, 51, 56, 60, 63], [43, 50, 53, 59],
        # B section: Floodmill lament
        [41, 48, 53, 56, 60], [44, 51, 56, 60, 63], [39, 46, 51, 55, 58], [43, 50, 55, 59],
        [44, 51, 56, 60, 63], [41, 48, 53, 56, 60], [38, 45, 50, 53, 57], [43, 50, 55, 59],
        # C section: Tender solitude
        [36, 43, 48, 51, 55], [44, 51, 56, 60], [43, 50, 53, 59], [36, 43, 48, 55],
    ]

    for b in range(bars):
        ch = chords[b]
        # Sparse, deliberate water-drop piano pulse
        events.append((b * 4.0 + 0.0, "piano", ch[0] + 12, 2.5, 0.55, -0.18))
        events.append((b * 4.0 + 1.0, "piano", ch[2] + 12, 1.8, 0.42, -0.05))
        events.append((b * 4.0 + 2.0, "piano", ch[3] + 12, 2.0, 0.46, 0.08))
        if b % 2 == 1:
            events.append((b * 4.0 + 3.0, "piano", ch[1] + 12, 1.5, 0.36, -0.10))

        if b >= 2:
            _add_pad_chord(events, b, [ch[0], ch[1] + 12, ch[2]], "strings", 3.8, 0.36 if b < 8 else 0.44, 0.05)

    # Cello sings the tragic inversion of Elena's motif
    cello_mel = [
        (1, 0.0, 60, 1.5, 0.72), (1, 1.5, 62, 1.0, 0.74), (1, 2.5, 63, 1.5, 0.78),
        (2, 0.0, 67, 2.0, 0.80), (2, 2.0, 65, 1.5, 0.72),
        (3, 0.0, 62, 2.0, 0.68), (3, 2.0, 60, 1.5, 0.62),
        (5, 0.0, 60, 1.5, 0.70), (5, 1.5, 58, 1.0, 0.68), (5, 2.5, 56, 1.5, 0.66),
        (6, 0.0, 55, 2.5, 0.64),
        (8, 0.0, 65, 1.5, 0.78), (8, 1.5, 67, 1.0, 0.80), (8, 2.5, 68, 1.5, 0.84),
        (9, 0.0, 67, 2.0, 0.78), (9, 2.0, 63, 1.5, 0.72),
        (10, 0.0, 62, 2.0, 0.70), (10, 2.0, 60, 1.5, 0.66),
        (11, 0.0, 59, 3.0, 0.62),
        (12, 0.0, 63, 1.5, 0.74), (12, 1.5, 65, 1.0, 0.72), (12, 2.5, 67, 1.5, 0.76),
        (13, 0.0, 65, 2.0, 0.70), (13, 2.0, 62, 1.5, 0.64),
        (14, 0.0, 60, 3.2, 0.60),
    ]
    for bar_i, beat_i, m, d, v in cello_mel:
        events.append((bar_i * 4.0 + beat_i, "cello", m, d, v, -0.14))

    # Piano lonely high answer in C section
    piano_c = [
        (16, 0.0, 72, 1.5, 0.60), (16, 1.5, 74, 1.0, 0.62), (16, 2.5, 75, 1.5, 0.64),
        (17, 0.0, 72, 2.5, 0.56),
        (18, 0.0, 71, 2.5, 0.52),
        (19, 0.0, 72, 3.5, 0.48),
    ]
    for bar_i, beat_i, m, d, v in piano_c:
        events.append((bar_i * 4.0 + beat_i, "piano", m, d, v, 0.16))

    ir = build_hall_ir(2.8, bright_hz=2200.0, seed=33)
    return render_score(bars, 4, bpm, events, ir, wet_mix=0.29, target_lufs_db=-19.5, seed=303)


def compose_ironwatch() -> np.ndarray:
    """
    IRONWATCH (72s @ 72 BPM = 22 bars in 4/4, C# Minor):
    Deep strings, ancient ceremonial percussion (with wide rests), noble French horn.
    Serious, mysterious, imposing without a constant droning noise.
    """
    bpm = 73.3
    bars = 22
    events = []
    # C#m -> A -> F#m -> G#sus4 -> C#m -> B -> A -> G#
    chords = [
        [37, 44, 49, 52, 56], [33, 40, 45, 49, 52], [42, 49, 54, 57, 61], [44, 51, 56, 61],
        [37, 44, 49, 52, 56], [35, 42, 47, 51, 54], [33, 40, 45, 49, 52], [44, 51, 56, 60],
        # B section: Keep of Secret Records
        [42, 49, 54, 57, 61], [37, 44, 49, 52, 56], [35, 42, 47, 51, 54], [44, 51, 56, 60],
        [33, 40, 45, 49, 52], [35, 42, 47, 51, 54], [37, 44, 49, 52, 56], [44, 51, 56, 60],
        # C section: Stealth vigilance (lots of silence and low pizz-like piano/drum)
        [37, 44, 49, 56], [33, 40, 45, 52], [42, 49, 54, 57], [44, 51, 56, 60],
        [33, 40, 45, 52], [37, 44, 49, 56],
    ]

    for b in range(bars):
        ch = chords[b]
        # Ceremonial slow drum heartbeat only on select bars so it feels measured & tense
        if b % 2 == 0 and b < 16:
            events.append((b * 4.0 + 0.0, "drum", 37, 1.0, 0.72, -0.05))
            events.append((b * 4.0 + 2.5, "drum", 37, 0.8, 0.45, 0.05))
        elif b >= 16 and b % 2 == 0:
            events.append((b * 4.0 + 0.0, "drum", 37, 0.9, 0.50, 0.0))

        # Low measured cello/strings (not constantly sustained at full volume; pauses every 4th bar)
        if b % 4 != 3:
            _add_pad_chord(events, b, [ch[0], ch[1] + 12, ch[2]], "strings", 3.6, 0.44 if b < 16 else 0.30, 0.0)
        # Subtle solemn harp/piano fifth toll
        events.append((b * 4.0, "piano", ch[1] + 12, 2.2, 0.44, -0.22))
        events.append((b * 4.0 + 2.0, "piano", ch[2] + 12, 1.6, 0.36, 0.22))

    # French Horn & Cello carry the Warden's serious motif
    horn_mel = [
        (2, 0.0, 61, 1.5, 0.68), (2, 1.5, 63, 1.0, 0.70), (2, 2.5, 64, 1.5, 0.74),
        (3, 0.0, 68, 2.2, 0.76), (3, 2.2, 66, 1.4, 0.66),
        (6, 0.0, 64, 1.5, 0.68), (6, 1.5, 63, 1.0, 0.66), (6, 2.5, 61, 1.5, 0.64),
        (7, 0.0, 60, 2.8, 0.60),
        (8, 0.0, 66, 1.5, 0.72), (8, 1.5, 68, 1.0, 0.74), (8, 2.5, 69, 1.5, 0.78),
        (9, 0.0, 68, 2.0, 0.74), (9, 2.0, 64, 1.5, 0.68),
        (10, 0.0, 63, 1.5, 0.68), (10, 1.5, 61, 1.5, 0.66), (10, 3.0, 59, 1.0, 0.62),
        (11, 0.0, 60, 3.0, 0.58),
        (12, 0.0, 64, 1.5, 0.70), (12, 1.5, 66, 1.0, 0.72), (12, 2.5, 68, 1.5, 0.75),
        (13, 0.0, 66, 2.0, 0.70), (13, 2.0, 63, 1.5, 0.64),
        (14, 0.0, 61, 3.2, 0.64),
    ]
    for bar_i, beat_i, m, d, v in horn_mel:
        events.append((bar_i * 4.0 + beat_i, "horn", m, d, v, -0.12))

    # Cello reflection in C section
    events.append((17 * 4.0, "cello", 61, 2.0, 0.62, 0.14))
    events.append((17 * 4.0 + 2.0, "cello", 64, 1.8, 0.64, 0.14))
    events.append((18 * 4.0, "cello", 63, 2.8, 0.58, 0.14))
    events.append((20 * 4.0, "cello", 56, 3.2, 0.54, 0.14))

    ir = build_hall_ir(2.9, bright_hz=2000.0, seed=44)
    return render_score(bars, 4, bpm, events, ir, wet_mix=0.28, target_lufs_db=-19.0, seed=404)


def compose_dawnspire() -> np.ndarray:
    """
    DAWNSPIRE (78s @ 92 BPM = 30 bars in 4/4, Eb Major / Eb Lydian):
    Sweeping harp currents, soaring airy flutes, uplifting string harmonies.
    Rising above the storm clouds into celestial mountain air.
    """
    bpm = 92.3
    bars = 30
    events = []
    # Eb -> Bb/D -> Cm7 -> Abmaj7 -> Eb -> Fm7 -> Abmaj7 -> Bbsus4
    base_prog = [
        [39, 46, 51, 55, 58], [38, 46, 53, 58, 62], [48, 55, 60, 63, 67], [44, 51, 56, 60, 63],
        [39, 46, 51, 55, 58], [41, 48, 53, 56, 60], [44, 51, 56, 60, 67], [46, 53, 58, 63, 65],
    ]
    chords = []
    for b in range(bars):
        if b < 16:
            chords.append(base_prog[b % 8])
        elif b < 24:
            # Observatory ascent lift: Abmaj7 -> Bb -> Cm7 -> Eb/G
            lift = [
                [44, 51, 56, 60, 67], [46, 53, 58, 62, 65], [48, 55, 60, 63, 67], [43, 51, 55, 58, 63],
                [41, 48, 53, 56, 60], [44, 51, 56, 60, 63], [46, 53, 58, 62, 65], [46, 53, 58, 63, 65],
            ]
            chords.append(lift[b - 16])
        else:
            # Calm high mountain wind plateau before loop
            out_p = [
                [39, 46, 51, 55, 58], [44, 51, 56, 60, 63], [48, 55, 60, 63, 67],
                [44, 51, 56, 60, 63], [46, 53, 58, 62, 65], [39, 46, 51, 55, 58],
            ]
            chords.append(out_p[b - 24])

    for b in range(bars):
        ch = chords[b]
        # Sweeping harp ripples
        for idx, pos in enumerate([0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5]):
            if b >= 24 and idx >= 6:
                continue
            m = ch[idx % len(ch)] + (12 if idx >= 4 else 0)
            events.append((b * 4.0 + pos, "harp", m, 1.8, 0.55 if idx in (0, 4) else 0.42, -0.3 + idx * 0.08))

        if b >= 2 and b % 2 == 0:
            vel_s = 0.48 if b < 16 else (0.62 if b < 24 else 0.40)
            _add_pad_chord(events, b, [ch[0], ch[1] + 12, ch[2]], "strings", 7.4, vel_s, 0.0)
        if b in (0, 8, 16, 20, 24):
            events.append((b * 4.0 + 0.5, "celesta", ch[-1] + 12, 1.6, 0.42, 0.35))
            events.append((b * 4.0 + 1.5, "celesta", ch[2] + 24, 1.6, 0.36, -0.30))

    # Uplifting soaring melody (major transformation of Ashvale motif!)
    mel = [
        (2, 0.0, 75, 1.0, 0.72), (2, 1.0, 77, 1.0, 0.75), (2, 2.0, 79, 1.5, 0.80), (2, 3.5, 82, 0.5, 0.78),
        (3, 0.0, 80, 1.5, 0.76), (3, 1.5, 77, 1.0, 0.70), (3, 2.5, 75, 1.5, 0.66),
        (4, 0.0, 75, 1.0, 0.74), (4, 1.0, 77, 1.0, 0.76), (4, 2.0, 79, 1.5, 0.80), (4, 3.5, 84, 0.5, 0.78),
        (5, 0.0, 82, 1.5, 0.78), (5, 1.5, 79, 1.0, 0.72), (5, 2.5, 77, 1.5, 0.68),
        (6, 0.0, 79, 1.5, 0.74), (6, 1.5, 80, 1.0, 0.76), (6, 2.5, 82, 1.5, 0.78),
        (7, 0.0, 77, 3.0, 0.68),
        # Second ascent
        (10, 0.0, 75, 1.0, 0.74), (10, 1.0, 79, 1.0, 0.76), (10, 2.0, 82, 1.5, 0.80), (10, 3.5, 87, 0.5, 0.78),
        (11, 0.0, 84, 1.5, 0.78), (11, 1.5, 82, 1.0, 0.74), (11, 2.5, 79, 1.5, 0.70),
        (13, 0.0, 80, 1.5, 0.74), (13, 1.5, 79, 1.0, 0.70), (13, 2.5, 75, 1.5, 0.66),
        (15, 0.0, 77, 3.2, 0.64),
        # Observatory Peak (Horn + Flute octave harmony)
        (16, 0.0, 79, 1.5, 0.80), (16, 1.5, 80, 1.0, 0.82), (16, 2.5, 82, 1.5, 0.85),
        (17, 0.0, 86, 1.5, 0.84), (17, 1.5, 84, 1.0, 0.80), (17, 2.5, 82, 1.5, 0.76),
        (18, 0.0, 84, 1.5, 0.82), (18, 1.5, 82, 1.0, 0.78), (18, 2.5, 79, 1.5, 0.74),
        (19, 0.0, 82, 2.5, 0.72),
        (20, 0.0, 80, 1.5, 0.76), (20, 1.5, 79, 1.0, 0.74), (20, 2.5, 77, 1.5, 0.72),
        (21, 0.0, 75, 2.0, 0.74), (21, 2.0, 77, 1.5, 0.70),
        (22, 0.0, 79, 2.0, 0.72), (22, 2.0, 82, 1.8, 0.70),
        (23, 0.0, 82, 3.0, 0.64),
        # Calm horizon breathing room
        (26, 0.0, 75, 1.5, 0.62), (26, 1.5, 77, 1.0, 0.64), (26, 2.5, 79, 1.5, 0.66),
        (27, 0.0, 75, 3.0, 0.58),
    ]
    for bar_i, beat_i, m, d, v in mel:
        events.append((bar_i * 4.0 + beat_i, "flute", m, d, v, 0.10))
        if 16 <= bar_i < 24:
            events.append((bar_i * 4.0 + beat_i, "horn", m - 12, d, v * 0.72, -0.18))

    ir = build_hall_ir(2.6, bright_hz=3000.0, seed=55)
    return render_score(bars, 4, bpm, events, ir, wet_mix=0.27, target_lufs_db=-18.5, seed=505)


def compose_great_bell() -> np.ndarray:
    """
    GREAT BELL SANCTUM (80s @ 84 BPM = 28 bars in 4/4, D Minor -> Bb Major -> D Minor):
    Sacred cathedral solemnity. Distant bronze bell toll, noble strings, piano, French horn.
    """
    bpm = 84.0
    bars = 28
    events = []
    # Dm -> F/C -> Bbmaj7 -> A7sus4 -> Gm7 -> Dm/F -> Ebmaj7 -> A
    chords = [
        [38, 45, 50, 53, 57], [48, 53, 57, 60, 65], [46, 53, 58, 62, 65], [45, 52, 57, 62],
        [43, 50, 55, 58, 62], [41, 48, 53, 57, 62], [39, 46, 51, 55, 58], [45, 52, 57, 61],
    ]

    for b in range(bars):
        ch = chords[b % 8]
        # Soft cathedral bronze bell chime every 8 bars (sacred punctuation, never jarring)
        if b in (0, 8, 16, 24):
            events.append((b * 4.0, "bell", ch[0] + 12, 6.0, 0.50, 0.0))

        # Noble piano / harp arpeggio
        for idx, pos in enumerate([0.0, 1.0, 2.0, 3.0]):
            m = ch[idx % len(ch)] + (12 if idx >= 2 else 0)
            events.append((b * 4.0 + pos, "piano", m, 2.2, 0.56 if idx == 0 else 0.42, -0.20 + idx * 0.12))

        if b % 2 == 0:
            _add_pad_chord(events, b, [ch[0], ch[1] + 12, ch[2]], "strings", 7.4, 0.54 if b >= 8 else 0.42, 0.0)
        if b >= 8 and b % 4 == 0:
            events.append((b * 4.0, "drum", 38, 1.1, 0.58, 0.0))

    # Grand Sanctum Theme (Thirteenth Bell development)
    mel = [
        (2, 0.0, 74, 1.5, 0.72), (2, 1.5, 76, 1.0, 0.74), (2, 2.5, 77, 1.5, 0.78),
        (3, 0.0, 81, 2.0, 0.80), (3, 2.0, 79, 1.5, 0.74),
        (4, 0.0, 77, 1.5, 0.76), (4, 1.5, 76, 1.0, 0.72), (4, 2.5, 74, 1.5, 0.68),
        (5, 0.0, 72, 2.0, 0.66), (5, 2.0, 74, 1.5, 0.64),
        (6, 0.0, 75, 1.5, 0.72), (6, 1.5, 74, 1.0, 0.68), (6, 2.5, 70, 1.5, 0.64),
        (7, 0.0, 69, 3.0, 0.62),
        # Cathedral Chorus with Horn + Cello
        (9, 0.0, 62, 1.5, 0.78), (9, 1.5, 64, 1.0, 0.80), (9, 2.5, 65, 1.5, 0.84),
        (10, 0.0, 69, 1.5, 0.86), (10, 1.5, 67, 1.0, 0.82), (10, 2.5, 65, 1.5, 0.78),
        (11, 0.0, 64, 2.5, 0.74),
        (12, 0.0, 67, 1.5, 0.80), (12, 1.5, 69, 1.0, 0.82), (12, 2.5, 70, 1.5, 0.85),
        (13, 0.0, 69, 1.5, 0.80), (13, 1.5, 65, 1.0, 0.76), (13, 2.5, 62, 1.5, 0.72),
        (14, 0.0, 63, 1.5, 0.76), (14, 1.5, 65, 1.5, 0.74), (14, 3.0, 67, 1.0, 0.72),
        (15, 0.0, 69, 3.2, 0.72),
        # High flute & celesta over strings
        (18, 0.0, 74, 1.5, 0.72), (18, 1.5, 77, 1.0, 0.76), (18, 2.5, 81, 1.5, 0.80),
        (19, 0.0, 79, 2.0, 0.76), (19, 2.0, 77, 1.5, 0.70),
        (20, 0.0, 75, 1.5, 0.72), (20, 1.5, 74, 1.0, 0.68), (20, 2.5, 70, 1.5, 0.64),
        (21, 0.0, 69, 3.0, 0.60),
        (24, 0.0, 74, 2.0, 0.64), (24, 2.0, 76, 1.5, 0.62),
        (25, 0.0, 77, 2.0, 0.60), (25, 2.0, 74, 1.8, 0.56),
    ]
    for bar_i, beat_i, m, d, v in mel:
        inst = "horn" if 9 <= bar_i <= 15 else ("flute" if bar_i >= 18 else "piano")
        events.append((bar_i * 4.0 + beat_i, inst, m, d, v, -0.10 if inst == "horn" else 0.10))

    ir = build_hall_ir(3.1, bright_hz=2500.0, seed=66)
    return render_score(bars, 4, bpm, events, ir, wet_mix=0.30, target_lufs_db=-18.5, seed=606)


def compose_great_bell_climax() -> np.ndarray:
    """
    GREAT BELL CLIMAX (64s @ 96 BPM = 24 bars in 4/4, D Minor -> Bb -> C -> D Major!):
    Layered heroic swell for beacon conduits, network stabilization, and severing the chains.
    Transitions triumphantly from D Minor urgency into radiant D Major resolution.
    """
    bpm = 90.0
    bars = 24
    events = []
    chords = [
        # Bars 0..11: Urgent ritual climb (Dm -> Bb -> C -> Dm -> Gm -> Bb -> C -> A)
        [38, 45, 50, 53, 57], [46, 53, 58, 62, 65], [48, 55, 60, 64, 67], [38, 45, 50, 57, 62],
        [43, 50, 55, 58, 62], [46, 53, 58, 62, 65], [48, 55, 60, 64, 67], [45, 52, 57, 61, 64],
        [38, 45, 50, 53, 57], [46, 53, 58, 62, 65], [48, 55, 60, 64, 67], [45, 52, 57, 61, 64],
        # Bars 12..23: Chains shattered — Radiant D Major triumph (D -> G -> Bm -> A -> D -> G -> A -> D)
        [38, 45, 50, 54, 57], [43, 50, 55, 59, 62], [47, 54, 59, 62, 66], [45, 52, 57, 61, 64],
        [38, 45, 50, 54, 57], [43, 50, 55, 59, 62], [45, 52, 57, 61, 64], [38, 45, 50, 54, 57],
        [43, 50, 55, 59, 62], [45, 52, 57, 61, 64], [38, 45, 50, 54, 57], [38, 45, 50, 54, 57],
    ]

    for b in range(bars):
        ch = chords[b]
        # Ceremonial timpani/drum pulse building to Bar 12 liberation
        if b < 16:
            events.append((b * 4.0 + 0.0, "drum", 38, 0.9, 0.72, 0.0))
            events.append((b * 4.0 + 2.0, "drum", 43, 0.7, 0.56, 0.0))
            if b >= 8:
                events.append((b * 4.0 + 3.0, "drum", 38, 0.5, 0.48, 0.0))

        # Cathedral bell crown chimes on key structural milestones
        if b in (0, 8, 12, 16, 20):
            events.append((b * 4.0, "bell", 50 if b >= 12 else 38, 5.5, 0.62, 0.0))

        # Sweeping harp + strings + horn choir
        for idx, pos in enumerate([0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5]):
            m = ch[idx % len(ch)] + (12 if idx >= 3 else 0)
            events.append((b * 4.0 + pos, "harp", m, 1.4, 0.58 if idx in (0, 4) else 0.45, -0.35 + idx * 0.1))

        _add_pad_chord(events, b, [ch[0], ch[1] + 12, ch[2], ch[3] + 12], "strings", 3.8, 0.68 if b >= 12 else 0.58, 0.0)

    # Climax Melody: urgent minor theme -> transcendent D major liberation!
    mel = [
        (0, 0.0, 74, 1.0, 0.78), (0, 1.0, 76, 1.0, 0.80), (0, 2.0, 77, 1.5, 0.84), (0, 3.5, 81, 0.5, 0.82),
        (1, 0.0, 79, 1.5, 0.82), (1, 1.5, 77, 1.0, 0.78), (1, 2.5, 74, 1.5, 0.74),
        (2, 0.0, 76, 1.5, 0.80), (2, 1.5, 79, 1.0, 0.82), (2, 2.5, 84, 1.5, 0.86),
        (3, 0.0, 81, 3.0, 0.82),
        (4, 0.0, 79, 1.5, 0.80), (4, 1.5, 77, 1.0, 0.78), (4, 2.5, 74, 1.5, 0.74),
        (5, 0.0, 77, 1.5, 0.78), (5, 1.5, 79, 1.0, 0.80), (5, 2.5, 82, 1.5, 0.84),
        (6, 0.0, 84, 2.0, 0.86), (6, 2.0, 81, 1.5, 0.80),
        (7, 0.0, 81, 3.2, 0.82),
        # Bars 12..19: Radiant D Major Liberation (Ashvale Motif in Major!)
        (12, 0.0, 74, 1.0, 0.86), (12, 1.0, 76, 1.0, 0.88), (12, 2.0, 78, 1.5, 0.92), (12, 3.5, 81, 0.5, 0.90),
        (13, 0.0, 79, 1.5, 0.88), (13, 1.5, 78, 1.0, 0.84), (13, 2.5, 74, 1.5, 0.80),
        (14, 0.0, 78, 1.5, 0.86), (14, 1.5, 81, 1.0, 0.88), (14, 2.5, 86, 1.5, 0.92),
        (15, 0.0, 85, 2.0, 0.88), (15, 2.0, 81, 1.5, 0.82),
        (16, 0.0, 86, 1.5, 0.90), (16, 1.5, 85, 1.0, 0.86), (16, 2.5, 81, 1.5, 0.82),
        (17, 0.0, 79, 1.5, 0.82), (17, 1.5, 78, 1.0, 0.78), (17, 2.5, 74, 1.5, 0.76),
        (18, 0.0, 76, 2.0, 0.78), (18, 2.0, 79, 1.5, 0.76),
        (19, 0.0, 78, 3.5, 0.76),
    ]
    for bar_i, beat_i, m, d, v in mel:
        events.append((bar_i * 4.0 + beat_i, "horn", m - 12, d, v * 0.92, -0.14))
        events.append((bar_i * 4.0 + beat_i, "flute", m, d, v * 0.84, 0.14))
    # Radiant piano chord on resolution
    events.append((20 * 4.0, "piano", 74, 3.5, 0.68, 0.0))
    events.append((21 * 4.0, "celesta", 86, 3.0, 0.45, 0.25))
    events.append((22 * 4.0, "piano", 74, 4.0, 0.58, 0.0))

    ir = build_hall_ir(3.0, bright_hz=2800.0, seed=77)
    return render_score(bars, 4, bpm, events, ir, wet_mix=0.30, target_lufs_db=-17.8, seed=707)


def compose_epilogue_dawn() -> np.ndarray:
    """
    ENDING / EPILOGUE SUNRISE (75s @ 70 BPM = 22 bars in 4/4, F Major / D Minor-to-Major):
    Intimate, deeply emotional reprise of Bellhaven's main melody on warm felt piano,
    singing solo cello, delicate harp, and luminous strings.
    """
    bpm = 70.4
    bars = 22
    events = []
    # Fmaj7 -> C/E -> Dm9 -> Bbmaj7 -> F/A -> Gm7 -> Csus4 -> Fmaj7
    chords = [
        [41, 48, 57, 60, 64], [40, 48, 55, 60, 64], [38, 45, 50, 57, 64], [46, 53, 58, 62, 65],
        [45, 53, 57, 60, 65], [43, 50, 55, 58, 62], [48, 55, 60, 65, 67], [41, 48, 57, 60, 64],
        # B section: Morning Memory (warm lift)
        [46, 53, 58, 62, 65], [48, 55, 60, 64, 67], [45, 52, 57, 60, 64], [38, 45, 50, 57, 62],
        [43, 50, 58, 62, 65], [48, 55, 60, 65, 67], [41, 48, 57, 60, 64], [41, 48, 57, 60, 65],
        # C section: Peaceful intimacy (solo piano + solo cello breath)
        [38, 45, 53, 57], [46, 53, 58, 62], [41, 48, 57, 60], [48, 55, 60, 64],
        [46, 53, 58, 62], [41, 48, 57, 64],
    ]

    for b in range(bars):
        ch = chords[b]
        # Warm felt piano arpeggios
        if b < 16:
            arp = [ch[0] + 12, ch[1] + 12, ch[2], ch[3], ch[4], ch[3]]
            beats = [0.0, 0.5, 1.0, 2.0, 2.5, 3.0]
            for pos, m in zip(beats, arp):
                events.append((b * 4.0 + pos, "piano", m, 1.6, 0.54 if pos == 0.0 else 0.40, -0.14))
        else:
            events.append((b * 4.0 + 0.0, "piano", ch[0] + 12, 3.2, 0.50, -0.14))
            events.append((b * 4.0 + 1.5, "piano", ch[2], 2.2, 0.42, 0.04))
            events.append((b * 4.0 + 2.5, "piano", ch[3], 1.8, 0.38, 0.12))

        if b in (0, 8, 15, 21):
            events.append((b * 4.0 + 1.0, "harp", ch[-1] + 12, 2.2, 0.45, 0.25))
            events.append((b * 4.0 + 2.0, "celesta", ch[2] + 24, 1.5, 0.30, 0.32))

        if 2 <= b < 16 and b % 2 == 0:
            _add_pad_chord(events, b, [ch[0], ch[1] + 12, ch[2]], "strings", 7.2, 0.46 if b < 8 else 0.56, 0.0)

    # Emotional reprise of Bellhaven's motif transformed into glowing F Major hope
    mel = [
        # Bars 1..7: Piano leads Bellhaven's theme warmly
        (1, 0.0, 77, 1.0, 0.72), (1, 1.0, 79, 1.0, 0.74), (1, 2.0, 81, 1.5, 0.78), (1, 3.5, 84, 0.5, 0.74),
        (2, 0.0, 81, 1.5, 0.76), (2, 1.5, 79, 1.0, 0.70), (2, 2.5, 77, 1.5, 0.66),
        (3, 0.0, 74, 1.5, 0.68), (3, 1.5, 77, 1.0, 0.70), (3, 2.5, 79, 1.5, 0.72),
        (4, 0.0, 81, 2.5, 0.72),
        (5, 0.0, 79, 1.5, 0.70), (5, 1.5, 77, 1.0, 0.68), (5, 2.5, 74, 1.5, 0.64),
        (6, 0.0, 72, 2.0, 0.64), (6, 2.0, 74, 1.5, 0.62),
        (7, 0.0, 77, 3.0, 0.62),
        # Bars 8..15: Singing cello & warm flute duet on Elena's memory motif
        (8, 0.0, 65, 1.5, 0.76), (8, 1.5, 67, 1.0, 0.78), (8, 2.5, 69, 1.5, 0.82),
        (9, 0.0, 72, 1.5, 0.84), (9, 1.5, 69, 1.0, 0.78), (9, 2.5, 67, 1.5, 0.72),
        (10, 0.0, 69, 1.5, 0.78), (10, 1.5, 65, 1.0, 0.74), (10, 2.5, 64, 1.5, 0.70),
        (11, 0.0, 62, 2.8, 0.68),
        (12, 0.0, 67, 1.5, 0.74), (12, 1.5, 69, 1.0, 0.76), (12, 2.5, 70, 1.5, 0.78),
        (13, 0.0, 69, 1.5, 0.74), (13, 1.5, 67, 1.0, 0.70), (13, 2.5, 64, 1.5, 0.66),
        (14, 0.0, 65, 3.5, 0.68),
        # Bars 16..20: Tender whisper on piano
        (16, 0.0, 77, 1.5, 0.64), (16, 1.5, 79, 1.0, 0.66), (16, 2.5, 81, 1.5, 0.68),
        (17, 0.0, 79, 2.0, 0.62), (17, 2.0, 77, 1.5, 0.58),
        (18, 0.0, 76, 2.5, 0.56),
        (19, 0.0, 77, 3.2, 0.54),
    ]
    for bar_i, beat_i, m, d, v in mel:
        if 8 <= bar_i <= 15:
            events.append((bar_i * 4.0 + beat_i, "cello", m, d, v, -0.14))
            events.append((bar_i * 4.0 + beat_i, "flute", m + 12, d, v * 0.62, 0.16))
        else:
            events.append((bar_i * 4.0 + beat_i, "piano", m, d, v, 0.10))

    ir = build_hall_ir(2.7, bright_hz=2600.0, seed=88)
    return render_score(bars, 4, bpm, events, ir, wet_mix=0.28, target_lufs_db=-18.5, seed=808)


# ---------------------------------------------------------------------------
# Natural Environmental Ambience (Warm, Filtered, Sparse, Seamless)
# ---------------------------------------------------------------------------

def _pink_noise(n: int, rng) -> np.ndarray:
    """Generates smooth Voss-like filtered pink noise (1/f) with zero harsh static."""
    white = rng.standard_normal(n)
    freqs = np.fft.rfftfreq(n, d=1.0 / SR)
    spec = np.fft.rfft(white)
    # 1/sqrt(f) pink shaping with gentle low-shelf control and hard high roll-off
    scale = 1.0 / np.maximum(1.0, np.sqrt(freqs / 40.0))
    scale[0] = 0.0
    out = np.fft.irfft(spec * scale, n=n)
    out /= max(1e-8, float(np.std(out)))
    return out


def _brown_breeze(n: int, lo_hz: float, hi_hz: float, cycle_s: float, rng) -> np.ndarray:
    """Gentle natural air/wind/water bed with ultra-slow organic swelling."""
    noise_l = _pink_noise(n, rng)
    noise_r = _pink_noise(n, rng)
    l = _fft_bandpass(noise_l, lo_hz, hi_hz)
    r = _fft_bandpass(noise_r, lo_hz, hi_hz)
    t = np.arange(n, dtype=np.float64) / SR
    # Multiple slow inharmonic-feeling periodic swells locked to track duration so zero click
    dur_s = float(n) / SR
    c1 = round(dur_s / max(4.0, cycle_s))
    c2 = max(1, c1 + 1)
    mod_l = 0.55 + 0.25 * np.sin(TAU * c1 * t / dur_s) + 0.15 * np.sin(TAU * c2 * t / dur_s + 1.1)
    mod_r = 0.55 + 0.25 * np.sin(TAU * c1 * t / dur_s + 0.7) + 0.15 * np.sin(TAU * c2 * t / dur_s + 2.0)
    return np.column_stack((l * mod_l, r * mod_r))


def _place_wrapped(buf: np.ndarray, start_s: float, clip: np.ndarray) -> None:
    n = buf.shape[0]
    idx = int(round(start_s * SR)) % n
    clen = clip.shape[0]
    if idx + clen <= n:
        buf[idx:idx + clen] += clip
    else:
        first = n - idx
        buf[idx:] += clip[:first]
        rem = min(clen - first, n)
        buf[:rem] += clip[first:first + rem]


def _bird_chirp(base_hz: float, dur_s: float, pan: float, rng) -> np.ndarray:
    """Gentle natural songbird phrase (sweet frequency sweep, never piercing)."""
    n = int(dur_s * SR)
    t = np.arange(n, dtype=np.float64) / SR
    # Smooth bell-shaped envelope and warm downward-upward trill
    env = np.sin(math.pi * t / dur_s) ** 1.6
    glide = base_hz * (1.0 + 0.16 * np.sin(math.pi * t / dur_s + rng.uniform(0, 1.5)))
    phase = TAU * np.cumsum(glide) / SR
    sig = _fft_lowpass((np.sin(phase) + 0.15 * np.sin(2.0 * phase)) * env, 2900.0)
    return _pan_stereo(sig * 0.12, pan)


def _water_droplet(freq_hz: float, pan: float) -> np.ndarray:
    """Soft buoyant water bubble/droplet for Floodmill stream."""
    dur_s = 0.085
    n = int(dur_s * SR)
    t = np.arange(n, dtype=np.float64) / SR
    f = freq_hz * np.exp(t * 9.5)
    phase = TAU * np.cumsum(f) / SR
    sig = np.sin(phase) * np.exp(-t / 0.022) * (1.0 - np.exp(-t / 0.004))
    return _pan_stereo(_fft_lowpass(sig, 2200.0) * 0.10, pan)


def _distant_creak_or_clink(kind: str, pan: float, rng) -> np.ndarray:
    if kind == "wood_creak":
        dur_s = 0.42
        n = int(dur_s * SR)
        t = np.arange(n, dtype=np.float64) / SR
        noise = _fft_bandpass(rng.standard_normal(n), 180.0, 520.0)
        tone = np.sin(TAU * (145.0 - 22.0 * t / dur_s) * t) * 0.5
        sig = (noise * 0.4 + tone * 0.3) * (np.sin(math.pi * t / dur_s) ** 1.4)
        return _pan_stereo(sig * 0.08, pan)
    else:  # distant stone tap / muted metallic echo
        dur_s = 0.35
        n = int(dur_s * SR)
        t = np.arange(n, dtype=np.float64) / SR
        hit = _fft_bandpass(rng.standard_normal(n), 280.0, 950.0) * np.exp(-t / 0.025)
        tail = np.sin(TAU * rng.uniform(310.0, 440.0) * t) * np.exp(-t / 0.12) * 0.3
        return _pan_stereo((hit + tail) * 0.07, pan)


def generate_ambience(region_id: str, dur_s: float = 48.0) -> np.ndarray:
    rng = np.random.default_rng(abs(hash("amb_" + region_id)) % (2 ** 31))
    n = int(dur_s * SR)
    ir = build_hall_ir(1.8, bright_hz=2000.0, seed=90)

    if region_id in ("bellhaven", "epilogue_dawn"):
        # Gentle breeze (< 550 Hz) + sparse sweet distant birds
        bed = _brown_breeze(n, 75.0, 520.0, 12.0, rng) * 0.055
        bird_times = [2.4, 2.8, 9.5, 16.2, 16.6, 25.0, 33.4, 33.8, 41.5]
        for idx, bt in enumerate(bird_times):
            pan = -0.65 if idx % 2 == 0 else 0.65
            freq = rng.uniform(1350.0, 1850.0) if region_id == "bellhaven" else rng.uniform(1450.0, 1980.0)
            _place_wrapped(bed, bt, _bird_chirp(freq, rng.uniform(0.14, 0.22), pan, rng))
        target_lufs = -28.0

    elif region_id == "briarwood":
        # Soft woodland leaf rustle + varied forest birds + very rare delicate forest shimmer
        bed = _brown_breeze(n, 110.0, 820.0, 10.0, rng) * 0.055
        # Soft leaf rustle swells (filtered, gentle, low-passed < 1500 Hz)
        for lt in (5.0, 18.5, 31.0, 42.0):
            rn = int(3.2 * SR)
            rt = np.arange(rn, dtype=np.float64) / SR
            rustle = _fft_bandpass(_pink_noise(rn, rng), 320.0, 1350.0) * (np.sin(math.pi * rt / 3.2) ** 2.0) * 0.045
            _place_wrapped(bed, lt, _pan_stereo(rustle, rng.uniform(-0.5, 0.5)))
        for idx, bt in enumerate([3.0, 3.35, 11.2, 21.5, 21.85, 29.0, 37.5, 44.2]):
            _place_wrapped(bed, bt, _bird_chirp(rng.uniform(1250.0, 1780.0), 0.18, rng.uniform(-0.7, 0.7), rng))
        target_lufs = -27.5

    elif region_id == "floodmill":
        # Gentle running brook (< 1150 Hz) + soft rain patters + sparse water droplets + distant wood creaks
        bed = _brown_breeze(n, 95.0, 1080.0, 14.0, rng) * 0.065
        # Soft sparse droplets
        for dt in np.linspace(1.2, dur_s - 1.5, 26):
            jitter_t = dt + rng.uniform(-0.35, 0.35)
            _place_wrapped(bed, jitter_t, _water_droplet(rng.uniform(420.0, 740.0), rng.uniform(-0.75, 0.75)))
        for ct in (8.0, 23.5, 38.0):
            _place_wrapped(bed, ct, _distant_creak_or_clink("wood_creak", rng.uniform(-0.6, 0.6), rng))
        target_lufs = -27.0

    elif region_id == "ironwatch":
        # Restrained dark stone hall air (mostly quiet, very low < 340 Hz) + sparse distant stone echoes
        bed = _brown_breeze(n, 55.0, 320.0, 16.0, rng) * 0.042
        for st in (6.5, 19.2, 31.8, 43.0):
            _place_wrapped(bed, st, _distant_creak_or_clink("stone_tap", rng.uniform(-0.7, 0.7), rng))
        target_lufs = -30.5

    elif region_id == "dawnspire":
        # Clean mountain air (220-780 Hz) + gentle slow alpine gusts (ZERO harsh white noise!)
        bed = _brown_breeze(n, 140.0, 760.0, 12.0, rng) * 0.048
        # Two subtle distant mountain gusts across 48s
        for gt in (10.0, 32.0):
            gn = int(4.5 * SR)
            g_t = np.arange(gn, dtype=np.float64) / SR
            g_env = np.sin(math.pi * g_t / 4.5) ** 2.2
            g_air = _fft_bandpass(_pink_noise(gn, rng), 240.0, 820.0) * g_env * 0.055
            _place_wrapped(bed, gt, _pan_stereo(g_air, 0.25 if gt < 20 else -0.25))
        target_lufs = -28.0

    elif region_id == "great_bell":
        # Quiet cathedral space + ultra-subtle distant bronze resonance every ~24s
        bed = _brown_breeze(n, 55.0, 300.0, 16.0, rng) * 0.036
        for bt in (8.0, 32.0):
            _place_wrapped(bed, bt, synth_cathedral_bell(146.83, 5.5, 0.22, pan=0.0))
        target_lufs = -30.0

    else:
        bed = _brown_breeze(n, 70.0, 480.0, 12.0, rng) * 0.045
        target_lufs = -29.0

    bed = _fft_lowpass(bed, 3200.0, slope=2.0)
    mix = apply_circular_reverb(bed, ir, wet_mix=0.20)
    rms = math.sqrt(float(np.mean(mix ** 2)) + 1e-12)
    gain = 10.0 ** ((target_lufs - 20.0 * math.log10(rms)) / 20.0)
    mix *= gain
    peak = float(np.max(np.abs(mix)))
    if peak > 0.35:
        mix *= (0.35 / peak)
    return mix


# ---------------------------------------------------------------------------
# Crisp, Warm, Natural SFX Library (No Harsh Raw Sine Beeps)
# ---------------------------------------------------------------------------

def generate_sfx(sfx_id: str, variant: int = 0) -> np.ndarray:
    rng = np.random.default_rng(abs(hash(f"{sfx_id}_{variant}")) % (2 ** 31))
    ir = build_hall_ir(0.9, bright_hz=2200.0, seed=120 + variant)

    def finalize(sig_stereo: np.ndarray, peak_limit: float = 0.45, do_verb: bool = True) -> np.ndarray:
        out = sig_stereo if not do_verb else apply_circular_reverb(sig_stereo, ir, wet_mix=0.14)
        out = _fft_lowpass(out, 5800.0, slope=1.5)
        fade = min(out.shape[0], int(0.015 * SR))
        out[-fade:] *= np.linspace(1.0, 0.0, fade)[:, None]
        pk = float(np.max(np.abs(out)))
        if pk > 1e-6:
            out *= min(1.0, peak_limit / pk) if pk > peak_limit else (peak_limit / max(pk, peak_limit))
        return out

    if sfx_id == "footstep":
        dur = 0.09
        n = int(dur * SR)
        t = np.arange(n, dtype=np.float64) / SR
        base_f = 95.0 + variant * 14.0
        thud = np.sin(TAU * base_f * t) * np.exp(-t / 0.018) * 0.42
        grit = _fft_bandpass(rng.standard_normal(n), 280.0, 1150.0) * np.exp(-t / 0.024) * 0.25
        sig = (thud + grit) * (1.0 - np.exp(-t / 0.003))
        return finalize(_pan_stereo(sig, 0.0), peak_limit=0.22, do_verb=False)

    elif sfx_id == "dialogue_open":
        h = synth_harp(440.0, 0.14, 0.45, 0.0) * 0.7
        c = synth_celesta(659.25, 0.16, 0.35, 0.12)
        ln = min(h.shape[0], c.shape[0], int(0.45 * SR))
        return finalize(h[:ln] + c[:ln], 0.30)

    elif sfx_id == "item_pickup":
        n = int(0.55 * SR)
        buf = np.zeros((n, 2), dtype=np.float64)
        _place_wrapped(buf, 0.0, synth_harp(587.33, 0.35, 0.65, -0.1)[:n])
        c2 = synth_celesta(880.0, 0.40, 0.55, 0.15)
        s2 = int(0.08 * SR)
        l2 = min(n - s2, c2.shape[0])
        buf[s2:s2 + l2] += c2[:l2]
        return finalize(buf, 0.38)

    elif sfx_id == "puzzle_solve":
        n = int(1.1 * SR)
        buf = np.zeros((n, 2), dtype=np.float64)
        for idx, m in enumerate([62, 69, 74, 78]):  # D major warm chord bloom
            c = synth_harp(midi_to_hz(m), 0.7, 0.65, -0.2 + idx * 0.14)
            s_i = int(idx * 0.09 * SR)
            ln = min(n - s_i, c.shape[0])
            buf[s_i:s_i + ln] += c[:ln]
        return finalize(buf, 0.45)

    elif sfx_id == "save_game":
        n = int(0.85 * SR)
        buf = np.zeros((n, 2), dtype=np.float64)
        for idx, m in enumerate([69, 76]):  # Warm A4 -> E5 piano fifth
            c = synth_felt_piano(midi_to_hz(m), 0.45, 0.62, rng)
            s_i = int(idx * 0.11 * SR)
            ln = min(n - s_i, c.shape[0])
            buf[s_i:s_i + ln] += c[:ln]
        return finalize(buf, 0.38)

    elif sfx_id in ("bell_toll", "great_bell_resonance"):
        freq = 196.0 if sfx_id == "bell_toll" else 146.83
        return finalize(synth_cathedral_bell(freq, 2.6, 0.85, 0.0), 0.52)

    elif sfx_id in ("beacon_activate", "observatory_activate", "sanctuary_awaken", "ritual_stabilize"):
        n = int(1.6 * SR)
        buf = np.zeros((n, 2), dtype=np.float64)
        chord = [50, 57, 62, 66, 69]
        for idx, m in enumerate(chord):
            c = synth_harp(midi_to_hz(m), 1.0, 0.70, -0.25 + idx * 0.12)
            s_i = int(idx * 0.06 * SR)
            ln = min(n - s_i, c.shape[0])
            buf[s_i:s_i + ln] += c[:ln]
        bell = synth_cathedral_bell(293.66, 1.5, 0.55, 0.0)
        ln_b = min(n, bell.shape[0])
        buf[:ln_b] += bell[:ln_b]
        return finalize(buf, 0.50)

    elif sfx_id in ("chapter_complete", "dawn_chord"):
        n = int(2.2 * SR)
        buf = np.zeros((n, 2), dtype=np.float64)
        notes = [53, 60, 65, 69, 72, 77]
        for idx, m in enumerate(notes):
            c = synth_felt_piano(midi_to_hz(m), 1.4, 0.68, rng)
            s_i = int(idx * 0.075 * SR)
            ln = min(n - s_i, c.shape[0])
            buf[s_i:s_i + ln] += c[:ln]
        return finalize(buf, 0.48)

    elif sfx_id in ("memory_fragment", "celestial_align", "conduit_align"):
        n = int(1.1 * SR)
        buf = np.zeros((n, 2), dtype=np.float64)
        for idx, m in enumerate([74, 81, 86]):
            c = synth_celesta(midi_to_hz(m), 0.7, 0.65, -0.18 + idx * 0.18)
            s_i = int(idx * 0.08 * SR)
            ln = min(n - s_i, c.shape[0])
            buf[s_i:s_i + ln] += c[:ln]
        return finalize(buf, 0.42)

    elif sfx_id == "binding_sever":
        n = int(2.4 * SR)
        buf = np.zeros((n, 2), dtype=np.float64)
        d = synth_ceremonial_drum(58.0, 1.2, 0.90, 0.0, rng)
        buf[:min(n, d.shape[0])] += d[:min(n, d.shape[0])]
        b = synth_cathedral_bell(146.83, 2.3, 0.88, 0.0)
        buf[:min(n, b.shape[0])] += b[:min(n, b.shape[0])]
        return finalize(buf, 0.56)

    elif sfx_id == "mountain_wind":
        dur = 1.4
        n = int(dur * SR)
        t = np.arange(n, dtype=np.float64) / SR
        env = np.sin(math.pi * t / dur) ** 1.8
        air = _fft_bandpass(_pink_noise(n, rng), 180.0, 680.0) * env * 0.30
        return finalize(_pan_stereo(air, 0.0), 0.24, do_verb=True)

    elif sfx_id in ("distant_thunder", "storm_recede"):
        dur = 1.8
        n = int(dur * SR)
        t = np.arange(n, dtype=np.float64) / SR
        env = np.exp(-t / 0.65) * (1.0 - np.exp(-t / 0.14))
        rumble = _fft_bandpass(_pink_noise(n, rng), 42.0, 190.0) * env * 0.65
        return finalize(_pan_stereo(rumble, 0.0), 0.38, do_verb=True)

    elif sfx_id in ("stone_movement", "bridge_mechanism"):
        dur = 0.75
        n = int(dur * SR)
        t = np.arange(n, dtype=np.float64) / SR
        env = np.sin(math.pi * t / dur) ** 1.3
        scrape = _fft_bandpass(_pink_noise(n, rng), 90.0, 420.0) * env * 0.40
        thump = synth_ceremonial_drum(82.0, 0.4, 0.55, 0.0, rng)
        out = _pan_stereo(scrape, 0.0)
        out[:min(n, thump.shape[0])] += thump[:min(n, thump.shape[0])] * 0.55
        return finalize(out, 0.36, do_verb=True)

    else:
        return finalize(synth_harp(523.25, 0.3, 0.5, 0.0), 0.32)


def write_wav_float(path: Path, data: np.ndarray) -> None:
    clipped = np.clip(data, -0.99, 0.99)
    pcm = (clipped * 32767.0).astype("<i2")
    channels = 2 if data.ndim == 2 and data.shape[1] == 2 else 1
    with wave.open(str(path), "wb") as wf:
        wf.setnchannels(channels)
        wf.setsampwidth(2)
        wf.setframerate(SR)
        wf.writeframes(pcm.tobytes())


def encode_ogg_from_array(ogg_path: Path, data: np.ndarray, quality: int = 6) -> None:
    tmp_wav = ogg_path.with_suffix(".tmp.wav")
    write_wav_float(tmp_wav, data)
    cmd = [
        "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
        "-i", str(tmp_wav),
        "-c:a", "libvorbis", "-q:a", str(quality),
        str(ogg_path),
    ]
    subprocess.run(cmd, check=True)
    if tmp_wav.exists():
        tmp_wav.unlink()


def measure_audio_file(path: Path) -> dict:
    """Measures ITU-R BS.1770 integrated loudness (LUFS) & true peak (dBTP) via ffmpeg ebur128."""
    cmd = [
        "ffmpeg", "-hide_banner", "-nostats",
        "-i", str(path),
        "-af", "ebur128=peak=true:framelog=quiet",
        "-f", "null", "-",
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True, check=True)
    text = proc.stderr + "\n" + proc.stdout
    lufs = None
    peak = None
    for line in text.splitlines():
        s = line.strip()
        if s.startswith("I:") and "LUFS" in s:
            try:
                lufs = float(s.split("I:")[1].split("LUFS")[0].strip())
            except ValueError:
                pass
        elif s.startswith("Peak:") and "dBFS" in s:
            try:
                peak = float(s.split("Peak:")[1].split("dBFS")[0].strip())
            except ValueError:
                pass
    return {"file": path.name, "lufs": lufs, "peak_db": peak}


def main() -> int:
    ensure_dirs()
    music_specs = [
        ("mus_bellhaven", compose_bellhaven),
        ("mus_briarwood", compose_briarwood),
        ("mus_floodmill", compose_floodmill),
        ("mus_ironwatch", compose_ironwatch),
        ("mus_dawnspire", compose_dawnspire),
        ("mus_great_bell", compose_great_bell),
        ("mus_great_bell_climax", compose_great_bell_climax),
        ("mus_epilogue_dawn", compose_epilogue_dawn),
    ]
    print("=== ASHVALE AUDIO FOUNDRY ===")
    force = "--force" in sys.argv
    for name, fn in music_specs:
        out = MUSIC_DIR / f"{name}.ogg"
        if out.exists() and not force:
            stats = measure_audio_file(out)
            print(f"[MUSIC]    {name}.ogg (cached) | {stats['lufs']} LUFS | Peak {stats['peak_db']} dBTP")
            continue
        arr = fn()
        encode_ogg_from_array(out, arr, quality=6)
        stats = measure_audio_file(out)
        print(f"[MUSIC]    {name}.ogg | {arr.shape[0]/SR:.1f}s | {stats['lufs']} LUFS | Peak {stats['peak_db']} dBTP")

    amb_regions = [
        "bellhaven", "briarwood", "floodmill", "ironwatch", "dawnspire", "great_bell", "epilogue_dawn"
    ]
    for reg in amb_regions:
        out = AMBIENCE_DIR / f"amb_{reg}.ogg"
        if out.exists() and not force:
            stats = measure_audio_file(out)
            print(f"[AMBIENCE] amb_{reg}.ogg (cached) | {stats['lufs']} LUFS | Peak {stats['peak_db']} dBTP")
            continue
        arr = generate_ambience(reg, dur_s=48.0)
        encode_ogg_from_array(out, arr, quality=5)
        stats = measure_audio_file(out)
        print(f"[AMBIENCE] amb_{reg}.ogg | {arr.shape[0]/SR:.1f}s | {stats['lufs']} LUFS | Peak {stats['peak_db']} dBTP")

    sfx_ids = [
        "dialogue_open", "item_pickup", "puzzle_solve", "save_game",
        "beacon_activate", "chapter_complete", "bell_toll", "mountain_wind",
        "distant_thunder", "stone_movement", "bridge_mechanism", "observatory_activate",
        "celestial_align", "sanctuary_awaken", "great_bell_resonance", "memory_fragment",
        "conduit_align", "ritual_stabilize", "binding_sever", "storm_recede", "dawn_chord",
    ]
    for v in range(3):
        out = SFX_DIR / f"sfx_footstep_{v}.wav"
        write_wav_float(out, generate_sfx("footstep", v))
    for sid in sfx_ids:
        out = SFX_DIR / f"sfx_{sid}.wav"
        write_wav_float(out, generate_sfx(sid, 0))
    print(f"[SFX]      Generated {len(sfx_ids) + 3} SFX WAV assets cleanly.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
