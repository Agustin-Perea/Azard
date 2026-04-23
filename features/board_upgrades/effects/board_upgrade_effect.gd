extends Resource
class_name BoardUpgradeEffect

var board_upgrade_definition: Resource

@warning_ignore("unused_signal")
signal animate
@warning_ignore("unused_signal")
signal item_use(roulette_controller)

func setup(definition: Resource) -> void:
	board_upgrade_definition = definition

func on_item_use(roulette_controller) -> void:
	pass

func on_signal_triggered(roulette_controller) -> void:
	item_use.emit(roulette_controller)

func on_item_added() -> void:
	pass

func on_item_removed() -> void:
	pass
