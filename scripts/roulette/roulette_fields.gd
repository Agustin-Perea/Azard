@tool
extends MultiMeshInstance3D
class_name RouletteFields
@export_group("Configuración de Rejilla")

@export var actualizar: bool = false:
	set(val): 
		actualizar = false
		setup_multimesh()

@export var offset_x: float = 0.222
@export var offset_z: float = 0.135

@export_group("Datos de Control")
@export var tabla_instancias: Array = []

@onready var number_labels : Array[Label3D]
@onready var labels : Node3D =  $"../Labels"

var radio_inicial : Vector3 = Vector3(-0.174, 0, 0)
var torque : float = -9.72973
var eje = Vector3.UP # (0, 1, 0)

@export var pos_inicial_label_0 := Vector3(0.016, -0.068, -0.174) # La posición de tu primer label
@export var rot_inicial_label_0 := Vector3(-81.4, 0, -5) # Si el label 0 ya tiene una rotación propia

func _ready() -> void:

	#Table_State.table_ready.connect(_on_table_ready)
	
	var children = labels.get_children()
	
	for child in children:
		if child is Label3D:
			number_labels.append(child)
	
	#ordenar por si acaso
	number_labels.sort_custom(func(a, b): return a.get_index() < b.get_index())
	
	for i in range(37):
		var t = Transform3D()
		t = t.rotated(Vector3.UP, deg_to_rad(torque * i))
		t = t.translated_local(pos_inicial_label_0)
		t = t.rotated_local(Vector3.RIGHT, deg_to_rad(rot_inicial_label_0.x))
		t = t.rotated_local(Vector3.UP, deg_to_rad(rot_inicial_label_0.y))
		t = t.rotated_local(Vector3.BACK, deg_to_rad(rot_inicial_label_0.z))
		number_labels[i].transform = t
	
	setup_multimesh()
	_on_table_ready()
	
	
func setup_multimesh():
	if not multimesh: return
	
	# Forzamos que el MultiMesh use el canal de color por código por si acaso
	#multimesh.use_colors = true

	var all_fields = 37
	
	multimesh.instance_count = all_fields
	tabla_instancias.clear()
	
	for i in range(all_fields):
		tabla_instancias.append(i)
		
		# 1. Posicionamiento XZ
		var angulo_total_rad : float = deg_to_rad(torque * i)
		# Creamos un transform limpio (identidad) en cada iteración
		var t = Transform3D()
		
		# Basis.from_euler es más estable para rotaciones en un solo eje
		t.basis = Basis(eje, angulo_total_rad)
		
		multimesh.set_instance_transform(i, t)

		# 2. Lógica de "Colores" (Transporte de UV)
		# Guardamos el valor 0.25 o 0.50 en el canal ROJO del color.
		var valor_uv = 0.25 if (i + 1) % 2 == 0 else -0.25
		
		# Enviamos el dato a la instancia 'i'
		multimesh.set_instance_color(i, Color(valor_uv, 0, 0, 1))
		

	notify_property_list_changed()

	
func _on_table_ready()-> void:
	for i in tabla_instancias.size():
		update_field_visual(i)
#on field changed(id) este deberia reasignar color al cambiado, en uievents

func update_field_visual(index :int)->void:
	var field := GameState.get_bet_field_model(index)
	number_labels[index].text = str(field.number)

	if field.color == Constants.BET_FIELD_COLOR.RED:
		multimesh.set_instance_color(index, Color(0.25, 0, 0, 1))
		number_labels[index].modulate = Color("000000ff")
	elif field.color == Constants.BET_FIELD_COLOR.BLACK:
		multimesh.set_instance_color(index, Color(0.50, 0, 0, 1))
		number_labels[index].modulate = Color("ffffffff")
	else:
		multimesh.set_instance_color(index, Color(0.00, 0, 0, 1))
		number_labels[index].modulate = Color("ffffffff")

func highlight_field(id : int)->void:
	var field_color_data = multimesh.get_instance_color(id)
	field_color_data.g = 1
	multimesh.set_instance_color(id, field_color_data)
	
func reset_field(id : int)->void:
		var field_color_data = multimesh.get_instance_color(id)
		field_color_data.g = 0
		multimesh.set_instance_color(id, field_color_data)
