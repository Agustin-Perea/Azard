extends SB_Button3D
class_name ExtraOfferSpot

const RARITY_AURA_SHADER := preload("res://resources/materials/shaders/2D/aura_lava.gdshader")
const RARITY_AURA_TEXTURE := preload("res://resources/materials/imported textures/kenney_particle-pack/PNG (Transparent)/star_05.png")

@export var offset_description_canvas: Vector3 = Vector3.ZERO
@export var offset_tooltip_anchor: Vector3 = Vector3.ZERO
@export var shop_offer_index: int = -1

@onready var icon: Sprite3D = $Icon
@onready var price_label: Label3D = $PriceLabel
@onready var price_coin: Sprite3D = $PriceCoin

var current_offer: Dictionary = {}
var rarity_aura: Sprite3D = null

func _ready() -> void:
	super()
	_ensure_rarity_aura()
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
	price_label.visible = true
	price_coin.visible = true
	icon.texture = _offer_icon_texture(offer)
	price_label.text = str(int(offer.get("price", 0)))
	price_coin.texture = coin_texture
	_update_rarity_aura(_offer_rarity_id(offer))
	if rarity_aura != null:
		rarity_aura.visible = true

func set_base_price_visible(value: bool) -> void:
	price_label.visible = value and not current_offer.is_empty()
	price_coin.visible = value and not current_offer.is_empty()

func clear_offer() -> void:
	shop_offer_index = -1
	current_offer.clear()
	_clear_visuals()

func _clear_visuals() -> void:
	enabled = false
	if collision_shape != null:
		collision_shape.disabled = true
	icon.visible = false
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
