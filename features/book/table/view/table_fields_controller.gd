extends Node3D
class_name TableFieldsController

@onready var table_fields : StaticBodyTable_ = $SBTable
@onready var zero_field : StaticBodyTable_ = $SBTZero
@onready var column_fields : StaticBodyTable_ = $SBTC
@onready var row_fields : StaticBodyTable_ = $SBTR
@onready var parity_fields : StaticBodyTable_ = $SBTP


func call_mult_anim(index : int)->void:
	
	if index >=  column_fields.first_index:
		column_fields.call_mult_anim(index)
	elif index >=  row_fields.first_index:
		row_fields.call_mult_anim(index)
	elif index >=  parity_fields.first_index:
		parity_fields.call_mult_anim(index)
	elif index >=  table_fields.first_index:
		table_fields.call_mult_anim(index)
	elif index ==  zero_field.first_index:
		zero_field.call_mult_anim(index)

func get_center_for_index(index: int) -> Vector3:
	if index >=  column_fields.first_index:
		return column_fields.calcular_centro_desde_indice(index)
	elif index >=  row_fields.first_index:
		return row_fields.calcular_centro_desde_indice(index)
	elif index >=  parity_fields.first_index:
		return parity_fields.calcular_centro_desde_indice(index)
	elif index >=  table_fields.first_index:
		return table_fields.calcular_centro_desde_indice(index)
	elif index ==  zero_field.first_index:
		return zero_field.calcular_centro_desde_indice(index)
	return Vector3.ZERO
		
func activate_highlight_field(index :int)->void:
	if index >=  column_fields.first_index:
		column_fields._activate_highlight(index)
	elif index >=  row_fields.first_index:
		row_fields._activate_highlight(index)
	elif index >=  parity_fields.first_index:
		parity_fields._activate_highlight(index)
	elif index >=  table_fields.first_index:
		table_fields._activate_highlight(index)
	elif index ==  zero_field.first_index:
		zero_field._activate_highlight(index)

func highlight_winning_result(index: int) -> void:
	table_fields.table_fields.highlight_winning_result(index)

func deactivate_highlight_field()->void:
		table_fields.table_fields.clear_temporary_highlights()
		column_fields._limpiar_highlight()
		row_fields._limpiar_highlight()
		parity_fields._limpiar_highlight()
		table_fields._limpiar_highlight()
		zero_field._limpiar_highlight()
