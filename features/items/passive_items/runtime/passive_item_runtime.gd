extends Resource
class_name PassiveItemRuntimeState

@export var quantity: int = 1

@export var passive_item_definition : PassiveItemDefinition


#deberia llamar quantity veces al onballuse()
func on_signal_used(roulette_controller : RouletteController)->void:
	if passive_item_definition == null or passive_item_definition.passive_item_effect == null:
		return
	for i in range(quantity):
		passive_item_definition.passive_item_effect.on_item_use(roulette_controller)
		
#deberia estar suscrito a señales del efecto del passive_item_definition
func on_item_added()->void:
	if passive_item_definition == null or passive_item_definition.passive_item_effect == null:
		return
	passive_item_definition.passive_item_effect.item_use.connect(on_signal_used)
	passive_item_definition.passive_item_effect.on_item_added()
	on_quantity_changed()
	
func on_item_removed()->void:
	if passive_item_definition == null or passive_item_definition.passive_item_effect == null:
		return
	if passive_item_definition.passive_item_effect.item_use.is_connected(on_signal_used):
		passive_item_definition.passive_item_effect.item_use.disconnect(on_signal_used)
	passive_item_definition.passive_item_effect.on_item_removed()

func on_quantity_changed() -> void:
	if passive_item_definition == null or passive_item_definition.passive_item_effect == null:
		return
	if passive_item_definition.passive_item_effect.has_method("on_runtime_quantity_changed"):
		passive_item_definition.passive_item_effect.on_runtime_quantity_changed(quantity)
