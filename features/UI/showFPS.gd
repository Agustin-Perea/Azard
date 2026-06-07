extends Control

@onready var double_velocity_checkbutton : CheckButton = $HBoxContainer/DoubleVelocityCheck
@onready var limit_checkbutton : CheckButton = $HBoxContainer/Limit30Check

func _ready() -> void:
	double_velocity_checkbutton.toggled.connect(on_double_velocity_checkbutton)
	limit_checkbutton.toggled.connect(on_limit_checkbutton)
	
	# Sincronizar el estado inicial de los botones
	double_velocity_checkbutton.button_pressed = Engine.time_scale > 1
	limit_checkbutton.button_pressed = Engine.max_fps == 30

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	$FPS.text = str(int(Engine.get_frames_per_second()))

func on_double_velocity_checkbutton(pressed: bool) -> void:
	if pressed:
		UiEventBus.TIME_SCALE = 2.0
	else:
		UiEventBus.TIME_SCALE = 1.0
		
	Engine.time_scale = UiEventBus.TIME_SCALE
	
func on_limit_checkbutton(pressed: bool) -> void:
	if pressed:
		Engine.max_fps = 30
	else:
		Engine.max_fps = 0
