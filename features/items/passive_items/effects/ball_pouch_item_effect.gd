extends PassiveItemEffect
class_name BallPouchItemEffect

const BALL_SLOT_BONUS := 1

var applied_bonus := 0

func on_item_added() -> void:
	if applied_bonus > 0:
		return
	applied_bonus = BALL_SLOT_BONUS
	GameState.add_ball_slot_bonus(applied_bonus, false)
	GameState.ensure_random_balls_for_active_slots()
	GameState.notify_ball_slots_changed()
	animate.emit()

func on_item_removed() -> void:
	if applied_bonus <= 0:
		return
	GameState.add_ball_slot_bonus(-applied_bonus)
	applied_bonus = 0
