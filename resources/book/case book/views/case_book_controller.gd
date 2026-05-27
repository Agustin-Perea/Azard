extends Node3D


@onready var left_cover : MeshInstance3D = $left_cover
@onready var right_cover : MeshInstance3D = $right_cover
@onready var bottom_cover : MeshInstance3D = $bottom_cover

@onready var ball_spot : BallElement = $left_cover/Ball_Spot
@onready var ball_spot_2 : BallElement = $left_cover/Ball_Spot2
@onready var ball_spot_3 : BallElement = $left_cover/Ball_Spot3

@onready var price_chart_ball : Label3D = $left_cover/price_chart_text/Label3D
@onready var price_chart_ball_2 : Label3D = $left_cover/price_chart_text2/Label3D
@onready var price_chart_ball_3 : Label3D = $left_cover/price_chart_text3/Label3D

@onready var bingo_chip_spot : BingoChipElement = $left_cover/Bingo_Chip_Spot
@onready var bingo_chip_spot_2 : BingoChipElement = $left_cover/Bingo_Chip_Spot2
@onready var bingo_chip_spot_3 : BingoChipElement = $left_cover/Bingo_Chip_Spot3

@onready var price_chart_chip : Label3D = $left_cover/price_chart_bet_chip/Label3D
@onready var price_chart_chip_2 : Label3D = $left_cover/price_chart_bet_chip2/Label3D
@onready var price_chart_chip_3 : Label3D = $left_cover/price_chart_bet_chip3/Label3D

@onready var reroll_price_chart : Label3D = $left_cover/price_chart_reroll/Label3D

@onready var reroll_button : SB_Button3D = $left_cover/SB_Button3D
@onready var map_button : SB_Button3D = $left_cover/Next_SB_Button3D
@onready var next_label : Label3D = $left_cover/next
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var audio_stream : AudioStreamPlayer = $AudioStreamPlayer

@onready var ball_description_canvas : BallDescription =  $left_cover/BallDescription
#@onready var bingo_chip_info : BingoChipinfo =  $bingo_chip_info




const SHOP_BALL_PRICES := {
	Constants.RARITY_ID.COMMON: 5,
	Constants.RARITY_ID.RARE: 7,
	Constants.RARITY_ID.EPIC: 8,
	Constants.RARITY_ID.LEGENDARY: 10,
}

const SHOP_REROLL_PRICE_BASE := 5
const SHOP_REROLL_PRICE_UPDATE := 1
var Shop_rerolls_count : int = 0 
var actual_reroll_price : int = 5

const SHOP_BASE_CHIP_MOD_PRICE := 4 #si este sale modificado se agrega el precio por modificacion
const SHOP_POTION_PRICE := 5

const SUMMARY_LEFT_COVER_MESH := preload("res://resources/map/models/map_left_case.res")
const SUMMARY_RIGHT_COVER_MESH := preload("res://resources/map/models/map_right_case.res")
const SUMMARY_BOTTOM_COVER_MESH := preload("res://resources/map/models/map_bottom_case.res")
const SUMMARY_BUTTON_MESH := preload("res://resources/book/model/button.tres")
const SUMMARY_BUTTON_MATERIAL := preload("res://resources/materials/finish_button_shader_material.tres")
const SUMMARY_COIN_TEXTURE := preload("res://resources/economy/coin.png")
const SUMMARY_PAPER_MATERIAL := preload("res://resources/book/materials/book_material.tres")
const BOOK_OPEN_SOUND := preload("res://resources/sounds/open_book.wav")
const BOOK_CLOSE_SOUND := preload("res://resources/sounds/kodack__closing-a-book.wav")

var summary_visible := false
var summary_root_left : Node3D
var summary_root_right : Node3D
var summary_title_label : Label3D
var summary_stats_label : Label3D
var summary_economy_label : Label3D
var summary_stats_lines: Array[Label3D] = []
var summary_economy_lines: Array[Label3D] = []
var summary_coin_sprites: Array[Sprite3D] = []
var summary_continue_mesh : MeshInstance3D
var summary_continue_label : Label3D
var summary_transitioning := false

