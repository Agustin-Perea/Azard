class_name EconomyComponent


var run_gold : int 
var initial_run_gold : int = 5000
var last_combat_gold_reward : int 
var last_combat_gold_breakdown: Dictionary = {}


signal gold_changed(run_gold : int)


const COMBAT_BASE_GOLD_BY_ENCOUNTER := {
	"normal": {1: 5, 2: 5, 3: 5},
	"elite": {1: 7, 2: 7, 3: 7},
	"miniboss": {1: 7, 2: 7, 3: 7},
	"boss": {1: 10, 2: 10, 3: 10},
}
var current_encounter_type: String = "normal"
var	current_act = 1

signal combat_gold_reward_granted(amount: int, breakdown: Dictionary, combat_stats: Dictionary)



func _init()->void:
	reload()

func reload()->void:
	run_gold = initial_run_gold
	last_combat_gold_reward = 0
	last_combat_gold_breakdown.clear()


func add_run_gold(amount: int) -> void:
	if amount <= 0:
		return
	run_gold += amount
	gold_changed.emit(run_gold)

func spend_run_gold(amount: int) -> bool:
	if amount <= 0:
		return true
	if run_gold < amount:
		return false
	run_gold -= amount
	gold_changed.emit(run_gold)
	return true

func can_afford(amount: int) -> bool:
	return run_gold >= amount


func _combat_base_gold() -> int:
	var by_act: Dictionary = COMBAT_BASE_GOLD_BY_ENCOUNTER.get(current_encounter_type, COMBAT_BASE_GOLD_BY_ENCOUNTER["normal"])
	return int(by_act.get(current_act, by_act.get(1, 5)))

func _turn_gold_bonus(turns_taken: int) -> int:
	return max(0, 5 - turns_taken)

func _remaining_reroll_gold_bonus(rerolls_remaining: int) -> int:
	return max(0, rerolls_remaining)
	
func calculate_combat_gold_reward(combat_stats: Dictionary = {}) -> Dictionary:
	var turns_taken := int(combat_stats.get("turns_taken", 0))
	var rerolls_remaining := int(combat_stats.get("rerolls_remaining", GameState.current_reroll))
	var base_gold := _combat_base_gold()
	var turn_bonus := _turn_gold_bonus(turns_taken)
	var reroll_bonus := _remaining_reroll_gold_bonus(rerolls_remaining)
	var total := base_gold + turn_bonus + reroll_bonus
	return {
		"base": base_gold,
		"encounter_type": current_encounter_type,
		"encounter_label": _encounter_label(),
		"turns_taken": turns_taken,
		"turns": turn_bonus,
		"speed": turn_bonus,
		"rerolls_remaining": rerolls_remaining,
		"rerolls": reroll_bonus,
		"health": 0,
		"multiplier": 0,
		"overkill": 0,
		"comeback": 0,
		"total": total,
	}
	
func grant_combat_victory_gold(combat_stats: Dictionary = {}) -> int:
	var breakdown := calculate_combat_gold_reward(combat_stats)
	var total := int(breakdown.get("total", 0))
	breakdown["gold_before"] = run_gold
	last_combat_gold_reward = total
	add_run_gold(total)
	breakdown["gold_after"] = run_gold
	last_combat_gold_breakdown = breakdown.duplicate(true)
	combat_gold_reward_granted.emit(total, breakdown, combat_stats)
	return total

func _encounter_label() -> String:
	match current_encounter_type:
		"boss":
			return "Boss"
		"miniboss", "elite":
			return "Miniboss"
		_:
			return "Enemigo comun"
