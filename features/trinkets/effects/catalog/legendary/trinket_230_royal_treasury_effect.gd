extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket230RoyalTreasuryEffect

func on_item_added() -> void:
	_connect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_use(roulette_controller) -> void:
	if roulette_controller.multiplier > 10.0:
		var game_state := _game_state()
		if game_state != null:
			game_state.add_run_gold(15)
			game_state.set_max_reroll(game_state.max_reroll + 1)
