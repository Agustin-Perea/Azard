extends Control

@onready var camera_3d: Camera3D = $Camera3D
# Un marcador en (0,1,0) frente a la cámara para mover las cosas ahí
var spot_de_carga: Vector3 = Vector3(0,1,0)

var batch_actual: Array[Dictionary] = []
var animaciones_congeladas: Array[Dictionary] = []

func _ready() -> void:
	UiEventBus.scene_changed.connect(procesar_escena_real)

func procesar_escena_real() -> void:
	print("procesando")
	
	# REGLA DE ORO 1: Hacer visible la pantalla de carga YA MISMO.
	# Esto tapa la pantalla inmediatamente, antes de cualquier await, evitando el flashazo de la cámara del nivel.
	self.visible = true
	
	# REGLA DE ORO 2: Guardar y congelar la velocidad del motor en el acto.
	# No importa si venías a velocidad x2, x10 o en cámara lenta, acá todo se frena.
	var velocidad_ant: float = Engine.time_scale
	Engine.time_scale = 0.0
	
	# Esperamos el frame técnico obligatorio para que el SceneTree termine de acomodar la escena nueva
	await get_tree().process_frame
	
	# Ahora que pasó el frame con el tiempo congelado, agarramos las cámaras de forma segura
	var camera_ant: Camera3D = get_viewport().get_camera_3d()
	camera_3d.make_current()
	
	var escena_actual = get_tree().current_scene
	print("Escena detectada: ", escena_actual.name if escena_actual else "NULA")
	
	if escena_actual:
		batch_actual.clear()
		animaciones_congeladas.clear()
		
		# Congelamos los reproductores de animación para que no fuercen tracks de invisibilidad
		_pausar_animaciones_recursivo(escena_actual)
		
		# Ejecutamos tu recolección por lotes de a 3 (completamente segura en velocidad 0.0)
		await recorrer_nodos_recursivo(escena_actual)
		
		if batch_actual.size() > 0:
			await procesar_lote_actual()
			
		# Devolvemos la vida a los nodos de animación
		_restaurar_animaciones()
		
	# Devolvemos el control a la cámara real del juego
	if camera_ant and is_instance_valid(camera_ant):
		camera_ant.make_current()
		
	# RESTAURAR VELOCIDAD ORIGINAL: Si venías en x2, acá el juego vuelve limpiamente a x2
	Engine.time_scale = velocidad_ant
	
	# Finalmente ocultamos el lienzo de carga
	self.visible = false

# Pausa física de los nodos de animación
func _pausar_animaciones_recursivo(nodo: Node) -> void:
	if nodo is AnimationPlayer or nodo is AnimationTree:
		animaciones_congeladas.append({
			"nodo": nodo,
			"modo_original": nodo.process_mode
		})
		nodo.process_mode = PROCESS_MODE_DISABLED
		
	for hijo in nodo.get_children():
		_pausar_animaciones_recursivo(hijo)

# Restauración de los modos de procesamiento de animación
func _restaurar_animaciones() -> void:
	for info in animaciones_congeladas:
		var nodo = info["nodo"]
		if is_instance_valid(nodo):
			nodo.process_mode = info["modo_original"]
	animaciones_congeladas.clear()

# Recorredor recursivo por lotes con carriles separados para GPUParticles3D
func recorrer_nodos_recursivo(nodo: Node) -> void:
	var debe_procesar: bool = false
	
	if nodo is Node3D:
		var det = nodo.global_transform.basis.determinant()
		if abs(det) >= 0.0001:
			if nodo is GPUParticles3D:
				if not nodo.emitting:
					debe_procesar = true
			else:
				if not nodo.visible:
					debe_procesar = true

	if debe_procesar:
		var info = {
			"nodo": nodo,
			"posicion_original": nodo.global_position,
			"visibility_original": nodo.visible,
			"estaba_emitiendo": false
		}
		
		if nodo is GPUParticles3D:
			info["estaba_emitiendo"] = nodo.emitting
		
		batch_actual.append(info)
		
		if batch_actual.size() == 3:
			await procesar_lote_actual()

	for hijo in nodo.get_children():
		await recorrer_nodos_recursivo(hijo)

# Procesamiento de lotes de a 3 (Los awaits acá responden al reloj interno, estables en time_scale = 0)
func procesar_lote_actual() -> void:
	for info in batch_actual:
		var nodo = info["nodo"]
		if is_instance_valid(nodo):
			nodo.global_position = spot_de_carga
			nodo.visible = true
			nodo.force_update_transform()
			
			if nodo is GPUParticles3D:
				nodo.restart()
				nodo.emitting = true
				
	await get_tree().process_frame
	await get_tree().process_frame
	
	for info in batch_actual:
		var nodo = info["nodo"]
		if is_instance_valid(nodo):
			nodo.visible = info["visibility_original"]
			nodo.global_position = info["posicion_original"]
			
			if nodo is GPUParticles3D:
				nodo.emitting = info["estaba_emitiendo"]
				if info["estaba_emitiendo"]:
					nodo.restart()
					
	batch_actual.clear()
