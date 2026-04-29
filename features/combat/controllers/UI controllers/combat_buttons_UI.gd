extends Control

@onready var selection_button  : Button = $SelectionButton
@onready var book_button : Button = $BookButton



func _ready() -> void:
	UiEventBus.selection_button_visible.connect(on_selection_button_visible)
	UiEventBus.book_button_visible.connect(on_book_button_visible)
	

func _on_selection_button_pressed() -> void:
	UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.NONE)

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

func on_selection_button_visible(value: bool)-> void:
	selection_button.visible = value

func on_book_button_visible(value: bool)-> void:
	book_button.visible = value
