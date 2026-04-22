extends Node3D

#debe llevar un count reseteable a final de turno, cada count aumenta la velocidad hasta un x2
@onready var background_mesh : MeshInstance3D = $BackgroundMesh
@onready var sprite_viewport : Sprite3D = $Sprite3D
@onready var viewport : SubViewport = $SubViewport
@onready var label_text : RichTextLabel = $SubViewport/RichTextLabel

@export var duracion_animacion : float = .5
@export var duracion_fade : float = .5
@export var giros_y : int = 2

var active_tween : Tween = null
var finished : bool = false

@export var base_spot : Vector3 = Vector3(-1.34,0.0,-1.278)
@export var mult_spot : Vector3 = Vector3(-0.822,0.0,-1.278)
@export var base_viewport_size := Vector2i(128, 128)
@export var long_viewport_size := Vector2i(320, 160)
@export var base_plane_size := Vector2(0.3, 0.3)
@export var long_plane_size := Vector2(0.72, 0.36)
@export var base_font_size := 46
@export var long_font_size := 36

func _ready():
	reset_state()
	BookEventBus.popuptext.connect(animate_in_pos)

func reset_state():
	# Si hay una animación corriendo, la detenemos
	if active_tween:
		active_tween.kill()
	active_tween = null
	finished = false
	
	# Reset de Transformación
	self.scale = Vector3.ZERO
	background_mesh.rotation.y = 0
	
	# Reset de Visibilidad (Alpha)
	sprite_viewport.modulate.a = 1.0 # El sprite suele controlarse mejor con modulate
	
	# Reset del Material del Mesh
	var material = background_mesh.get_active_material(0)
	if material:
		# Asegúrate de que el material tenga "Transparent" habilitado en sus propiedades
		material.albedo_color.a = .95
	
	# Ocultamos el nodo padre para seguridad extra hasta que inicie la animación
	self.visible = false

func animate_in_pos(spot_global_postion :Vector3, text : String, global : bool = false)->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			reset_state()
			self.visible = true

			#Setup de datos
			
			if global:
				self.global_position = spot_global_postion
			else:
				self.position = spot_global_postion
			
			label_text.bbcode_enabled = true
			_apply_text_layout(text)
			label_text.text = "[wave amp=50 freq=5]" + text + "[/wave]"

			#Nueva Animación
			active_tween = create_tween()
			active_tween.finished.connect(kill_tween)
			finished = false
			# APARICIÓN (Paralelo) ---
			active_tween.set_parallel(true)
			active_tween.tween_property(self, "scale", Vector3.ONE, duracion_animacion)\
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

			var rotacion_final_y = background_mesh.rotation.y + (PI * 2 * giros_y)
			active_tween.tween_property(background_mesh, "rotation:y", rotacion_final_y, duracion_animacion)\
				.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

			# --- FASE 2: ESPERA ---
			active_tween.set_parallel(false)
			active_tween.tween_interval(0.5) # Tiempo que se queda estático y visible

			# --- FASE 3: DESVANECIMIENTO (Fade Out) ---
			active_tween.chain().set_parallel(true)
			active_tween.tween_property(sprite_viewport, "modulate:a", 0.0, duracion_fade)

			var material = background_mesh.get_active_material(0)
			if material:
				active_tween.tween_property(material, "albedo_color:a", 0.0, duracion_fade)

			# --- FASE 4: FINALIZACIÓN ---
			#active_tween.chain().tween_callback(func(): self.visible = false)
			return true
	}))
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			return active_tween == null
	}))

func kill_tween()->void:
	if active_tween:
		active_tween.kill()
	active_tween = null
	finished = true

func _apply_text_layout(text: String) -> void:
	var is_long := text.length() > 6
	var viewport_size := long_viewport_size if is_long else base_viewport_size
	var plane_size := long_plane_size if is_long else base_plane_size
	var font_size := long_font_size if is_long else base_font_size

	viewport.size = viewport_size
	label_text.size = Vector2(viewport_size)
	label_text.position = Vector2.ZERO
	label_text.pivot_offset = Vector2(viewport_size) * 0.5
	label_text.add_theme_font_size_override("normal_font_size", font_size)

	var plane := background_mesh.mesh as PlaneMesh
	if plane != null:
		plane.size = plane_size
