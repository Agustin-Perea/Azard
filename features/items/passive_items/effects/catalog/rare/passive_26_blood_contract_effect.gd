extends "res://features/items/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive26BloodContractEffect

func on_item_added() -> void:
	_connect_book_signal("bet_post_resolved", _on_bet_post_resolved)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_post_resolved", _on_bet_post_resolved)

func on_item_use(roulette_controller) -> void:
	roulette_controller.multiply_mult_score(2.0)

func _on_bet_post_resolved(roulette_controller) -> void:
	var game_state := _game_state()
	if game_state != null and game_state.current_healt < game_state.max_healt * 0.5:
		item_use.emit(roulette_controller)
