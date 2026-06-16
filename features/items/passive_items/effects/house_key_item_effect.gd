extends PassiveItemEffect
class_name HouseKeyItemEffect

const REROLL_BONUS := 1
const CHIP_BONUS := 1

var applied_reroll_bonus := 0
var extra_chip_ids: Array[int] = []

func on_item_added() -> void:

	GameState.max_reroll = max(0, GameState.max_reroll + REROLL_BONUS)
	GameState.add_extra_chip()
	#GameState.current_reroll = clamp(GameState.current_reroll + delta, 0, GameState.max_reroll)
	animate.emit()

func on_item_removed() -> void:
	GameState.max_reroll = max(0, GameState.max_reroll - REROLL_BONUS)
	GameState.remove_extra_chip(0)#no siempre sera la id 0
