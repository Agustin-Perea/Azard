extends "res://features/passive_items/effects/catalog/base_catalog_passive_item_effect.gd"
class_name Passive20LuckyThreadEffect

var winning_fields_this_resolution := 0

func on_item_added() -> void:
	_connect_book_signal("bet_pre_resolve", _on_bet_pre_resolve)
	_connect_book_signal("bet_resolved", _on_bet_resolved)
	_connect_book_signal("bet_post_resolved", _on_bet_post_resolved)

func on_item_removed() -> void:
	_disconnect_book_signal("bet_pre_resolve", _on_bet_pre_resolve)
	_disconnect_book_signal("bet_resolved", _on_bet_resolved)
	_disconnect_book_signal("bet_post_resolved", _on_bet_post_resolved)

func on_item_use(roulette_controller) -> void:
	roulette_controller.add_multiplier(0.20)

func _on_bet_pre_resolve(_roulette_controller) -> void:
	winning_fields_this_resolution = 0

func _on_bet_resolved(_roulette_controller) -> void:
	winning_fields_this_resolution += 1

func _on_bet_post_resolved(roulette_controller) -> void:
	if winning_fields_this_resolution >= 2:
		item_use.emit(roulette_controller)
