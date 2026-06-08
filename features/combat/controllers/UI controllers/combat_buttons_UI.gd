extends Control

@onready var selection_button  : Button = $SelectionButton
@onready var book_button : Button = $BookButton
@onready var menu_button : Button = $MenuButton

@onready var gold_label: Label = $GoldHUD/HBoxContainer/Label



func _ready() -> void:
	UiEventBus.selection_button_visible.connect(on_selection_button_visible)
	UiEventBus.book_button_visible.connect(on_book_button_visible)
	GameState.economy_component.gold_changed.connect(_on_gold_changed)
	_on_gold_changed(GameState.economy_component.run_gold)

func _on_selection_button_pressed() -> void:
	UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.NONE)#esto va al placeholder

	EventManager.add_event(EventManager.QueueType.GAME, GameEvent.new({
		"paralel": false,
		"action": func():
			UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.EnemySelection)
			return true
	}))
	
	

func _on_book_button_pressed() -> void:
	
	
	UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.BookState)
	EventManager.add_event(EventManager.QueueType.GAME, GameEvent.new({
		"paralel": false,
		"action": func():
			UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.ROULETTE)
			return true
	}))

func _on_menu_button_pressed() -> void:
	#if GameState.has_pending_roulette_attack(GameState.get_current_scene_path()):
		#return
	#GameState.save_run(GameState.get_current_scene_path())
	EventManager.clear_queue(EventManager.QueueType.GAME)
	UiEventBus.selection_button_visible.emit(false)
	UiEventBus.book_button_visible.emit(false)
	UiEventBus.change_scene_to.emit(Constants.MAIN_MENU_SCENE_PATH)
	
func on_selection_button_visible(value: bool)-> void:
	selection_button.visible = value

func on_book_button_visible(value: bool)-> void:
	book_button.visible = value


func _on_gold_changed(current_gold: int) -> void:
	if gold_label != null:
		gold_label.text = str(current_gold)
		
