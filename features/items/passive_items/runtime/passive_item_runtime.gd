extends Resource
class_name PassiveItemRuntimeState

@export var quantity: int = 1
@export var final_price: int

@export var passive_item_definition : PassiveItemDefinition


#deberia hacerlo una sola vez y el efecto decidir que hacer con la cantidad
func on_signal_used(roulette_controller : RouletteController)->void:
	passive_item_definition.passive_item_effect.on_item_use(roulette_controller,quantity)

#deberia estar suscrito a señales del efecto del passive_item_definition
func on_item_added() -> void:
	var item_signal = passive_item_definition.passive_item_effect.item_use
	
	if not item_signal.is_connected(on_signal_used):
		item_signal.connect(on_signal_used)
		
	passive_item_definition.passive_item_effect.on_item_added()
	
func on_item_removed()->void:
	passive_item_definition.passive_item_effect.item_use.disconnect(on_signal_used)
	passive_item_definition.passive_item_effect.on_item_removed()
