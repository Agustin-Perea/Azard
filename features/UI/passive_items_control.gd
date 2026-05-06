extends Control
class_name PassiveItemsUI

@onready var item_container : VBoxContainer = $VBoxContainer
@onready var panel_scene = preload("res://features/items/passive_items/views/passive_item_panel.tscn")


func _ready() -> void:
	BookEventBus.reload.connect(clear_panel)
	UiEventBus.add_passive_item.connect(add_passive_item_panel)

func add_passive_item_panel(data_model : PassiveItemDefinition)->void:
	var nuevo_panel : PassiveItemPanel = panel_scene.instantiate() 
	nuevo_panel.dataModel = data_model
	item_container.add_child(nuevo_panel)

func clear_panel()->void:
	for child in item_container.get_children():
		if child.visible:
			child.queue_free() # Borra cada panel de forma segura
