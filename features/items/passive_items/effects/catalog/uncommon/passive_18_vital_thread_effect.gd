extends "res://features/items/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive18VitalThreadEffect

var winning_fields_this_resolution := 0

func on_item_added() -> void:
	_connect_book_signal("bet_pre_resolve", _on_bet_pre_resolve)
	_connect_book_signal("bet_resolved", _on_bet_resolved)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_pre_resolve", _on_bet_pre_resolve)
	_disconnect_book_signal("bet_resolved", _on_bet_resolved)

func on_item_use(_roulette_controller) -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.heal_player(1)

func _on_bet_pre_resolve(_roulette_controller) -> void:
	winning_fields_this_resolution = 0

func _on_bet_resolved(roulette_controller) -> void:
	winning_fields_this_resolution += 1
	if winning_fields_this_resolution % 2 == 0:
		item_use.emit(roulette_controller)
