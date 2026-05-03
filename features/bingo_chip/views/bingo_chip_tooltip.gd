extends Node3D
class_name BingoChipTooltip


@onready var description: Label3D = $Description
@onready var use_button: SB_Button3D = get_node_or_null("SB_Button3D")
@onready var button_collision: CollisionShape3D = $SB_Button3D/CollisionShape3D
#
var bingo_chip_element: BingoChipElement

func _ready() -> void:
	#DragService.dragged_changed.connect(deactivate)
	UiEventBus.deactivate_descriptions.connect(deactivate)
	pass
	
func activate()->void:
	#UiEventBus.deactivate_descriptions.emit()
	visible = true
	button_collision.disabled = false
	
func deactivate()->void:
	visible = false
	button_collision.disabled = true
	if bingo_chip_element:
		bingo_chip_element.deactivate_chip_info()
		bingo_chip_element = null

func assign_bingo_chip_element(bingo_chip_elem : BingoChipElement)->void:
	activate()
	bingo_chip_element = bingo_chip_elem
	
	
