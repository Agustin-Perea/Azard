extends Node3D

const BALL_SPOT_SCENE := preload("res://features/balls/views/ball_spot.tscn")
const EXTRA_SLOT_OFFSET := Vector3(0, 0, 0.3324633)

@onready var ball_spot : BallElement = $Ball_Spot
@onready var ball_spot_2 : BallElement = $Ball_Spot2

var ball_spots: Array[BallElement] = []


func _ready() -> void:
	ball_spots = [ball_spot, ball_spot_2]
	UiEventBus.ball_slots_changed.connect(_on_ball_slots_changed)
	_setup_ball_slots(GameState.get_ball_slot_count())
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
	for spot: BallElement in ball_spots:
		if !spot.ball_data:
			spot._assign_data_model(get_not_used_ball())
		spot.drop_active = true
	
	if _all_ball_spots_empty():
		reset_balls()
		for spot: BallElement in ball_spots:
			spot._assign_data_model(get_not_used_ball())


func _on_spin_started()->void:
	for spot: BallElement in ball_spots:
		spot.drop_active = false

func reset_balls()->void:
	GameState.balls_deck.shuffle_balls()

func get_mirror_source_for(ball_element: BallElement) -> BallDefinition:
	for source_element: BallElement in ball_spots:
		if source_element != ball_element and source_element.ball_data != null:
			return source_element.ball_data.ball_definition
	return null

func _on_ball_slots_changed(slot_count: int) -> void:
	_setup_ball_slots(slot_count)
	recharge_balls()

func _setup_ball_slots(slot_count: int) -> void:
	var target_count: int = max(2, slot_count)
	while ball_spots.size() < target_count:
		var new_spot := BALL_SPOT_SCENE.instantiate() as BallElement
		add_child(new_spot)
		new_spot.name = "Ball_Spot" + str(ball_spots.size() + 1)
		var previous_spot := ball_spots[ball_spots.size() - 1]
		new_spot.position = previous_spot.position + EXTRA_SLOT_OFFSET
		ball_spots.append(new_spot)
	for i in range(ball_spots.size()):
		var enabled := i < target_count
		if enabled:
			ball_spots[i].activate()
		else:
			ball_spots[i]._assign_data_model(null)

func _all_ball_spots_empty() -> bool:
	for spot: BallElement in ball_spots:
		if spot.ball_data:
			return false
	return true
