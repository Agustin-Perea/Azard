extends MoveableElement
class_name BallElement

@export var ball_data: BallRuntimeState
##para obtener modelo de TableState

@export var drop_active: bool = true

@onready var ball_description_canvas : BallDescription =  $"../BallDescription"
@export var offset_description_canvas: Vector3
@onready var ball_mesh: MeshInstance3D = $ball_mesh


var active : bool = true
var description_active : bool = false



var shop_price: int = 0

@onready var aura : Sprite3D = $Sprite3D_aura

const AURA_MATERIALS : Array[ShaderMaterial] = [
	preload(Constants.RARITY_MATERIAL_ROUTES[Constants.RARITY.COMMON]),
	preload(Constants.RARITY_MATERIAL_ROUTES[Constants.RARITY.RARE]),
	preload(Constants.RARITY_MATERIAL_ROUTES[Constants.RARITY.EPIC]),
	preload(Constants.RARITY_MATERIAL_ROUTES[Constants.RARITY.LEGENDARY])
]



func _ready() -> void:
	super()
			
	#if not aura_material:
		#aura_material = ShaderMaterial.new()
		#aura_material.shader = preload("res://Resources/Shaders/selection_outline.gdshader")
		#aura_material = null
		
	if ball_data:
		_assign_data_model(ball_data)


func _assign_data_model(new_data:BallRuntimeState)->void:
	ball_data = new_data
	if ball_data:
		if !active:
			activate()
		if ball_data and ball_data.ball_definition.ball_material:
			ball_mesh.material_override = ball_data.ball_definition.ball_material
		
		match ball_data.ball_definition.rarity:
			Constants.RARITY.COMMON:
				aura.material_override = AURA_MATERIALS[0]
			Constants.RARITY.RARE:
				aura.material_override = AURA_MATERIALS[1]
			Constants.RARITY.EPIC:
				aura.material_override = AURA_MATERIALS[2]
			Constants.RARITY.LEGENDARY:
				aura.material_override = AURA_MATERIALS[3]
	
		#if ball_mesh and ball_mesh.material_override:
			#ball_mesh.material_override.next_pass = aura_material
			#_deactivate_selection_aura() 
		ball_mesh.visible = true
	else:
		deactivate()


func activate()->void:
	active = true
	ball_mesh.visible = active
	aura.visible = active
	$CollisionShape3D.disabled = false

	
func _activate_selection_aura():
	#var chip_data = ball_mesh.get_instance_shader_parameter("chip_data") 
#
	## Si es null, lo inicializamos nosotros
	#if chip_data == null:
		#chip_data = Vector3(0.0, 0.0, 0.0)
#
	#chip_data.z = 0.005 # Tu grosor
	#ball_mesh.set_instance_shader_parameter("chip_data", chip_data)
	pass
	
func _deactivate_selection_aura():
	#var chip_data = ball_mesh.get_instance_shader_parameter("chip_data") 
#
	#if chip_data == null:
		#chip_data = Vector3(0.0, 0.0, 0.0)
		#
	#chip_data.z = 0.0
	#ball_mesh.set_instance_shader_parameter("chip_data", chip_data)
	pass
	
func deactivate()->void:
	_deactivate_selection_aura()
	active = false
	ball_mesh.visible = active
	aura.visible = active
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

func deactivate_ball_desctiption()->void:
	_deactivate_selection_aura()
	ball_description_canvas.visible = false
	description_active = false



func on_press() -> void:
	super()
	if ball_data:
		activate_ball_desctiption()
		
	
func on_enter() -> void:
	super()
	if DragService.dragged == null && ball_data:
		activate_ball_desctiption()


func on_exit() -> void:
	super()
	pass

	
	
##ovverides de Moveable
func stop_drag()->void:
	var field_under_mouse := DragService._get_field_under_mouse()
	DragService._return_to_origin()
	if ball_data and field_under_mouse and field_under_mouse.get("collider").is_in_group("roulette_collision"):
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
	BookEventBus.turn_log_close_requested.emit()
	BookEventBus.start_spin.emit(ball_data)
	##desactivacion de la bola
	_assign_data_model(null)
	ball_description_canvas.visible = false
	description_active = false
	deactivate_ball_desctiption()


func _on_mouse_entered():
	if DragService.dragged == null && ball_data:
		BookEventBus.turn_log_close_requested.emit()
		activate_ball_desctiption()