var shop_nodes: Array = []
var shop_node_visibility: Dictionary = {}
var shop_collision_disabled: Dictionary = {}
var shop_button_enabled: Dictionary = {}
var default_next_text := "Next"
var default_left_cover_mesh: Mesh
var default_right_cover_mesh: Mesh
var default_bottom_cover_mesh: Mesh
var default_left_cover_material: Material
var default_right_cover_material: Material
var default_bottom_cover_material: Material
var default_map_button_position: Vector3


func _ready() -> void:
	default_next_text = next_label.text
	default_left_cover_mesh = left_cover.mesh
	default_right_cover_mesh = right_cover.mesh
	default_bottom_cover_mesh = bottom_cover.mesh
	default_left_cover_material = left_cover.material_override
	default_right_cover_material = right_cover.material_override
	default_bottom_cover_material = bottom_cover.material_override
	default_map_button_position = map_button.position
	_create_summary_view()
	_cache_shop_nodes()
	reroll_button.pressed.connect(_on_reroll_pressed)
	map_button.pressed.connect(on_map_button_pressed)
	GameState.economy_component.combat_gold_reward_granted.connect(_on_combat_gold_reward_granted)
	reroll()
	Shop_rerolls_count = 0
	reroll_price_chart.text = str(SHOP_REROLL_PRICE_BASE + SHOP_REROLL_PRICE_UPDATE * Shop_rerolls_count)
	_set_summary_visible(false)

func _on_reroll_pressed()->void:
	if summary_visible:
		return
	actual_reroll_price = SHOP_REROLL_PRICE_BASE + SHOP_REROLL_PRICE_UPDATE * Shop_rerolls_count
	if GameState.economy_component.can_afford(actual_reroll_price):
		GameState.economy_component.spend_run_gold(actual_reroll_price)
		reroll()
	

func reroll() -> void:
	if summary_visible:
		return

	Shop_rerolls_count += 1
	actual_reroll_price = SHOP_REROLL_PRICE_BASE + SHOP_REROLL_PRICE_UPDATE * Shop_rerolls_count
	reroll_price_chart.text = str(actual_reroll_price)
	
	
	var ball_created : BallRuntimeState = GameState.object_pool_database.ball_pool_definition.get_random_ball()
	
	ball_spot._assign_data_model(ball_created)
	price_chart_ball.text = str(ball_created.ball_definition.base_price)
	
	
	ball_created = GameState.object_pool_database.ball_pool_definition.get_random_ball()
	ball_spot_2._assign_data_model(ball_created)
	price_chart_ball_2.text = str(ball_created.ball_definition.base_price)
	
	ball_created = GameState.object_pool_database.ball_pool_definition.get_random_ball()
	ball_spot_3._assign_data_model(ball_created)
	price_chart_ball_3.text = str(ball_created.ball_definition.base_price)
	
	#pool bingo_chips
	var bingo_chip_created : BetFieldModel = GameState.object_pool_database.bingo_chips_constructor.get_random_bet_field_model()
	bingo_chip_spot.assign_data_model(bingo_chip_created) 
	price_chart_chip.text = str(SHOP_BASE_CHIP_MOD_PRICE)
	
	bingo_chip_created = GameState.object_pool_database.bingo_chips_constructor.get_random_bet_field_model()
	bingo_chip_spot_2.assign_data_model(bingo_chip_created) 
	price_chart_chip_2.text = str(SHOP_BASE_CHIP_MOD_PRICE)
	
	bingo_chip_created = GameState.object_pool_database.bingo_chips_constructor.get_random_bet_field_model()
	bingo_chip_spot_3.assign_data_model(bingo_chip_created) 
	price_chart_chip_3.text = str(SHOP_BASE_CHIP_MOD_PRICE)
	
	UiEventBus.deactivate_descriptions.emit()



