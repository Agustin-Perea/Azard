class_name StadisticsComponent

var max_damage : int = 0

var enemies_slain : int = 0

var bosses_slain : int = 0

var floors : int = 0

var gold_earned : int = 0

var gold_spent : int = 0

func _init() -> void:
	call_deferred("setup")

func setup()->void:
	BookEventBus.unit_death.connect(on_unit_death)
	BookEventBus.attack_damage.connect(on_attack_damage)
	BookEventBus.earn_gold.connect(on_earn_gold)
	BookEventBus.spent_gold.connect(on_spent_gold)
	BookEventBus.boss_defeated.connect(on_boss_defeated)
	
func on_unit_death(unit : Unit)->void:
	enemies_slain += 1
	
func on_boss_defeated()->void:
	bosses_slain += 1

func on_attack_damage(attack_damage : float)->void:
	if attack_damage > max_damage:
		max_damage = int(attack_damage)

func on_earn_gold(gold : int)->void:
	gold_earned += gold
	
func on_spent_gold(gold : int)->void:
	gold_spent += gold
