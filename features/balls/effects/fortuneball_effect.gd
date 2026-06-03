extends BallEffect 
class_name FortuneBallEffect


func on_pre_resolve(roullette_controller: RouletteController)->void:
	roullette_controller.add_base(GameState.economy_component.run_gold)

func on_bet_resolved(roullette_controller: RouletteController)->void:
	print("betresolved")
	pass
func on_post_resolved(roullette_controller: RouletteController)->void:
	print("postresolve")
	pass

	
