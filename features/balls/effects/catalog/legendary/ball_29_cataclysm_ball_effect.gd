extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name CataclysmBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var shield := GameState.consume_player_shield()
	if shield <= 0:
		return
	var new_base := shield * 2
	if new_base <= 0:
		return
	roulette_controller.update_base_score(new_base)
	BookEventBus.turn_log_entry.emit("CataclysmBall: base " + str(new_base) + " por shield x2", Color(0.86, 0.20, 0.52, 1.0))
