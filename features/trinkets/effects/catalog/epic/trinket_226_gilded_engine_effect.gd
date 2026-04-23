extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket226GildedEngineEffect

var combat_bonus := 0.0

func on_item_added() -> void:
	_connect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_post_resolved", on_signal_triggered)

func on_item_use(roulette_controller) -> void:
	if combat_bonus > 0.0:
		roulette_controller.add_multiplier(combat_bonus)
	var golden_count := 0
	for entry in _winning_entries(roulette_controller):
		if _is_golden_field(entry["field"]):
			golden_count += int(entry["chip_count"])
	if golden_count > 0:
		combat_bonus += 0.20 * golden_count
		_set_game_state_meta_flag(Constants.TRINKET_EFFECT_FLAG.GILDED_ENGINE_MULT, combat_bonus)
