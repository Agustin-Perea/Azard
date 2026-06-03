class_name EconomyComponent


var run_gold : int 
var initial_run_gold : int = 0 #5000
var last_combat_gold_reward : int 

var combat_max_multiplier


signal gold_changed(run_gold : int)



#raro
var combat_final_overkill: int = 0
var combat_turns_taken : int



const COMBAT_BASE_GOLD_BY_ENCOUNTER := {
	"normal": {1: 5, 2: 5, 3: 5},
	"elite": {1: 7, 2: 7, 3: 7},
	"miniboss": {1: 7, 2: 7, 3: 7},
	"boss": {1: 10, 2: 10, 3: 10},
}
var current_encounter_type: String = "normal"
var	current_act = 1

signal combat_gold_reward_granted(amount: int, breakdown: Dictionary)



func _init()->void:
	BookEventBus.victory.connect(grant_combat_victory_gold)	
	reload()

func reload()->void:
	run_gold = initial_run_gold
	last_combat_gold_reward = 0
	combat_turns_taken = 0
	combat_max_multiplier = 1.0

	


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

func _turn_gold_bonus() -> int:
	return max(0, 5 - combat_turns_taken)

func _remaining_reroll_gold_bonus() -> int:
	return max(0, GameState.current_reroll)
	
func calculate_combat_gold_reward() -> Dictionary:
	var base_gold := _combat_base_gold()
	var turn_bonus := _turn_gold_bonus()
	var reroll_bonus := _remaining_reroll_gold_bonus()
	var total := base_gold + turn_bonus + reroll_bonus
	return {
		"base": base_gold,
		"turns": turn_bonus,
		"speed": turn_bonus,
		"rerolls": reroll_bonus,
		"health": 0,
		"multiplier": 0,
		"overkill": 0,
		"comeback": 0,
		"total": total,
	}
	
func grant_combat_victory_gold() -> int:
	print("queso")
	var breakdown := calculate_combat_gold_reward()
	var total := int(breakdown.get("total", 0))
	last_combat_gold_reward = total
	add_run_gold(total)
	combat_gold_reward_granted.emit(total, breakdown)
	return total
	
func _health_gold_bonus() -> int:
	var hp : int
	var hp_max : int
	if GameState.player_stats != null:
		hp = GameState.player_stats.current_healt
		hp_max = GameState.player_stats.max_healt
	if hp_max <= 0:
		return 0
	var ratio := float(hp) / float(hp_max)
	if ratio >= 1.0:
		return 6
	if ratio >= 0.8:
		return 3
	return 0

func _multiplier_gold_bonus() -> int:
	if combat_max_multiplier >= 12.0:
		return 20
	if combat_max_multiplier >= 8.0:
		return 14
	if combat_max_multiplier >= 5.0:
		return 9
	if combat_max_multiplier >= 3.0:
		return 5
	if combat_max_multiplier >= 2.0:
		return 2
	return 0
	
func _overkill_gold_bonus() -> int:
	if combat_final_overkill >= 20:
		return 10
	if combat_final_overkill >= 10:
		return 6
	if combat_final_overkill >= 5:
		return 3
	if combat_final_overkill >= 1:
		return 1
	return 0
