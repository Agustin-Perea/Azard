extends Node3D
class_name RouletteStatsPage

const BALL_MESH := preload("res://resources/book/model/roulette_ball.tres")
const BUTTON_MESH := preload("res://resources/book/model/button.tres")
const BUTTON_MATERIAL := preload("res://resources/materials/finish_button_shader_material.tres")

const TEXT_DARK := Color(0.07, 0.05, 0.04, 1.0)
const TEXT_PURPLE := Color(0.34, 0.13, 0.48, 1.0)
const TEXT_BLUE := Color(0.12, 0.38, 0.66, 1.0)
const TEXT_GREEN := Color(0.12, 0.62, 0.18, 1.0)
const TEXT_GOLD := Color(0.82, 0.48, 0.02, 1.0)
const TEXT_MUTED := Color(0.36, 0.31, 0.28, 0.58)
const TEXT_WHITE := Color(1.0, 1.0, 1.0, 1.0)
const OUTLINE_LIGHT := Color(0.88, 0.94, 0.72, 0.8)

signal toggle_requested

var left_cover: Node3D
var right_cover: Node3D

var left_root: Node3D
var right_root: Node3D
var toggle_button: SB_Button3D
var toggle_label: Label3D
var toggle_mesh: MeshInstance3D

var group_rows: Array[Dictionary] = []
var ball_rows: Array[Dictionary] = []
var toggle_enabled := true
var page_visible := false

func setup(left_cover_node: Node3D, right_cover_node: Node3D) -> void:
	left_cover = left_cover_node
	right_cover = right_cover_node
	_create_roots()
	_create_toggle_button()
	_create_static_labels()
	refresh()
	set_page_visible(false)

func refresh() -> void:
	_clear_dynamic_rows()
	_build_probability_rows()
	_build_ball_rows()

func set_page_visible(value: bool) -> void:
	page_visible = value
	left_root.visible = value
	right_root.visible = value
	toggle_label.text = "Ruleta" if value else "Info"
	refresh()

func set_toggle_enabled(value: bool) -> void:
	toggle_enabled = value
	if toggle_button:
		toggle_button.enabled = value
	var collision_shape := toggle_button.get_node_or_null("CollisionShape3D") if toggle_button else null
	if collision_shape and collision_shape is CollisionShape3D:
		collision_shape.disabled = not value
	if toggle_mesh:
		toggle_mesh.transparency = 0.0 if value else 0.45
	if toggle_label:
		toggle_label.modulate = TEXT_WHITE if value else Color(0.7, 0.7, 0.7, 0.85)

func get_toggle_button() -> SB_Button3D:
	return toggle_button

func _create_roots() -> void:
	left_root = Node3D.new()
	left_root.name = "RouletteStatsLeftPage"
	left_cover.add_child(left_root)

	right_root = Node3D.new()
	right_root.name = "RouletteStatsRightPage"
	right_cover.add_child(right_root)

func _create_toggle_button() -> void:
	toggle_button = SB_Button3D.new()
	toggle_button.name = "RouletteStatsToggleButton"
	toggle_button.position = Vector3(-0.08, 0.035, -0.78)

	toggle_mesh = MeshInstance3D.new()
	toggle_mesh.name = "MeshInstance3D"
	toggle_mesh.mesh = BUTTON_MESH
	toggle_mesh.scale = Vector3(0.85, 0.75, 0.72)
	toggle_mesh.material_override = BUTTON_MATERIAL.duplicate()
	toggle_button.add_child(toggle_mesh)

	toggle_label = _create_label(
		toggle_mesh,
		"ToggleLabel",
		Vector3(0.0, 0.017, 0.01),
		"Info",
		13,
		TEXT_WHITE,
		Color(0.05, 0.25, 0.05, 0.9),
		HORIZONTAL_ALIGNMENT_CENTER
	)
	toggle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D"
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(0.34, 0.09, 0.23)
	collision_shape.shape = box_shape
	toggle_button.add_child(collision_shape)

	left_cover.add_child(toggle_button)
	toggle_button.input_event.connect(toggle_button._on_input_event)
	toggle_button.mouse_entered.connect(toggle_button._on_mouse_entered)
	toggle_button.mouse_exited.connect(toggle_button._on_mouse_exited)
	toggle_button.pressed.connect(_on_toggle_pressed)