func on_map_button_pressed()->void:
	if summary_visible:
		_transition_summary_to_shop()
		return
	#PlayerUiEvents.change_book_page.emit(Constants.BOOK_PAGE.MAP)
	#preload()
	GameState.temp_scene_changed_value +=1
	UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.MAP)
	#UiEventBus.change_scene_to.emit("res://scenes/combat/battle_scene_1.tscn")

func _on_combat_gold_reward_granted(amount: int, breakdown: Dictionary, combat_stats: Dictionary) -> void:
	_update_summary_text(amount, breakdown, combat_stats)
	_set_summary_visible(true)

func _create_summary_view() -> void:
	summary_root_left = Node3D.new()
	summary_root_left.name = "CombatSummaryLeft"
	left_cover.add_child(summary_root_left)

	summary_root_right = Node3D.new()
	summary_root_right.name = "CombatSummaryRight"
	right_cover.add_child(summary_root_right)

	summary_title_label = _create_summary_label(
		summary_root_left,
		"Title",
		Vector3(-0.88, 0.125, -1.80),
		"Victoria",
		25,
		Color(0.15, 0.66, 0.18, 1.0),
		Color(0.85, 1.0, 0.72, 0.85)
	)
	summary_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary_stats_label = _create_summary_label(
		summary_root_left,
		"Stats",
		Vector3(-1.48, 0.125, -1.44),
		"Estadisticas",
		17,
		Color(0.34, 0.13, 0.48, 1.0),
		Color(0.9, 0.8, 1.0, 0.8)
	)
	summary_economy_label = _create_summary_label(
		summary_root_right,
		"Economy",
		Vector3(0.18, 0.125, -1.65),
		"Economia",
		18,
		Color(0.82, 0.48, 0.02, 1.0),
		Color(1.0, 0.92, 0.35, 0.85)
	)
	_create_summary_line_labels()
	_create_coin_sprite(summary_root_right, Vector3(0.74, 0.128, -1.66), 0.64)
	summary_continue_mesh = MeshInstance3D.new()
	summary_continue_mesh.name = "ContinueButtonVisual"
	summary_continue_mesh.position = Vector3(-0.76, 0.13, -0.23)
	summary_continue_mesh.scale = Vector3(1.48, 1.0, 1.14)
	summary_continue_mesh.mesh = SUMMARY_BUTTON_MESH
	summary_continue_mesh.material_override = SUMMARY_BUTTON_MATERIAL
	summary_root_left.add_child(summary_continue_mesh)

	summary_continue_label = _create_summary_label(
		summary_root_left,
		"ContinueLabel",
		Vector3(-0.76, 0.19, -0.235),
		"Continuar",
		11,
		Color(1.0, 1.0, 1.0, 1.0),
		Color(0.1, 0.35, 0.1, 0.9)
	)
	summary_continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary_continue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	summary_continue_label.no_depth_test = true

