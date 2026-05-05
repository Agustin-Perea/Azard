extends "res://features/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive09FirstAidTapeEffect

var used_this_combat := false

func on_item_added() -> void:
	_connect_book_signal("bet_resolved", _on_bet_resolved)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_resolved", _on_bet_resolved)

func on_item_use(_roulette_controller) -> void:
	var game_state := _game_state()
	if game_state != null:
		game_state.heal_player(3)

func _on_bet_resolved(roulette_controller) -> void:
	if used_this_combat:
		return
	used_this_combat = true
	item_use.emit(roulette_controller)
