extends Control
class_name PassiveItemsUI

@onready var item_container: VBoxContainer = $VBoxContainer
@onready var item_container: VBoxContainer = $VBoxContainer
@onready var panel_scene = preload("res://features/items/passive_items/views/passive_item_panel.tscn")

@onready var passive_item_control : Control = $PassiveItemDescritpion
@onready var passive_item_description_name : Label = $PassiveItemDescritpion/Panel/VBoxContainer/Name
@onready var passive_item_description : Label = $PassiveItemDescritpion/Panel/VBoxContainer/Desctiption



# RuntimeState -> Panel
var panels_by_item: Dictionary = {}

func _ready() -> void:
	BookEventBus.reload.connect(clear_panels)
	UiEventBus.clear_passive_items_panels.connect(clear_panels)
	UiEventBus.add_passive_item.connect(add_passive_item_panel)

func add_passive_item_panel(data_model: PassiveItemRuntimeState) -> void:
	# Si ya existe el panel, solo refresca datos
	if panels_by_item.has(data_model):
		var existing_panel: PassiveItemPanel = panels_by_item[data_model]
		
		# llamá al método que actualiza la UI
		existing_panel.update_view()
		return

	# Si no existe, crea uno nuevo
	var nuevo_panel: PassiveItemPanel = panel_scene.instantiate()

func add_passive_item_panel(data_model: PassiveItemRuntimeState) -> void:
	# Si ya existe el panel, solo refresca datos
	if panels_by_item.has(data_model):
		var existing_panel: PassiveItemPanel = panels_by_item[data_model]
		
		# llamá al método que actualiza la UI
		existing_panel.update_view()
		return

	# Si no existe, crea uno nuevo
	var nuevo_panel: PassiveItemPanel = panel_scene.instantiate()

	nuevo_panel.dataModel = data_model


	item_container.add_child(nuevo_panel)
	
	nuevo_panel.pressed.connect(show_description.bind(nuevo_panel))
	# guardar referencia
	panels_by_item[data_model] = nuevo_panel
	nuevo_panel.update_view()

func clear_panels() -> void:
	var children = item_container.get_children()

	for i in range(1, children.size()):
		children[i].queue_free()

	panels_by_item.clear()

func show_description(panel : PassiveItemPanel)->void: 

	passive_item_control.visible = true
	passive_item_description_name.text = panel.dataModel.passive_item_definition.passive_item_effect.name
	passive_item_description.text = panel.dataModel.passive_item_definition.passive_item_effect.description
	passive_item_control.global_position = panel.global_position
