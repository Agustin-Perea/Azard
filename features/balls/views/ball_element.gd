extends MoveableElement
class_name BallElement

@export var ball_data: BallRuntimeState
##para obtener modelo de TableState

@export var drop_active: bool = true

@onready var ball_description_canvas : BallDescription =  $"../BallDescription"
@export var offset_description_canvas: Vector3
@onready var ball_mesh: MeshInstance3D = $ball_mesh


var aura_material: ShaderMaterial

var active : bool = true
var description_active : bool = false

func _ready() -> void:
	super()
			
	#if not aura_material:
		#aura_material = ShaderMaterial.new()
		#aura_material.shader = preload("res://Resources/Shaders/selection_outline.gdshader")
		#aura_material = null
		
	if ball_data:
		_assign_data_model(ball_data)
		

	
	call_deferred("setup")
	

func setup()->void:
	#ball_description_canvas.deactivate_canvas.connect(_deactivate_selection_aura)
	pass


func _assign_data_model(new_data:BallRuntimeState)->void:
	ball_data = new_data
	if ball_data:
		if !active:
			activate()
		if ball_data and ball_data.ball_definition.ball_material:
			ball_mesh.material_override = ball_data.ball_definition.ball_material
		#if ball_mesh and ball_mesh.material_override:
			#ball_mesh.material_override.next_pass = aura_material
			#_deactivate_selection_aura() 
		ball_mesh.visible = true
	else:
		deactivate()


func activate()->void:
	active = true
	ball_mesh.visible = active
	#area3D.process_mode = PROCESS_MODE_INHERIT	
	
func _activate_selection_aura():
	var chip_data = ball_mesh.get_instance_shader_parameter("chip_data") 

	# Si es null, lo inicializamos nosotros
	if chip_data == null:
		chip_data = Vector3(0.0, 0.0, 0.0)

	chip_data.z = 0.005 # Tu grosor
	ball_mesh.set_instance_shader_parameter("chip_data", chip_data)
	
func _deactivate_selection_aura():
	var chip_data = ball_mesh.get_instance_shader_parameter("chip_data") 

	if chip_data == null:
		chip_data = Vector3(0.0, 0.0, 0.0)
		
	chip_data.z = 0.0
	ball_mesh.set_instance_shader_parameter("chip_data", chip_data)
	
func deactivate()->void:
	_deactivate_selection_aura()
	active = false
	ball_mesh.visible = active
	$CollisionShape3D.disabled = true
	
func ball_description_changed()->void:
	deactivate_ball_desctiption()

	
func activate_ball_desctiption()->void:
	if ball_description_canvas.ball_element != self:
			ball_description_canvas.assign_ball_model(self)
			
	
	_activate_selection_aura()
	ball_description_canvas.update_labels()
	ball_description_canvas.position =  self.position + offset_description_canvas
	
	ball_description_canvas.visible = true
		
	#if drop_active:
		#CombatEventBus.update_base_score.emit(data.base_damage)#updatear desde aqui el score esta mal, solo deberia ser representativo

func deactivate_ball_desctiption()->void:
	_deactivate_selection_aura()
	ball_description_canvas.visible = false
	description_active = false
	#if drop_active:
		#CombatEventBus.update_base_score.emit(1)
		
	#



#func on_press(area: ClickableArea) -> void:
	#super(area)
	#
	#activate_ball_desctiption()
		
	
func on_enter() -> void:
	if DragService.dragged == null:
		activate_ball_desctiption()


func on_exit() -> void:
	pass

	
	
##ovverides de Moveable
func stop_drag()->void:
	var field_under_mouse := DragService._get_field_under_mouse()
	DragService._return_to_origin()
	if field_under_mouse and field_under_mouse.get("collider").is_in_group("roulette_collision"):
		_on_chip_dropped()

@warning_ignore("unused_parameter")
func _on_chip_dropped():

	if drop_active:
		use_ball()
	elif description_active:
		deactivate_ball_desctiption()
	else:
		description_active = true
		
	##se agrega el template de ataque(su funcion y demas) se modificara el score
	##del ataque a medida que aumente el daño
	#
	##falta que si vuelve al container se elimine la bet y se  ordene

func use_ball()->void:
	#agrega eventos de la bola
	BookEventBus.start_spin.emit(ball_data)
	#roulette spin with, this ball
	#

	#CombatEventBus.last_ball_data_used = self.data
	#data.on_ball_use()
		#
	##llama al estado de Spin de Ruleta
	#bet_resolver.spin()
	#
	#
	##desactivacion de la bola
	_assign_data_model(null)
	ball_description_canvas.visible = false
	description_active = false
	deactivate_ball_desctiption()


func _on_mouse_entered():
	if DragService.dragged == null:
		activate_ball_desctiption()
