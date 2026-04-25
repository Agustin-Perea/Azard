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
	var trigger_ids: Array[int] = trinket_definition.get_trigger_ids()
	var bus := _book_event_bus()
	if bus == null:
		return
	if trigger_ids.has(Constants.TRINKET_TRIGGER.TRIGGER_REROLL_USED) and not bus.reroll_used.is_connected(_on_reroll_used):
		bus.reroll_used.connect(_on_reroll_used)
	if trigger_ids.has(Constants.TRINKET_TRIGGER.TRIGGER_COMBAT_START) and not bus.combat_started.is_connected(_on_combat_started):
		bus.combat_started.connect(_on_combat_started)
	if trigger_ids.has(Constants.TRINKET_TRIGGER.TRIGGER_COMBAT_END) and not bus.combat_ended.is_connected(_on_combat_ended):
		bus.combat_ended.connect(_on_combat_ended)
	if trigger_ids.has(Constants.TRINKET_TRIGGER.TRIGGER_COMBAT_KILL) and not bus.combat_kill.is_connected(_on_combat_kill):
		bus.combat_kill.connect(_on_combat_kill)
	if trigger_ids.has(Constants.TRINKET_TRIGGER.TRIGGER_ENEMY_KILLED) and not bus.enemy_killed.is_connected(_on_enemy_killed):
		bus.enemy_killed.connect(_on_enemy_killed)

func _disconnect_runtime_hooks() -> void:
	var bus := _book_event_bus()
	if bus != null and bus.reroll_used.is_connected(_on_reroll_used):
		bus.reroll_used.disconnect(_on_reroll_used)
	if bus != null and bus.combat_started.is_connected(_on_combat_started):
		bus.combat_started.disconnect(_on_combat_started)
	if bus != null and bus.combat_ended.is_connected(_on_combat_ended):
		bus.combat_ended.disconnect(_on_combat_ended)
	if bus != null and bus.combat_kill.is_connected(_on_combat_kill):
		bus.combat_kill.disconnect(_on_combat_kill)
	if bus != null and bus.enemy_killed.is_connected(_on_enemy_killed):
		bus.enemy_killed.disconnect(_on_enemy_killed)

func _on_reroll_used(roulette_controller = null) -> void:
	if trinket_definition == null or trinket_definition.trinket_effect == null:
		return
	for i in range(quantity):
		trinket_definition.trinket_effect.on_reroll_used(roulette_controller)

func _on_combat_started() -> void:
	if trinket_definition == null or trinket_definition.trinket_effect == null:
		return
	for i in range(quantity):
		trinket_definition.trinket_effect.on_combat_start()

func _on_combat_ended(_victory: bool = false) -> void:
	if trinket_definition == null or trinket_definition.trinket_effect == null:
		return
	for i in range(quantity):
		trinket_definition.trinket_effect.on_combat_end()

func _on_combat_kill(_unit = null) -> void:
	if trinket_definition == null or trinket_definition.trinket_effect == null:
		return
	for i in range(quantity):
		trinket_definition.trinket_effect.on_combat_kill()

func _on_enemy_killed(_unit = null) -> void:
	if trinket_definition == null or trinket_definition.trinket_effect == null:
		return
	for i in range(quantity):
		trinket_definition.trinket_effect.on_enemy_killed()

func _book_event_bus() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("BookEventBus")
