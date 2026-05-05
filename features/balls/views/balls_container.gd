extends Node3D


@onready var ball_spot : BallElement = $Ball_Spot
@onready var ball_spot_2 : BallElement = $Ball_Spot2



func _ready() -> void:
	reset_balls()
	recharge_balls()
	BookEventBus.player_turn.connect(recharge_balls)
	BookEventBus.player_turn_started.connect(recharge_balls)
	#PlayerUiEvents.spin_started.connect(_on_spin_started)

func get_not_used_ball()->BallRuntimeState:
	return null

func recharge_balls()->void:
	GameState.refill_ball_hand(_slot_count())
	ball_spot.drop_active = true
	ball_spot_2.drop_active = true


func _on_spin_started()->void:
	ball_spot.drop_active = false
	ball_spot_2.drop_active = false

func reset_balls()->void:
	GameState.ensure_ball_run_ready(_slot_count())

func _slot_count() -> int:
	var count := 0
	for child in get_children():
		if child is BallElement:
			count += 1
	return max(count, GameState.DEFAULT_BALL_HAND_SIZE)
