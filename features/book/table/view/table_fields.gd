#@tool
extends MultiMeshInstance3D
class_name TableFields
@export_group("Configuración de Rejilla")

@export var actualizar: bool = false:
	set(val): 
		actualizar = false
		setup_multimesh()

@export var offset_x: float = 0.222
@export var offset_z: float = 0.135


var table_instances: Array = []

@onready var mesh_groups : Node3D = get_node_or_null("../Table_Groups")

@export_group("Datos de Control")
@export var table_instances_groups: Array = [MeshInstance3D]

var number_labels : Array[Label3D]
@onready var labels : Node3D =  $"../Labels"

@export var group_labels : Array[Label3D]

var temporary_highlighted_ids: Array[int] = []




func _ready() -> void:
	
	#Table_State.table_ready.connect(_on_table_ready)
	
	var children = labels.get_children()
	
	for child in children:
		if child is Label3D:
			number_labels.append(child)
	
	if 	mesh_groups:
		var mesh_children = mesh_groups.get_children()
		
		for child in mesh_children:
			if child is MeshInstance3D:
				table_instances_groups.append(child)

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
	table_instances.clear()
	
	for f in range(filas):
		var fila_actual = []
		for c in range(columnas):
			var i = (f * columnas) + c
			table_instances.append(i)
			
			# 1. Posicionamiento XZ
			var t = Transform3D()
			t.origin = Vector3(c * offset_x, 0, f * offset_z)
			multimesh.set_instance_transform(i, t)

			# 2. Lógica de "Colores" (Transporte de UV)
			# Guardamos el valor 0.25 o 0.50 en el canal ROJO del color.
			var valor_uv = 0.25 if (i + 1) % 2 == 0 else -0.25
			
			# Enviamos el dato a la instancia 'i'
			multimesh.set_instance_color(i, Color(valor_uv, 0, 0, 1))
		
		#table_instances.append(fila_actual)
	
	notify_property_list_changed()

func set_table_state_betfields()->void:
	pass
	
	
func _on_table_ready()-> void:
	for i in table_instances.size():
		update_field_visual(i+1)
#on field changed(id) este deberia reasignar color al cambiado, en uievents

func update_field_visual(index :int)->void:
	var field := GameState.get_bet_field_model(index)#cuidado con el
	#print(str(index))
	#print(str(field.number))
	#print(str(field.color))
	#print(number_labels[index].text)
	
	if index > 0 and index <= 37:
		number_labels[index-1].text = str(field.number)
		#print(number_labels[index].text)
		if field.color == Constants.BET_FIELD_COLOR.RED:
			multimesh.set_instance_color(index-1, Color(0.0, 0, 0, 1))
			number_labels[index-1].modulate = Color("000000ff")
		elif field.color == Constants.BET_FIELD_COLOR.BLACK:
			multimesh.set_instance_color(index-1, Color(0.25, 0, 0, 1))
			number_labels[index-1].modulate = Color("ffffffff")
		else:
			multimesh.set_instance_color(index-1, Color(-0.25, 0, 0, 1))
			number_labels[index-1].modulate = Color("ffffffff")
	elif index > 36:
		pass
	elif index == 0:
		pass

func highlight_field(id : int)->void:
	if id > 0 and id < 37:
		var field_color_data = multimesh.get_instance_color(id-1)
		field_color_data.g = 1
		multimesh.set_instance_color(id-1, field_color_data)
	elif id > 36:
		var group_index = id - 36
		if group_index < table_instances_groups.size():
			var mesh_instance = table_instances_groups[group_index]
			var shader_mat = mesh_instance.get_surface_override_material(0)
			mesh_instance.set_instance_shader_parameter("chip_data", Vector3(0.0, 1.0, 0.0))
	elif id == 0:
		var mesh_instance = table_instances_groups[table_instances_groups.size() - 1]
		if mesh_instance == null:
			return
		if not mesh_instance is MeshInstance3D:
			return
		var material = mesh_instance.get_surface_override_material(0)
		if material == null:
			return
		if material is ShaderMaterial:
			mesh_instance.set_instance_shader_parameter("chip_data", Vector3(0.0, 1.0, 0.0))
	
