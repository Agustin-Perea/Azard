extends "res://features/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive19VisionEffect

func on_item_added() -> void:
	_connect_book_signal("bet_resolved", on_signal_triggered)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_resolved", on_signal_triggered)

func on_item_use(roulette_controller) -> void:
	roulette_controller.add_multiplier(0.25)
