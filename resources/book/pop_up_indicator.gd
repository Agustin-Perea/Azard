extends Control

# Control de velocidad acumulativa por turno
@onready var background_rect : ColorRect = $ColorRect
@onready var label_viewport : TextureRect = $TextureRect
@onready var label_text : RichTextLabel = $SubViewport/RichTextLabel

@export var duracion_animacion : float = .5
@export var duracion_fade : float = .3
@export var giros : int = 2

var active_tween : Tween = null
var finished : bool = false

@export var base_spot : Vector2 = Vector2(100, 100)
@export var mult_spot : Vector2 = Vector2(200, 100)

@onready var audio_stream_player : AudioStreamPlayer = $AudioStreamPlayer

var count : int = 0
var step_increase : float = 1.1
var limit_velocity : float = 5
var base_pitch : float = 2

func _ready():
	# Forzar el pivote al centro exacto del tamaño actual del Control
	self.pivot_offset = self.size / 2
	background_rect.pivot_offset = background_rect.size / 2
	
	reset_state()
	BookEventBus.popuptext.connect(animate_in_pos)
	BookEventBus.spin_started.connect(reset_count)

func reset_state():
	if active_tween:
		active_tween.kill()
	active_tween = null
	finished = false
	
	# Reset de Transformación 2D
	self.scale = Vector2.ZERO
	background_rect.rotation = 0
	
	# Reseteamos la opacidad (Alpha) de los dos elementos visuales principales a 1.0
	background_rect.modulate.a = 1.0
	label_viewport.modulate.a = 1.0
	
	self.visible = false

func animate_in_pos(spot_3d_position : Vector3, text : String, global : bool = false) -> void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			reset_state()
			
			var cam = get_viewport().get_camera_3d()
			if not cam:
				return true 
			
			# 1. Obtenemos la posición cruda en pantalla 2D
			var screen_pos : Vector2 = cam.unproject_position(spot_3d_position)
			
			# 2. Corregimos el desfase: restamos la mitad del tamaño para que el CENTRO del Control coincida con el punto 3D
			var corrected_pos : Vector2 = screen_pos - (self.size / 2)
			
			audio_stream_player.stream = preload("res://resources/sounds/Rise07.wav")
			audio_stream_player.pitch_scale = min(base_pitch * (step_increase ** count), base_pitch * limit_velocity)
			audio_stream_player.play()
			self.visible = true

			var divisor_actual: float = step_increase ** count
			var fixed_duracion_animacion : float = max(duracion_animacion / divisor_actual, duracion_animacion / limit_velocity)
			var fixed_duracion_fade : float = max(duracion_fade / divisor_actual, duracion_fade / limit_velocity)
			
			# 3. Aplicamos la posición corregida por el tamaño
			if global:
				self.global_position = corrected_pos
			else:
				self.position = corrected_pos
				
			# Desplazamiento offset vertical inicial (ajustable)
			self.position.y -= 10.0 
			
			label_text.bbcode_enabled = true
			label_text.text = "[wave amp=50 freq=5]" + text + "[/wave]"

			active_tween = create_tween()
			active_tween.finished.connect(kill_tween)
			finished = false
			
			# --- FASE 1: APARICIÓN ---
			active_tween.set_parallel(true)
			active_tween.tween_property(self, "scale", Vector2.ONE, fixed_duracion_animacion)\
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

			var rotacion_final = background_rect.rotation + (PI * 2 * giros)
			active_tween.tween_property(background_rect, "rotation", rotacion_final, fixed_duracion_animacion)\
				.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

			# --- FASE 2: ESPERA ---
			active_tween.set_parallel(false)
			active_tween.tween_interval(0.5)

			# --- FASE 3: DESVANECIMIENTO ---
			active_tween.chain().set_parallel(true)
			active_tween.tween_property(background_rect, "modulate:a", 0.0, fixed_duracion_fade)
			
			# Cambiado: Animamos la opacidad del label_viewport (TextureRect) en vez de los colores del RichTextLabel
			active_tween.tween_property(label_viewport, "modulate:a", 0.0, fixed_duracion_fade)
			
			count += 1
			
			# --- FASE 4: FINALIZACIÓN ---
			active_tween.chain().tween_callback(func(): 
				self.visible = false
				kill_tween()
			)
			return true
	}))
	
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			return active_tween == null
	}))

func kill_tween() -> void:
	if active_tween:
		active_tween.kill()
	active_tween = null
	finished = true

func reset_count() -> void: 
	count = 0
