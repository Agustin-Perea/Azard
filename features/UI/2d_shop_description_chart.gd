extends Control
class_name PassiveItemShopChart

#data 
#target to follow
@export var passive_item_shop_element: PassiveItemShopElement

#name
@onready var panel_description : PanelContainer = $Panel
@onready var buy_button : Button = get_node_or_null("Button")
@onready var item_name : Label = $Panel/VBoxContainer/Name
@onready var item_description : Label = $Panel/VBoxContainer/Desctiption


@export var target : Node3D 
@onready var cam = get_viewport().get_camera_3d()

#-649.0
func _ready() -> void:
	DragService.dragged_changed.connect(deactivate)
	UiEventBus.deactivate_descriptions.connect(deactivate)
	if buy_button:
		buy_button.pressed.connect(on_button_buy_pressed)
# Usamos _process para que se actualice al mismo ritmo que el renderizado de la pantalla
func _process(_delta):
	if target and cam:
		update_position()

func update_position() -> void:
	# Se ejecuta inmediatamente, en el mismo frame que la cámara
	var screen_pos = cam.unproject_position(target.global_position)
	position = screen_pos

func change_passive_item_data(new_passive_item_shop_element: PassiveItemShopElement) -> void:
	if passive_item_shop_element != new_passive_item_shop_element:
		passive_item_shop_element = new_passive_item_shop_element
		item_name.text = passive_item_shop_element.passive_item_data.passive_item_effect.name
		item_description.text =  passive_item_shop_element.passive_item_data.passive_item_effect.description
		target = passive_item_shop_element
		if target:
			var screen_pos = cam.unproject_position(target.global_position)
			if screen_pos.x > get_viewport_rect().size.x / 2.0:
				panel_description.position.x = -649
			else:
				panel_description.position.x = 143
		activate()
	
func deactivate() ->void:
	self.visible = false
	if buy_button:
		buy_button.disabled = true
	passive_item_shop_element = null

func activate() ->void:
	if buy_button:
		if GameState.economy_component.can_afford(passive_item_shop_element.passive_item_data.base_price):
			buy_button.disabled = false
		else:
			buy_button.disabled = true
	self.visible = true

func on_button_buy_pressed()->void:
	passive_item_shop_element._on_button_buy_pressed()
	deactivate()
	
