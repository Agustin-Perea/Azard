extends SB_Button3D
class_name ExtraOfferSpot

const PRICE_CHART_MESH := preload("res://resources/3d_UI/price_chart.res")
const RARITY_AURA_SHADER := preload("res://resources/materials/shaders/2D/aura_lava.gdshader")
const RARITY_AURA_TEXTURE := preload("res://resources/materials/imported textures/kenney_particle-pack/PNG (Transparent)/star_05.png")

@export var offset_description_canvas: Vector3 = Vector3.ZERO
@export var offset_tooltip_anchor: Vector3 = Vector3.ZERO
@export var shop_offer_index: int = -1

@onready var icon: Sprite3D = $Icon
@onready var price_label: Label3D = $PriceLabel
@onready var price_coin: Sprite3D = $PriceCoin

var current_offer: Dictionary = {}
var price_chart: MeshInstance3D = null
var rarity_aura: Sprite3D = null
var potion_texture: Texture2D = null

func _ready() -> void:
	super()
	_ensure_price_chart()
	_ensure_rarity_aura()
	_configure_price_rendering()
	_clear_visuals()
	set_process(true)

func assign_offer(offer_index: int, offer: Dictionary, coin_texture: Texture2D) -> void:
	shop_offer_index = offer_index
	current_offer = offer
	visible = true
	enabled = true
	if collision_shape != null:
		collision_shape.disabled = false
	icon.visible = true
	if price_chart != null:
		price_chart.visible = true
	price_label.visible = true
	price_coin.visible = true
	icon.texture = _offer_icon_texture(offer)
	price_label.text = str(int(offer.get("price", 0)))
	price_coin.texture = coin_texture
	_update_rarity_aura(_offer_rarity_id(offer))
	if rarity_aura != null:
		rarity_aura.visible = true

func set_base_price_visible(value: bool) -> void:
	var should_show := value and not current_offer.is_empty()
	if price_chart != null:
		price_chart.visible = should_show
	price_label.visible = should_show
	price_coin.visible = should_show

func clear_offer() -> void:
	shop_offer_index = -1
	current_offer.clear()
	_clear_visuals()

func _clear_visuals() -> void:
	enabled = false
	if collision_shape != null:
		collision_shape.disabled = true
	icon.visible = false
	if price_chart != null:
		price_chart.visible = false
	price_label.visible = false
	price_coin.visible = false
	if rarity_aura != null:
		rarity_aura.visible = false

func _process(_delta: float) -> void:
	if rarity_aura == null or not visible or current_offer.is_empty():
		return
	if rarity_aura.get_parent() == get_parent():
		rarity_aura.position = position + Vector3(0.1, 0.018, -0.13)
		rarity_aura.rotation_degrees = Vector3(-90.0, 0.0, 0.0)

func _ensure_price_chart() -> void:
	if price_chart != null:
		return
	price_chart = MeshInstance3D.new()
	price_chart.name = "PriceChart"
	price_chart.mesh = PRICE_CHART_MESH
	price_chart.position = Vector3(0.1, 0.006, 0.016)
	price_chart.rotation_degrees = Vector3(0.0, 0.0, -7.0)
	price_chart.scale = Vector3(0.4, 0.4, 0.4)
	add_child(price_chart)

func _configure_price_rendering() -> void:
	if price_chart != null:
		_raise_material_priority(price_chart, 19, false)
	price_label.no_depth_test = false
	price_label.render_priority = 21
	price_coin.no_depth_test = false
	price_coin.render_priority = 20

func _raise_material_priority(geometry: GeometryInstance3D, priority: int, no_depth := true) -> void:
	var material: Material = geometry.material_override
	if material == null and geometry is MeshInstance3D:
		var mesh_instance := geometry as MeshInstance3D
		if mesh_instance.mesh != null and mesh_instance.mesh.get_surface_count() > 0:
			material = mesh_instance.mesh.surface_get_material(0)
	if material == null:
		return
	var local_material := material.duplicate()
	local_material.resource_local_to_scene = true
	local_material.set("render_priority", priority)
	if local_material.get("no_depth_test") != null:
		local_material.set("no_depth_test", no_depth)
	geometry.material_override = local_material

