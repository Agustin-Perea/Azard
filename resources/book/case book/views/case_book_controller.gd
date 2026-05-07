extends Node3D

const EXTRA_OFFER_TOOLTIP_SCENE := preload("res://features/balls/views/ball_shop_tooltip.tscn")
const PRICE_CHART_MESH := preload("res://resources/3d_UI/price_chart.res")

@onready var ball_spot :  = $left_cover/Ball_Spot
@onready var ball_spot_2 : BallElement = $left_cover/Ball_Spot2
@onready var ball_spot_3 : BallElement = $left_cover/Ball_Spot3
@onready var price_charts: Array[Node3D] = [
	$left_cover/price_chart,
	$left_cover/price_chart2,
	$left_cover/price_chart3,
]

@onready var bingo_chip_spot : BingoChipElement = $left_cover/Bingo_Chip_Spot
@onready var bingo_chip_spot_2 : BingoChipElement = $left_cover/Bingo_Chip_Spot2
@onready var bingo_chip_spot_3 : BingoChipElement = $left_cover/Bingo_Chip_Spot3
@onready var extra_offer_spots := [
	$left_cover/ExtraOfferSpot,
	$left_cover/ExtraOfferSpot2,
	$left_cover/ExtraOfferSpot3,
]
#
@onready var reroll_button : SB_Button3D = $left_cover/SB_Button3D
@onready var map_button : SB_Button3D = $left_cover/Next_SB_Button3D
@onready var reroll_description: Label3D = $left_cover/rerollDescription

@onready var ball_description_canvas : BallDescription =  $left_cover/BallDescription
#@onready var bingo_chip_info : BingoChipinfo =  $bingo_chip_info

const EXTRA_OFFER_TOOLTIP_SCALE := Vector3(0.64, 0.64, 0.64)

var gold_label: Label
var price_labels: Array[Label3D] = []
var price_coins: Array[Sprite3D] = []
var chip_price_charts: Array[MeshInstance3D] = []
var chip_price_labels: Array[Label3D] = []
var chip_price_coins: Array[Sprite3D] = []
var extra_offer_tooltip: BallDescription
var active_extra_offer_index := -1
var coin_texture: Texture2D
var reroll_locked := false


#test reset
@warning_ignore("unused_parameter")
func _on_clickable_area_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:

		await get_tree().process_frame
		#CombatEventBus.reload.emit() esto se debe usar en defeat
		#TransitionLayer._change_scente_to(Constants.TEST_SCENE)
		#get_tree().call_deferred("reload_current_scene")


func _ready() -> void:
	coin_texture = _make_coin_texture()
	reroll_button.pressed.connect(reroll)
	map_button.pressed.connect(on_map_button_pressed)
	GameState.gold_changed.connect(_on_gold_changed)
	GameState.shop_offers_generated.connect(_on_shop_offers_generated)
	GameState.shop_offer_bought.connect(_on_shop_offer_bought)
	GameState.shop_purchase_failed.connect(_on_shop_purchase_failed)
	UiEventBus.deactivate_descriptions.connect(_hide_extra_offer_tooltip)
	_build_shop_overlay()
	_build_price_labels()
	_build_chip_price_labels()
	_build_extra_offer_cards()
	if GameState.last_shop_offers.is_empty():
		GameState.generate_shop_offers()
	else:
		_on_shop_offers_generated(GameState.last_shop_offers)
	_on_gold_changed(GameState.run_gold)


func reroll() -> void:
	if reroll_locked:
		return
	reroll_locked = true
	GameState.reroll_shop_offers()
	_update_reroll_label()
	await get_tree().create_timer(0.35).timeout
	reroll_locked = false

func _on_shop_offers_generated(offers: Array) -> void:
	_assign_ball_spot(ball_spot, 0)
	_assign_ball_spot(ball_spot_2, 1)
	_assign_ball_spot(ball_spot_3, 2)
	_assign_bingo_chip_spots()
	_refresh_shop_visuals()
	_update_reroll_label()
	UiEventBus.deactivate_descriptions.emit()

