extends MoveableElement
class_name PassiveItemElement

@export var passive_item_data: PassiveItemDefinition


@onready var sprite3d : Sprite3D = $Sprite3D

@onready var description_canvas : PassiveItemDescription =  $PassiveItemDescription

#colisiones de los botones
@export var add_collision : CollisionShape3D
@export var item_collision : CollisionShape3D

@export var next_camera : Camera3D

func _ready() -> void:
	super()

	#data = ObjectPoolsDataBase.passive_item_pool_definition.get_random_item()
	#sprite3d.texture = data.image_texture
	activate()
	description_canvas.add_button.pressed.connect(_on_button_add_pressed)
	
	
#ovverides de Moveable
func stop_drag()->void:
	DragService._return_to_origin()
	

func on_press() -> void:
	super()
	description_canvas.visible = !description_canvas.visible


@warning_ignore("unused_parameter")
func on_release() -> void:
	pass

@warning_ignore("unused_parameter")
func on_enter() -> void:
	#mostrar datos
	#update base_score
	if DragService.dragged == null or DragService.dragged == self:
		description_canvas.description.text = passive_item_data.get_description()
		description_canvas.name_label.text = passive_item_data.get_display_name()

		

@warning_ignore("unused_parameter")
func on_exit() -> void:
	#dejar de mostrar datos
	#if Drag_Service.dragged == null:
	#	description_canvas.visible = false
	pass




@warning_ignore("unused_parameter")
func _on_chip_dropped(container_area: Area3D):
	#description_canvas.visible = false
	pass

@warning_ignore("unused_parameter")
func _on_button_add_pressed()->void:
	GameState.add_passive_item(passive_item_data)
	deactivate()
	
func activate()->void:
	#data = ObjectPoolsDataBase.passive_item_pool_definition.get_random_item()
	sprite3d.texture = passive_item_data.image_texture
	
	item_collision.disabled = true
	add_collision.disabled = false
	description_canvas.description.text = passive_item_data.get_description()
	description_canvas.name_label.text = passive_item_data.get_display_name()
	description_canvas.visible = true
	

func deactivate()->void:
	item_collision.disabled = true
	add_collision.disabled = true
	self.visible = false
	#go to mapbook
	#PlayerUiEvents.change_book_page.emit(Constants.BOOK_PAGE.MAP)
	#CameraEventBus.changeCamera.emit(next_camera,0.5)
