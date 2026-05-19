extends ActionController
class_name PlayerActionController

@onready var attack_camera : Camera3D = $"../ModelVisualComponent/CameraPlayer/CameraPlayer-camera"

@onready var roulette_controller : RouletteController = $"../Books/Book"

var lethal_preview_target: Unit = null

func _ready() -> void:
	super()
	roulette_controller.finish_button.pressed.connect(_do_attacK)
	roulette_controller.totalChanged.connect(_refresh_lethal_preview)
	actual_attacK_Info = AttackInfo.new()
	actual_attacK_Info.attacker = $".."
	
	
	UiEventBus.change_target.connect(on_change_target)
	#CombatEventBus.unit_death.connect(get_target)
	
	
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
	_apply_pending_target_if_needed()
	_update_roulette_attack_context()
	if not GameState.has_pending_roulette_attack(GameState.get_current_scene_path()):
		roulette_controller.reset_score()
	_refresh_lethal_preview()


func on_change_target(new_target : Unit):
	#if target:
		#target.shaders._deactivate_selection_aura()

	target = new_target
	_update_roulette_attack_context()
	_refresh_lethal_preview()
	#if new_target:
		#target.shaders._activate_selection_aura()

func _do_attacK()->void:
	_apply_pending_target_if_needed()
	_update_roulette_attack_context()
	#cambiar de estado
	#cerrar libro y cambiarlo a placeholder(quitar visibilidad)
	UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.NONE)

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
				actual_attacK_Info.target = target
				actual_attacK_Info.damage = int(round(roulette_controller.score))
				
				actual_attacK_Info.type = roulette_controller.last_ball_used.ball_definition.attack_type
				actual_attacK_Info.splash_percent = float(roulette_controller.get_attack_modifier(&"splash_percent", 0.0))
				actual_attacK_Info.poison_damage = int(roulette_controller.get_attack_modifier(&"poison_damage", 0))
				actual_attacK_Info.poison_turns = int(roulette_controller.get_attack_modifier(&"poison_turns", 0))
			
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
	perform_attack.emit(actual_attacK_Info)

func _update_roulette_attack_context() -> void:
	if roulette_controller == null:
		return
	var target_name := ""
	if target != null:
		target_name = target.name
	roulette_controller.set_attack_context(attacker.name, target_name)

func _apply_pending_target_if_needed() -> void:
	var pending := GameState.get_pending_roulette_attack(GameState.get_current_scene_path())
	if pending.is_empty():
		return
	var pending_target_name := str(pending.get("target_name", ""))
	if pending_target_name == "":
		return
	var restored_target := _find_enemy_by_name(pending_target_name)
	if restored_target != null:
		on_change_target(restored_target)

func _find_enemy_by_name(unit_name: String) -> Unit:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy is Unit and enemy.name == unit_name:
			return enemy as Unit
	return null

func _refresh_lethal_preview() -> void:
	var damage := int(round(roulette_controller.score))
	var active := _is_attack_lethal(damage)
	if lethal_preview_target != null and lethal_preview_target != target and lethal_preview_target.status_view_component != null:
		lethal_preview_target.status_view_component.set_lethal_preview(false)
	if _is_current_attack_all_enemies():
		for enemy in get_tree().get_nodes_in_group("enemy"):
			if enemy is Unit and enemy.status_view_component != null:
				enemy.status_view_component.set_lethal_preview(active and _unit_would_die(enemy as Unit, damage))
		lethal_preview_target = null
	elif target != null and target.stats != null and damage > 0:
		if target.status_view_component != null:
			target.status_view_component.set_lethal_preview(active)
		lethal_preview_target = target
	elif lethal_preview_target != null and lethal_preview_target.status_view_component != null:
		lethal_preview_target.status_view_component.set_lethal_preview(false)
		lethal_preview_target = null
	BookEventBus.lethal_preview_changed.emit(active)

func _is_attack_lethal(damage: int) -> bool:
	if damage <= 0:
		return false
	if _is_current_attack_all_enemies():
		var enemies := get_tree().get_nodes_in_group("enemy")
		if enemies.is_empty():
			return false
		for enemy in enemies:
			if enemy is Unit and _unit_would_die(enemy as Unit, damage):
				return true
		return false
	if target == null:
		return false
	return _unit_would_die(target, damage)

func _is_current_attack_all_enemies() -> bool:
	return roulette_controller.last_ball_used != null \
		and roulette_controller.last_ball_used.ball_definition != null \
		and roulette_controller.last_ball_used.ball_definition.attack_type == Constants.ATTACK_TYPE.ALL

func _unit_would_die(unit: Unit, damage: int) -> bool:
	return unit != null and unit.stats != null and damage >= unit.stats.current_healt + unit.stats.shield