func reset_field(id : int)->void:
	if id > 0 and id < 37:
		var field_color_data = multimesh.get_instance_color(id-1)
		field_color_data.g = 0
		multimesh.set_instance_color(id-1, field_color_data)
	elif id > 36:
		var group_index = id - 36
		if group_index < table_instances_groups.size():
			var mesh_instance = table_instances_groups[group_index]
			var shader_mat = mesh_instance.get_surface_override_material(0)
			
			mesh_instance.set_instance_shader_parameter("chip_data", Vector3(0.0, 0.0, 0.0))
	elif id == 0:
		var mesh_instance = table_instances_groups[table_instances_groups.size() - 1]
		if mesh_instance == null:
			return
		if not mesh_instance is MeshInstance3D:
			return
		var material = mesh_instance.get_surface_override_material(0)
		if material == null:
			return
		if material is ShaderMaterial:
			mesh_instance.set_instance_shader_parameter(
				"chip_data",
				Vector3.ZERO
			)

func clear_temporary_highlights() -> void:
	for id in temporary_highlighted_ids:
		reset_field(id)
	temporary_highlighted_ids.clear()

func preview_coverage(field_id: int) -> void:
	clear_temporary_highlights()
	if not _is_valid_bet_field_id(field_id):
		return
	_add_temporary_highlight(field_id)
	var preview_field := GameState.bet_field_models[field_id] as BetFieldModel
	if preview_field == null or preview_field.ConditionStrategy == null:
		return
	if field_id > 36:
		for i in range(1, min(37, GameState.bet_field_models.size())):
			var candidate := GameState.bet_field_models[i] as BetFieldModel
			if candidate != null and preview_field.ConditionStrategy.matches(candidate, preview_field):
				_add_temporary_highlight(i)
	elif field_id > 0:
		var number := preview_field.number
		var color := preview_field.color
		for i in range(1, min(37, GameState.bet_field_models.size())):
			var candidate := GameState.bet_field_models[i] as BetFieldModel
			if candidate != null and candidate.number == number and candidate.color == color:
				_add_temporary_highlight(i)

func highlight_winning_result(result_field_id: int) -> void:
	clear_temporary_highlights()
	if not _is_valid_bet_field_id(result_field_id):
		return
	_add_temporary_highlight(result_field_id)
	if result_field_id == 0:
		return
	var winner := GameState.bet_field_models[result_field_id] as BetFieldModel
	if winner == null:
		return
	for i in range(37, GameState.bet_field_models.size()):
		var group_field := GameState.bet_field_models[i] as BetFieldModel
		if group_field != null and group_field.ConditionStrategy != null and group_field.ConditionStrategy.matches(winner, group_field):
			_add_temporary_highlight(i)

func _add_temporary_highlight(id: int) -> void:
	if temporary_highlighted_ids.has(id):
		return
	highlight_field(id)
	temporary_highlighted_ids.append(id)

func _is_valid_bet_field_id(id: int) -> bool:
	return id >= 0 and id < GameState.bet_field_models.size()
		
func highlight_equals_field(id : int)->void:
	var number := GameState.bet_field_models[id].number
	var color := GameState.bet_field_models[id].color 

	if id > 0 and id < 37:
		for i in GameState.bet_field_models.size():
			if number == GameState.bet_field_models[i].number and color == GameState.bet_field_models[i].color:
				highlight_field(i)
	elif id > 36:
		highlight_field(id)
		for i in GameState.bet_field_models.size()-12:
			if GameState.bet_field_models[id].ConditionStrategy.matches(GameState.bet_field_models[i],GameState.bet_field_models[id]):
				highlight_field(i)
	elif id == 0:
		highlight_field(id)


func reset_equals_field(id : int)->void:
	var number := GameState.bet_field_models[id].number
	var color := GameState.bet_field_models[id].color
	
	if id >0 and id < 37:
		for i in GameState.bet_field_models.size()-12:
			if number == GameState.bet_field_models[i].number and color == GameState.bet_field_models[i].color:
				reset_field(i)
	elif id > 36:
		reset_field(id)
		for i in GameState.bet_field_models.size()-12:
			if GameState.bet_field_models[id].ConditionStrategy.matches(GameState.bet_field_models[i],GameState.bet_field_models[id]):
				reset_field(i)
	elif id == 0:
		reset_field(id)
