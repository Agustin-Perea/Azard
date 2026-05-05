extends Control

@onready var selection_button  : Button = $SelectionButton
@onready var book_button : Button = $BookButton

var gold_label: Label


func _ready() -> void:
	UiEventBus.selection_button_visible.connect(on_selection_button_visible)
	UiEventBus.book_button_visible.connect(on_book_button_visible)
	_build_gold_hud()
	GameState.gold_changed.connect(_on_gold_changed)
	_on_gold_changed(GameState.run_gold)
	

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

func on_selection_button_visible(value: bool)-> void:
	selection_button.visible = value

func on_book_button_visible(value: bool)-> void:
	book_button.visible = value

func _build_gold_hud() -> void:
	var panel := PanelContainer.new()
	panel.name = "GoldHud"
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.position = Vector2(-190, 18)
	panel.size = Vector2(168, 44)
	add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.07, 0.04, 0.78)
	style.border_color = Color(0.95, 0.72, 0.18, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)

	var coin := ColorRect.new()
	coin.custom_minimum_size = Vector2(22, 22)
	coin.color = Color(0.95, 0.72, 0.18, 1.0)
	row.add_child(coin)

	gold_label = Label.new()
	gold_label.add_theme_font_size_override("font_size", 22)
	gold_label.text = "0"
	row.add_child(gold_label)

func _on_gold_changed(current_gold: int) -> void:
	if gold_label != null:
		gold_label.text = str(current_gold)
