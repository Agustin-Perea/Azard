extends PassiveItemEffect
class_name LoadedDiceItemEffect

const LUCK_BONUS := 6

var applied_luck := 0

func on_item_added() -> void:
	on_runtime_quantity_changed(1)

func on_item_removed() -> void:
	if applied_luck == 0:
		return
	GameState.add_luck(-applied_luck)
	applied_luck = 0

func on_runtime_quantity_changed(quantity: int) -> void:
	var target_luck: int = max(0, quantity) * LUCK_BONUS
	var delta: int = target_luck - applied_luck
	if delta == 0:
		return
	applied_luck = target_luck
	GameState.add_luck(delta)
