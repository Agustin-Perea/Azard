extends Control
class_name PassiveItemsUI

const HELP_FONT := preload("res://resources/fonts/FuzzyBubbles-Bold.ttf")
const TOOLTIP_WIDTH := 520.0
const TOOLTIP_HEIGHT := 250.0
const TOOLTIP_MARGIN := 24.0

@onready var item_container : VBoxContainer = $VBoxContainer
@onready var panel_scene = preload("res://features/items/passive_items/views/passive_item_panel.tscn")

var items_scroll: ScrollContainer
var tooltip_panel: Panel
var tooltip_title: Label
var tooltip_meta: Label
var tooltip_description: Label
var active_tooltip_panel: PassiveItemPanel
var tracked_scene_path := ""

func _ready() -> void:
	set_process(true)
	BookEventBus.reload.connect(clear_panel)
	UiEventBus.add_passive_item.connect(add_passive_item_panel)
	UiEventBus.scene_changed.connect(_refresh_visibility)
	_wrap_item_container_in_scroll()
	_create_tooltip()
	_refresh_visibility()
	call_deferred("_refresh_visibility")
	call_deferred("_populate_existing_passive_items")

func _process(_delta: float) -> void:
	var scene_path := _get_active_scene_path()
	if scene_path != tracked_scene_path:
		_refresh_visibility(scene_path)

func add_passive_item_panel(data_model : PassiveItemDefinition)->void:
	var nuevo_panel : PassiveItemPanel = panel_scene.instantiate() 
	nuevo_panel.dataModel = data_model
	nuevo_panel.set_quantity(_get_runtime_quantity(data_model))
	nuevo_panel.tooltip_requested.connect(_show_tooltip)
	nuevo_panel.tooltip_closed.connect(_hide_tooltip_from_panel)
	item_container.add_child(nuevo_panel)

func _populate_existing_passive_items() -> void:
	for item: PassiveItemRuntimeState in GameState.passiveItems_collection:
		if item != null and item.passive_item_definition != null:
			add_passive_item_panel(item.passive_item_definition)

func clear_panel()->void:
	_hide_tooltip()
	for child in item_container.get_children():
		if child.visible:
			child.queue_free() # Borra cada panel de forma segura

func _create_tooltip() -> void:
	tooltip_panel = Panel.new()
	tooltip_panel.name = "PassiveItemTooltip"
	tooltip_panel.visible = false
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_panel.custom_minimum_size = Vector2(TOOLTIP_WIDTH, 0.0)
	tooltip_panel.z_index = 30

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0627451, 0.027451, 0.0705882, 0.93)
	style.border_color = Color(0.913725, 0.929412, 0.733333, 0.32)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_left = 22
	style.content_margin_top = 16
	style.content_margin_right = 22
	style.content_margin_bottom = 18
	tooltip_panel.add_theme_stylebox_override("panel", style)
	add_child(tooltip_panel)

	var content := VBoxContainer.new()
	content.name = "Content"
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 22.0
	content.offset_top = 16.0
	content.offset_right = -22.0
	content.offset_bottom = -18.0
	content.add_theme_constant_override("separation", 10)
	tooltip_panel.add_child(content)

	tooltip_title = Label.new()
	tooltip_title.name = "Title"
	tooltip_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tooltip_title.add_theme_font_override("font", HELP_FONT)
	tooltip_title.add_theme_font_size_override("font_size", 30)
	content.add_child(tooltip_title)

	tooltip_meta = Label.new()
	tooltip_meta.name = "Meta"
	tooltip_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tooltip_meta.add_theme_font_override("font", HELP_FONT)
	tooltip_meta.add_theme_font_size_override("font_size", 19)
	tooltip_meta.add_theme_color_override("font_color", Color(0.913725, 0.929412, 0.733333, 0.90))
	content.add_child(tooltip_meta)

	tooltip_description = Label.new()
	tooltip_description.name = "Description"
	tooltip_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tooltip_description.add_theme_font_override("font", HELP_FONT)
	tooltip_description.add_theme_font_size_override("font_size", 22)
	tooltip_description.add_theme_color_override("font_color", Color(1, 1, 1, 0.88))
	content.add_child(tooltip_description)

func _show_tooltip(panel: PassiveItemPanel, data_model: PassiveItemDefinition) -> void:
	if data_model == null or data_model.passive_item_effect == null:
		return
	active_tooltip_panel = panel
	tooltip_title.text = data_model.passive_item_effect.name
	tooltip_title.add_theme_color_override("font_color", _get_item_rarity_color(data_model))
	tooltip_meta.text = _get_item_rarity_name(data_model) + " | " + ("Acumulable" if data_model.cumulative else "Unico") + " | x" + str(_get_runtime_quantity(data_model))
	tooltip_description.text = data_model.passive_item_effect.description
	tooltip_panel.size = _get_tooltip_size()
	tooltip_panel.position = _get_tooltip_position(panel)
	tooltip_panel.visible = true

func _wrap_item_container_in_scroll() -> void:
	if item_container == null or item_container.get_parent() != self:
		return
	items_scroll = ScrollContainer.new()
	items_scroll.name = "PassiveItemsScroll"
	items_scroll.anchor_left = 0.0
	items_scroll.anchor_top = 0.0
	items_scroll.anchor_right = 0.0
	items_scroll.anchor_bottom = 1.0
	items_scroll.offset_left = 38.0
	items_scroll.offset_top = 0.0
	items_scroll.offset_right = 186.0
	items_scroll.offset_bottom = -18.0
	items_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	items_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	items_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(items_scroll)
	move_child(items_scroll, 0)

	remove_child(item_container)
	item_container.offset_left = 0.0
	item_container.offset_top = 0.0
	item_container.offset_right = 128.0
	item_container.offset_bottom = 0.0
	item_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	item_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	item_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	items_scroll.add_child(item_container)

