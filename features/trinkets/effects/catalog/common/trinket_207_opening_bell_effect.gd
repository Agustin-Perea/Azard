extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket207OpeningBellEffect

func on_combat_start() -> void:
	_set_game_state_meta_flag("trinket_opening_bell_used", false)