func _ensure_rarity_aura() -> void:
	if rarity_aura != null:
		return
	rarity_aura = Sprite3D.new()
	rarity_aura.name = "%s_RarityAura" % name
	rarity_aura.texture = RARITY_AURA_TEXTURE
	rarity_aura.pixel_size = 0.0008
	rarity_aura.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	rarity_aura.render_priority = 20
	rarity_aura.no_depth_test = true
	var shader_material := ShaderMaterial.new()
	shader_material.shader = RARITY_AURA_SHADER
	shader_material.set_shader_parameter("radio_base", 0.236)
	shader_material.set_shader_parameter("velocidad_giro", 0.62)
	shader_material.set_shader_parameter("intensidad_lava", 0.05)
	shader_material.set_shader_parameter("suavizado", 0.1)
	rarity_aura.material_override = shader_material
	rarity_aura.visible = false
	if get_parent() != null:
		get_parent().add_child.call_deferred(rarity_aura)
	else:
		add_child.call_deferred(rarity_aura)

func _update_rarity_aura(rarity_id: int) -> void:
	if rarity_aura == null:
		_ensure_rarity_aura()
	var shader_material := rarity_aura.material_override as ShaderMaterial
	if shader_material == null:
		return
	shader_material.set_shader_parameter("color_aura", _rarity_color(rarity_id))
	shader_material.set_shader_parameter("radio_base", 0.236)

func _offer_icon_texture(offer: Dictionary) -> Texture2D:
	if str(offer.get("type", "")) == GameState.SHOP_ITEM_TYPE_POTION:
		if potion_texture == null:
			potion_texture = _make_potion_texture()
		return potion_texture
	var item = offer.get("item", null)
	if item == null:
		return null
	var texture = item.get("image_texture")
	return texture as Texture2D

func _offer_rarity_id(offer: Dictionary) -> int:
	var item = offer.get("item", null)
	if item == null or not item.has_method("get_rarity_id"):
		return Constants.BALL_RARITY.RARITY_COMMON
	return int(item.get_rarity_id())

func _rarity_color(rarity_id: int) -> Color:
	match rarity_id:
		Constants.BALL_RARITY.RARITY_UNCOMMON:
			return Color(0.3, 0.95, 0.42, 0.42)
		Constants.BALL_RARITY.RARITY_RARE:
			return Color(0.35, 0.62, 1.0, 0.5)
		Constants.BALL_RARITY.RARITY_EPIC:
			return Color(0.75, 0.25, 1.0, 0.58)
		Constants.BALL_RARITY.RARITY_LEGENDARY:
			return Color(1.0, 0.78, 0.18, 0.65)
		_:
			return Color(0.55, 0.63, 0.72, 0.72)

func _make_potion_texture() -> Texture2D:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y in range(64):
		for x in range(64):
			image.set_pixel(x, y, Color(0, 0, 0, 0))
	for y in range(10, 50):
		for x in range(22, 42):
			var in_neck: bool = y < 22 and x >= 27 and x <= 36
			var center: Vector2 = Vector2(31.5, 38.0)
			var in_body: bool = y >= 22 and Vector2(float(x), float(y)).distance_to(center) <= 18.0
			if not in_neck and not in_body:
				continue
			var highlight: float = max(0.0, 1.0 - Vector2(float(x), float(y)).distance_to(Vector2(26.0, 24.0)) / 22.0)
			var color: Color = Color(0.92, 0.14, 0.24, 1.0).lerp(Color(1.0, 0.72, 0.78, 1.0), highlight * 0.45)
			image.set_pixel(x, y, color)
	for y in range(7, 12):
		for x in range(25, 39):
			image.set_pixel(x, y, Color(0.42, 0.21, 0.11, 1.0))
	return ImageTexture.create_from_image(image)
