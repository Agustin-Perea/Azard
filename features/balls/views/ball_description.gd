extends MeshInstance3D
class_name BallDescription
@onready var ball_name : Label3D = $Name
@onready var base_damage_text : Label3D = $BaseDamage
@onready var description: Label3D = $Description
@onready var action_text: Label3D = $Spin
@onready var button: SB_Button3D = $Spin_Button3D
@onready var deactivate_button: SB_Button3D = $X_Button3D
@onready var aura: Sprite3D = $aura

@export var ball_element : BallElement

@export var spin : bool = false

signal deactivate_canvas

var rarity_text: Label3D = null

func _ready() -> void:
	_ensure_rarity_label()
	_configure_tooltip_rendering()
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
	var is_shop_offer := ball_element.shop_offer_index >= 0
	var rarity_id := definition.get_rarity_id()
	var rarity_color := _rarity_color(rarity_id)
	ball_name.text = definition.get_display_name()
	ball_name.font_size = 18 if is_shop_offer else 34
	var base_damage := definition.get_damage_for_level(ball_element.ball_data.level_upgrade)
	if is_shop_offer:
		base_damage_text.text = "Base\n%d" % base_damage
		base_damage_text.position = Vector3(0.73, 0.077, 0.02)
	else:
		base_damage_text.text = "Base damage\n%d" % base_damage
		base_damage_text.position = Vector3(0.12, 0.009922445, -1.01)
	base_damage_text.font_size = 16 if is_shop_offer else 24
	base_damage_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.text = _fit_description(definition.get_description(), is_shop_offer)
	description.font_size = 14 if is_shop_offer else 21
	description.width = 140.0 if is_shop_offer else 280.0
	_update_rarity_label(rarity_id, rarity_color, is_shop_offer)
	_update_aura_color(rarity_color)
	if action_text != null:
		if is_shop_offer:
			action_text.text = "comprar"
			action_text.font_size = 17
		else:
			action_text.text = "usar"
			action_text.font_size = 18

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
		BookEventBus.popuptext.emit(ball_element.global_position, "No alcanza el Gold", true)
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

func _fit_description(text: String, is_shop_offer: bool) -> String:
	var clean := text.strip_edges().replace("\n", " ")
	var max_length := 110 if is_shop_offer else 170
	if clean.length() <= max_length:
		return clean
	return clean.substr(0, max_length - 3).strip_edges() + "..."

func _ensure_rarity_label() -> void:
	if rarity_text != null:
		return
	rarity_text = Label3D.new()
	rarity_text.name = "Rarity"
	rarity_text.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	rarity_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rarity_text.outline_modulate = Color.BLACK
	add_child(rarity_text)

func _update_rarity_label(rarity_id: int, rarity_color: Color, is_shop_offer: bool) -> void:
	if rarity_text == null:
		_ensure_rarity_label()
	rarity_text.text = _rarity_name(rarity_id)
	rarity_text.modulate = rarity_color
	rarity_text.font_size = 14 if is_shop_offer else 20
	rarity_text.outline_size = 5
	rarity_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	rarity_text.width = 96.0 if is_shop_offer else 170.0
	rarity_text.position = Vector3(0.29, 0.079, -0.106) if is_shop_offer else Vector3(-0.64, 0.013, -1.29)

func _configure_tooltip_rendering() -> void:
	_raise_material_priority(self, 80)
	for child in get_children():
		if child is GeometryInstance3D:
			var geometry := child as GeometryInstance3D
			_raise_material_priority(geometry, 81)
		if child is Label3D:
			var label := child as Label3D
			label.no_depth_test = true
		elif child is Sprite3D:
			var sprite := child as Sprite3D
			sprite.no_depth_test = true
			sprite.render_priority = 81

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

func _update_aura_color(rarity_color: Color) -> void:
	if aura == null:
		return
	var shader_material := aura.material_override as ShaderMaterial
	if shader_material == null:
		aura.modulate = rarity_color
		return
	shader_material = shader_material.duplicate() as ShaderMaterial
	aura.material_override = shader_material
	shader_material.set_shader_parameter("color_aura", rarity_color)

func _rarity_name(rarity_id: int) -> String:
	match rarity_id:
		Constants.BALL_RARITY.RARITY_UNCOMMON:
			return "Uncommon"
		Constants.BALL_RARITY.RARITY_RARE:
			return "Rare"
		Constants.BALL_RARITY.RARITY_EPIC:
			return "Epic"
		Constants.BALL_RARITY.RARITY_LEGENDARY:
			return "Legendary"
		_:
			return "Common"

func _rarity_color(rarity_id: int) -> Color:
	match rarity_id:
		Constants.BALL_RARITY.RARITY_UNCOMMON:
			return Color(0.3, 0.95, 0.42, 1.0)
		Constants.BALL_RARITY.RARITY_RARE:
			return Color(0.35, 0.62, 1.0, 1.0)
		Constants.BALL_RARITY.RARITY_EPIC:
			return Color(0.75, 0.25, 1.0, 1.0)
		Constants.BALL_RARITY.RARITY_LEGENDARY:
			return Color(1.0, 0.78, 0.18, 1.0)
		_:
			return Color(0.43, 0.43, 0.36, 1.0)
