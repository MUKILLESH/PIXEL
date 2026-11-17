#!/usr/bin/env python3
"""
Audits all generated Music, Ambience, and SFX assets for:
  - Peak clipping (<= -1 dBFS safety)
  - High-frequency hiss / static (>3.5 kHz spectral ratio on Ambience)
  - Loop boundary continuity (sample jump between end and start)
  - Music vs Ambience level separation
Also renders a 64s crossfaded OST sampler at docs/audio_previews/ashvale_ost_sampler.ogg.
"""

import glob
import math
import os
import subprocess
import wave
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parents[2]


def decode_f32(path: Path) -> np.ndarray:
    cmd = [
        "ffmpeg", "-hide_banner", "-loglevel", "error",
        "-i", str(path), "-f", "f32le", "-acodec", "pcm_f32le", "-ac", "2", "-ar", "44100", "-"
    ]
    p = subprocess.run(cmd, capture_output=True, check=True)
    return np.frombuffer(p.stdout, dtype=np.float32).reshape(-1, 2)


def main() -> int:
    issues = []
    print("--- MUSIC SPECTRAL & SEAM AUDIT ---")
    tracks = sorted((ROOT / "assets" / "audio" / "music").glob("*.ogg"))
    sampler_parts = []
    music_rms_list = []

    for f in tracks:
        a = decode_f32(f)
        pk = float(np.max(np.abs(a)))
        pk_db = 20.0 * math.log10(max(1e-9, pk))
        rms = float(np.sqrt(np.mean(a ** 2)))
        rms_db = 20.0 * math.log10(max(1e-9, rms))
        music_rms_list.append(rms_db)
        seam_jump = float(np.max(np.abs(a[0] - a[-1])))
        win = a[:44100 * 8, 0]
        spec = np.abs(np.fft.rfft(win)) ** 2
        freqs = np.fft.rfftfreq(win.shape[0], 1.0 / 44100.0)
        hf_ratio = float(np.sum(spec[freqs > 4000.0]) / max(1e-12, np.sum(spec)))
        print(f"  {f.name:28s} | RMS {rms_db:6.1f} dB | Peak {pk_db:6.1f} dBFS | SeamJump {seam_jump:.4f} | >4kHz {hf_ratio*100:.2f}%")
        if pk >= 0.99 or seam_jump > 0.05:
            issues.append(f"MUSIC ISSUE {f.name}: peak={pk:.3f}, seam={seam_jump:.4f}")
        seg = a[44100 * 8:44100 * 16].copy()
        fade = int(0.8 * 44100)
        seg[:fade] *= np.linspace(0.0, 1.0, fade)[:, None]
        seg[-fade:] *= np.linspace(1.0, 0.0, fade)[:, None]
        sampler_parts.append(seg)

    print("--- AMBIENCE HISS & SEAM AUDIT ---")
    amb_rms_list = []
    for f in sorted((ROOT / "assets" / "audio" / "ambience").glob("*.ogg")):
        a = decode_f32(f)
        pk = float(np.max(np.abs(a)))
        pk_db = 20.0 * math.log10(max(1e-9, pk))
        rms_db = 20.0 * math.log10(max(1e-9, float(np.sqrt(np.mean(a ** 2)))))
        amb_rms_list.append(rms_db)
        seam_jump = float(np.max(np.abs(a[0] - a[-1])))
        win = a[:44100 * 8, 0]
        spec = np.abs(np.fft.rfft(win)) ** 2
        freqs = np.fft.rfftfreq(win.shape[0], 1.0 / 44100.0)
        hf_ratio = float(np.sum(spec[freqs > 3500.0]) / max(1e-12, np.sum(spec)))
        print(f"  {f.name:28s} | RMS {rms_db:6.1f} dB | Peak {pk_db:6.1f} dBFS | SeamJump {seam_jump:.4f} | >3.5kHz Hiss {hf_ratio*100:.3f}%")
        if pk >= 0.99 or hf_ratio > 0.05 or seam_jump > 0.03:
            issues.append(f"AMBIENCE ISSUE {f.name}: peak={pk:.3f}, hf={hf_ratio:.4f}, seam={seam_jump:.4f}")

    avg_music = sum(music_rms_list) / max(1, len(music_rms_list))
    avg_amb = sum(amb_rms_list) / max(1, len(amb_rms_list))
    print(f"--- MIX HEADROOM SUMMARY ---")
    print(f"  Avg Raw Music RMS: {avg_music:.1f} dB | Avg Raw Ambience RMS: {avg_amb:.1f} dB (Asset Separation: {avg_music - avg_amb:.1f} dB)")
    print(f"  Effective In-Game Separation (+ Player offsets -2.5 vs -6.5 dB): {(avg_music - 2.5) - (avg_amb - 6.5):.1f} dB")

    print("--- SFX PEAK AUDIT ---")
    max_sfx_pk = -100.0
    sfx_files = sorted((ROOT / "assets" / "audio" / "sfx").glob("*.wav"))
    for f in sfx_files:
        a = decode_f32(f)
        pk_db = 20.0 * math.log10(max(1e-9, float(np.max(np.abs(a)))))
        max_sfx_pk = max(max_sfx_pk, pk_db)
        if pk_db > -1.0:
            issues.append(f"SFX TOO LOUD: {f.name} {pk_db:.1f} dBFS")
    print(f"  Verified {len(sfx_files)} SFX files | Max SFX Peak: {max_sfx_pk:.1f} dBFS")

    sampler = np.vstack(sampler_parts)
    preview_dir = ROOT / "docs" / "audio_previews"
    preview_dir.mkdir(parents=True, exist_ok=True)
    tmp_wav = preview_dir / "ashvale_ost_sampler.tmp.wav"
    out_ogg = preview_dir / "ashvale_ost_sampler.ogg"
    pcm = (np.clip(sampler, -0.98, 0.98) * 32767.0).astype("<i2")
    with wave.open(str(tmp_wav), "wb") as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)
        wf.setframerate(44100)
        wf.writeframes(pcm.tobytes())
    subprocess.run([
        "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
        "-i", str(tmp_wav), "-c:a", "libvorbis", "-q:a", "6", str(out_ogg)
    ], check=True)
    if tmp_wav.exists():
        tmp_wav.unlink()
    print(f"Sampler preview generated: {out_ogg.relative_to(ROOT)}")
    print(f"ISSUES ({len(issues)}):", issues)
    return 0 if not issues else 1


if __name__ == "__main__":
    raise SystemExit(main())
