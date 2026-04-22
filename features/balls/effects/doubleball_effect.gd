extends BallEffect 
class_name DoubleBallEffect


func on_pre_resolve()->void:
	pass
func on_bet_resolved()->void:
	pass
func on_post_resolved(roullette_controller: RouletteController)->void:
	roullette_controller.multiply_mult_score(2)
