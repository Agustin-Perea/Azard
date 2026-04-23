extends "res://features/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive10FeltGlovesEffect

var used_this_combat := false

func on_item_added() -> void:
	_connect_book_signal("bet_pre_resolve", _on_bet_pre_resolve)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_pre_resolve", _on_bet_pre_resolve)

func on_item_use(roulette_controller) -> void:
	roulette_controller.add_base(1)

func _on_bet_pre_resolve(roulette_controller) -> void:
	if used_this_combat:
		return
	used_this_combat = true
	item_use.emit(roulette_controller)
