extends Node

const MENU_MUSIC_PATH := "res://resources/music/Ghosts of Void.mp3" #"res://resources/music/frontier-home.mp3"
const COMBAT_MUSIC_PATH :="res://resources/music/Balatro.mp3" #"res://resources/music/sunshire-theme.mp3"#

const MENU_VOLUME_DB := -14.0
const COMBAT_VOLUME_DB := -20.0
const FADE_SECONDS := 0.75

var _player: AudioStreamPlayer
var _fade_tween: Tween
var _current_track := ""
var _menu_music: AudioStream
var _combat_music: AudioStream
var _music_volume_multiplier := 1.0
var _current_base_volume_db := MENU_VOLUME_DB

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.name = "MusicPlayer"
	_player.bus = "Master"
	_player.volume_db = MENU_VOLUME_DB
	add_child(_player)
	_player.finished.connect(_on_music_finished)
	_menu_music = load(MENU_MUSIC_PATH)
	_combat_music = load(COMBAT_MUSIC_PATH)
	_configure_loop(_menu_music)
	_configure_loop(_combat_music)
	var settings_manager := get_node_or_null("/root/SettingsManager")
	if settings_manager != null:
		_music_volume_multiplier = float(settings_manager.get("music_volume"))
		settings_manager.music_volume_changed.connect(set_music_volume_multiplier)

func play_menu_music() -> void:
	_play_music(_menu_music, "menu", MENU_VOLUME_DB,55)

func play_combat_music() -> void:
	_play_music(_combat_music, "combat", COMBAT_VOLUME_DB,18)

func stop_music() -> void:
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_player, "volume_db", -80.0, FADE_SECONDS)
	_fade_tween.finished.connect(func():
		_player.stop()
		_current_track = ""
	)

func _play_music(stream: AudioStream, track_name: String, target_volume_db: float, offset: float = 0) -> void:
	if _player == null or stream == null:
		return
	if _current_track == track_name and _player.playing:
		return
	if _fade_tween:
		_fade_tween.kill()

	if _player.playing:
		_fade_tween = create_tween()
		_fade_tween.tween_property(_player, "volume_db", -80.0, FADE_SECONDS * 0.5)
		_fade_tween.finished.connect(func():
			_start_track(stream, track_name, target_volume_db, offset)
		)
		return

	_start_track(stream, track_name, target_volume_db, offset)

func _start_track(stream: AudioStream, track_name: String, target_volume_db: float, offset: float = 0) -> void:
	_configure_loop(stream)
	_player.stream = stream
	_player.volume_db = -80.0
	_player.play(offset)
	_current_track = track_name
	_current_base_volume_db = target_volume_db
	_fade_tween = create_tween()
	_fade_tween.tween_property(_player, "volume_db", _scaled_volume_db(target_volume_db), FADE_SECONDS)

func set_music_volume_multiplier(value: float) -> void:
	_music_volume_multiplier = clampf(value, 0.0, 1.0)
	if _player == null or not _player.playing:
		return
	if _fade_tween != null and _fade_tween.is_running():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_player, "volume_db", _scaled_volume_db(_current_base_volume_db), 0.16)

func _scaled_volume_db(base_volume_db: float) -> float:
	if _music_volume_multiplier <= 0.0:
		return -80.0
	return base_volume_db + linear_to_db(_music_volume_multiplier)

func _configure_loop(stream: AudioStream) -> void:
	if stream == null:
		return
	if stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_DISABLED

func _on_music_finished() -> void:
	if _current_track == "" or _player == null or _player.stream == null:
		return
	_player.play()
