extends Node3D
class_name ModelVisualComponent
@export var mesh: MeshInstance3D

var material: ShaderMaterial
var material_overlay: ShaderMaterial

@onready var selection_gizmo : Control = get_node_or_null("Control")

func _ready() -> void:
	# Asegurar instancia única del material
	material = mesh.material_override.duplicate()
	if mesh.material_overlay:
		material_overlay = mesh.material_overlay.duplicate()
		mesh.material_overlay = material_overlay
	mesh.material_override = material
	
	toggle_mi_stand(false)

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
	
func toggle_mi_stand(activado: bool):
	# Al haber usado .duplicate(), esto solo afectará a ESTE personaje
	if material_overlay:
		material_overlay.set_shader_parameter("active", activado)
		if selection_gizmo:
			selection_gizmo.visible = activado

func _play_dissolve(duration: float = 0.5):
	var tween = create_tween()
	material.set_shader_parameter("flash_modifier", 1)
	material.set_shader_parameter("burn_size", .1)
	tween.tween_method(
		func(v): material.set_shader_parameter("dissolve_value", v),
		0.0,
		1.0,
		duration
	)
	
func set_flash_modifier(value : float)->void:
	material.set_shader_parameter("flash_modifier", value)
