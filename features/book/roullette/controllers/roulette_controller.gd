extends Node
class_name RouletteController

var rng := RandomNumberGenerator.new()
var score: float = 0

signal numberChanged
signal baseChanged
signal multiplicatorChanged(float)
signal totalChanged
@warning_ignore("unused_signal")
signal betResolved

var base: float = 1
var multiplier: float = 1
var number_winner: int
var winner_betfield_model: BetFieldModel
var result_field_id: int = 0
var last_winning_bet_entries: Array[Dictionary] = []
var last_ball_used: BallRuntimeState = null
var resolution_in_progress := false
var resolution_ready := false

@onready var roulette_control: RouletteControl = $left_cover
@onready var table_meshes: TableFieldsController = $right_cover/BetTable
@onready var ball_mesh: MeshInstance3D = $left_cover/roulette_ball
@onready var finish_button: SB_Button3D = $left_cover/FinishMoveButton

func _ready() -> void:
	BookEventBus.start_spin.connect(on_start_spin)
	rng.randomize()

func update_base_score(new_base: int) -> void:
	_queue_score_event(func():
		base = new_base
		baseChanged.emit()
	)

func multiply_mult_score(mult_factor: float) -> void:
	_queue_score_event(func():
		multiplier *= mult_factor
		multiplicatorChanged.emit(mult_factor)
	)

func add_multiplier(mult: float) -> void:
	_queue_score_event(func():
		multiplier += mult
		multiplicatorChanged.emit(mult)
	)

func add_base(base_added: float) -> void:
	_queue_score_event(func():
		base += base_added
		baseChanged.emit()
	)

func changeScore() -> void:
	_queue_score_event(func():
		score = int(round(base)) * int(round(multiplier))
		totalChanged.emit()
	)

func reset_score() -> void:
	resolution_ready = false
	last_winning_bet_entries.clear()
	_queue_score_event(func():
		score = 0
		multiplier = 1
		base = 1
		baseChanged.emit()
		multiplicatorChanged.emit(0)
		totalChanged.emit()
	)

func is_resolution_ready() -> bool:
	return resolution_ready

func get_final_score() -> int:
	return int(round(score))

func on_start_spin(ball: BallRuntimeState) -> void:
	if ball == null or ball.ball_definition == null:
		push_error("on_start_spin received an invalid ball runtime state")
		return

	last_ball_used = ball
	resolution_in_progress = true
	resolution_ready = false
	BookEventBus.spin_started.emit()
	reset_score()

	var resolved_damage := ball.ball_definition.get_damage_for_level(ball.level_upgrade)
	add_base(resolved_damage)
	if ball.ball_definition.ball_material:
		ball_mesh.material_override = ball.ball_definition.ball_material

	UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.RoulleteSpin)
	UiEventBus.change_collision_detection.emit(true)

	result_field_id = _random_result_field_id()
	winner_betfield_model = GameState.get_bet_field_model(result_field_id)
	if winner_betfield_model == null:
		push_error("Could not resolve roulette result field: " + str(result_field_id))
		UiEventBus.change_collision_detection.emit(false)
		resolution_in_progress = false
		return

	number_winner = winner_betfield_model.number
	roulette_control.spin(number_winner)
	_queue_game_event(func():
		numberChanged.emit()
		return true
	)

	await roulette_control.spin_finished
	BookEventBus.spin_finished.emit()
	table_meshes.activate_highlight_field(result_field_id)

	_queue_game_event(func():
		UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.BetResolve)
		return true
	)

	await get_tree().create_timer(1).timeout
	_resolve_bets(result_field_id)
	await _wait_for_game_queue()

	BookEventBus.bet_post_resolved.emit(self)
	if ball.ball_definition.ball_effect != null:
		ball.ball_definition.ball_effect.set_meta("runtime_level", ball.level_upgrade)
		ball.ball_definition.ball_effect.set_meta("runtime_ball_id", ball.ball_definition.ball_id)
		ball.ball_definition.ball_effect.on_post_resolved(self)

	changeScore()
	_queue_cleanup_after_resolution()
	_queue_resolution_completed()

func spin() -> void:
	if last_ball_used != null:
		on_start_spin(last_ball_used)

func _max_result_field_id() -> int:
	var result_ids := _result_field_ids()
	if result_ids.is_empty():
		return 36
	return int(result_ids.back())

func _random_result_field_id() -> int:
	var result_ids := _result_field_ids()
	if result_ids.is_empty():
		return rng.randi_range(0, 36)
	return int(result_ids[rng.randi_range(0, result_ids.size() - 1)])

func _result_field_ids() -> Array[int]:
	var ids: Array[int] = []
	for field_id in range(GameState.bet_field_models.size()):
		var field := GameState.get_bet_field_model(field_id)
		if field != null and field.ConditionStrategy is StraightUpCondition:
			ids.append(field_id)
	return ids

@warning_ignore("shadowed_variable")
func _resolve_bets(result_field_id: int) -> float:
	var winner_model := GameState.get_bet_field_model(result_field_id) as BetFieldModel
	if winner_model == null:
		push_error("Cannot resolve bets for invalid result field: " + str(result_field_id))
		return multiplier

	last_winning_bet_entries.clear()
	var active_bets := GameState.get_Bets() as Dictionary[int, Array]

	winner_model.activateHighlight.emit()
	BookEventBus.bet_pre_resolve.emit(self)

	var count := 0
	for field_id in active_bets:
		var field := GameState.get_bet_field_model(field_id) as BetFieldModel
		if field == null or field.ConditionStrategy == null:
			continue

		var chip_stack: Array = active_bets[field_id]
		if chip_stack.is_empty() or not field.ConditionStrategy.matches(winner_model, field):
			continue

		for i in range(chip_stack.size()):
			_queue_bet_multiplier(field_id, field, field.multiplier)

		last_winning_bet_entries.append({
			"field_id": field_id,
			"field": field,
			"chip_count": chip_stack.size(),
			"field_multiplier": field.multiplier,
		})

		BookEventBus.bet_resolved.emit(self)
		count += 1

	return multiplier

func reroll() -> void:
	if last_ball_used == null:
		return
	if not GameState.consume_reroll():
		return

	BookEventBus.reroll_used.emit(self)
	on_start_spin(last_ball_used)

func _queue_bet_multiplier(field_id: int, field: BetFieldModel, mult: float) -> void:
	_queue_game_event(func():
		multiplier += mult
		multiplicatorChanged.emit(mult)
		table_meshes.call_mult_anim(field_id)
		field.call_betfield_animation.emit()
		return true
	)

func _queue_score_event(action: Callable) -> void:
	_queue_game_event(func():
		action.call()
		return true
	)

func _queue_game_event(action: Callable, paralel: bool = false, blocking: bool = true, in_front: bool = false) -> void:
	EventManager.add_event(EventManager.QueueType.GAME, GameEvent.new({
		"paralel": paralel,
		"blocking": blocking,
		"action": action,
	}), in_front)

func _queue_cleanup_after_resolution() -> void:
	_queue_game_event(func():
		table_meshes.deactivate_highlight_field()
		UiEventBus.change_collision_detection.emit(false)
		return true
	)

func _queue_resolution_completed() -> void:
	_queue_game_event(func():
		resolution_in_progress = false
		resolution_ready = true
		BookEventBus.roulette_resolution_completed.emit(self, get_final_score(), last_ball_used)
		return true
	)

func _wait_for_game_queue() -> void:
	var marker := {"done": false}
	_queue_game_event(func():
		marker["done"] = true
		return true
	)
	while not bool(marker["done"]):
		await get_tree().physics_frame
