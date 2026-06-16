extends BallEffect 
class_name AscendBallEffect



func on_pre_resolve(roullette_controller: RouletteController, quantity : int = 0)->void:
	roullette_controller.last_ball_used.extra_base_damage += 1

func on_bet_resolved(roullette_controller: RouletteController, quantity : int = 0)->void:
	pass
	
func on_post_resolved(roullette_controller: RouletteController, quantity : int = 0)->void:
	print("postresolve")
	pass
	
