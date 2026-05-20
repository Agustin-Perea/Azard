extends "res://features/balls/effects/catalog/base_catalog_ball_effect.gd"
class_name VoidBallCatalogEffect

func on_post_resolved(roulette_controller: RouletteController) -> void:
	roulette_controller.set_attack_modifier(&"ignore_shield", true)
	BookEventBus.turn_log_entry.emit("VoidBall: atraviesa shield", Color(0.55, 0.35, 0.72, 1.0))
