extends StaticBody3D
class_name BetGroupItemElement

@export var bet_group_item_data: BetGroupItemDefinition

@onready var sprite3d : Sprite3D = $Sprite3D #obj



@onready var description_canvas : BetGroupItemChart = $"../BetGroupItemDescritpion"
@onready var price_label : Label3D = $PriceLabel

@onready var self_collision : CollisionShape3D = $CollisionShape3D

var price : int = 4

func _ready() -> void:
	#crear random por rng 
	
	activate()

func assign_bet_group_item(new_bet_group_item_data: BetGroupItemDefinition)->void:
	bet_group_item_data = new_bet_group_item_data
	price_label.text = str(bet_group_item_data.base_price)
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
	if GameState.economy_component.can_afford(bet_group_item_data.base_price):
		GameState.economy_component.spend_run_gold(bet_group_item_data.base_price)
		GameState.add_bet_group_level_up(bet_group_item_data.group_upgrade)

	deactivate()
	

func activate()->void:
	self.visible = true
	self_collision.disabled = false
	sprite3d.texture = bet_group_item_data.image_texture

func deactivate()->void:
	self.visible = false
	self_collision.disabled = true


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		# Filtramos para que SÓLO responda al click izquierdo
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				on_press()
