extends Resource
class_name BoardUpgradeRuntimeState

@export var quantity: int = 1
@export var board_upgrade_definition: Resource

func on_signal_used(roulette_controller) -> void:
	if board_upgrade_definition == null or board_upgrade_definition.board_upgrade_effect == null:
		return
	board_upgrade_definition.board_upgrade_effect.set_meta("runtime_quantity", quantity)
	for i in range(quantity):
		board_upgrade_definition.board_upgrade_effect.on_item_use(roulette_controller)

func on_item_added() -> void:
	if board_upgrade_definition == null or board_upgrade_definition.board_upgrade_effect == null:
		return
	board_upgrade_definition.board_upgrade_effect.setup(board_upgrade_definition)
	board_upgrade_definition.board_upgrade_effect.set_meta("runtime_quantity", quantity)
	if not board_upgrade_definition.board_upgrade_effect.item_use.is_connected(on_signal_used):
		board_upgrade_definition.board_upgrade_effect.item_use.connect(on_signal_used)
	board_upgrade_definition.board_upgrade_effect.on_item_added()

func apply_stack_delta() -> void:
	if board_upgrade_definition == null or board_upgrade_definition.board_upgrade_effect == null:
		return
	board_upgrade_definition.board_upgrade_effect.setup(board_upgrade_definition)
	board_upgrade_definition.board_upgrade_effect.set_meta("runtime_quantity", 1)
	board_upgrade_definition.board_upgrade_effect.on_item_added()
	board_upgrade_definition.board_upgrade_effect.set_meta("runtime_quantity", quantity)

func on_item_removed() -> void:
	if board_upgrade_definition == null or board_upgrade_definition.board_upgrade_effect == null:
		return
	if board_upgrade_definition.board_upgrade_effect.item_use.is_connected(on_signal_used):
		board_upgrade_definition.board_upgrade_effect.item_use.disconnect(on_signal_used)
	board_upgrade_definition.board_upgrade_effect.on_item_removed()