func _assign_ball_spot(spot: BallElement, offer_index: int) -> void:
	if offer_index >= GameState.last_shop_offers.size():
		spot._assign_data_model(null)
		return
	var offer := GameState.last_shop_offers[offer_index]
	if offer.get("type", "") != GameState.SHOP_ITEM_TYPE_BALL or bool(offer.get("sold", false)):
		spot._assign_data_model(null)
		return
	var definition := offer.get("item", null) as BallDefinition
	if definition == null:
		spot._assign_data_model(null)
		return
	var runtime := BallRuntimeState.new()
	runtime.ball_definition = definition
	runtime.level_upgrade = 1
	runtime.used = false
	spot._assign_data_model(runtime)
	spot.shop_offer_index = offer_index
	spot.shop_price = int(offer.get("price", 0))

func _assign_bingo_chip_spots() -> void:
	if GameState.object_pool_database == null:
		return
	bingo_chip_spot.assign_data_model(GameState.object_pool_database.bingo_chips_constructor.get_random_bet_field_model())
	bingo_chip_spot_2.assign_data_model(GameState.object_pool_database.bingo_chips_constructor.get_random_bet_field_model())
	bingo_chip_spot_3.assign_data_model(GameState.object_pool_database.bingo_chips_constructor.get_random_bet_field_model())
	_assign_shop_chip_price(bingo_chip_spot, 0)
	_assign_shop_chip_price(bingo_chip_spot_2, 1)
	_assign_shop_chip_price(bingo_chip_spot_3, 2)

func _build_shop_overlay() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "ShopOverlay"
	add_child(canvas)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(root)

	var gold_panel := PanelContainer.new()
	gold_panel.name = "GoldHud"
	gold_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	gold_panel.position = Vector2(-180, 14)
	gold_panel.size = Vector2(156, 46)
	gold_panel.custom_minimum_size = Vector2(156, 46)
	gold_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(gold_panel)

	var gold_style := StyleBoxFlat.new()
	gold_style.bg_color = Color(0.055, 0.045, 0.025, 0.94)
	gold_style.border_color = Color(0.95, 0.74, 0.22, 1.0)
	gold_style.set_border_width_all(3)
	gold_style.set_corner_radius_all(9)
	gold_panel.add_theme_stylebox_override("panel", gold_style)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	gold_panel.add_child(row)

	var coin := PanelContainer.new()
	coin.custom_minimum_size = Vector2(30, 30)
	row.add_child(coin)

	var coin_style := StyleBoxFlat.new()
	coin_style.bg_color = Color(1.0, 0.76, 0.18, 1.0)
	coin_style.border_color = Color(0.42, 0.27, 0.05, 1.0)
	coin_style.set_border_width_all(2)
	coin_style.set_corner_radius_all(15)
	coin.add_theme_stylebox_override("panel", coin_style)

	var coin_texture := TextureRect.new()
	coin_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	coin_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin_texture.texture = self.coin_texture
	coin.add_child(coin_texture)

	var gold_label_margin := MarginContainer.new()
	gold_label_margin.add_theme_constant_override("margin_top", 5)
	row.add_child(gold_label_margin)

	gold_label = Label.new()
	gold_label.add_theme_color_override("font_color", Color.WHITE)
	gold_label.add_theme_font_size_override("font_size", 27)
	gold_label.custom_minimum_size = Vector2(66, 32)
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gold_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	gold_label.text = "0"
	gold_label_margin.add_child(gold_label)

func _build_price_labels() -> void:
	price_labels.clear()
	price_coins.clear()
	for chart in price_charts:
		if chart is GeometryInstance3D:
			_raise_material_priority(chart as GeometryInstance3D, 19, false)
		var label := Label3D.new()
		label.name = "PriceLabel"
		label.position = chart.position + Vector3(-0.02, 0.027, 0.015)
		label.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		label.modulate = Color(1.0, 0.92, 0.36, 1.0)
		label.outline_modulate = Color(0.0, 0.0, 0.0, 1.0)
		label.outline_size = 5
		label.font_size = 16
		label.no_depth_test = false
		label.render_priority = 21
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = ""
		$left_cover.add_child(label)
		price_labels.append(label)

		var coin_sprite := Sprite3D.new()
		coin_sprite.name = "PriceCoin"
		coin_sprite.position = chart.position + Vector3(0.075, 0.029, 0.012)
		coin_sprite.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		coin_sprite.texture = coin_texture
		coin_sprite.pixel_size = 0.00105
		coin_sprite.modulate = Color(1.0, 0.95, 0.65, 1.0)
		coin_sprite.no_depth_test = false
		coin_sprite.render_priority = 20
		$left_cover.add_child(coin_sprite)
		price_coins.append(coin_sprite)

