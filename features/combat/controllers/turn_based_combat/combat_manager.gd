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
	print("combate terminado")
	


func _on_perform_attack(attack_info : AttackInfo)->void:

	if attack_info.type == Constants.ATTACK_TYPE.ALL:
		for enemy in EnemyGroup.group.duplicate():
			enemy._recieve_attack(attack_info.damage)
	else:
		attack_info.target._recieve_attack(attack_info.damage)

	await get_tree().create_timer(0.05).timeout
	if GameState.has_pending_roulette_attack(GameState.get_current_scene_path()):
		GameState.clear_pending_roulette_attack(false)
	GameState.save_combat_snapshot(GameState.get_current_scene_path(), Player, EnemyGroup)
	UiEventBus.apply_camera_shake.emit(.1,.5,15)
	UiEventBus.frame_freeze.emit(.1,.333)
	#debe chequear por tipo de ataque y dar su ataque y efecto o todo el atkinfo en si a las unidades correspondientes
	


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
			print("victory")
			return true
	}))

func _defeat()->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			print("defeat")
			GameState.end_run()
			BookEventBus.defeat.emit()
			EventManager.call_deferred("clear_queue",EventManager.QueueType.GAME)
			combat_finished = true
			return true
	}),true)
