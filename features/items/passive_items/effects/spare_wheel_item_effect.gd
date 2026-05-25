extends PassiveItemEffect
class_name SpareWheelItemEffect

const REROLL_BONUS := 1

var applied_bonus := 0

func on_item_added() -> void:
	if applied_bonus > 0:
		return
	applied_bonus = REROLL_BONUS
	GameState.max_reroll += applied_bonus
	GameState.current_reroll += applied_bonus
	animate.emit()

func on_item_removed() -> void:
	if applied_bonus <= 0:
		return
	GameState.max_reroll = max(0, GameState.max_reroll - applied_bonus)
	GameState.current_reroll = clamp(GameState.current_reroll - applied_bonus, 0, GameState.max_reroll)
	applied_bonus = 0