func _build_chip_price_labels() -> void:
	chip_price_charts.clear()
	chip_price_labels.clear()
	chip_price_coins.clear()
	var chip_spots: Array[BingoChipElement] = [bingo_chip_spot, bingo_chip_spot_2, bingo_chip_spot_3]
	for spot in chip_spots:
		var chart := MeshInstance3D.new()
		chart.name = "ChipPriceChart"
		chart.mesh = PRICE_CHART_MESH
		chart.position = spot.position + Vector3(0.01, 0.068, -0.175)
		chart.rotation_degrees = Vector3(0.0, 0.0, -7.0)
		chart.scale = Vector3(0.78, 0.78, 0.78)
		_raise_material_priority(chart, 19, false)
		$left_cover.add_child(chart)
		chip_price_charts.append(chart)

		var label := Label3D.new()
		label.name = "ChipPriceLabel"
		label.position = chart.position + Vector3(-0.02, 0.027, 0.015)
		label.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		label.modulate = Color(1.0, 0.92, 0.36, 1.0)
		label.outline_modulate = Color.BLACK
		label.outline_size = 5
		label.font_size = 16
		label.no_depth_test = false
		label.render_priority = 21
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = str(GameState.SHOP_CHIP_MOD_PRICE)
		$left_cover.add_child(label)
		chip_price_labels.append(label)

		var coin_sprite := Sprite3D.new()
		coin_sprite.name = "ChipPriceCoin"
		coin_sprite.position = chart.position + Vector3(0.075, 0.029, 0.012)
		coin_sprite.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		coin_sprite.texture = coin_texture
		coin_sprite.pixel_size = 0.00105
		coin_sprite.no_depth_test = false
		coin_sprite.render_priority = 20
		$left_cover.add_child(coin_sprite)
		chip_price_coins.append(coin_sprite)

func _build_extra_offer_cards() -> void:
	for spot in extra_offer_spots:
		spot.pressed.connect(_on_extra_offer_spot_pressed.bind(spot))
	_build_extra_offer_tooltip()

func _build_extra_offer_tooltip() -> void:
	extra_offer_tooltip = EXTRA_OFFER_TOOLTIP_SCENE.instantiate() as BallDescription
	extra_offer_tooltip.name = "ExtraOfferTooltip"
	extra_offer_tooltip.visible = false
	extra_offer_tooltip.scale = EXTRA_OFFER_TOOLTIP_SCALE
	extra_offer_tooltip.spin = false
	$left_cover.add_child(extra_offer_tooltip)
	_disable_extra_offer_tooltip_aura()
	_configure_extra_offer_tooltip_rendering()
	extra_offer_tooltip.button.pressed.connect(_buy_active_extra_offer)
	_hide_extra_offer_tooltip()

func _disable_extra_offer_tooltip_aura() -> void:
	if extra_offer_tooltip == null:
		return
	var tooltip_aura := extra_offer_tooltip.get_node_or_null("aura") as Sprite3D
	if tooltip_aura != null:
		tooltip_aura.visible = false

func _configure_extra_offer_tooltip_rendering() -> void:
	_raise_material_priority(extra_offer_tooltip, 100)
	for child in extra_offer_tooltip.get_children():
		if child is GeometryInstance3D:
			_raise_material_priority(child as GeometryInstance3D, 101)
		if child is Label3D:
			var label := child as Label3D
			label.no_depth_test = true
		elif child is Sprite3D:
			var sprite := child as Sprite3D
			sprite.no_depth_test = true
			sprite.render_priority = 101

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

func _refresh_shop_visuals() -> void:
	for index in range(price_labels.size()):
		var has_offer := index < GameState.last_shop_offers.size()
		var offer := GameState.last_shop_offers[index] if has_offer else {}
		var is_ball := has_offer and str(offer.get("type", "")) == GameState.SHOP_ITEM_TYPE_BALL
		var sold := has_offer and bool(offer.get("sold", false))
		var visible := is_ball and not sold
		price_charts[index].visible = visible
		price_labels[index].visible = visible
		price_coins[index].visible = visible
		price_labels[index].text = str(int(offer.get("price", 0))) if visible else ""
	_refresh_extra_offer_cards()

