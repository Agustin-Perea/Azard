extends Node3D

@export var mesh: MeshInstance3D

var material: ShaderMaterial

func _ready() -> void:
	# Asegurar instancia única del material
	material = mesh.material_override.duplicate()
	mesh.material_override = material


func _play_hit_flash(duration: float = 0.5):
	var tween = create_tween()

	# Subida rápida a blanco
	tween.tween_method(
		func(v): material.set_shader_parameter("flash_modifier", v),
		0.0,
		1.0,
		duration * 0.1
	)

	# Bajada suave
	tween.tween_method(
		func(v): material.set_shader_parameter("flash_modifier", v),
		1.0,
		0.0,
		duration * .9
	)


func _play_dissolve(duration: float = 0.5):
	var tween = create_tween()

	tween.tween_method(
		func(v): material.set_shader_parameter("dissolve_value", v),
		0.0,
		1.0,
		duration
	)
