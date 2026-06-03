extends BallEffect 
class_name AscendBallEffect



func on_pre_resolve(roullette_controller: RouletteController)->void:
	roullette_controller.last_ball_used.extra_base_damage += 1

func on_bet_resolved(roullette_controller: RouletteController)->void:
	
	pass
func on_post_resolved(roullette_controller: RouletteController)->void:
	print("postresolve")
	pass

	
