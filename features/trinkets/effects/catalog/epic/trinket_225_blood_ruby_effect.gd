extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket225BloodRubyEffect

func on_item_added() -> void:
	_connect_book_signal("bet_pre_resolve", on_signal_triggered)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_pre_resolve", on_signal_triggered)

func on_item_use(roulette_controller) -> void:
	var game_state := _game_state()
	if game_state == null or game_state.max_healt <= 0:
		return
	var hp_ratio := float(game_state.current_healt) / float(game_state.max_healt)
	if hp_ratio < 0.5:
		roulette_controller.add_multiplier(1.0)
	if hp_ratio < 0.25:
		roulette_controller.add_base(2)
