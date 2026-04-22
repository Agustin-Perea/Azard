extends StaticBody3D
class_name StaticBodyTable_

var size_x_collider = 0.668
var size_z_collider = 1.626
@export var columns = 3
@export var rows = 12

@export var first_index = 0

@onready var table_fields : TableFields = $"../Bet_Fields"


var last_field_entered : int = -1

func _ready() -> void:
	UiEventBus.change_collision_detection.connect(_on_change_collision_detection)

func _on_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	# Solo procesamos si el mouse está entrando o moviéndose DENTRO
	if event is InputEventMouseMotion or (event is InputEventMouseButton and event.pressed):
		var numero_celda = calcular_indice_desde_posicion(event_position)
		
		if numero_celda != last_field_entered:
			_limpiar_highlight() # Limpiamos el anterior antes de marcar el nuevo
			last_field_entered = numero_celda
			table_fields.highlight_equals_field(numero_celda)

# Esta función detecta eventos en CUALQUIER parte de la pantalla
func _input(event: InputEvent) -> void:
	# Si el usuario suelta el click izquierdo en cualquier lugar del juego
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			_limpiar_highlight()

func _on_mouse_exited() -> void:
	# Si salimos del área pero NO estamos presionando el click, limpiamos.
	# Si estamos presionando el click, el _input general se encargará cuando suelte.
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_limpiar_highlight()

func _activate_highlight(numero_celda : int) -> void:
	_limpiar_highlight() # Limpiamos el anterior antes de marcar el nuevo
	last_field_entered = numero_celda
	table_fields.highlight_equals_field(numero_celda)

func _limpiar_highlight() -> void:
	if last_field_entered != -1:
		table_fields.reset_equals_field(last_field_entered)
		last_field_entered = -1

func calcular_indice_desde_posicion(global_pos: Vector3) -> int:
	var col_node = $CollisionShape3D
	var shape = col_node.shape as BoxShape3D
	if not shape: return -1

	var size = shape.size
	var centro_local = col_node.transform.origin
	var click_local = to_local(global_pos)

	# 1. Posición relativa al borde de la caja (esquina inferior izquierda)
	var pos_relativa_caja_x = click_local.x - centro_local.x + (size.x / 2.0)
	var pos_relativa_caja_z = click_local.z - centro_local.z + (size.z / 2.0)

	# 2. Normalización (0.0 a 0.99)
	var x_norm = clamp(pos_relativa_caja_x / size.x, 0.0, 0.99)
	var z_norm = clamp(pos_relativa_caja_z / size.z, 0.0, 0.99)

	# 3. Mapeo a la cuadrícula usando las variables
	var col = int(x_norm * columns)
	var row = int(z_norm * rows)

	# 4. Índice lineal (IMPORTANTE: Se multiplica por num_columnas)
	return first_index + (row * columns) + col
	
	
	
func calcular_centro_desde_indice(indice: int) -> Vector3:
	var col_node = $CollisionShape3D
	var shape = col_node.shape as BoxShape3D
	indice -= first_index

	
	# Validamos que el índice no se pase del total (columnas * filas)
	if not shape or indice < 0 or indice >= (columns * rows): 
		return Vector3.ZERO

	var size = shape.size
	var centro_local_caja = col_node.transform.origin

	# 1. Obtener fila y columna dinámicamente
	var fila = int(indice / columns)
	var col = indice % columns

	# 2. Calcular el tamaño de cada celda según los parámetros recibidos
	var ancho_celda = size.x / float(columns)
	var largo_celda = size.z / float(rows)

	# 3. Calcular el centro de la celda (Local a la caja)
	# Partimos del borde izquierdo/superior (-size/2)
	var x_local = (-size.x / 2.0) + (col * ancho_celda) + (ancho_celda / 2.0)
	var z_local = (-size.z / 2.0) + (fila * largo_celda) + (largo_celda / 2.0)

	# 4. Sumamos el offset del CollisionShape y elevamos un poco en Y (+.1)
	var punto_local = Vector3(
		x_local + centro_local_caja.x, 
		centro_local_caja.y+.02, 
		z_local + centro_local_caja.z
	)
	
	return to_global(punto_local)
	
func update_field(index : int)->void:
	table_fields.update_field_visual(index)


#se deberia desactivar junto a las clickablesares, incluso el collision
func call_mult_anim(index : int)->void:
	#esto es una negrada
	var multiplicator_indicator = $"../../../Temp/PopUpText"
	#print("Referencia del objeto: ", multiplicator_indicator)
	
	if multiplicator_indicator != null:
		var pos := calcular_centro_desde_indice(index)
		pos.y += 0.1
		multiplicator_indicator.animate_in_pos(pos,"+"+str(int(GameState.bet_field_models[index].multiplier)),true)


func _on_mouse_entered() -> void:
	pass # Replace with function body.

func _on_change_collision_detection(value : bool):
	$CollisionShape3D.disabled = value
