@tool
extends MultiMeshInstance3D
class_name TableFields
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

func _ready() -> void:

	#Table_State.table_ready.connect(_on_table_ready)
	
	var children = labels.get_children()
	
	for child in children:
		if child is Label3D:
			number_labels.append(child)
	
	#ordenar por si acaso
	number_labels.sort_custom(func(a, b): return a.get_index() < b.get_index())
	setup_multimesh()
	_on_table_ready()
	
func setup_multimesh():
	if not multimesh: return
	
	# Forzamos que el MultiMesh use el canal de color por código por si acaso
	#multimesh.use_colors = true
	
	var columnas = 3
	var filas = 12
	var total = columnas * filas
	
	multimesh.instance_count = total
	tabla_instancias.clear()
	
	for f in range(filas):
		var fila_actual = []
		for c in range(columnas):
			var i = (f * columnas) + c
			tabla_instancias.append(i)
			
			# 1. Posicionamiento XZ
			var t = Transform3D()
			t.origin = Vector3(c * offset_x, 0, f * offset_z)
			multimesh.set_instance_transform(i, t)

			# 2. Lógica de "Colores" (Transporte de UV)
			# Guardamos el valor 0.25 o 0.50 en el canal ROJO del color.
			var valor_uv = 0.25 if (i + 1) % 2 == 0 else -0.25
			
			# Enviamos el dato a la instancia 'i'
			multimesh.set_instance_color(i, Color(valor_uv, 0, 0, 1))
		
		#tabla_instancias.append(fila_actual)
	
	notify_property_list_changed()

func set_table_state_betfields()->void:
	pass
	
	
func _on_table_ready()-> void:
	for i in tabla_instancias.size():
		update_field_visual(i)
#on field changed(id) este deberia reasignar color al cambiado, en uievents

func update_field_visual(index :int)->void:
	var field := GameState.get_bet_field_model(index+1)
	#print(str(index))
	#print(str(field.number))
	#print(str(field.color))
	#print(number_labels[index].text)
	number_labels[index].text = str(field.number)
	#print(number_labels[index].text)
	if field.color == Constants.BET_FIELD_COLOR.RED:
		multimesh.set_instance_color(index, Color(0.0, 0, 0, 1))
		number_labels[index].modulate = Color("000000ff")
	elif field.color == Constants.BET_FIELD_COLOR.BLACK:
		multimesh.set_instance_color(index, Color(0.25, 0, 0, 1))
		number_labels[index].modulate = Color("ffffffff")
	else:
		multimesh.set_instance_color(index, Color(-0.25, 0, 0, 1))
		number_labels[index].modulate = Color("ffffffff")

func highlight_field(id : int)->void:
	if id >=0 and id < number_labels.size():  
		var field_color_data = multimesh.get_instance_color(id)
		field_color_data.g = 1
		multimesh.set_instance_color(id, field_color_data)
	
func reset_field(id : int)->void:
	if id >=0 and id < number_labels.size(): 
		var field_color_data = multimesh.get_instance_color(id)
		field_color_data.g = 0
		multimesh.set_instance_color(id, field_color_data)
		
func highlight_equals_field(id : int)->void:
	var number := GameState.bet_field_models[id+1].number
	var color := GameState.bet_field_models[id+1].color 
	if id >=0 and id < number_labels.size(): 
		for i in GameState.bet_field_models.size():
			if number == GameState.bet_field_models[i].number and color == GameState.bet_field_models[i].color:
				highlight_field(i-1)

func reset_equals_field(id : int)->void:
	var number := GameState.bet_field_models[id+1].number
	var color := GameState.bet_field_models[id+1].color
	if id >=0 and id < number_labels.size(): 
		for i in GameState.bet_field_models.size():
			if number == GameState.bet_field_models[i].number and color == GameState.bet_field_models[i].color:
				reset_field(i-1)
