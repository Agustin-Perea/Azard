extends Resource
class_name TrinketEffect

var trinket_definition: Resource

@warning_ignore("unused_signal")
signal animate
@warning_ignore("unused_signal")
signal item_use(roulette_controller)

func setup(definition: Resource) -> void:
	trinket_definition = definition

func on_item_use(roulette_controller) -> void:
	pass

func on_signal_triggered(roulette_controller) -> void:
	item_use.emit(roulette_controller)

func on_item_added() -> void:
	pass

func on_item_removed() -> void:
	pass

func on_item_enabled() -> void:
	pass

func on_item_disabled() -> void:
	pass

func on_pre_resolve(_roulette_controller = null) -> void:
	pass

func on_bet_resolved(_roulette_controller = null) -> void:
	pass

func on_post_resolved(_roulette_controller = null) -> void:
	pass

func on_reroll_used(_roulette_controller = null) -> void:
	pass

func on_combat_start() -> void:
	pass

func on_combat_end() -> void:
	pass

func on_combat_kill() -> void:
	pass

func on_enemy_killed() -> void:
	pass
