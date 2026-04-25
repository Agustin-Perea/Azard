class_name Unit extends Node3D

## Señales que emite
@warning_ignore("unused_signal")
signal movement_complete
signal attack_beginning()
signal attack_complete

##Componentes

#stats
@export var stats : StatsComponent


#animation and camera
@onready var animation_tree: AnimationTree = $AnimationTree
var animation_state_machine : AnimationNodeStateMachinePlayback


#esto no deberia estar aqui, es algo de al accion
#@export var attack_camera : Camera3D 
#@onready var attack_camera_player : AnimationPlayer = $CameraAttack/AnimationPlayer

##shaders, es algo del modelo
#@onready var shaders : EntityShader = $Shaders
#damage canvas
@onready var status_view_component : StatusViewComponent = $StatusViewComponent

#movement manager
@onready var action_controller : ActionController = $ActionController

#como obtengo al target?
@export var target : Node3D



func _ready() -> void:
	stats = stats.duplicate(true)
	
	status_view_component.set_up(stats)
	stats.set_up()
	#movement_manager.base_damage = ataque
	animation_state_machine = animation_tree.get("parameters/playback")
	#camera_state_machine = camera_animation_tree.get("parameters/playback")
	#if not attack_camera:
		#attack_camera = get_node_or_null("CameraAttack/Camera-camera")
	#movement_manager.attacker = self
	stats.death.connect(_death)
	
	@warning_ignore("unused_parameter")
	animation_tree.animation_finished.connect(func(anim_name: StringName): anim_finished = true)


var anim_finished = false
#confio que esta el animador y tambien la camara
func perform_movement() -> void:
	if target:
		# Orientamos el personaje hacia el objetivo
		# Usamos global_position para evitar problemas con la jerarquía
		look_at(target.global_position, Vector3.UP,true)
		
		# Opcional: Bloquear la rotación en el eje X para que no se incline hacia arriba/abajo
		self.rotation.x = 0 
		self.rotation.z = 0
	
	attack_beginning.emit()
	
	
	#CameraEventBus.changeCamera.emit(attack_camera,0.333)
	animation_state_machine.travel("GolemAttack")
	
	#attack_camera_player.play("GolemAttack")
	anim_finished = false
	
	var ev = GameEvent.new({
		"paralel": false,
		"action": func():

			return anim_finished
	})
	EventManager.add_event(EventManager.QueueType.GAME, ev)
	ev = GameEvent.new({
		"paralel": false,
		"action": func():
			attack_complete.emit()
			
			return true
	})
	EventManager.add_event(EventManager.QueueType.GAME, ev)


func _play_animation(anim_name : String)-> void:
	
	animation_state_machine.start(anim_name)


#quitar despues, esto pasa en recieve damage
func _show_damaged(damage: float) -> void:
	status_view_component._show_damaged(damage)


func _recieve_attack(damage : int)-> void:
	animation_state_machine.start("hurt")
	stats._substract_life(damage)
	status_view_component._show_damaged(damage)

func _death()-> void:
	status_view_component.health_sprite_viewport.visible = false
	status_view_component.damage_text.visible = false
	animation_state_machine.start("death")
	anim_finished = false
	
	EventManager.add_event(
	EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			queue_free()
			return true
	}))
	EventManager.add_event(
	EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			return anim_finished
	}), 
	true)


#area para ser seleccionado por inputs como target
#@warning_ignore("unused_parameter")
#func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	#
	#if event is InputEventMouseButton and event.pressed:
		#PlayerUiEvents.change_target.emit(self)
#
#
#func _on_target_area_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	#if event is InputEventMouseButton and event.pressed:
		#PlayerUiEvents.change_target.emit(self)


##llamada hacia el UI, podria hacerlo el mismo 
func apply_camera_shake(strength: float, duration: float, frequency: float)->void:
	UiEventBus.apply_camera_shake.emit(strength,duration,frequency)
	
func frame_freeze(timescale: float, duration: float)->void:
	UiEventBus.frame_freeze.emit(timescale,duration)
