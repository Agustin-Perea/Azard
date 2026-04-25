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
		#else:
			#button.pressed.connect(add_ball)
	if deactivate_button:
		deactivate_button.pressed.connect(deactivate)
	DragService.dragged_changed.connect(deactivate)


	
func assign_ball_model(new_model : BallElement)->void:
	if ball_element:
		ball_element.ball_description_changed()
	ball_element = new_model
	update_labels()
	
func update_labels()->void:
	button.collision_shape.disabled = false
	deactivate_button.collision_shape.disabled = false

	ball_name.text = ball_element.ball_data.ball_definition.ball_effect.name
	base_damage_text.text = str(ball_element.ball_data.ball_definition.base_damage)
	description.text = ball_element.ball_data.ball_definition.ball_effect.description

#@warning_ignore("unused_parameter")
#func add_ball(area : Area3D)->void:
	#self.visible = false
	#GameState.balls.all_balls.push_back(ball_element.data)
	#ball_element._assign_data_model(null)

@warning_ignore("unused_parameter")
func spin_with_ball()->void:
	#enviar esta bola al book con spin
	ball_element.use_ball()
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
