extends Node3D

const OFFER_BUTTON_SIZE := Vector2(260, 42)

@onready var ball_spot :  = $left_cover/Ball_Spot
@onready var ball_spot_2 : BallElement = $left_cover/Ball_Spot2
@onready var ball_spot_3 : BallElement = $left_cover/Ball_Spot3

@onready var bingo_chip_spot : BingoChipElement = $left_cover/Bingo_Chip_Spot
@onready var bingo_chip_spot_2 : BingoChipElement = $left_cover/Bingo_Chip_Spot2
@onready var bingo_chip_spot_3 : BingoChipElement = $left_cover/Bingo_Chip_Spot3
#
@onready var reroll_button : SB_Button3D = $left_cover/SB_Button3D
@onready var map_button : SB_Button3D = $left_cover/Next_SB_Button3D

@onready var ball_description_canvas : BallDescription =  $left_cover/BallDescription
#@onready var bingo_chip_info : BingoChipinfo =  $bingo_chip_info

var offer_buttons: Array[Button] = []
var gold_label: Label
var reroll_label: Label


#test reset
@warning_ignore("unused_parameter")
func _on_clickable_area_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:

		await get_tree().process_frame
		#CombatEventBus.reload.emit() esto se debe usar en defeat
		#TransitionLayer._change_scente_to(Constants.TEST_SCENE)
		#get_tree().call_deferred("reload_current_scene")


func _ready() -> void:
	reroll_button.pressed.connect(reroll)
	map_button.pressed.connect(on_map_button_pressed)
	GameState.gold_changed.connect(_on_gold_changed)
	GameState.shop_offers_generated.connect(_on_shop_offers_generated)
	GameState.shop_offer_bought.connect(_on_shop_offer_bought)
	GameState.shop_purchase_failed.connect(_on_shop_purchase_failed)
	_build_shop_overlay()
	if GameState.last_shop_offers.is_empty():
		GameState.generate_shop_offers()
	else:
		_on_shop_offers_generated(GameState.last_shop_offers)
	_on_gold_changed(GameState.run_gold)


func reroll() -> void:
	if not GameState.reroll_shop_offers():
		BookEventBus.popuptext.emit(reroll_button.global_position, "No alcanza el Gold")
	_update_reroll_label()

func _on_shop_offers_generated(offers: Array) -> void:
	_assign_ball_spot(ball_spot, 0)
	_assign_ball_spot(ball_spot_2, 1)
	_assign_ball_spot(ball_spot_3, 2)
	_assign_bingo_chip_spots()
	_refresh_offer_buttons()
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

func _build_shop_overlay() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "ShopOverlay"
	add_child(canvas)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(root)

	gold_label = Label.new()
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	gold_label.add_theme_font_size_override("font_size", 24)
	gold_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	gold_label.position = Vector2(-220, 18)
	gold_label.size = Vector2(200, 34)
	root.add_child(gold_label)

	reroll_label = Label.new()
	reroll_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	reroll_label.add_theme_font_size_override("font_size", 16)
	reroll_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	reroll_label.position = Vector2(-260, 54)
	reroll_label.size = Vector2(240, 26)
	root.add_child(reroll_label)

	for index in range(6):
		var button := Button.new()
		button.size = OFFER_BUTTON_SIZE
		button.position = Vector2(24, 90 + index * 48)
		button.pressed.connect(_on_shop_offer_pressed.bind(index))
		root.add_child(button)
		offer_buttons.append(button)

func _refresh_offer_buttons() -> void:
	for index in range(offer_buttons.size()):
		var button := offer_buttons[index]
		if index >= GameState.last_shop_offers.size():
			button.visible = false
			continue
		var offer := GameState.last_shop_offers[index]
		var price := int(offer.get("price", 0))
		var sold := bool(offer.get("sold", false))
		button.visible = true
		button.disabled = sold
		var prefix := _offer_type_label(str(offer.get("type", "")))
		var suffix := " (vendido)" if sold else " - %d Gold" % price
		button.text = "%s: %s%s" % [prefix, GameState.get_shop_offer_name(offer), suffix]

func _offer_type_label(item_type: String) -> String:
	match item_type:
		GameState.SHOP_ITEM_TYPE_BALL:
			return "Pelota"
		GameState.SHOP_ITEM_TYPE_TRINKET:
			return "Trinket"
		GameState.SHOP_ITEM_TYPE_BOARD_UPGRADE:
			return "Tablero"
	return "Item"

func _on_shop_offer_pressed(index: int) -> void:
	if GameState.buy_shop_offer(index):
		_refresh_offer_buttons()
		_assign_ball_spot(ball_spot, 0)
		_assign_ball_spot(ball_spot_2, 1)
		_assign_ball_spot(ball_spot_3, 2)
	else:
		BookEventBus.popuptext.emit(global_position, "No alcanza el Gold")

func _on_shop_offer_bought(_offer: Dictionary) -> void:
	_refresh_offer_buttons()

func _on_shop_purchase_failed(_offer: Dictionary, _reason: String) -> void:
	BookEventBus.popuptext.emit(global_position, "No alcanza el Gold")

func _on_gold_changed(current_gold: int) -> void:
	if gold_label != null:
		gold_label.text = "Gold: %d" % current_gold
	_refresh_offer_buttons()
	UiEventBus.deactivate_descriptions.emit()

func _update_reroll_label() -> void:
	if reroll_label != null:
		reroll_label.text = "Reroll tienda: %d Gold" % GameState.get_shop_reroll_cost()

func on_map_button_pressed()->void:
	#PlayerUiEvents.change_book_page.emit(Constants.BOOK_PAGE.MAP)
	#preload()
	GameState.temp_scene_changed_value +=1
	get_tree().call_deferred("change_scene_to_file","res://scenes/combat/battle_scene_1.tscn")
	
