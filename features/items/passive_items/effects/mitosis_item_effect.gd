extends PassiveItemEffect
class_name MitosisItemEffect

const HEAL_BONUS := 2

var applied_heal_bonus := 0

func on_item_added() -> void:
	on_runtime_quantity_changed(1)

func on_item_removed() -> void:
	if applied_heal_bonus == 0:
		return
	GameState.add_healing_effect_bonus(-applied_heal_bonus)
	applied_heal_bonus = 0

func on_runtime_quantity_changed(quantity: int) -> void:
	var target_bonus: int = max(0, quantity) * HEAL_BONUS
	var delta: int = target_bonus - applied_heal_bonus
	if delta == 0:
		return
	applied_heal_bonus = target_bonus
	GameState.add_healing_effect_bonus(delta)
