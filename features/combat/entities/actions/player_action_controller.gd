extends ActionController
class_name PlayerActionController

@onready var attack_camera : Camera3D = $"../ModelVisualComponent/CameraPlayer/CameraPlayer-camera"

@onready var roulette_controller : RouletteController = $"../Books/Book"



func _ready() -> void:
	super()
	roulette_controller.finish_button.pressed.connect(_do_attacK)
	actual_attacK_Info = AttackInfo.new()
	actual_attacK_Info.attacker = $".."
	
	
	UiEventBus.change_target.connect(on_change_target)
	#CombatEventBus.unit_death.connect(get_target)
	
	
func perform_movement() -> void:
	UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.BookState)
	UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.ROULETTE)
	UiEventBus.activate_status_view_component.emit()
	if target:
		on_change_target(target)
	else:
		get_target()
		on_change_target(target)
	
	#reset del attack info y la ruleta y su visual
	
	roulette_controller.reset_score()


func on_change_target(new_target : Unit):
	#if target:
		#target.shaders._deactivate_selection_aura()

	target = new_target
	#if new_target:
		#target.shaders._activate_selection_aura()

func _do_attacK()->void:
	#cambiar de estado
	
	if target:
		# Orientamos el personaje hacia el objetivo
		# Usamos global_position para evitar problemas con la jerarquía
		attacker.look_at(target.global_position, Vector3.UP,true)
		#target.shaders._deactivate_selection_aura()
		
		# Opcional: Bloquear la rotación en el eje X para que no se incline hacia arriba/abajo
		attacker.rotation.x = 0 
		attacker.rotation.z = 0
		actual_attacK_Info.target = target
		actual_attacK_Info.damage = roulette_controller.score
	
	attack_beginning.emit()

	
	#cerrar libro y cambiarlo a placeholder(quitar visibilidad)
	UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.NONE)
	
	
	#inicio de animacion de ataque

	var ev = GameEvent.new({
		"paralel": false,
		"action": func():
			UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.StandBy)
			UiEventBus.changeCamera.emit(attack_camera,.5)
			animation_state_machine.start("attack")
			anim_finished = false
			return true
	})
	EventManager.add_event(EventManager.QueueType.GAME, ev)
	#espera a que termine la animacion
	ev = GameEvent.new({
		"paralel": false,
		"action": func():
			return anim_finished
	})
	
	EventManager.add_event(EventManager.QueueType.GAME, ev)
	ev = GameEvent.new({
		"paralel": false,
		"action": func():
			self.attack_complete.emit()
			return true
	})
	EventManager.add_event(EventManager.QueueType.GAME, ev)


func _perform_attack()->void:
	#pasa el atkInfo actual hacia el manager que le da a los enemigos
	#podria ser una señal emitida, y el combat controller se suscribe a esta señal de las units
	perform_attack.emit(actual_attacK_Info)
