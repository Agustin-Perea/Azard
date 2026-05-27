extends Node






@onready var shop_camera : Camera3D = $shop_camera


@onready var map_button : SB_Button3D = $SB_Button3D
func _ready() -> void:
	#PlayerUiEvents.disable_camera_buttons.emit()
	UiEventBus.book_button_visible.emit(false)
	UiEventBus.selection_button_visible.emit(false)
	UiEventBus.deactivate_status_view_component.emit()
	UiEventBus.changeCamera.emit(shop_camera,0.0)
	map_button.pressed.connect(change_to_map)


func change_to_map() -> void:
	UiEventBus.change_scene_to.emit(GameState.MAP_SCENE_PATH)
