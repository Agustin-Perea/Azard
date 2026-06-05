extends ActionController
class_name PlayerActionController

@onready var attack_camera : Camera3D = $"../ModelVisualComponent/CameraPlayer/CameraPlayer-camera"

@onready var roulette_controller : RouletteController = $"../Books/Book"

func _ready() -> void:
	super()
	roulette_controller.finish_button.pressed.connect(_do_attacK)
	next_attacK_Info = AttackInfo.new()
	next_attacK_Info.attacker = $".."

	#CombatEventBus.unit_death.connect(get_target)
	
	BookEventBus.change_target.connect(on_change_target)
	
func perform_movement() -> void:
	UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.EnemySelection)
	UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.NONE)
	UiEventBus.activate_status_view_component.emit()
	BookEventBus.player_turn.emit()
	if target:
		on_change_target(target)
	else:
		get_target()
		on_change_target(target)
	
	#reset del attack info y la ruleta y su visual
	
	roulette_controller.reset_score()


func on_change_target(new_target : Unit):
	if target:
		target.model_visual_component.toggle_mi_stand(false)

	target = new_target
	if new_target:
		target.model_visual_component.toggle_mi_stand(true)

func _do_attacK()->void:
	#cambiar de estado
	#cerrar libro y cambiarlo a placeholder(quitar visibilidad)
	UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.NONE)
	target.model_visual_component.toggle_mi_stand(false)
	
	#espera a que termine la animacion
	var ev = GameEvent.new({
		"paralel": false,
		"action": func():
			if target:
				# Orientamos el personaje hacia el objetivo
				# Usamos global_position para evitar problemas con la jerarquía
				attacker.look_at(target.global_position, Vector3.UP,true)
				#target.shaders._deactivate_selection_aura()
				
				# Opcional: Bloquear la rotación en el eje X para que no se incline hacia arriba/abajo
				attacker.rotation.x = 0 
				attacker.rotation.z = 0
				next_attacK_Info.target = target
				next_attacK_Info.damage = roulette_controller.score
				BookEventBus.attack_damage.emit(roulette_controller.score)
				
				next_attacK_Info.type = roulette_controller.last_ball_used.ball_definition.attack_type
			
			attack_beginning.emit()
			return true
	})
	EventManager.add_event(EventManager.QueueType.GAME, ev)
	#inicio de animacion de ataque
	ev = GameEvent.new({
		"paralel": false,
		"action": func():
			UiEventBus.deactivate_status_view_component.emit()
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
	
	#es mejor usar un tween
	EventManager.add_event(EventManager.QueueType.GAME, ev)
	#espera a que termine la animacion
	ev = GameEvent.new({
		"paralel": false,
		"action": func():
			attacker.rotation = Vector3.ZERO
			return true
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
	perform_attack.emit(next_attacK_Info)
