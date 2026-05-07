extends SceneTree

var has_run := false

func _process(_delta: float) -> bool:
	if has_run:
		return true
	has_run = true
	var game_state = get_root().get_node_or_null("GameState")
	if game_state == null:
		_fail("GameState autoload not found")
		return true
	game_state.run_gold = 0
	game_state.add_run_gold(100)
	if game_state.run_gold != 100:
		_fail("Gold add failed")
		return true
	if not game_state.spend_run_gold(45) or game_state.run_gold != 55:
		_fail("Gold spend failed")
		return true
	if game_state.spend_run_gold(100):
		_fail("Overspend should fail")
		return true

	game_state.current_act = 1
	game_state.current_encounter_type = "normal"
	game_state.combat_turns_taken = 2
	game_state.current_reroll = 3
	game_state.current_healt = 80
	game_state.max_healt = 100
	if game_state.player_stats != null:
		game_state.player_stats.current_healt = 80
		game_state.player_stats.max_healt = 100
	game_state.combat_max_multiplier = 5.0
	game_state.combat_final_overkill = 6
	var reward: Dictionary = game_state.calculate_combat_gold_reward()
	if int(reward["total"]) != 11:
		_fail("Unexpected combat reward: " + str(reward))
		return true

	var ball_definition: BallDefinition = BallDefinition.new()
	ball_definition.ball_id = 9001
	ball_definition.display_name = "Economy Test Ball"
	ball_definition.base_damage = 1
	ball_definition.rarity_type = Constants.BALL_RARITY.RARITY_COMMON
	if game_state._price_for_ball(ball_definition) != 5:
		_fail("Unexpected common ball price")
		return true
	game_state.run_gold = 5
	game_state.owned_ball_deck.clear()
	game_state.draw_pile.clear()
	game_state.discard_pile.clear()
	game_state.current_ball_hand.clear()
	game_state.last_shop_offers.clear()
	game_state.last_shop_offers.append({
		"type": game_state.SHOP_ITEM_TYPE_BALL,
		"item": ball_definition,
		"price": 5,
		"sold": false,
	})
	if not game_state.buy_shop_offer(0):
		_fail("Shop ball purchase failed")
		return true
	if game_state.run_gold != 0 or game_state.owned_ball_deck.size() != 1 or not bool(game_state.last_shop_offers[0]["sold"]):
		_fail("Shop ball purchase did not update state")
		return true

	var trinket = load("res://features/trinkets/definition/common/trinket_201_red_thread_definition.tres")
	game_state.run_gold = 59
	game_state.last_shop_offers.clear()
	game_state.last_shop_offers.append({
		"type": game_state.SHOP_ITEM_TYPE_TRINKET,
		"item": trinket,
		"price": 60,
		"sold": false,
	})
	if game_state.buy_shop_offer(0):
		_fail("Unaffordable trinket purchase should fail")
		return true

	game_state.run_gold = 5
	game_state.current_healt = 50
	game_state.max_healt = 100
	game_state.run_potion_bought = false
	if game_state.player_stats != null:
		game_state.player_stats.current_healt = 50
		game_state.player_stats.max_healt = 100
	game_state.last_shop_offers.clear()
	game_state.last_shop_offers.append({
		"type": game_state.SHOP_ITEM_TYPE_POTION,
		"item": null,
		"price": game_state.SHOP_POTION_PRICE,
		"sold": false,
	})
	if not game_state.buy_shop_offer(0):
		_fail("Potion purchase failed")
		return true
	if game_state.run_gold != 0 or game_state.current_healt != 75 or not game_state.run_potion_bought:
		_fail("Potion purchase did not update state")
		return true
	game_state.run_gold = 5
	game_state.last_shop_offers.clear()
	game_state.last_shop_offers.append({
		"type": game_state.SHOP_ITEM_TYPE_POTION,
		"item": null,
		"price": game_state.SHOP_POTION_PRICE,
		"sold": false,
	})
	if game_state.buy_shop_offer(0) or game_state.run_gold != 5:
		_fail("Second potion purchase should fail without spending")
		return true

	if game_state.get_shop_reroll_cost() != 10:
		_fail("Unexpected first reroll cost")
		return true
	game_state.run_gold = 20
	game_state.shop_reroll_count = 0
	if not game_state.reroll_shop_offers():
		_fail("First shop reroll should be available")
		return true
	if game_state.run_gold != 10:
		_fail("First shop reroll did not spend expected gold")
		return true
	if game_state.get_shop_reroll_cost() != 15:
		_fail("Second shop reroll cost should increase")
		return true
	game_state.run_gold = 15
	if not game_state.reroll_shop_offers():
		_fail("Second shop reroll should be available")
		return true
	if game_state.run_gold != 0:
		_fail("Second shop reroll did not spend expected gold")
		return true
	game_state.run_potion_bought = false
	game_state.generate_shop_offers()
	for offer in game_state.last_shop_offers:
		var offer_type := str(offer.get("type", ""))
		if offer_type != game_state.SHOP_ITEM_TYPE_BALL:
			_fail("Only balls should be generated in this shop")
			return true

	print("economy_shop_ok:", int(reward["total"]))
	quit(0)
	return true

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
