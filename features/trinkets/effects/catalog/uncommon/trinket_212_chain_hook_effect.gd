extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket212ChainHookEffect

func on_item_added() -> void:
	_add_game_state_meta_number(Constants.TRINKET_EFFECT_FLAG.CHAIN_SECONDARY_DAMAGE_BONUS, 0.20)
