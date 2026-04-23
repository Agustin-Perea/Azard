extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket216ZeroSealEffect

func on_item_added() -> void:
	_connect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_use(roulette_controller) -> void:
	for entry in _winning_entries(roulette_controller):
		if _is_zero_family(entry["field"]):
			roulette_controller.add_multiplier(2.0)
			var game_state := _game_state()
			if game_state != null:
				game_state.add_run_gold(6)
			return
