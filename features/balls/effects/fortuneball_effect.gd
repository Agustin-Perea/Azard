extends BallEffect 
class_name FortuneBallEffect


func on_pre_resolve(roullette_controller: RouletteController, quantity : int = 0)->void:
	roullette_controller.add_base(GameState.economy_component.run_gold)

func on_bet_resolved(roullette_controller: RouletteController, quantity : int = 0)->void:
	print("betresolved")
	pass
func on_post_resolved(roullette_controller: RouletteController, quantity : int = 0)->void:
	print("postresolve")
	pass

	
