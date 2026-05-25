extends Control
class_name PassiveItemsUI

const TOOLTIP_WIDTH := 430.0
const TOOLTIP_HEIGHT := 190.0
const TOOLTIP_MARGIN := 24.0

@onready var item_container : VBoxContainer = $VBoxContainer
@onready var panel_scene = preload("res://features/items/passive_items/views/passive_item_panel.tscn")

var tooltip_panel: Panel
var tooltip_title: Label
var tooltip_description: Label
var active_tooltip_panel: PassiveItemPanel

func _ready() -> void:
	BookEventBus.reload.connect(clear_panel)
	UiEventBus.add_passive_item.connect(add_passive_item_panel)
	_create_tooltip()
	call_deferred("_populate_existing_passive_items")

func add_passive_item_panel(data_model : PassiveItemDefinition)->void:
	var nuevo_panel : PassiveItemPanel = panel_scene.instantiate() 
	nuevo_panel.dataModel = data_model
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
	style.bg_color = Color(0.22, 0.10, 0.18, 0.93)
	style.border_color = Color(0.91, 0.93, 0.73, 0.34)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 18
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
	tooltip_title.add_theme_font_size_override("font_size", 30)
	tooltip_title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.20, 1.0))
	content.add_child(tooltip_title)

	tooltip_description = Label.new()
	tooltip_description.name = "Description"
	tooltip_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tooltip_description.add_theme_font_size_override("font_size", 22)
	tooltip_description.add_theme_color_override("font_color", Color(1, 1, 1, 0.88))
	content.add_child(tooltip_description)

func _show_tooltip(panel: PassiveItemPanel, data_model: PassiveItemDefinition) -> void:
	if data_model == null or data_model.passive_item_effect == null:
		return
	active_tooltip_panel = panel
	tooltip_title.text = data_model.passive_item_effect.name
	tooltip_description.text = data_model.passive_item_effect.description
	tooltip_panel.size = Vector2(TOOLTIP_WIDTH, TOOLTIP_HEIGHT)
	tooltip_panel.position = _get_tooltip_position(panel)
	tooltip_panel.visible = true

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
	var tooltip_size := Vector2(TOOLTIP_WIDTH, TOOLTIP_HEIGHT)
	var target := panel_rect.position + Vector2(panel_rect.size.x + TOOLTIP_MARGIN, 12.0)
	if target.x + tooltip_size.x > viewport_size.x - TOOLTIP_MARGIN:
		target.x = max(TOOLTIP_MARGIN, panel_rect.position.x - tooltip_size.x - TOOLTIP_MARGIN)
	target.y = clampf(target.y, TOOLTIP_MARGIN, max(TOOLTIP_MARGIN, viewport_size.y - tooltip_size.y - TOOLTIP_MARGIN))
	return target

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
