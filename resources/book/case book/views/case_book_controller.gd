extends Node3D


@onready var ball_spot :  = $left_cover/Ball_Spot
@onready var ball_spot_2 : BallElement = $left_cover/Ball_Spot2
@onready var ball_spot_3 : BallElement = $left_cover/Ball_Spot3

@onready var bingo_chip_spot : BingoChipElement = $left_cover/Bingo_Chip_Spot
@onready var bingo_chip_spot_2 : BingoChipElement = $left_cover/Bingo_Chip_Spot2
@onready var bingo_chip_spot_3 : BingoChipElement = $left_cover/Bingo_Chip_Spot3
#
@onready var reroll_button : SB_Button3D = $left_cover/SB_Button3D
@onready var map_button : SB_Button3D = $left_cover/Next_SB_Button3D

@onready var ball_description_canvas : BallDescription =  $left_cover/BallDescription
#@onready var bingo_chip_info : BingoChipinfo =  $bingo_chip_info


#test reset
@warning_ignore("unused_parameter")
func _on_clickable_area_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:

		await get_tree().process_frame
		#CombatEventBus.reload.emit() esto se debe usar en defeat
		#TransitionLayer._change_scente_to(Constants.TEST_SCENE)
		#get_tree().call_deferred("reload_current_scene")


func _ready() -> void:
	reroll_button.pressed.connect(reroll)
	map_button.pressed.connect(on_map_button_pressed)
	reroll()


func reroll() -> void:
	#pool bolas

	ball_spot._assign_data_model(GameState.object_pool_database.ball_pool_definition.get_random_ball())
	ball_spot_2._assign_data_model(GameState.object_pool_database.ball_pool_definition.get_random_ball())
	ball_spot_3._assign_data_model(GameState.object_pool_database.ball_pool_definition.get_random_ball())
	#pool bingo_chips
	bingo_chip_spot.assign_data_model(GameState.object_pool_database.bingo_chips_constructor.get_random_bet_field_model()) 
	bingo_chip_spot_2.assign_data_model(GameState.object_pool_database.bingo_chips_constructor.get_random_bet_field_model()) 
	bingo_chip_spot_3.assign_data_model(GameState.object_pool_database.bingo_chips_constructor.get_random_bet_field_model()) 

	UiEventBus.deactivate_descriptions.emit()


func on_map_button_pressed()->void:
	#PlayerUiEvents.change_book_page.emit(Constants.BOOK_PAGE.MAP)
	#preload()
	GameState.temp_scene_changed_value +=1
	get_tree().call_deferred("change_scene_to_file","res://scenes/combat/battle_scene_1.tscn")
	
