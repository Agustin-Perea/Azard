extends PassiveItemEffect
class_name ThirdChipItemEffect

var extra_chip_ids: Array[int] = []

func on_item_added() -> void:
	on_runtime_quantity_changed(1)

func on_item_removed() -> void:
	_set_extra_chip_count(0)

func on_runtime_quantity_changed(quantity: int) -> void:
	_set_extra_chip_count(max(0, quantity))

func _set_extra_chip_count(target_count: int) -> void:
	while extra_chip_ids.size() < target_count:
		extra_chip_ids.append(GameState.add_extra_chip())
	while extra_chip_ids.size() > target_count:
		var chip_id := int(extra_chip_ids.pop_back())
		GameState.remove_extra_chip(chip_id)
