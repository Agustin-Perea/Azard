extends PassiveItemEffect
class_name HouseKeyItemEffect

const REROLL_BONUS := 1
const CHIP_BONUS := 1

var applied_reroll_bonus := 0
var extra_chip_ids: Array[int] = []

func on_item_added() -> void:
	_set_reroll_bonus(REROLL_BONUS)
	_set_extra_chip_count(CHIP_BONUS)
	animate.emit()

func on_item_removed() -> void:
	_set_extra_chip_count(0)
	_set_reroll_bonus(0)

func _set_reroll_bonus(target_bonus: int) -> void:
	target_bonus = max(0, target_bonus)
	if applied_reroll_bonus == target_bonus:
		return
	var delta := target_bonus - applied_reroll_bonus
	GameState.max_reroll = max(0, GameState.max_reroll + delta)
	GameState.current_reroll = clamp(GameState.current_reroll + delta, 0, GameState.max_reroll)
	applied_reroll_bonus = target_bonus

func _set_extra_chip_count(target_count: int) -> void:
	target_count = max(0, target_count)
	while extra_chip_ids.size() < target_count:
		extra_chip_ids.append(GameState.add_extra_chip())
	while extra_chip_ids.size() > target_count:
		var chip_id := int(extra_chip_ids.pop_back())
		GameState.remove_extra_chip(chip_id)
