extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket214SplitNeedleEffect

func on_item_added() -> void:
	_connect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_use(roulette_controller) -> void:
	var distinct_fields: Dictionary = {}
	for entry in _winning_entries(roulette_controller):
		distinct_fields[entry["field_id"]] = true
	if distinct_fields.size() >= 2:
		roulette_controller.add_multiplier(0.25)
