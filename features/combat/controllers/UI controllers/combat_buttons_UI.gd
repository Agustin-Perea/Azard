extends Control

@onready var selection_button  : Button = $SelectionButton
@onready var book_button : Button = $BookButton
@onready var gold_label: Label = $GoldHUD/HBoxContainer/Label

var help_button: Button
var help_book_open := false
var last_non_help_page: Constants.BOOK_PAGE = Constants.BOOK_PAGE.NONE
var current_book_page: Constants.BOOK_PAGE = Constants.BOOK_PAGE.NONE
var selection_button_requested_visible := true
var book_button_requested_visible := true
var state_to_restore_after_help := ""

func _ready() -> void:
	_create_help_button()
	UiEventBus.selection_button_visible.connect(on_selection_button_visible)
	UiEventBus.book_button_visible.connect(on_book_button_visible)
	UiEventBus.change_book_page.connect(_on_book_page_requested)
	UiEventBus.book_page_change_started.connect(_on_book_page_change_started)
	UiEventBus.book_page_change_finished.connect(_on_book_page_change_finished)
	UiEventBus.scene_changed.connect(_on_scene_changed)
	GameState.economy_component.gold_changed.connect(_on_gold_changed)
	_on_gold_changed(GameState.economy_component.run_gold)
	call_deferred("_refresh_hud_buttons")

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
	selection_button_requested_visible = value
	_refresh_hud_buttons()

func on_book_button_visible(value: bool)-> void:
	book_button_requested_visible = value
	_refresh_hud_buttons()


func _on_gold_changed(current_gold: int) -> void:
	if gold_label != null:
		gold_label.text = str(current_gold)

func _create_help_button() -> void:
	help_button = Button.new()
	help_button.name = "HelpBookButton"
	help_button.text = "?"
	help_button.anchor_left = 1.0
	help_button.anchor_right = 1.0
	help_button.offset_left = -122.0
	help_button.offset_top = 132.0
	help_button.offset_right = -28.0
	help_button.offset_bottom = 226.0
	help_button.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	help_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	help_button.add_theme_font_size_override("font_size", 46)
	help_button.add_theme_stylebox_override("normal", _make_help_button_style(Color(0.3529412, 0.1764706, 0.2784314, 0.86), Color(0.18, 0.08, 0.14, 1.0)))
	help_button.add_theme_stylebox_override("hover", _make_help_button_style(Color(0.46, 0.22, 0.36, 0.95), Color(0.18, 0.08, 0.14, 1.0)))
	help_button.add_theme_stylebox_override("pressed", _make_help_button_style(Color(0.20, 0.10, 0.17, 1.0), Color(0.18, 0.08, 0.14, 1.0)))
	help_button.pressed.connect(_on_help_button_pressed)
	add_child(help_button)

func _make_help_button_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_width_bottom = 8
	style.border_color = border
	style.corner_radius_top_left = 28
	style.corner_radius_top_right = 28
	style.corner_radius_bottom_right = 28
	style.corner_radius_bottom_left = 28
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 6
	return style

func _on_help_button_pressed() -> void:
	if not help_button.visible:
		return
	if help_button.disabled:
		return
	help_button.disabled = true
	if help_book_open:
		state_to_restore_after_help = _get_state_for_book_page(last_non_help_page)
		UiEventBus.change_book_page.emit(last_non_help_page)
		return

	if last_non_help_page != Constants.BOOK_PAGE.CASE:
		UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.BookState)
	UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.HELP)

func _on_book_page_requested(book_page: Constants.BOOK_PAGE) -> void:
	current_book_page = book_page
	_refresh_hud_buttons(true)

func _on_scene_changed() -> void:
	_refresh_hud_buttons()

func _on_book_page_change_started(book_page: Constants.BOOK_PAGE) -> void:
	current_book_page = book_page
	_refresh_hud_buttons(true)
	if book_page == Constants.BOOK_PAGE.HELP:
		help_button.text = "X"
		return

	if help_book_open:
		help_button.text = "?"

func _on_book_page_change_finished(book_page: Constants.BOOK_PAGE) -> void:
	current_book_page = book_page
	_refresh_hud_buttons()
	if book_page == Constants.BOOK_PAGE.HELP:
		UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.BookState)
		help_book_open = true
		help_button.text = "X"
		_refresh_hud_buttons()
		return

	help_book_open = false
	help_button.text = "?"
	last_non_help_page = book_page
	if state_to_restore_after_help != "":
		UiEventBus.changeToState.emit(state_to_restore_after_help)
		state_to_restore_after_help = ""
	_refresh_hud_buttons()

func _get_state_for_book_page(book_page: Constants.BOOK_PAGE) -> String:
	match book_page:
		Constants.BOOK_PAGE.ROULETTE:
			return Constants.COMBAT_STATE_NAMES.BookState
		Constants.BOOK_PAGE.CASE, Constants.BOOK_PAGE.MAP:
			return Constants.COMBAT_STATE_NAMES.BookCaseState
		Constants.BOOK_PAGE.NONE:
			return Constants.COMBAT_STATE_NAMES.EnemySelection
		_:
			return Constants.COMBAT_STATE_NAMES.BookState

func _set_help_button_available(available: bool, transitioning: bool) -> void:
	if help_button == null:
		return
	help_button.visible = available
	help_button.disabled = transitioning || not available
	help_button.mouse_filter = Control.MOUSE_FILTER_STOP if available else Control.MOUSE_FILTER_IGNORE
	help_button.focus_mode = Control.FOCUS_ALL if available else Control.FOCUS_NONE
	if not available:
		help_button.release_focus()

func _refresh_hud_buttons(transitioning: bool = false) -> void:
	var map_open := current_book_page == Constants.BOOK_PAGE.MAP or _is_map_scene_active()
	var help_open_or_opening := current_book_page == Constants.BOOK_PAGE.HELP or help_book_open
	_set_help_button_available(not map_open, transitioning)
	selection_button.visible = selection_button_requested_visible and not help_open_or_opening and not map_open
	book_button.visible = book_button_requested_visible and not help_open_or_opening and not map_open

func _is_map_scene_active() -> bool:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return false
	if current_scene.name == "Map":
		return true
	return current_scene.scene_file_path == "res://features/map/views/map_scene.tscn"
