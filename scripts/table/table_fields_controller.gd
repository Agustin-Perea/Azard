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
