extends ColorRect
class_name shout_animation

var finish_time: float = 2.5
var tween: Tween

@onready var shader_material: ShaderMaterial = material
@onready var shout_spot: Node3D = $"../shout_spot"


func reset() -> void:
	if tween:
		tween.kill()

	_update_shader_center()

	shader_material.set_shader_parameter("time", 0.0)

	tween = create_tween()

	tween.tween_method(
		func(value: float):
			shader_material.set_shader_parameter("time", value),
		0.0,
		finish_time,
		finish_time
	)


func _update_shader_center() -> void:
	var cam = get_viewport().get_camera_3d()

	if not cam:
		return

	# posición pantalla (pixeles)
	var screen_pos = cam.unproject_position(
		shout_spot.global_position
	)

	# pantalla → local ColorRect
	var local_pos = (
		get_global_transform_with_canvas()
		.affine_inverse()
		* screen_pos
	)

	# local → UV
	var uv = local_pos / size

	shader_material.set_shader_parameter(
		"center",
		uv
	)
