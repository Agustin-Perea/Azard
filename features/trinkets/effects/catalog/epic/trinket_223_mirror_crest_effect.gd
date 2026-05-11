extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket223MirrorCrestEffect

func on_item_added() -> void:
	_add_game_state_meta_number(Constants.TRINKET_EFFECT_FLAG.COPY_EFFECTIVENESS_BONUS, 0.25)