func _refresh_extra_offer_cards() -> void:
	for spot in extra_offer_spots:
		spot.clear_offer()

func _on_shop_offer_pressed(index: int) -> void:
	if GameState.buy_shop_offer(index):
		_refresh_shop_visuals()
		_assign_ball_spot(ball_spot, 0)
		_assign_ball_spot(ball_spot_2, 1)
		_assign_ball_spot(ball_spot_3, 2)
	else:
		BookEventBus.popuptext.emit(global_position, "No alcanza el Gold", true)

func _on_extra_offer_spot_pressed(spot) -> void:
	if spot.shop_offer_index < 0:
		return
	UiEventBus.deactivate_descriptions.emit()
	await get_tree().process_frame
	_show_extra_offer_tooltip(spot.shop_offer_index)

func _on_shop_offer_bought(_offer: Dictionary) -> void:
	_refresh_shop_visuals()

func _on_shop_purchase_failed(offer: Dictionary, reason: String) -> void:
	var text := "No alcanza el Gold"
	if reason == "potion_already_bought":
		text = "Ya compraste una pocion"
	BookEventBus.popuptext.emit(_shop_offer_popup_position(offer), text, true)

func _on_gold_changed(current_gold: int) -> void:
	if gold_label != null:
		gold_label.text = str(current_gold)
	_refresh_shop_visuals()
	UiEventBus.deactivate_descriptions.emit()

func _update_reroll_label() -> void:
	if reroll_description != null:
		reroll_description.text = "Reroll\n%d G" % GameState.get_shop_reroll_cost()

func _assign_shop_chip_price(spot: BingoChipElement, index: int) -> void:
	if index < 0 or index >= chip_price_charts.size() or index >= chip_price_labels.size() or index >= chip_price_coins.size():
		spot.set_shop_price(GameState.SHOP_CHIP_MOD_PRICE)
		return
	var visuals: Array[Node3D] = [chip_price_charts[index], chip_price_labels[index], chip_price_coins[index]]
	spot.set_shop_price(GameState.SHOP_CHIP_MOD_PRICE, visuals)

func _show_extra_offer_tooltip(offer_index: int) -> void:
	if offer_index < 0 or offer_index >= GameState.last_shop_offers.size():
		_hide_extra_offer_tooltip()
		return
	var offer := GameState.last_shop_offers[offer_index]
	if bool(offer.get("sold", false)):
		_hide_extra_offer_tooltip()
		return
	if str(offer.get("type", "")) != GameState.SHOP_ITEM_TYPE_POTION:
		_hide_extra_offer_tooltip()
		return
	var local_index := offer_index - 3
	if local_index < 0 or local_index >= extra_offer_spots.size():
		_hide_extra_offer_tooltip()
		return
	var base_position := _extra_offer_tooltip_position(local_index)
	active_extra_offer_index = offer_index
	extra_offer_spots[local_index].set_base_price_visible(false)
	extra_offer_tooltip.position = base_position
	extra_offer_tooltip.scale = EXTRA_OFFER_TOOLTIP_SCALE
	extra_offer_tooltip.ball_name.text = GameState.get_shop_offer_name(offer)
	extra_offer_tooltip.base_damage_text.text = _rarity_name_for_offer(offer)
	extra_offer_tooltip.base_damage_text.font_size = 12
	extra_offer_tooltip.base_damage_text.modulate = _offer_rarity_color(offer)
	extra_offer_tooltip.description.text = _short_offer_description(offer)
	extra_offer_tooltip.description.font_size = 12
	extra_offer_tooltip.description.width = 140.0
	extra_offer_tooltip.action_text.text = "comprar"
	extra_offer_tooltip.action_text.font_size = 15
	_disable_extra_offer_tooltip_aura()
	extra_offer_tooltip.visible = true
	extra_offer_tooltip.button.collision_shape.disabled = false
	extra_offer_tooltip.deactivate_button.collision_shape.disabled = true

