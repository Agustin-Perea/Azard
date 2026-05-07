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
	_configure_rendering()
	
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
	
func _configure_rendering() -> void:
	for child in get_children():
		if child is GeometryInstance3D:
			var geometry := child as GeometryInstance3D
			_raise_material_priority(geometry, 90)
		if child is Label3D:
			var label := child as Label3D
			label.no_depth_test = true
		elif child is Sprite3D:
			var sprite := child as Sprite3D
			sprite.no_depth_test = true
			sprite.render_priority = 90

func _raise_material_priority(geometry: GeometryInstance3D, priority: int) -> void:
	var material := geometry.material_override
	if material == null:
		return
	var local_material := material.duplicate()
	local_material.resource_local_to_scene = true
	local_material.set("render_priority", priority)
	if local_material.get("no_depth_test") != null:
		local_material.set("no_depth_test", true)
	geometry.material_override = local_material
