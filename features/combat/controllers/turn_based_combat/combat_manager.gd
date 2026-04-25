extends Node

@onready var combatStateMachine:  = $CombatStateMachine

@export var Player:UnitGroup 
@export var EnemyGroup:UnitGroup 

var combat_finished : bool = false

func _ready() -> void:
	##iniciar nivel
	
	combat_finished = false
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
		Player._begin_turn()
		await Player.turn_complete
		if combat_finished: break
		EnemyGroup._begin_turn()
		await EnemyGroup.turn_complete
	print("combate terminado")
	


func _on_perform_attack(attack_info : AttackInfo)->void:
	UiEventBus.apply_camera_shake.emit(.1,.5,15)
	UiEventBus.frame_freeze.emit(.1,.333)
	
	
	attack_info.target._recieve_attack(attack_info.damage)
	#debe chequear por tipo de ataque y dar su ataque y efecto o todo el atkinfo en si a las unidades correspondientes
	


func _victory()->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			combat_finished = true
			EnemyGroup.turn_complete.emit()
			#es mejor que esto sea un estado con una secuencia de sucesos particular
			#CombatEventBus.changeToState.emit("Victory")
			#PlayerUiEvents.disable_book.emit()
			print("victory")
			return true
	}))

func _defeat()->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			EventManager.call_deferred("clear_queue",EventManager.QueueType.GAME)
			combat_finished = true
			return true
	}),true)
