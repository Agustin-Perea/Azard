extends Control

@onready var continue_button: Button = $MenuContent/Buttons/ContinueButton
@onready var confirm_overlay: Control = $ConfirmOverlay
@onready var click_player: AudioStreamPlayer = $ClickPlayer

func _ready() -> void:
	if has_node("/root/UiHud"):
		UiHud.visible = false
	UiEventBus.selection_button_visible.emit(false)
	UiEventBus.book_button_visible.emit(false)
	continue_button.disabled = not GameState.has_save()
	continue_button.modulate.a = 1.0 if GameState.has_save() else 0.45
	confirm_overlay.visible = false

func _on_play_button_pressed() -> void:
	_play_click()
	if GameState.has_save():
		confirm_overlay.visible = true
		return
	_start_new_run()

func _on_confirm_new_run_button_pressed() -> void:
	_play_click()
	confirm_overlay.visible = false
	_start_new_run()

func _on_cancel_new_run_button_pressed() -> void:
	_play_click()
	confirm_overlay.visible = false

func _start_new_run() -> void:
	GameState.new_run()
	_go_to_scene(GameState.MAP_SCENE_PATH)

func _on_continue_button_pressed() -> void:
	if not GameState.has_save():
		return
	_play_click()
	if GameState.load_run():
		_go_to_scene(GameState.get_current_scene_path())
	else:
		continue_button.disabled = true
		continue_button.modulate.a = 0.45

func _on_quit_button_pressed() -> void:
	_play_click()
	get_tree().quit()

func _go_to_scene(scene_path: String) -> void:
	if has_node("/root/UiHud"):
		UiHud.visible = true
	UiEventBus.change_scene_to.emit(scene_path)

func _play_click() -> void:
	if click_player != null:
		click_player.play()
