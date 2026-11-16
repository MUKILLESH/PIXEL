extends SceneTree
## Windowed Performance & Memory Profiler across all 6 ASHVALE regions.
## Must be run WITHOUT --headless (rendered OpenGL GPU frame timing).
## Usage:
##   .\Godot_v4.7.2-stable_win64_console.exe --quit-after 600 -s res://tests/profile_phase7.gd

func frames(count: int = 20) -> void:
	for _i in range(count):
		await process_frame

func _wait_scene(expected: String) -> Node:
	for _i in range(60):
		await process_frame
		if current_scene != null and current_scene.name == expected:
			await frames(15)
			return current_scene
	return null

func run_profile() -> void:
	var regions := [
		["BellhavenVillage", "res://scenes/sjt_exterior.tscn"],
		["BriarwoodForest", "res://scenes/briarwood_forest.tscn"],
		["FloodmillVillage", "res://scenes/floodmill_village.tscn"],
		["IronwatchKeep", "res://scenes/ironwatch_keep.tscn"],
		["DawnspireMountain", "res://scenes/dawnspire_mountain.tscn"],
		["GreatBellSanctum", "res://scenes/great_bell_sanctum.tscn"],
	]
	print("=== ASHVALE WINDOWED PERFORMANCE PROFILE ===")
	for entry in regions:
		var rname: String = entry[0]
		var rpath: String = entry[1]
		var t_load0: int = Time.get_ticks_usec()
		change_scene_to_file(rpath)
		var sc := await _wait_scene(rname)
		var load_ms: float = float(Time.get_ticks_usec() - t_load0) / 1000.0
		if sc == null:
			print("PROFILE ERROR: Failed to load " + rname)
			continue
		# Measure steady-state frame timing over 65 rendered frames (>1.0s)
		var t_ss0: int = Time.get_ticks_usec()
		await frames(65)
		var ss_sec: float = float(Time.get_ticks_usec() - t_ss0) / 1000000.0
		var measured_fps: float = 65.0 / maxf(0.001, ss_sec)
		var avg_frame_ms: float = (ss_sec * 1000.0) / 65.0
		var mon_fps: float = Performance.get_monitor(Performance.TIME_FPS)
		var phys_ms: float = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
		var mem_mb: float = float(Performance.get_monitor(Performance.MEMORY_STATIC)) / (1024.0 * 1024.0)
		var nodes: int = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
		var orphans: int = int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
		print("PROFILE REGION=%s load_ms=%.2f steady_fps=%.1f engine_fps=%.1f avg_frame_ms=%.2f physics_ms=%.2f mem_mb=%.2f nodes=%d orphans=%d" % [
			rname, load_ms, measured_fps, mon_fps, avg_frame_ms, phys_ms, mem_mb, nodes, orphans
		])
	print("=== PROFILE COMPLETE ===")
	quit(0)

func _init() -> void:
	call_deferred("run_profile")