func _extra_offer_tooltip_position(local_index: int) -> Vector3:
	var spot = extra_offer_spots[local_index]
	return spot.position + spot.offset_description_canvas

func _buy_active_extra_offer() -> void:
	if active_extra_offer_index < 0:
		return
	var index := active_extra_offer_index
	if GameState.buy_shop_offer(index):
		_hide_extra_offer_tooltip()
		_refresh_shop_visuals()

func _hide_extra_offer_tooltip() -> void:
	if active_extra_offer_index >= 3:
		var local_index := active_extra_offer_index - 3
		if local_index >= 0 and local_index < extra_offer_spots.size():
			extra_offer_spots[local_index].set_base_price_visible(true)
	if extra_offer_tooltip != null:
		extra_offer_tooltip.visible = false
		extra_offer_tooltip.button.collision_shape.disabled = true
	active_extra_offer_index = -1

func _short_offer_description(offer: Dictionary) -> String:
	var text := GameState.get_shop_offer_description(offer).strip_edges().replace("\n", " ")
	var max_length := 110
	if text.length() <= max_length:
		return text
	return text.substr(0, max_length - 3).strip_edges() + "..."

func _rarity_name_for_offer(offer: Dictionary) -> String:
	if str(offer.get("type", "")) == GameState.SHOP_ITEM_TYPE_POTION:
		return "Pocion"
	var item = offer.get("item", null)
	if item == null or not item.has_method("get_rarity_id"):
		return "Common"
	match int(item.get_rarity_id()):
		2:
			return "Uncommon"
		3:
			return "Rare"
		4:
			return "Epic"
		5:
			return "Legendary"
		_:
			return "Common"

func _offer_rarity_color(offer: Dictionary) -> Color:
	if str(offer.get("type", "")) == GameState.SHOP_ITEM_TYPE_POTION:
		return Color(0.95, 0.24, 0.32, 1.0)
	var item = offer.get("item", null)
	if item == null or not item.has_method("get_rarity_id"):
		return Color.WHITE
	var rarity_id := int(item.get_rarity_id())
	match rarity_id:
		2:
			return Color(0.3, 0.95, 0.42, 1.0)
		3:
			return Color(0.35, 0.62, 1.0, 1.0)
		4:
			return Color(0.75, 0.25, 1.0, 1.0)
		5:
			return Color(1.0, 0.78, 0.18, 1.0)
		_:
			return Color(0.78, 0.78, 0.68, 1.0)

func _shop_offer_popup_position(offer: Dictionary) -> Vector3:
	if not offer.has("type"):
		return reroll_button.global_position
	var offer_index := GameState.last_shop_offers.find(offer)
	match offer_index:
		0:
			return ball_spot.global_position
		1:
			return ball_spot_2.global_position
		2:
			return ball_spot_3.global_position
		3, 4, 5:
			var local_index := offer_index - 3
			if local_index >= 0 and local_index < extra_offer_spots.size():
				return extra_offer_spots[local_index].global_position
	return global_position

func _make_coin_texture() -> Texture2D:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y in range(64):
		for x in range(64):
			var offset: Vector2 = Vector2(float(x) - 31.5, float(y) - 31.5)
			var distance: float = offset.length()
			if distance > 30.0:
				image.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var rim: bool = distance > 24.0
			var shine: float = max(0.0, 1.0 - offset.distance_to(Vector2(-12.0, -14.0)) / 28.0)
			var shade: float = clamp((offset.y + 30.0) / 60.0, 0.0, 1.0)
			var color: Color = Color(0.96, 0.66, 0.12, 1.0).lerp(Color(0.55, 0.28, 0.04, 1.0), shade * 0.45)
			color = color.lerp(Color(1.0, 0.94, 0.52, 1.0), shine * 0.42)
			if rim:
				color = Color(0.64, 0.35, 0.06, 1.0).lerp(Color(1.0, 0.84, 0.28, 1.0), shine * 0.35)
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)

func on_map_button_pressed()->void:
	#PlayerUiEvents.change_book_page.emit(Constants.BOOK_PAGE.MAP)
	#preload()
	GameState.temp_scene_changed_value +=1
	get_tree().call_deferred("change_scene_to_file","res://scenes/combat/battle_scene_1.tscn")
	
