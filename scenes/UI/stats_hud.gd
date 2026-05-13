extends Control
@onready var target : Node3D = $"../LifeView"
@onready var cam = get_viewport().get_camera_3d()

func _process(delta):
	var screen_pos = cam.unproject_position(target.global_position)
	position = screen_pos
