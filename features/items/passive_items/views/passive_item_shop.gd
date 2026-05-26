extends StaticBody3D
class_name PassiveItemShopElement

@export var passive_item_data: PassiveItemDefinition

@onready var sprite3d : Sprite3D = $Sprite3D
@onready var item_chart : MeshInstance3D = $item_chart
@onready var description_canvas : PassiveItemShopChart = $"../PassiveItemShopDescritpion"
@onready var price_label : Label3D = $PriceLabel

@onready var self_collision : CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	passive_item_data = GameState.object_pool_database.passive_item_pool_definition.get_random_item()
	price_label.text = "$" + str(passive_item_data.base_price)
	activate()
	

func on_press() -> void:
	description_canvas.change_passive_item_data(self)
	

@warning_ignore("unused_parameter")
func on_enter() -> void:
	#mostrar datos
	#update base_score
	#if DragService.dragged == null or DragService.dragged == self:
		#description_canvas.description.text = passive_item_data.passive_item_effect.description
		#description_canvas.name_label.text = passive_item_data.passive_item_effect.name
	pass
		



@warning_ignore("unused_parameter")
func _on_button_buy_pressed()->void:
	if GameState.economy_component.can_afford(passive_item_data.base_price):
		GameState.economy_component.spend_run_gold(passive_item_data.base_price)
		GameState.add_passive_item(passive_item_data)

	deactivate()
	

func activate()->void:
	self.visible = true
	self_collision.disabled = false
	sprite3d.texture = passive_item_data.image_texture


func deactivate()->void:
	self.visible = false
	self_collision.disabled = true
	#description_canvas.deactivate()

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		# Filtramos para que SÓLO responda al click izquierdo
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				on_press()
