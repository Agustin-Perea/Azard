extends BallEffect 
class_name DoubleBallEffect


func on_pre_resolve(roullette_controller: RouletteController)->void:
	print("preseolve")
	pass
func on_bet_resolved(roullette_controller: RouletteController)->void:
	print("betresolved")
	pass
func on_post_resolved(roullette_controller: RouletteController)->void:
	print("postresolve")
	roullette_controller.multiply_mult_score(2)

	
