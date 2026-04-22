extends PassiveItemEffect
class_name SpiralItemEffect

func on_item_use(roulette_controller)->void:
	animate.emit()
	roulette_controller.multiply_mult_score(1.5)

	
func on_item_added()->void:
	BookEventBus.bet_resolved.connect(on_signal_triggered)

func on_item_removed()->void:
	BookEventBus.bet_resolved.disconnect(on_signal_triggered)
