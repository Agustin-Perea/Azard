extends Node

const FADE_SECONDS := 0.5

var _player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer # <--- Nuevo reproductor para SFX
var _fade_tween: Tween
var _current_track_path := ""
var _music_volume_multiplier := 1.0
var _current_base_volume_db := -14.0

func _ready() -> void:
	# --- Configuración del Reproductor de Música ---
	_player = AudioStreamPlayer.new()
	_player.name = "MusicPlayer"
	_player.bus = "Master"
	_player.volume_db = -14.0
	add_child(_player)
	_player.finished.connect(_on_music_finished)
	
	# --- Configuración del Reproductor de SFX (Polifónico) ---
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SFXPlayer"
	_sfx_player.bus = "Master" # O un bus "SFX" si lo creas en el futuro
	
	# Creamos y asignamos el recurso polifónico para permitir sonidos simultáneos
	var poly_stream := AudioStreamPolyphonic.new()
	poly_stream.polyphony = 16 # Permite hasta 16 sonidos superpuestos a la vez
	_sfx_player.stream = poly_stream
	
	add_child(_sfx_player)
	_sfx_player.play() # Debe estar "reproduciendo" el poly_stream para poder usarlo
	
	# --- Settings ---
	var settings_manager := get_node_or_null("/root/SettingsManager")
	if settings_manager != null:
		_music_volume_multiplier = float(settings_manager.get("music_volume"))
		settings_manager.music_volume_changed.connect(set_music_volume_multiplier)


# =============================================================================
# MÉTODOS DE MÚSICA (Con Fades)
# =============================================================================

func play_music(track_data: Dictionary) -> void:
	var path: String = track_data.get("path", "")
	var target_volume: float = track_data.get("volume", 0.0)
	var offset: float = track_data.get("offset", 0.0)
	
	if _player == null or path == "":
		return
		
	# Corrección de seguridad: Evita crasheos si _fade_tween es null inicialmente
	if _current_track_path == path and (_fade_tween == null or !_fade_tween.is_running()):
		return
		
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()

	if _player.playing:
		_fade_tween = create_tween()
		_fade_tween.tween_property(_player, "volume_db", -80.0, FADE_SECONDS * 0.5 / UiEventBus.TIME_SCALE)
		_fade_tween.finished.connect(func():
			_start_track(path, target_volume, offset)
		)
		return

	_start_track(path, target_volume, offset)

func _start_track(path: String, target_volume_db: float, offset: float) -> void:
	var stream: AudioStream = load(path)
	if stream == null:
		push_error("No se pudo cargar el archivo de audio en: " + path)
		return
		
	_configure_loop(stream)
	_player.stream = stream
	_player.volume_db = -80.0
	_player.play(offset)
	
	_current_track_path = path
	_current_base_volume_db = target_volume_db
	
	_fade_tween = create_tween()
	_fade_tween.tween_property(_player, "volume_db", _scaled_volume_db(target_volume_db), FADE_SECONDS / UiEventBus.TIME_SCALE)

func stop_music() -> void:
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_player, "volume_db", -80.0, FADE_SECONDS / UiEventBus.TIME_SCALE)
	_fade_tween.finished.connect(func():
		_player.stop()
		_current_track_path = ""
	)


# =============================================================================
# MÉTODOS DE EFECTOS DE SONIDO (SFX - Sin Fades, Polifónicos)
# =============================================================================

## Reproduce un efecto de sonido instantáneamente de fondo usando su Path de Constants o String directo
func play_sfx(sfx_path: String) -> void:
	if sfx_path == "":
		return
		
	var stream: AudioStream = load(sfx_path)
	if stream == null:
		push_error("No se pudo cargar el SFX en el path: " + sfx_path)
		return
		
	# Obtenemos el controlador de reproducción polifónica
	var playback: AudioStreamPlaybackPolyphonic = _sfx_player.get_stream_playback()
	if playback:
		# Esto reproduce el sonido inmediatamente en su propia "voz" sin cortar los demás
		playback.play_stream(stream)


# =============================================================================
# UTILIDADES Y CONFIGURACIÓN
# =============================================================================

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
	elif stream is AudioStreamOggVorbis:
		stream.loop = true 

func _on_music_finished() -> void:
	if _current_track_path == "" or _player == null or _player.stream == null:
		return
	_player.play()
