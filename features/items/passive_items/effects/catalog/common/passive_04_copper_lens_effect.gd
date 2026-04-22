extends "res://features/items/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive04CopperLensEffect

var used_this_resolution := false

func on_item_added() -> void:
	_connect_book_signal("bet_pre_resolve", _on_bet_pre_resolve)
	_connect_book_signal("bet_resolved", _on_bet_resolved)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_pre_resolve", _on_bet_pre_resolve)
	_disconnect_book_signal("bet_resolved", _on_bet_resolved)

func on_item_use(roulette_controller) -> void:
	roulette_controller.add_base(1)

func _on_bet_pre_resolve(_roulette_controller) -> void:
	used_this_resolution = false

func _on_bet_resolved(roulette_controller) -> void:
	if used_this_resolution:
		return
	used_this_resolution = true
	item_use.emit(roulette_controller)
