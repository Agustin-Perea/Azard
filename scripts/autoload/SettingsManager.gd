extends Node

signal music_volume_changed(value: float)
signal sfx_volume_changed(value: float)
signal fullscreen_changed(enabled: bool)

const SETTINGS_PATH := "user://settings.json"
const DEFAULT_MUSIC_VOLUME := 1.0
const DEFAULT_SFX_VOLUME := 0.6
const DEFAULT_FULLSCREEN := false

var music_volume := DEFAULT_MUSIC_VOLUME
var sfx_volume := DEFAULT_SFX_VOLUME
var fullscreen := DEFAULT_FULLSCREEN

func _ready() -> void:
	load_settings()
	_apply_fullscreen()

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	music_volume = clampf(float(parsed.get("music_volume", DEFAULT_MUSIC_VOLUME)), 0.0, 1.0)
	sfx_volume = clampf(float(parsed.get("sfx_volume", DEFAULT_SFX_VOLUME)), 0.0, 1.0)
	fullscreen = bool(parsed.get("fullscreen", DEFAULT_FULLSCREEN))

func save_settings() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo guardar opciones: %s" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify({
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"fullscreen": fullscreen,
	}, "\t"))

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	save_settings()
	music_volume_changed.emit(music_volume)
	var music_manager := get_node_or_null("/root/MusicManager")
	if music_manager != null:
		music_manager.call("set_music_volume_multiplier", music_volume)

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	save_settings()
	sfx_volume_changed.emit(sfx_volume)

func set_fullscreen(value: bool) -> void:
	fullscreen = value
	_apply_fullscreen()
	save_settings()
	fullscreen_changed.emit(fullscreen)

func get_music_volume_percent() -> int:
	return int(round(music_volume * 100.0))

func get_sfx_volume_percent() -> int:
	return int(round(sfx_volume * 100.0))

func get_sfx_volume_db(base_volume_db: float = 0.0) -> float:
	return _volume_to_db(base_volume_db, sfx_volume)

func _apply_fullscreen() -> void:
	return
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _volume_to_db(base_volume_db: float, value: float) -> float:
	if value <= 0.0:
		return -80.0
	return base_volume_db + linear_to_db(value)