func _create_summary_line_labels() -> void:
	var stats_positions := [
		Vector3(-1.45, 0.125, -1.22),
		Vector3(-1.45, 0.125, -1.05),
		Vector3(-1.45, 0.125, -0.88),
		Vector3(-1.45, 0.125, -0.71),
		Vector3(-1.45, 0.125, -0.54),
		Vector3(-1.45, 0.125, -0.37),
	]
	for i in stats_positions.size():
		var color := Color(0.07, 0.05, 0.04, 1.0)
		if i == 0:
			color = Color(0.16, 0.4, 0.62, 1.0)
		elif i == 3:
			color = Color(0.78, 0.08, 0.07, 1.0)
		var label := _create_summary_label(
			summary_root_left,
			"StatsLine" + str(i),
			stats_positions[i],
			"",
			13,
			color,
			Color(0.86, 0.92, 0.68, 0.75)
		)
		summary_stats_lines.append(label)

	var economy_positions := [
		Vector3(0.18, 0.125, -1.38),
		Vector3(0.18, 0.125, -1.17),
		Vector3(0.18, 0.125, -0.96),
		Vector3(0.18, 0.125, -0.75),
		Vector3(0.18, 0.125, -0.54),
		Vector3(0.18, 0.125, -0.33),
	]
	for i in economy_positions.size():
		var color := Color(0.07, 0.05, 0.04, 1.0)
		if i == 4:
			color = Color(0.82, 0.48, 0.02, 1.0)
		var label := _create_summary_label(
			summary_root_right,
			"EconomyLine" + str(i),
			economy_positions[i],
			"",
			13,
			color,
			Color(0.94, 0.9, 0.56, 0.85)
		)
		summary_economy_lines.append(label)

func _create_coin_sprite(parent: Node3D, sprite_position: Vector3, sprite_scale: float) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.name = "SummaryCoin"
	sprite.texture = SUMMARY_COIN_TEXTURE
	sprite.position = sprite_position
	sprite.rotation_degrees.x = -90.0
	sprite.pixel_size = 0.001
	sprite.scale = Vector3.ONE * sprite_scale
	parent.add_child(sprite)
	summary_coin_sprites.append(sprite)
	return sprite

func _create_summary_label(parent: Node3D, label_name: String, label_position: Vector3, label_text: String, label_font_size: int, label_color: Color, outline_color: Color) -> Label3D:
	var label := Label3D.new()
	label.name = label_name
	label.position = label_position
	label.rotation_degrees.x = -90.0
	label.text = label_text
	label.font_size = label_font_size
	label.modulate = label_color
	label.outline_size = 1
	label.outline_modulate = outline_color
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	parent.add_child(label)
	return label

func _cache_shop_nodes() -> void:
	shop_nodes.clear()
	shop_node_visibility.clear()
	shop_collision_disabled.clear()
	shop_button_enabled.clear()

	for child in left_cover.get_children():
		if child == map_button or child == next_label or child == summary_root_left:
			continue
		_cache_shop_node(child)

	for child in right_cover.get_children():
		if child == summary_root_right:
			continue
		_cache_shop_node(child)

func _cache_shop_node(node: Node) -> void:
	shop_nodes.append(node)
	shop_node_visibility[node] = node.visible
	_cache_interactive_state(node)

func _cache_interactive_state(node: Node) -> void:
	if node is CollisionShape3D:
		shop_collision_disabled[node] = node.disabled
	if node is SB_Button3D:
		shop_button_enabled[node] = node.enabled
	for child in node.get_children():
		_cache_interactive_state(child)

func _set_summary_visible(value: bool) -> void:
	summary_visible = value
	_set_summary_background(value)
	summary_root_left.visible = value
	summary_root_right.visible = value

	for node in shop_nodes:
		node.visible = bool(shop_node_visibility.get(node, true)) if not value else false

	for collision_shape in shop_collision_disabled.keys():
		collision_shape.disabled = true if value else bool(shop_collision_disabled[collision_shape])

	for button in shop_button_enabled.keys():
		button.enabled = false if value else bool(shop_button_enabled[button])

	map_button.enabled = true
	map_button.position = Vector3(-0.84, -0.075, -0.23) if value else default_map_button_position
	next_label.text = "Continuar" if value else default_next_text
	next_label.visible = false if value else true
	UiEventBus.deactivate_descriptions.emit()