func _create_static_labels() -> void:
	var title := _create_label(
		left_root,
		"ProbabilitiesTitle",
		Vector3(-0.88, 0.13, -1.86),
		"Probabilidades",
		21,
		TEXT_PURPLE,
		OUTLINE_LIGHT,
		HORIZONTAL_ALIGNMENT_CENTER
	)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var group_header := _create_label(
		left_root,
		"GroupHeader",
		Vector3(-1.50, 0.13, -1.58),
		"Grupo",
		11,
		TEXT_BLUE,
		OUTLINE_LIGHT
	)
	group_header.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	_create_label(left_root, "ProbabilityHeader", Vector3(-0.88, 0.13, -1.58), "Prob", 11, TEXT_BLUE, OUTLINE_LIGHT, HORIZONTAL_ALIGNMENT_CENTER)
	_create_label(left_root, "LevelHeader", Vector3(-0.56, 0.13, -1.58), "Lv", 11, TEXT_BLUE, OUTLINE_LIGHT, HORIZONTAL_ALIGNMENT_CENTER)
	_create_label(left_root, "ValueHeader", Vector3(-0.30, 0.13, -1.58), "Valor", 11, TEXT_BLUE, OUTLINE_LIGHT, HORIZONTAL_ALIGNMENT_CENTER)

	var inventory_title := _create_label(
		right_root,
		"InventoryTitle",
		Vector3(0.78, 0.13, -1.86),
		"Inventario",
		21,
		TEXT_GREEN,
		OUTLINE_LIGHT,
		HORIZONTAL_ALIGNMENT_CENTER
	)
	inventory_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var order_title := _create_label(
		right_root,
		"BallOrderTitle",
		Vector3(0.20, 0.13, -1.58),
		"Pool de bolas",
		13,
		TEXT_GOLD,
		OUTLINE_LIGHT
	)
	order_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _clear_dynamic_rows() -> void:
	for row in group_rows:
		var node: Node = row.get("root")
		if node and is_instance_valid(node):
			node.queue_free()
	group_rows.clear()

	for row in ball_rows:
		var node: Node = row.get("root")
		if node and is_instance_valid(node):
			node.queue_free()
	ball_rows.clear()

func _build_probability_rows() -> void:
	var rows := _get_group_stats()
	var start_z := -1.42
	var row_step := 0.095

	for i in rows.size():
		var row := rows[i]
		var root := Node3D.new()
		root.name = "ProbabilityRow" + str(i)
		left_root.add_child(root)
		group_rows.append({"root": root})

		var row_z := start_z + (i * row_step)
		var row_color: Color = row.get("color", TEXT_DARK)
		_create_label(root, "Group", Vector3(-1.50, 0.13, row_z), str(row.get("name", "")), 8, row_color, OUTLINE_LIGHT)
		_create_label(root, "Probability", Vector3(-0.88, 0.13, row_z), str(row.get("probability", "")), 8, TEXT_DARK, OUTLINE_LIGHT, HORIZONTAL_ALIGNMENT_CENTER)
		_create_label(root, "Level", Vector3(-0.56, 0.13, row_z), "Lv " + str(row.get("level", 0)), 8, TEXT_DARK, OUTLINE_LIGHT, HORIZONTAL_ALIGNMENT_CENTER)
		_create_label(root, "Value", Vector3(-0.30, 0.13, row_z), "+" + str(row.get("value", 0)), 8, TEXT_GOLD, OUTLINE_LIGHT, HORIZONTAL_ALIGNMENT_CENTER)

func _build_ball_rows() -> void:
	var balls: Array = GameState.balls_deck.all_balls if GameState.balls_deck else []
	var start_z := -1.38
	var row_step := 0.24

	if balls.is_empty():
		_create_empty_inventory_label()
		return

	for i in balls.size():
		var ball := balls[i] as BallRuntimeState
		if ball == null:
			continue

		var root := Node3D.new()
		root.name = "BallInventoryRow" + str(i)
		right_root.add_child(root)
		ball_rows.append({"root": root})

		var row_z := start_z + (i * row_step)
		var text_color := TEXT_MUTED if ball.used else TEXT_DARK

		_create_ball_visual(root, ball, Vector3(0.28, 0.13, row_z), ball.used)

		var details := _get_ball_label(ball)
		_create_label(root, "Details", Vector3(0.56, 0.13, row_z), details, 10, text_color, OUTLINE_LIGHT)

func _create_empty_inventory_label() -> void:
	var root := Node3D.new()
	root.name = "EmptyBallInventory"
	right_root.add_child(root)
	ball_rows.append({"root": root})
	_create_label(root, "EmptyText", Vector3(0.20, 0.13, -1.32), "Sin bolas en el mazo", 11, TEXT_MUTED, OUTLINE_LIGHT)

