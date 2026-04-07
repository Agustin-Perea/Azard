extends StaticBody3D
class_name StaticBodyTable

const SIZE_X = 0.668
const SIZE_Z = 1.626
const COLUMNAS = 3
const FILAS = 12

@onready var table_fields : TableFields = $"../Bet_Fields"


var last_field_entered : int = -1
func _on_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:

	if event is InputEventMouseMotion or (event is InputEventMouseButton and event.pressed):
		
		var col_node = $CollisionShape3D
		var shape = col_node.shape as BoxShape3D
		
		if not shape: return

		# 1. Dimensiones y offset
		var size = shape.size
		var centro_local = col_node.transform.origin
		
		# 2. Convertir el impacto global a local del objeto
		var click_local = to_local(event_position)
		
		# 3. Ajustar posición relativa al inicio de la caja (esquina -size/2)
		var pos_relativa_caja_x = click_local.x - centro_local.x + (size.x / 2.0)
		var pos_relativa_caja_z = click_local.z - centro_local.z + (size.z / 2.0)
		
		# 4. Normalizar (0.0 a 1.0)
		var x_norm = clamp(pos_relativa_caja_x / size.x, 0.0, 0.99)
		var z_norm = clamp(pos_relativa_caja_z / size.z, 0.0, 0.99)
		
		# 5. Calcular índices (3 columnas, 12 filas)
		var col = int(x_norm * 3)
		var fila = int(z_norm * 12)
		
		# 6. Número final 1-36
		var numero_celda = (fila * 3) + col
		print(numero_celda)
		# 7. Solo emitir/cambiar si es una celda nueva (para no saturar)
		if numero_celda != last_field_entered:
			if last_field_entered >= 0 and last_field_entered < 36:
				table_fields.reset_equals_field(last_field_entered+1)
			last_field_entered = numero_celda
			table_fields.highlight_equals_field(numero_celda+1)
		
func _on_mouse_exited() -> void:
	if last_field_entered > -1 and last_field_entered < 36:
		table_fields.reset_equals_field(last_field_entered+1)
		last_field_entered = -1

func calcular_indice_desde_posicion(global_pos: Vector3) -> int:
	var col_node = $CollisionShape3D
	var shape = col_node.shape as BoxShape3D
	if not shape: return -1

	# Tu lógica matemática original:
	var size = shape.size
	var centro_local = col_node.transform.origin
	var click_local = to_local(global_pos) # Usamos la pos global del raycast

	var pos_relativa_caja_x = click_local.x - centro_local.x + (size.x / 2.0)
	var pos_relativa_caja_z = click_local.z - centro_local.z + (size.z / 2.0)

	var x_norm = clamp(pos_relativa_caja_x / size.x, 0.0, 0.99)
	var z_norm = clamp(pos_relativa_caja_z / size.z, 0.0, 0.99)

	var col = int(x_norm * 3)
	var fila = int(z_norm * 12)

	return (fila * 3) + col
	
	
	
func calcular_centro_desde_indice(indice: int) -> Vector3:
	var col_node = $CollisionShape3D
	var shape = col_node.shape as BoxShape3D
	if not shape or indice < 0 or indice >= 36: return Vector3.ZERO

	var size = shape.size
	var centro_local_caja = col_node.transform.origin

	# 1. Obtener fila y columna desde el índice (Inversa de fila * 3 + col)
	var fila = int(indice / 3)
	var col = indice % 3

	# 2. Calcular el tamaño de cada celda individual
	var ancho_celda = size.x / 3.0
	var largo_celda = size.z / 12.0

	# 3. Calcular el centro de la celda en espacio local de la caja
	# Empezamos desde la esquina (-size/2) y sumamos (celda * n) + (media celda)
	var local_x = (-size.x / 2.0) + (col * ancho_celda) + (ancho_celda / 2.0)
	var local_z = (-size.z / 2.0) + (fila * largo_celda) + (largo_celda / 2.0)

	# 4. Ajustar según el offset de la colisión y pasar a coordenadas globales
	var punto_local = Vector3(local_x + centro_local_caja.x, centro_local_caja.y +.1, local_z + centro_local_caja.z)
	
	return to_global(punto_local)
	
func update_field(index : int)->void:
	table_fields.update_field_visual(index+1)


#se deberia desactivar junto a las clickablesares, incluso el collision
func call_mult_anim(index : int)->void:
	pass
	#var multiplicator_indicator = CombatEventBus.multiplicator_indicator
	#print("Referencia del objeto: ", multiplicator_indicator)
	#
	#if multiplicator_indicator != null:
		#var pos := calcular_centro_desde_indice(index-1)
		#pos.y += 0.1
		#multiplicator_indicator.animate_in_pos(pos,"+"+str(int(Table_State.fields[index-1].multiplier)),true)
	#else:
		#print("EL OBJETO multiplicator_indicator ES NULO")


func _on_mouse_entered() -> void:
	pass # Replace with function body.
