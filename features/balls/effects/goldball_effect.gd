extends BallEffect 
class_name GoldBallEffect


func on_pre_resolve(roullette_controller: RouletteController)->void:
	pass

func on_bet_resolved(roullette_controller: RouletteController)->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			GameState.economy_component.add_run_gold(1)
			return true
	}))



	pass
func on_post_resolved(roullette_controller: RouletteController)->void:
	print("postresolve")
	pass

	
