extends MeshInstance3D
class_name BallDescription
@onready var ball_name : Label3D = $Name
@onready var base_damage_text : Label3D = $BaseDamage
@onready var description: Label3D = $Description
@onready var button: SB_Button3D = $Spin_Button3D
@onready var deactivate_button: SB_Button3D = $X_Button3D

@export var ball_element : BallElement

@export var spin : bool = false

signal deactivate_canvas

func _ready() -> void:
	if button:
		if spin:
			button.pressed.connect(spin_with_ball)
		else:
			button.pressed.connect(add_ball)
	if deactivate_button:
		deactivate_button.pressed.connect(deactivate)
	DragService.dragged_changed.connect(deactivate)
	UiEventBus.deactivate_descriptions.connect(deactivate)

	
func assign_ball_model(new_model : BallElement)->void:
	if ball_element:
		ball_element.ball_description_changed()
	ball_element = new_model
	update_labels()
	
func update_labels()->void:
	button.collision_shape.disabled = false
	deactivate_button.collision_shape.disabled = false
	
	var definition := ball_element.ball_data.ball_definition
	ball_name.text = definition.get_display_name()
	base_damage_text.text = str(definition.get_damage_for_level(ball_element.ball_data.level_upgrade))
	description.text = definition.get_description()

@warning_ignore("unused_parameter")
func add_ball()->void:
	if ball_element == null:
		return
	var bought := true
	if ball_element.shop_offer_index >= 0:
		bought = GameState.buy_shop_offer(ball_element.shop_offer_index)
	else:
		GameState.add_ball(ball_element.ball_data)
	if not bought:
		BookEventBus.popuptext.emit(ball_element.global_position, "No alcanza el Gold")
		return
	self.visible = false
	ball_element._assign_data_model(null)

@warning_ignore("unused_parameter")
func spin_with_ball()->void:
	#enviar esta bola al book con spin
	if ball_element != null and ball_element.use_ball():
		deactivate()

func deactivate()->void:
	deactivate_canvas.emit()
	button.collision_shape.disabled = true
	deactivate_button.collision_shape.disabled = true
	self.visible = false

func activate()->void:
	button.collision_shape.disabled = false
	deactivate_button.collision_shape.disabled = false
	self.visible = true
