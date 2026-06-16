extends Node3D

# Sintaxis real de Godot 4 con @onready
@onready var nodo_enemigos: Node3D = $Enemies
@onready var nodo_particles: Node3D = $GpuParticles
@onready var nodo_shaders: Node3D = $Shaders


func _ready() -> void:
	# Asegurarnos de que todo empiece oculto y apagado
	preparar_escena()
	UiHud.visible = false
	# En Godot 4, las funciones asíncronas se esperan directamente con await
	await compilar_nodos_simples(nodo_enemigos)
	await compilar_nodos_simples(nodo_shaders)
	await compilar_particulas(nodo_particles)
	
	# Terminado el proceso, vamos al menú principal
	ir_al_menu_principal()

func preparar_escena() -> void:
	# Hacemos visibles los contenedores padres
	nodo_enemigos.visible = true
	nodo_shaders.visible = true
	nodo_particles.visible = true
	
	# Ocultamos cada elemento hijo individualmente
	for child in nodo_enemigos.get_children():
		if child is Node3D:
			child.visible = false
			
	for child in nodo_shaders.get_children():
		if child is Node3D:
			child.visible = false
			
	for child in nodo_particles.get_children():
		if child is GPUParticles3D:
			child.visible = false
			child.emitting = false

# Controlador para Meshes, Sprite3D y nodos comunes
func compilar_nodos_simples(nodo_padre: Node3D) -> void:
	for objeto in nodo_padre.get_children():
		if objeto is Node3D:
			# 1. Lo hacemos visible frente a la cámara de carga
			objeto.visible = true
			
			# 2. Reemplazo de yield por await en Godot 4
			await get_tree().process_frame
			await get_tree().process_frame
			
			# 3. Lo ocultamos para seguir con el próximo
			objeto.visible = false

# Controlador especial para GPUParticles3D (Godot 4)
func compilar_particulas(nodo_padre: Node3D) -> void:
	for particula in nodo_padre.get_children():
		if particula is GPUParticles3D:
			# 1. Activamos visibilidad y emisión
			particula.visible = true
			particula.emitting = true
			
			# 2. Esperamos los dos frames críticos para procesar el material de la partícula
			await get_tree().process_frame
			await get_tree().process_frame
			await get_tree().create_timer(.1).timeout
			# 3. Apagamos la emisión y ocultamos
			particula.emitting = false
			particula.visible = false

func ir_al_menu_principal() -> void:
	# Sintaxis de cambio de escena corregida para Godot 4
	get_tree().change_scene_to_file(Constants.MAIN_MENU_SCENE_PATH)
