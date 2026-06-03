extends Node
class_name ActionController


signal attack_beginning()
signal attack_complete
signal perform_attack(AttackInfo)

@export var attacker : Unit
@export var target : Unit
@export var Delay:float = 1.0
var anim_finished = false

@export var base_damage = 10

@export var camera_attack : Camera3D


@onready var animation_tree: AnimationTree = $"../AnimationTree"

var animation_state_machine : AnimationNodeStateMachinePlayback

#deberia tener una coleccion de ataque como recurso con sus datos

var next_attacK_Info : AttackInfo

#al comenzar turno amigo o al terminar su turno elige el siguiente ataque y se representa en attackinfo
#el atk info deberia tener la animacion a instanciar, ataque a transmitir, target, etc

func _ready() -> void:
	animation_state_machine = animation_tree.get("parameters/playback")
	
	#if not attack_camera :
		#attack_camera = get_node_or_null("../CameraAttack/Camera-camera")
	#esto se va a cambiar
	@warning_ignore("unused_parameter")
	animation_tree.animation_finished.connect(func(anim_name: StringName): anim_finished = true)
	
	attacker = $"../"
	next_attacK_Info = AttackInfo.new()
	next_attacK_Info.attacker = $".."
	next_attacK_Info.damage = base_damage

#perform movement elige un movimiento existente
func perform_movement() -> void:
	
	get_target()
	if target:
		# Orientamos el personaje hacia el objetivo
		# Usamos global_position para evitar problemas con la jerarquía
		attacker.look_at(target.global_position, Vector3.UP,true)
		
		# Opcional: Bloquear la rotación en el eje X para que no se incline hacia arriba/abajo
		attacker.rotation.x = 0 
		attacker.rotation.z = 0
	
	attack_beginning.emit()
	
	
	#CameraEventBus.changeCamera.emit(attack_camera,0.333)
	#en realidad la attack camera, el nombre y demas es dado un "ataque" recurso que deberia tener

	animation_state_machine.travel("attack")
	UiEventBus.changeCamera.emit(camera_attack)
	UiEventBus.deactivate_status_view_component.emit()
	
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

func _perform_attack() -> void:	
	next_attacK_Info.damage = base_damage
	next_attacK_Info.target = target
	perform_attack.emit(next_attacK_Info)

#
func get_target() -> void:
	if attacker:
		var groups = attacker.get_groups()
		if "enemy" in groups:
			var players = get_tree().get_nodes_in_group("player")

			if players.size() > 0:
				target = players.pick_random() as Unit
			else:
				target = null
		elif "player" in groups:
			var enemies = get_tree().get_nodes_in_group("enemy")

			if enemies.size() > 0:
				target = enemies.pick_random() as Unit
			else:
				target = null

		
