extends Control

@onready var selection_button  : Button = $SelectionButton
@onready var book_button : Button = $BookButton
@onready var menu_button : Button = $MenuButton


@onready var gold_label: Label = $GoldHUD/HBoxContainer/Label
var autosave_feedback_label: Label
var autosave_feedback_tween: Tween

func _ready() -> void:
	UiEventBus.selection_button_visible.connect(on_selection_button_visible)
	UiEventBus.book_button_visible.connect(on_book_button_visible)
	UiEventBus.autosave_feedback_requested.connect(_on_autosave_feedback_requested)
	GameState.economy_component.gold_changed.connect(_on_gold_changed)
	_on_gold_changed(GameState.economy_component.run_gold)
	_create_autosave_feedback()

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
	if GameState.has_pending_roulette_attack(GameState.get_current_scene_path()):
		return
	GameState.save_run(GameState.get_current_scene_path())
	UiEventBus.selection_button_visible.emit(false)
	UiEventBus.book_button_visible.emit(false)
	UiEventBus.change_scene_to.emit(GameState.MAIN_MENU_SCENE_PATH)

func on_selection_button_visible(value: bool)-> void:
	selection_button.visible = value

func on_book_button_visible(value: bool)-> void:
	book_button.visible = value


func _on_gold_changed(current_gold: int) -> void:
	if gold_label != null:
		gold_label.text = str(current_gold)

func _create_autosave_feedback() -> void:
	var gold_hud := get_node_or_null("GoldHUD")
	if gold_hud == null:
		return
	autosave_feedback_label = Label.new()
	autosave_feedback_label.name = "AutosaveFeedbackLabel"
	autosave_feedback_label.text = "guardado"
	autosave_feedback_label.modulate = Color(1.0, 0.84, 0.2, 0.0)
	autosave_feedback_label.position = Vector2(-12, 42)
	autosave_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	gold_hud.add_child(autosave_feedback_label)

func _on_autosave_feedback_requested() -> void:
	if autosave_feedback_label == null:
		return
	if autosave_feedback_tween != null and autosave_feedback_tween.is_running():
		autosave_feedback_tween.kill()
	autosave_feedback_label.modulate.a = 0.0
	autosave_feedback_label.position = Vector2(-12, 42)
	autosave_feedback_tween = create_tween()
	autosave_feedback_tween.set_parallel(true)
	autosave_feedback_tween.tween_property(autosave_feedback_label, "modulate:a", 1.0, 0.16)
	autosave_feedback_tween.tween_property(autosave_feedback_label, "position:y", 34.0, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	autosave_feedback_tween.chain().tween_property(autosave_feedback_label, "modulate:a", 0.0, 0.45).set_delay(0.2)
