extends Node

@onready var combatStateMachine:  = $CombatStateMachine

@export var Player:UnitGroup 
@export var EnemyGroup:UnitGroup 

var combat_finished : bool = false

func _ready() -> void:
	var music_manager := get_node_or_null("/root/MusicManager")
	if music_manager != null:
		music_manager.call("play_combat_music")
	##iniciar nivel
	BookEventBus.battle_init.emit()
	combat_finished = false
	for player in Player.group:
		player.action_controller.perform_attack.connect(_on_perform_attack)
	for enemy in EnemyGroup.group:
		enemy.action_controller.perform_attack.connect(_on_perform_attack)
	
	#winner
	Player.defeat.connect(_defeat)
	EnemyGroup.defeat.connect(_victory)	
	
	GameState.apply_combat_snapshot(GameState.get_current_scene_path(), Player, EnemyGroup)
	if EnemyGroup.group.is_empty():
		_victory()
		return
	if Player.group.is_empty():
		_defeat()
		return
	GameState.save_combat_snapshot(GameState.get_current_scene_path(), Player, EnemyGroup)
	
	
	## Comenzar Turnos
	game_loop()

	
	
func game_loop() -> void:
	
	while(true):
		if combat_finished: break
		Player._begin_turn()
		await Player.turn_complete
		if combat_finished: break
		EnemyGroup._begin_turn()
		await EnemyGroup.turn_complete
	


func _on_perform_attack(attack_info : AttackInfo)->void:
	var actual_damage_dealt := 0

	if attack_info.bounce_hits > 0:
		actual_damage_dealt = _apply_bounce_attack(attack_info)
	elif attack_info.type == Constants.ATTACK_TYPE.ALL:
		for enemy in EnemyGroup.group.duplicate():
			actual_damage_dealt += _apply_damage_to_enemy(enemy, attack_info.damage)
	elif attack_info.type == Constants.ATTACK_TYPE.HALF:
		actual_damage_dealt = _apply_half_attack(attack_info)
	else:
		actual_damage_dealt = _apply_damage_to_enemy(attack_info.target, attack_info.damage)

	_apply_attack_status_effects(attack_info)
	_apply_attack_leech(attack_info, actual_damage_dealt)
	_apply_attack_bank_reward(attack_info)
	_apply_attack_self_damage(attack_info)
	await get_tree().create_timer(0.05).timeout
	if GameState.has_pending_roulette_attack(GameState.get_current_scene_path()):
		GameState.clear_pending_roulette_attack(false)
	GameState.save_combat_snapshot(GameState.get_current_scene_path(), Player, EnemyGroup)
	UiEventBus.apply_camera_shake.emit(.1,.5,15)
	UiEventBus.frame_freeze.emit(.1,.333)
	#debe chequear por tipo de ataque y dar su ataque y efecto o todo el atkinfo en si a las unidades correspondientes
	

func _apply_half_attack(attack_info: AttackInfo) -> int:
	if attack_info.target == null:
		return 0
	var actual_damage_dealt := 0
	var splash_targets := _get_adjacent_targets(attack_info.target)
	actual_damage_dealt += _apply_damage_to_enemy(attack_info.target, attack_info.damage)
	var splash_damage := int(floor(float(attack_info.damage) * attack_info.splash_percent))
	if splash_damage <= 0:
		return actual_damage_dealt
	for enemy in splash_targets:
		if enemy != null:
			actual_damage_dealt += _apply_damage_to_enemy(enemy, splash_damage)
	return actual_damage_dealt

func _get_adjacent_targets(target: Unit) -> Array[Unit]:
	var targets: Array[Unit] = []
	var target_index := EnemyGroup.group.find(target)
	if target_index == -1:
		return targets
	for neighbor_index in [target_index - 1, target_index + 1]:
		if neighbor_index >= 0 and neighbor_index < EnemyGroup.group.size():
			var enemy := EnemyGroup.group[neighbor_index]
			if enemy != null and enemy != target:
				targets.append(enemy)
	return targets

func _apply_bounce_attack(attack_info: AttackInfo) -> int:
	var targets := _get_bounce_targets(attack_info.target, attack_info.bounce_hits)
	var actual_damage_dealt := 0
	for enemy in targets:
		if enemy != null:
			actual_damage_dealt += _apply_damage_to_enemy(enemy, attack_info.damage)
	return actual_damage_dealt

func _get_bounce_targets(target: Unit, hit_count: int) -> Array[Unit]:
	var targets: Array[Unit] = []
	if hit_count <= 0 or EnemyGroup.group.is_empty():
		return targets
	var start_index := EnemyGroup.group.find(target)
	if start_index == -1:
		start_index = 0
	for i in range(hit_count):
		var enemy := EnemyGroup.group[(start_index + i) % EnemyGroup.group.size()]
		if enemy != null:
			targets.append(enemy)
	return targets

func _apply_attack_status_effects(attack_info: AttackInfo) -> void:
	if attack_info.target == null:
		return
	if attack_info.poison_damage > 0 and attack_info.poison_turns > 0:
		attack_info.target.apply_poison(attack_info.poison_damage, attack_info.poison_turns)
	if attack_info.mute_turns > 0:
		attack_info.target.apply_mute(attack_info.mute_turns)

func _apply_attack_leech(attack_info: AttackInfo, actual_damage_dealt: int) -> void:
	if attack_info.leech_percent <= 0.0 or actual_damage_dealt <= 0:
		return
	GameState.heal_player(int(ceil(float(actual_damage_dealt) * attack_info.leech_percent)))

func _apply_attack_bank_reward(attack_info: AttackInfo) -> void:
	if attack_info.bank_gold_reward <= 0:
		return
	GameState.economy_component.add_run_gold(attack_info.bank_gold_reward)

func _apply_attack_self_damage(attack_info: AttackInfo) -> void:
	if attack_info.self_damage <= 0 or attack_info.attacker == null:
		return
	attack_info.attacker._recieve_attack(attack_info.self_damage)

func _apply_damage_to_enemy(enemy: Unit, damage: int) -> int:
	if enemy == null or enemy.stats == null or damage <= 0:
		return 0
	var before_total := _remaining_effective_health(enemy)
	enemy._recieve_attack(damage)
	var after_total := _remaining_effective_health(enemy)
	return max(0, before_total - after_total)

func _remaining_effective_health(unit: Unit) -> int:
	if unit == null or unit.stats == null:
		return 0
	return max(0, unit.stats.current_healt) + max(0, unit.stats.shield)

func _victory()->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			combat_finished = true
			EnemyGroup.turn_complete.emit()
			#es mejor que esto sea un estado con una secuencia de sucesos particular
			UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.BookCaseState)
			UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.CASE)
			GameState.clear_combat_snapshot()
			BookEventBus.victory.emit()
			return true
	}))

func _defeat()->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			GameState.end_run()
			BookEventBus.defeat.emit()
			EventManager.call_deferred("clear_queue",EventManager.QueueType.GAME)
			combat_finished = true
			return true
	}),true)
