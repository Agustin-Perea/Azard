extends Node3D

#debe llevar un count reseteable a final de turno, cada count aumenta la velocidad hasta un x2
@onready var background_mesh : MeshInstance3D = $BackgroundMesh
@onready var sprite_viewport : Sprite3D = $Sprite3D
@onready var label_text : RichTextLabel = $SubViewport/RichTextLabel

@export var duracion_animacion : float = .5
@export var duracion_fade : float = .5
@export var giros_y : int = 2

var active_tween : Tween = null
var finished : bool = false

@export var base_spot : Vector3 = Vector3(-1.34,0.0,-1.278)
@export var mult_spot : Vector3 = Vector3(-0.822,0.0,-1.278)

func _ready():
	reset_state()
	#CombatEventBus.apply_mult.connect(animate_mult)
	#CombatEventBus.multiplicator_indicator = self#en realidad deberia ser global
	

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


@export var mult_position : Vector3
func animate_mult(multiply : float)-> Tween:
	#if active_tween:
	#	return active_tween
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			# reset
			reset_state()
			self.visible = true

			#Setup de datos
			self.position = mult_position
			label_text.bbcode_enabled = true
			label_text.text = "[wave amp=50 freq=5]x" + str(multiply) + "[/wave]"

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

			#aca se llama automaticamente active_tween.finished cuando se completa
			# --- FASE 4: FINALIZACIÓN ---
			return true #regrsa true y se va del gameevent, cuando el activetween termina se vuelve null
	}))

	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			return active_tween == null
	}))
	
	return active_tween

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
