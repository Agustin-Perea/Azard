extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket220PrismRingEffect

func on_item_added() -> void:
	_connect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_use(roulette_controller) -> void:
	for entry in _winning_entries(roulette_controller):
		var field := entry["field"] as BetFieldModel
		if (_is_red_field(field) or _is_black_field(field)) and (_is_prime_field(field) or _is_golden_field(field)):
			roulette_controller.add_multiplier(0.80)
			return