func _transition_summary_to_shop() -> void:
	if summary_transitioning:
		return
	if animation_player == null:
		_set_summary_visible(false)
		return

	summary_transitioning = true
	map_button.enabled = false
	animation_player.play("book_animations/book_close")
	_play_summary_page_sound(BOOK_CLOSE_SOUND)

	EventManager.add_event(EventManager.QueueType.GAME,
	GameEvent.new({
		"paralel": false,
		"action": func():
			return !animation_player.is_playing()
	}))

	EventManager.add_event(EventManager.QueueType.GAME,
	GameEvent.new({
		"paralel": false,
		"action": func():
			_set_summary_visible(false)
			animation_player.play("book_animations/book_open")
			_play_summary_page_sound(BOOK_OPEN_SOUND)
			return true
	}))

	EventManager.add_event(EventManager.QueueType.GAME,
	GameEvent.new({
		"paralel": false,
		"action": func():
			return !animation_player.is_playing()
	}))

	EventManager.add_event(EventManager.QueueType.GAME,
	GameEvent.new({
		"paralel": false,
		"action": func():
			summary_transitioning = false
			map_button.enabled = true
			return true
	}))

func _set_summary_background(value: bool) -> void:
	if value:
		left_cover.mesh = SUMMARY_LEFT_COVER_MESH
		right_cover.mesh = SUMMARY_RIGHT_COVER_MESH
		bottom_cover.mesh = SUMMARY_BOTTOM_COVER_MESH
		left_cover.material_override = SUMMARY_PAPER_MATERIAL
		right_cover.material_override = SUMMARY_PAPER_MATERIAL
		bottom_cover.material_override = SUMMARY_PAPER_MATERIAL
	else:
		left_cover.mesh = default_left_cover_mesh
		right_cover.mesh = default_right_cover_mesh
		bottom_cover.mesh = default_bottom_cover_mesh
		left_cover.material_override = default_left_cover_material
		right_cover.material_override = default_right_cover_material
		bottom_cover.material_override = default_bottom_cover_material

func _play_summary_page_sound(sound: AudioStream) -> void:
	if audio_stream == null:
		return
	audio_stream.stream = sound
	audio_stream.play()

func _update_summary_text(amount: int, breakdown: Dictionary, stats: Dictionary) -> void:
	var player_health: Dictionary = stats.get("player_health", {})
	var current_health := int(player_health.get("current", 0))
	var max_health := int(player_health.get("max", 0))
	var rerolls_remaining := int(stats.get("rerolls_remaining", breakdown.get("rerolls_remaining", 0)))
	var max_rerolls := int(stats.get("max_rerolls", GameState.max_reroll))
	var overkill := int(stats.get("overkill", 0))

	var stats_lines := [
		"Turnos: " + str(int(stats.get("turns_taken", breakdown.get("turns_taken", 0)))),
		"Dano hecho: " + str(int(stats.get("damage_dealt", 0))),
		"Dano recibido: " + str(int(stats.get("damage_received", 0))),
		"Vida: " + str(current_health) + "/" + str(max_health),
		"Rerolls: " + str(rerolls_remaining) + "/" + str(max_rerolls),
		"",
	]
	if overkill > 0:
		stats_lines[5] = "Overkill: " + str(overkill)
	_set_summary_lines(summary_stats_lines, stats_lines)

	var economy_lines := [
		str(breakdown.get("encounter_label", "Enemigo comun")) + ": +" + str(int(breakdown.get("base", 0))) + " G",
		"Rerolls sobrantes: +" + str(int(breakdown.get("rerolls", 0))) + " G",
		"Bonus por turnos: +" + str(int(breakdown.get("turns", 0))) + " G",
		"Oro anterior: " + str(int(breakdown.get("gold_before", 0))) + " G",
		"Total ganado: +" + str(amount) + " G",
		"Oro actual: " + str(int(breakdown.get("gold_after", GameState.economy_component.run_gold))) + " G",
	]
	_set_summary_lines(summary_economy_lines, economy_lines)

func _set_summary_lines(labels: Array[Label3D], lines: Array) -> void:
	for i in labels.size():
		var label := labels[i]
		label.text = str(lines[i]) if i < lines.size() else ""
		label.visible = label.text != ""
	
