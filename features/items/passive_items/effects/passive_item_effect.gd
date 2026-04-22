extends Resource 
class_name PassiveItemEffect

@export var name: String

@export var description: String

var passive_item_definition: PassiveItemDefinition

@warning_ignore("unused_signal")
signal animate
@warning_ignore("unused_signal")
signal item_use(roulette_controller)

func setup(definition: PassiveItemDefinition) -> void:
	passive_item_definition = definition

func on_item_use(roulette_controller)->void:
	pass
	
func on_signal_triggered(roulette_controller)->void:
	item_use.emit(roulette_controller)
	
#estas son callbacks de bola, ej al agregar una bola aumenta el mult en x.1
func on_ball_added()->void:
	pass
	
func on_ball_removed()->void:
	pass
	
func on_ball_enabled()->void:
	pass
	
func on_ball_disabled()->void:
	pass

#estas son callbacks propias
func on_item_added()->void:
	pass
func on_item_removed()->void:
	pass
func on_item_enabled()->void:
	pass
func on_item_disabled()->void:
	pass
	
#estas son callbacks de eventos, cada modelo tiene sus propios eventos y comportamiento
#ante un evento de combtae,personaje o demas comun

func on_pre_resolve()->void:
	pass
func on_bet_resolved()->void:
	pass
func on_post_resolved(roullette_controller)->void:
	pass
func on_reroll(roulette_controller)->void:
	pass
func on_combat_start()->void:
	pass
func on_combat_end()->void:
	pass
func on_combat_kill()->void:
	pass
func on_enemy_killed()->void:
	pass
func on_reward_generated()->void:
	pass
func on_shop_generated()->void:
	pass
func on_chest_opened()->void:
	pass
func on_event_reward_generated()->void:
	pass
func on_status_tick()->void:
	pass
	
func on_ball_use()->void:
	pass
	
func on_finish_turn()->void:
	pass
