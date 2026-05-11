extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket224HighRollerCrestEffect

func on_item_added() -> void:
	_connect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_use(roulette_controller) -> void:
	if _resolution_special_condition_count(roulette_controller) >= 3:
		roulette_controller.add_multiplier(1.5)
		var game_state := _game_state()
		if game_state != null:
			game_state.add_run_gold(8)
