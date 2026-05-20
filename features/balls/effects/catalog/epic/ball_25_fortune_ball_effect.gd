extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name FortuneBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	if GameState.economy_component == null:
		return
	var step := int(max(1, _scale_int(20, 15, 10)))
	var base_bonus := int(floor(float(GameState.economy_component.run_gold) / float(step)))
	if base_bonus <= 0:
		return
	_add_base(roulette_controller, base_bonus)
	BookEventBus.turn_log_entry.emit("FortuneBall: +" + str(base_bonus) + " base por oro", Color(0.92, 0.56, 0.18, 1.0))
