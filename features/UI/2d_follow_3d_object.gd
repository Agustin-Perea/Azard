extends Control

@export var target : Node3D 
@export var girar : bool = false # Activa o desactiva el giro desde el inspector
@export var velocidad_giro : float = -1.0 # Velocidad de rotación (en radianes por segundo)

@onready var cam = get_viewport().get_camera_3d()

func _process(delta):
	# Mantener la posición atada al objeto 3D
	if is_instance_valid(cam) and is_instance_valid(target):
		var screen_pos = cam.unproject_position(target.global_position)
		position = screen_pos
	
	# Si el bool "girar" está activo, rotamos el nodo 2D
	if girar:
		rotation += velocidad_giro * delta
