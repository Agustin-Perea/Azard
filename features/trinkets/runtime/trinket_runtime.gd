extends Resource
class_name TrinketRuntimeState

@export var quantity: int = 1
@export var trinket_definition: Resource

func on_signal_used(roulette_controller) -> void:
	if trinket_definition == null or trinket_definition.trinket_effect == null:
		return
	for i in range(quantity):
		trinket_definition.trinket_effect.on_item_use(roulette_controller)

func on_item_added() -> void:
	if trinket_definition == null or trinket_definition.trinket_effect == null:
		return
	trinket_definition.trinket_effect.setup(trinket_definition)
	if not trinket_definition.trinket_effect.item_use.is_connected(on_signal_used):
		trinket_definition.trinket_effect.item_use.connect(on_signal_used)
	_connect_runtime_hooks()
	trinket_definition.trinket_effect.on_item_added()

func on_item_removed() -> void:
	if trinket_definition == null or trinket_definition.trinket_effect == null:
		return
	if trinket_definition.trinket_effect.item_use.is_connected(on_signal_used):
		trinket_definition.trinket_effect.item_use.disconnect(on_signal_used)
	_disconnect_runtime_hooks()
	trinket_definition.trinket_effect.on_item_removed()

func _connect_runtime_hooks() -> void:
	if trinket_definition == null or not trinket_definition.has_method("get_trigger_ids"):
		return
	if not trinket_definition.get_trigger_ids().has(Constants.TRINKET_TRIGGER.TRIGGER_REROLL_USED):
		return
	var bus := _book_event_bus()
	if bus != null and not bus.reroll_used.is_connected(_on_reroll_used):
		bus.reroll_used.connect(_on_reroll_used)

func _disconnect_runtime_hooks() -> void:
	var bus := _book_event_bus()
	if bus != null and bus.reroll_used.is_connected(_on_reroll_used):
		bus.reroll_used.disconnect(_on_reroll_used)

func _on_reroll_used(roulette_controller = null) -> void:
	if trinket_definition == null or trinket_definition.trinket_effect == null:
		return
	for i in range(quantity):
		trinket_definition.trinket_effect.on_reroll_used(roulette_controller)

func _book_event_bus() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("BookEventBus")
