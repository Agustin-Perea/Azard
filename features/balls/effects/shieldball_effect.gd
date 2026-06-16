extends BallEffect 
class_name ShieldBallEffect


func on_pre_resolve(roullette_controller: RouletteController, quantity : int = 0)->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			GameState.player_stats.add_shield(4)
			return true
	}))

func on_bet_resolved(roullette_controller: RouletteController, quantity : int = 0)->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			GameState.player_stats.add_shield(1)
			return true
	}))
	pass
func on_post_resolved(roullette_controller: RouletteController, quantity : int = 0)->void:
	print("postresolve")
	pass

	
