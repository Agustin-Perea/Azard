extends PassiveItemEffect
class_name BaseCatalogPassiveItemEffect

func _winner(controller) -> BetFieldModel:
	if controller == null:
		return null
	return controller.winner_betfield_model

func _is_red(controller) -> bool:
	var winner := _winner(controller)
	return winner != null and winner.color == Constants.BET_FIELD_COLOR.RED

func _is_black(controller) -> bool:
	var winner := _winner(controller)
	return winner != null and winner.color == Constants.BET_FIELD_COLOR.BLACK

func _is_prime(controller) -> bool:
	var winner := _winner(controller)
	if winner == null:
		return false
	var n := winner.number
	if n < 2:
		return false
	var i := 2
	while i * i <= n:
		if n % i == 0:
			return false
		i += 1
	return true

func _connect_signal(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect_signal(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)

func _autoload(name: String) -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null(name)

func _game_state() -> Node:
	return _autoload("GameState")

func _book_event_bus() -> Node:
	return _autoload("BookEventBus")

func _connect_book_signal(signal_name: String, callable: Callable) -> void:
	var bus := _book_event_bus()
	if bus == null:
		return
	_connect_signal(Signal(bus, signal_name), callable)

func _disconnect_book_signal(signal_name: String, callable: Callable) -> void:
	var bus := _book_event_bus()
	if bus == null:
		return
	_disconnect_signal(Signal(bus, signal_name), callable)
