extends "res://features/items/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive06BlackRibbonEffect

func on_item_added() -> void:
	_connect_book_signal("bet_resolved", on_signal_triggered)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_resolved", on_signal_triggered)

func on_item_use(roulette_controller) -> void:
	if _is_black(roulette_controller):
		var game_state := _game_state()
		if game_state != null:
			game_state.add_run_shield(2)
