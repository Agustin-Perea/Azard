extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name MirrorBallCatalogEffect

const MIRROR_SOURCE_META := "mirror_source_definition"

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var source_definition := _get_source_definition(roulette_controller)
	if source_definition == null or source_definition.ball_effect == null:
		return
	if source_definition.ball_effect == self:
		return
	var source_effect := source_definition.ball_effect
	var had_power := source_effect.has_meta("effect_power")
	var previous_power = source_effect.get_meta("effect_power", 1.0)
	source_effect.set_meta("effect_power", _scale_float(0.70, 1.0, 1.30) * _copy_repeat_effect_power())
	source_effect.on_post_resolved(roulette_controller)
	if had_power:
		source_effect.set_meta("effect_power", previous_power)
	else:
		source_effect.remove_meta("effect_power")

func _get_source_definition(roulette_controller: RouletteController) -> BallDefinition:
	if roulette_controller == null or roulette_controller.last_ball_used == null:
		return null
	var source = roulette_controller.last_ball_used.get_meta(MIRROR_SOURCE_META, null)
	return source as BallDefinition
