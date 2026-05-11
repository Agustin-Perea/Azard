extends Node

@onready var combatStateMachine:  = $CombatStateMachine

@export var Player:UnitGroup 
@export var EnemyGroup:UnitGroup 

var combat_finished : bool = false
var combat_final_overkill: int = 0
var combat_turns_taken: int = 0
var combat_damage_dealt: int = 0
var combat_damage_received: int = 0

func _ready() -> void:
	##iniciar nivel
	
	combat_finished = false
	_reset_combat_stats()
	for player in Player.group:
		player.action_controller.perform_attack.connect(_on_perform_attack)
	for enemy in EnemyGroup.group:
		enemy.action_controller.perform_attack.connect(_on_perform_attack)
	
	#winner
	Player.defeat.connect(_defeat)
	EnemyGroup.defeat.connect(_victory)	
	
	
	
	## Comenzar Turnos
	game_loop()

	
	
func game_loop() -> void:
	
	while(true):
		if combat_finished: break
		_record_player_turn()
		Player._begin_turn()
		await Player.turn_complete
		if combat_finished: break
		EnemyGroup._begin_turn()
		await EnemyGroup.turn_complete
	print("combate terminado")
	


func _on_perform_attack(attack_info : AttackInfo)->void:

	var target_health_before := _get_target_health(attack_info)
	attack_info.target._recieve_attack(attack_info.damage)
	var target_health_after := _get_target_health(attack_info)
	_record_combat_damage(attack_info, target_health_before, target_health_after)
	
	await get_tree().create_timer(0.05).timeout
	UiEventBus.apply_camera_shake.emit(.1,.5,15)
	UiEventBus.frame_freeze.emit(.1,.333)
	#debe chequear por tipo de ataque y dar su ataque y efecto o todo el atkinfo en si a las unidades correspondientes
	
func _get_target_health(attack_info: AttackInfo) -> int:
	if attack_info == null or attack_info.target == null or attack_info.target.stats == null:
		return 0
	return attack_info.target.stats.current_healt

func _record_combat_damage(attack_info: AttackInfo, target_health_before: int, target_health_after: int) -> void:
	if attack_info == null or attack_info.attacker == null:
		return
	var damage_amount: int = int(max(0, int(attack_info.damage)))
	if attack_info.attacker.is_in_group("player"):
		var overkill: int = int(max(0, max(-target_health_after, damage_amount - max(0, target_health_before))))
		_record_damage_dealt(damage_amount, overkill)
	elif attack_info.attacker.is_in_group("enemy"):
		_record_damage_received(damage_amount)

func _reset_combat_stats() -> void:
	combat_final_overkill = 0
	combat_turns_taken = 0
	combat_damage_dealt = 0
	combat_damage_received = 0

func _record_player_turn() -> void:
	combat_turns_taken += 1

func _record_damage_dealt(amount: int, overkill: int = 0) -> void:
	combat_damage_dealt += max(0, amount)
	combat_final_overkill = max(combat_final_overkill, max(0, overkill))

func _record_damage_received(amount: int) -> void:
	combat_damage_received += max(0, amount)

func _build_combat_stats() -> Dictionary:
	return {
		"turns_taken": combat_turns_taken,
		"damage_dealt": combat_damage_dealt,
		"damage_received": combat_damage_received,
		"player_health": _player_health_snapshot(),
		"rerolls_remaining": GameState.current_reroll,
		"max_rerolls": GameState.max_reroll,
		"overkill": combat_final_overkill,
	}

func _player_health_snapshot() -> Dictionary:
	if GameState.player_stats == null:
		return {
			"current": 0,
			"max": 0,
		}
	return {
		"current": GameState.player_stats.current_healt,
		"max": GameState.player_stats.max_healt,
	}


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
			GameState.economy_component.grant_combat_victory_gold(_build_combat_stats())
			BookEventBus.victory.emit()
			print("victory")
			return true
	}))

func _defeat()->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			print("defeat")
			#BookEventBus.defeat.emit()
			EventManager.call_deferred("clear_queue",EventManager.QueueType.GAME)
			combat_finished = true
			return true
	}),true)