func _get_group_stats() -> Array[Dictionary]:
	var rows: Array[Dictionary] = [
		{
			"name": "Individual",
			"probability": "1/37",
			"level": _get_group_level("individual"),
			"value": 36,
			"color": TEXT_GOLD,
		}
	]

	var group_order := [
		{"key": "red", "name": "Rojo", "color": Color(0.82, 0.04, 0.08, 1.0)},
		{"key": "black", "name": "Negro", "color": TEXT_DARK},
		{"key": "even", "name": "Par", "color": TEXT_BLUE},
		{"key": "odd", "name": "Impar", "color": TEXT_PURPLE},
		{"key": "first_half", "name": "1-18", "color": TEXT_DARK},
		{"key": "second_half", "name": "19-36", "color": TEXT_DARK},
		{"key": "first_row", "name": "1st 12", "color": TEXT_GREEN},
		{"key": "second_row", "name": "2nd 12", "color": TEXT_GREEN},
		{"key": "third_row", "name": "3rd 12", "color": TEXT_GREEN},
		{"key": "first_column", "name": "Columna 1", "color": TEXT_GOLD},
		{"key": "second_column", "name": "Columna 2", "color": TEXT_GOLD},
		{"key": "third_column", "name": "Columna 3", "color": TEXT_GOLD},
	]
	var fields_by_key := _get_group_fields_by_key()

	for group in group_order:
		var key := str(group["key"])
		if not fields_by_key.has(key):
			continue
		var field := fields_by_key[key] as BetFieldModel
		rows.append({
			"name": group["name"],
			"probability": _get_probability_text(field),
			"level": _get_group_level(key),
			"value": int(round(field.multiplier)),
			"color": group["color"],
		})

	return rows

func _get_group_fields_by_key() -> Dictionary:
	var result := {}
	var fields: Array = GameState.bet_field_models
	for i in range(37, fields.size()):
		var field := fields[i] as BetFieldModel
		if field == null or field.ConditionStrategy == null:
			continue
		var key := _get_condition_key(field.ConditionStrategy)
		if key != "" and not result.has(key):
			result[key] = field
	return result

func _get_probability_text(field: BetFieldModel) -> String:
	var total: int = min(37, GameState.bet_field_models.size())
	var matches := 0
	for i in total:
		var candidate := GameState.bet_field_models[i] as BetFieldModel
		if candidate and field.ConditionStrategy.matches(candidate, field):
			matches += 1
	return str(matches) + "/" + str(total)

func _get_condition_key(condition: BetCondition) -> String:
	if condition is RedCondition:
		return "red"
	if condition is BlackCondition:
		return "black"
	if condition is EvenCondition:
		return "even"
	if condition is OddCondition:
		return "odd"
	if condition is FirstHalfCondition:
		return "first_half"
	if condition is SecondHalfCondition:
		return "second_half"
	if condition is FirstRowCondition:
		return "first_row"
	if condition is SecondRowCondition:
		return "second_row"
	if condition is ThirdRowCondition:
		return "third_row"
	if condition is FirstColumnCondition:
		return "first_column"
	if condition is SecondColumnCondition:
		return "second_column"
	if condition is ThirdColumnCondition:
		return "third_column"
	return ""

func _get_group_level(_key: String) -> int:
	return 0

func _create_ball_visual(parent: Node3D, ball: BallRuntimeState, visual_position: Vector3, used: bool) -> void:
	var visual := MeshInstance3D.new()
	visual.name = "BallVisual"
	visual.mesh = BALL_MESH
	visual.position = visual_position
	visual.scale = Vector3.ONE * 2.75

	var definition := ball.ball_definition if ball else null
	if definition and definition.ball_material:
		visual.material_override = definition.ball_material
	else:
		var fallback_material := StandardMaterial3D.new()
		fallback_material.albedo_color = Color(0.85, 0.85, 0.85, 1.0)
		visual.material_override = fallback_material

	visual.transparency = 0.55 if used else 0.0
	parent.add_child(visual)

func _get_ball_label(ball: BallRuntimeState) -> String:
	var definition := ball.ball_definition if ball else null
	if definition == null:
		return "Bola"

	var name := "Bola"
	if definition.ball_effect and definition.ball_effect.name != "":
		name = definition.ball_effect.name
	elif definition.resource_path != "":
		name = definition.resource_path.get_file().get_basename()

	var rarity := _get_rarity_text(definition.rarity)
	return name + " | " + rarity + " | Base " + str(definition.base_damage)

func _get_rarity_text(rarity: int) -> String:
	match rarity:
		Constants.RARITY.COMMON:
			return "Common"
		Constants.RARITY.RARE:
			return "Rare"
		Constants.RARITY.EPIC:
			return "Epic"
		Constants.RARITY.LEGENDARY:
			return "Legendary"
		_:
			return "Rareza ?"

func _create_label(
	parent: Node3D,
	label_name: String,
	label_position: Vector3,
	label_text: String,
	label_font_size: int,
	label_color: Color,
	outline_color: Color,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> Label3D:
	var label := Label3D.new()
	label.name = label_name
	label.position = label_position
	label.rotation_degrees.x = -90.0
	label.text = label_text
	label.font_size = label_font_size
	label.modulate = label_color
	label.outline_size = 1
	label.outline_modulate = outline_color
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.no_depth_test = true
	parent.add_child(label)
	return label

func _on_toggle_pressed() -> void:
	if not toggle_enabled:
		return
	toggle_requested.emit()
