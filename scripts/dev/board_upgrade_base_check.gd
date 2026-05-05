extends SceneTree

const BaseBoardUpgradeEffect := preload("res://features/board_upgrades/effects/catalog/base_catalog_board_upgrade_effect.gd")

func _init() -> void:
	var effect = BaseBoardUpgradeEffect.new()
	if effect == null:
		push_error("Could not instantiate base board upgrade effect.")
		quit(1)
		return
	print("board_upgrade_base_ok")
	quit(0)
