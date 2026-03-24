# BetFieldData.gd
extends Resource
class_name BetFieldModel



signal fieldChanged

#refactor
@warning_ignore("unused_signal")
signal isSelected
@warning_ignore("unused_signal")
signal activateHighlight
@warning_ignore("unused_signal")
signal desactivateHighlight
@warning_ignore("unused_signal")
signal mult_anim
@warning_ignore("unused_signal")
signal call_betfield_animation

	
@export var number: int:
	set(value):
		number = value
		fieldChanged.emit()

		
@export var multiplier: float = 36
@export var multiplier_by_level: float = 18 #la mitad pero en realidad hay que ver

@export var ConditionStrategy: BetCondition 


@export var color: Constants.BET_FIELD_COLOR = Constants.BET_FIELD_COLOR.RED
@export var parity: Constants.BET_FIELD_PARITY = Constants.BET_FIELD_PARITY.EVEN
@export var half_table: Constants.BET_FIELD_HALF_TABLE = Constants.BET_FIELD_HALF_TABLE.LESS_18
@export var column: Constants.BET_FIELD_COLUMN = Constants.BET_FIELD_COLUMN.COLUMN_1ST
@export var row: Constants.BET_FIELD_ROW = Constants.BET_FIELD_ROW.ROW_1ST


@export var modifiable: bool = true

func copy_metadata(new_model:BetFieldModel)->void:
	if modifiable:
		self.ConditionStrategy = new_model.ConditionStrategy
		#señal de cambio
		self.fieldChanged.emit()
		
		#refactor
		self.color = new_model.color
		self.parity = new_model.parity
		self.half_table = new_model.half_table
