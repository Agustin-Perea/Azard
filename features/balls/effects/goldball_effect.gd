extends BallEffect 
class_name GoldBallEffect


func on_pre_resolve(roullette_controller: RouletteController)->void:
	pass

func on_bet_resolved(roullette_controller: RouletteController)->void:
	GameState.economy_component.add_run_gold(1)
	pass
func on_post_resolved(roullette_controller: RouletteController)->void:
	print("postresolve")
	pass

	
