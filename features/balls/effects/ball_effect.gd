extends Resource 
class_name BallEffect

@export var name: String

@export var description: String

#estas son callbacks propias
func on_ball_added()->void:
	pass
	
func on_ball_removed()->void:
	pass
	
func on_ball_enabled()->void:
	pass
	
func on_ball_disabled()->void:
	pass
	
#estas son callbacks de eventos, cada modelo tiene sus propios eventos y comportamiento
#ante un evento de combtae,personaje o demas comun

func on_pre_resolve()->void:
	pass
func on_bet_resolved()->void:
	pass
func on_post_resolved(roullette_controller : RouletteController)->void:
	pass
	
func on_ball_use()->void:
	pass
	
func on_finish_turn()->void:
	pass
