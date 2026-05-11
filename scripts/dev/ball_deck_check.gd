extends SceneTree

const GameStateScript := preload("res://scripts/autoload/GameState.gd")
const BallDefinitionScript := preload("res://features/balls/definition/ball_definition.gd")

func _init() -> void:
	var game_state = GameStateScript.new()
	game_state.ball_rng.randomize()
	for ball_id in [1, 2, 6]:
		var definition: BallDefinition = _make_ball_definition(ball_id)
		game_state.ball_definition_cache[ball_id] = definition
		game_state.add_ball_to_deck(definition, false)
	game_state.refill_ball_hand(2)
	if game_state.owned_ball_deck.size() != 3:
		push_error("Starter deck size mismatch: " + str(game_state.owned_ball_deck.size()))
		quit(1)
		return
	if game_state.current_ball_hand.size() != 2:
		push_error("Starter hand size mismatch: " + str(game_state.current_ball_hand.size()))
		quit(1)
		return
	if game_state.get_hand_ball(0) == null or game_state.get_hand_ball(1) == null:
		push_error("Starter hand has empty slots.")
		quit(1)
		return

	var spent := game_state.spend_hand_ball(0)
	if spent == null or game_state.get_hand_ball(0) != null or game_state.discard_pile.size() != 1:
		push_error("Spending a ball did not move it to discard.")
		quit(1)
		return

	game_state.refill_ball_hand(2)
	if game_state.get_hand_ball(0) == null:
		push_error("Refill did not replace the empty hand slot.")
		quit(1)
		return

	game_state.spend_hand_ball(0)
	game_state.spend_hand_ball(1)
	game_state.refill_ball_hand(2)
	if game_state.get_hand_ball(0) == null or game_state.get_hand_ball(1) == null:
		push_error("Discard recycle did not refill the hand.")
		quit(1)
		return

	var rewards := game_state.generate_ball_reward_options(3)
	if rewards.size() != 3:
		push_error("Reward offer size mismatch: " + str(rewards.size()))
		quit(1)
		return
	for reward in rewards:
		if not (reward is BallDefinition):
			push_error("Reward offer contains a non-ball definition.")
			quit(1)
			return

	print("ball_deck_ok:", game_state.owned_ball_deck.size())
	quit(0)

func _make_ball_definition(ball_id: int) -> BallDefinition:
	var definition: BallDefinition = BallDefinitionScript.new()
	definition.ball_id = ball_id
	definition.display_name = "TestBall%d" % ball_id
	definition.description = "Deck test ball."
	definition.pool_weight = 100 + ball_id
	definition.base_damage = 1
	return definition
