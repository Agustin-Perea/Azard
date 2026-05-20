extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name GraveBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	var execute_threshold := _scale_float(0.15, 0.20, 0.25)
	roulette_controller.set_attack_modifier(&"grave_execute_threshold", execute_threshold)
	BookEventBus.turn_log_entry.emit("GraveBall: ejecuta enemigos con poca vida", Color(0.28, 0.58, 0.42, 1.0))
