extends Node



@onready var dialogue_box : DialogueBox = $Control
@onready var combat_manager :  CombatManager = $"../BattleManager/CombatGroups"
@onready var boss_unit :  Unit = $"../BattleManager/CombatGroups/EnemyGroup/EnemyEntity"

@export var camera :  Camera3D 

func _ready() -> void:
	MusicManager.play_music(Constants.MUSIC_EVENT)
	dialogue_box.dialogue_finished.connect(on_dialogue_finished)
	UiEventBus.deactivate_descriptions.emit()
	combat_manager.boss_defeated.connect(on_boss_defeated)

func on_dialogue_finished()->void:
	dialogue_box.visible = false
	combat_manager.paused = false
	
	UiEventBus.changeCamera.emit(camera,1)
	boss_unit.animation_state_machine.travel("init")
	boss_unit.anim_finished = false
	var ev = GameEvent.new({
		"paralel": false,
		"action": func():
			return boss_unit.anim_finished
	})
	EventManager.add_event(EventManager.QueueType.GAME, ev)
	
	ev = GameEvent.new({
		"paralel": false,
		"action": func():
			combat_manager.game_loop()
			return true
	})
	EventManager.add_event(EventManager.QueueType.GAME, ev)


func on_boss_defeated()->void:
	await get_tree().create_timer(0.5).timeout
	UiEventBus.change_scene_to.emit("res://scenes/combat/FinishGame_scene.tscn")
	print("termino we")
