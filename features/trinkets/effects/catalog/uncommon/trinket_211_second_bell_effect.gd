extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket211SecondBellEffect

func on_item_added() -> void:
	_connect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_use(roulette_controller) -> void:
	var seen := 0
	for entry in _winning_entries(roulette_controller):
		var chip_count := int(entry["chip_count"])
		if seen < 2 and seen + chip_count >= 2:
			roulette_controller.add_base(2)
			roulette_controller.add_multiplier(0.15)
			return
		seen += chip_count
