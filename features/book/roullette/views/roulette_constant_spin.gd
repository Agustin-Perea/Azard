extends Node3D

@export var rotation_speed: float = 1.0 # Velocidad de giro

func _physics_process(delta: float) -> void:
	# Esto rota la orientación (basis) sin tocar la posición absoluta
	rotate_y(rotation_speed * delta)
