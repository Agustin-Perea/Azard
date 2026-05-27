extends Node


@export var chest : Node3D 
@export var player : Node3D 

@export var chest_button : SB_Button3D 
@export var add_passive_item_button : SB_Button3D 

@onready var reward_camera : Camera3D = $reward_camera/Camera
@onready var reward_camera_animation_player : AnimationPlayer = $reward_camera/AnimationPlayer

@export var book_camera : Camera3D 
func _ready() -> void:
	#PlayerUiEvents.disable_camera_buttons.emit()
	UiEventBus.book_button_visible.emit(false)
	UiEventBus.selection_button_visible.emit(false)
	UiEventBus.deactivate_status_view_component.emit()
	UiEventBus.changeCamera.emit(reward_camera,0.0)
	reward_camera_animation_player.play("chest_animations/chest_camera_init")
	chest_button.pressed.connect(chest_pressed)
	add_passive_item_button.pressed.connect(change_to_map)
	#chest_button.activate()
	pass

func chest_pressed() -> void:
	reward_camera_animation_player.play("chest_animations/chest_camera_open")
	#chest_button.deactivate()

func change_to_map() -> void:
	UiEventBus.change_scene_to.emit(GameState.MAP_SCENE_PATH)
	
