extends PassiveItemEffect
class_name TwinFuseItemEffect

const POWER_BONUS := 0.50

var applied_bonus := 0.0

func on_item_added() -> void:
	_apply_bonus(POWER_BONUS)

func on_item_removed() -> void:
	_apply_bonus(0.0)

func on_runtime_quantity_changed(quantity: int) -> void:
	_apply_bonus(POWER_BONUS * max(1, quantity))

func _apply_bonus(new_bonus: float) -> void:
	if applied_bonus != 0.0:
		GameState.add_copy_repeat_effect_power_bonus(-applied_bonus)
	applied_bonus = maxf(0.0, new_bonus)
	if applied_bonus != 0.0:
		GameState.add_copy_repeat_effect_power_bonus(applied_bonus)
