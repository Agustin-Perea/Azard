extends BallEffect 
class_name RerollBallEffect


func on_pre_resolve(roullette_controller: RouletteController)->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			#agregar 1 reroll  en la batalla, no puede rerollear
			#deactivate reroll
			return true
	}))

func on_bet_resolved(roullette_controller: RouletteController)->void:
	pass
func on_post_resolved(roullette_controller: RouletteController)->void:
	print("postresolve")
	pass

	
