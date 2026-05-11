extends Resource
class_name PassiveItemRuntimeState

@export var quantity: int = 1

@export var passive_item_definition : PassiveItemDefinition


#deberia llamar quantity veces al onballuse()
func on_signal_used(roulette_controller : RouletteController)->void:
	for i in range(quantity):
		passive_item_definition.passive_item_effect.on_item_use(roulette_controller)
		
#deberia estar suscrito a señales del efecto del passive_item_definition
func on_item_added()->void:
	passive_item_definition.passive_item_effect.item_use.connect(on_signal_used)
	passive_item_definition.passive_item_effect.on_item_added()
	
func on_item_removed()->void:
	passive_item_definition.passive_item_effect.item_use.disconnect(on_signal_used)
	passive_item_definition.passive_item_effect.on_item_removed()
