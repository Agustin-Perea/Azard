extends Camera3D

@export var amplitud_movimiento: Vector3 = Vector3(0.1, 0.15, 0.0) # Movimiento (X, Y, Z)
@export var amplitud_rotacion: Vector3 = Vector3(0.02, 0.02, 0.01) # Rotación sutil
@export var velocidad: float = 1.8

var posicion_inicial: Vector3
var rotacion_inicial: Vector3
var tiempo: float = 0.0

func _ready() -> void:
	posicion_inicial = global_position
	rotacion_inicial = rotation

func _physics_process(delta: float) -> void:
	tiempo += delta
	
	# 1. Loop de posición (Bobbing)
	var offset_pos = Vector3.ZERO
	offset_pos.x = sin(tiempo * velocidad) * amplitud_movimiento.x
	offset_pos.y = cos(tiempo * velocidad * 0.7) * amplitud_movimiento.y # Desfase para que sea más natural
	
	global_position = posicion_inicial + offset_pos
	
	# 2. Loop de rotación sutil (Cámara en mano)
	var offset_rot = Vector3.ZERO
	offset_rot.x = sin(tiempo * velocidad * 0.5) * amplitud_rotacion.x
	offset_rot.y = cos(tiempo * velocidad) * amplitud_rotacion.y
	offset_rot.z = sin(tiempo * velocidad * 1.5) * amplitud_rotacion.z
	
	rotation = rotacion_inicial + offset_rot
