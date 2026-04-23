extends "res://features/trinkets/effects/catalog/base_catalog_trinket_effect.gd"
class_name Trinket218ExecutionWireEffect

func on_combat_kill() -> void:
	_add_game_state_meta_number(Constants.TRINKET_EFFECT_FLAG.EXECUTION_NEXT_MULT, 1.0)
