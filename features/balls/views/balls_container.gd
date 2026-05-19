extends Node3D


@onready var ball_spot : BallElement = $Ball_Spot
@onready var ball_spot_2 : BallElement = $Ball_Spot2



func _ready() -> void:
	reset_balls()
	recharge_balls()
	BookEventBus.player_turn.connect(recharge_balls)
	#PlayerUiEvents.spin_started.connect(_on_spin_started)

func get_not_used_ball()->BallRuntimeState:
	for ball_raw in GameState.balls_deck.all_balls:
		var ball = ball_raw as BallRuntimeState 
		
		if ball and not ball.used:
			ball.used = true
			return ball
	return null

func recharge_balls()->void:
	if !ball_spot.ball_data:
		ball_spot._assign_data_model(get_not_used_ball())
	if !ball_spot_2.ball_data:
		ball_spot_2._assign_data_model(get_not_used_ball())
	
	ball_spot.drop_active = true
	ball_spot_2.drop_active = true
	
	if !ball_spot.ball_data && !ball_spot_2.ball_data:
		reset_balls()
		ball_spot._assign_data_model(get_not_used_ball())
		ball_spot_2._assign_data_model(get_not_used_ball())


func _on_spin_started()->void:
	ball_spot.drop_active = false
	ball_spot_2.drop_active = false

func reset_balls()->void:
	GameState.balls_deck.shuffle_balls()

func get_mirror_source_for(ball_element: BallElement) -> BallDefinition:
	var source_element: BallElement = null
	if ball_element == ball_spot:
		source_element = ball_spot_2
	elif ball_element == ball_spot_2:
		source_element = ball_spot
	if source_element == null or source_element.ball_data == null:
		return null
	return source_element.ball_data.ball_definition