func _refresh_visibility(scene_path := "") -> void:
	if scene_path == "":
		scene_path = _get_active_scene_path()
	tracked_scene_path = scene_path
	var should_show := scene_path.find("/combat/") != -1 or scene_path.find("\\combat\\") != -1
	visible = true
	if items_scroll != null:
		items_scroll.visible = should_show
	mouse_filter = Control.MOUSE_FILTER_PASS if should_show else Control.MOUSE_FILTER_IGNORE
	if not should_show:
		_hide_tooltip()

func _get_active_scene_path() -> String:
	if get_tree().current_scene != null and get_tree().current_scene.scene_file_path != "":
		return get_tree().current_scene.scene_file_path
	return GameState.get_current_scene_path()

func _hide_tooltip_from_panel(panel: PassiveItemPanel) -> void:
	if active_tooltip_panel != panel:
		return
	_hide_tooltip()

func _hide_tooltip() -> void:
	active_tooltip_panel = null
	if tooltip_panel != null:
		tooltip_panel.visible = false

func _get_tooltip_position(panel: PassiveItemPanel) -> Vector2:
	if panel == null:
		return Vector2.ZERO
	var viewport_size := get_viewport_rect().size
	var panel_rect := panel.get_global_rect()
	var tooltip_size := _get_tooltip_size()
	var target := panel_rect.position + Vector2(panel_rect.size.x + TOOLTIP_MARGIN, 12.0)
	if target.x + tooltip_size.x > viewport_size.x - TOOLTIP_MARGIN:
		target.x = max(TOOLTIP_MARGIN, panel_rect.position.x - tooltip_size.x - TOOLTIP_MARGIN)
	target.y = clampf(target.y, TOOLTIP_MARGIN, max(TOOLTIP_MARGIN, viewport_size.y - tooltip_size.y - TOOLTIP_MARGIN))
	return target

func _get_tooltip_size() -> Vector2:
	var viewport_size := get_viewport_rect().size
	var max_width := maxf(280.0, viewport_size.x - TOOLTIP_MARGIN * 2.0)
	var max_height := maxf(220.0, viewport_size.y - TOOLTIP_MARGIN * 2.0)
	return Vector2(minf(TOOLTIP_WIDTH, max_width), minf(TOOLTIP_HEIGHT, max_height))

func _get_runtime_quantity(data_model: PassiveItemDefinition) -> int:
	for item in GameState.passiveItems_collection:
		if item != null and item.passive_item_definition == data_model:
			return max(1, item.quantity)
	return 1

func _get_item_rarity_name(item: PassiveItemDefinition) -> String:
	var item_name := _get_item_name(item)
	var uncommon_items := [
		"Vision", "BallPouch", "SafetyNet", "GoldenDust", "EchoPin", "ToxicInk",
		"ChainCoil", "TableSigil", "VitalThread", "LuckyThread", "LuckyClover",
	]
	var rare_items := [
		"OmegaRoll", "TrinketStrap", "IronShell", "RouletteChalk", "HighRollerBadge",
		"BloodContract", "DealerGloves", "GoldPocket", "GraveWax", "SplitLedger",
		"LoadedDice",
	]
	var epic_items := [
		"ThirdChip", "GoldenLedger", "WeightedWheel", "TwinFuse", "DeadmansSwitch",
		"LoadedMark", "FortuneIdol", "Mitosis", "HouseWin", "RobaAlmas",
	]
	var legendary_items := [
		"HouseKey", "CrownOfOdds", "RoyalTreasury", "FinalBetSeal", "EyeOfFortune",
		"LastCoin", "PerfectCrime", "GoldenReversal", "CasinoCrown", "HouseAlwaysWins",
	]
	if uncommon_items.has(item_name):
		return "Uncommon"
	if rare_items.has(item_name):
		return "Rare"
	if epic_items.has(item_name):
		return "Epic"
	if legendary_items.has(item_name):
		return "Legendary"
	return _get_rarity_text(item.rarity if item != null else Constants.RARITY.COMMON)

func _get_item_rarity_color(item: PassiveItemDefinition) -> Color:
	match _get_item_rarity_name(item):
		"Uncommon":
			return Color(0.36, 1.0, 0.48, 1.0)
		"Rare":
			return Constants.RARITY_COLORS.get(Constants.RARITY.RARE, Color(0.2, 0.5, 1.0, 1.0))
		"Epic":
			return Constants.RARITY_COLORS.get(Constants.RARITY.EPIC, Color(0.7, 0.5, 1.0, 1.0))
		"Legendary":
			return Constants.RARITY_COLORS.get(Constants.RARITY.LEGENDARY, Color(1.0, 0.85, 0.2, 1.0))
		_:
			return Constants.RARITY_COLORS.get(Constants.RARITY.COMMON, Color(1, 1, 1, 1))

func _get_item_name(item: PassiveItemDefinition) -> String:
	if item != null and item.passive_item_effect != null and item.passive_item_effect.name != "":
		return item.passive_item_effect.name
	if item != null and item.resource_path != "":
		return item.resource_path.get_file().get_basename()
	return ""

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

func _input(event: InputEvent) -> void:
	if tooltip_panel == null or not tooltip_panel.visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_position: Vector2 = event.position
		if tooltip_panel.get_global_rect().has_point(click_position):
			return
		if active_tooltip_panel != null and active_tooltip_panel.get_global_rect().has_point(click_position):
			return
		_hide_tooltip()
