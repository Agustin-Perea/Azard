extends Control

@onready var main_menu_button : Button = $Button

func _ready() -> void:
	main_menu_button.pressed.connect(on_button_pressed)
	
func on_button_pressed() -> void:
	GameState.end_run()
	UiEventBus.change_scene_to.emit(Constants.MAIN_MENU_SCENE_PATH)
