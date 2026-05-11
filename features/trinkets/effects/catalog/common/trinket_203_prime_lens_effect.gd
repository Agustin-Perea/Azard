extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket203PrimeLensEffect

func on_item_added() -> void:
	_connect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_use(roulette_controller) -> void:
	var count := 0
	for entry in _winning_entries(roulette_controller):
		if _is_prime_field(entry["field"]):
			count += int(entry["chip_count"])
	if count > 0:
		roulette_controller.add_base(count)
		roulette_controller.add_multiplier(0.10 * count)
