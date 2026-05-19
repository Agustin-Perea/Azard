extends Node2D
class_name Map

var scroll_speed := 15
const MAP_NODE = preload("res://features/map/views/map_button.tscn")


@onready var map_generator : MapGenerator 
@onready var lines : Node2D = $Visuals/Lines
@onready var nodes : Node2D = $Visuals/Nodes
@onready var visuals : Node2D = $Visuals
@onready var camera_2D : Camera2D = $Camera2D

var map_data : Array[Array]
var layers_completed : int = -1
var last_node : MapNode
var camera_edge_x : float

# Variables para drag
var is_dragging := false
var drag_start_pos := Vector2.ZERO
var camera_start_pos := Vector2.ZERO
var min_camera_x := 0.0
var max_camera_x := 0.0

func _ready() -> void:
	var music_manager := get_node_or_null("/root/MusicManager")
	if music_manager != null:
		music_manager.call("play_menu_music")
	map_generator = GameState.map_generator
	camera_edge_x = map_generator.layer_distance * (map_generator.layers) - get_viewport_rect().size.x
	geerate_new_map()
	#unlock_layer(0)
	unlock_next_layers()
	# Configurar límites de cámara
	min_camera_x = 0.0
	max_camera_x = camera_edge_x
	if map_generator.last_node:
		layers_completed = map_generator.last_node.row
		var node_camera_pos_x := (map_generator.last_node.row) * map_generator.layer_distance
		if camera_edge_x > node_camera_pos_x:
			camera_2D.position.x = node_camera_pos_x
		else:
			camera_2D.position.x = camera_edge_x
# Dentro del script del Mapa (asegúrate de que is_dragging sea accesible)
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_pos = event.position
				camera_start_pos = camera_2D.position
			else:
				is_dragging = false

	elif event is InputEventMouseMotion:
		if is_dragging:
			var drag_delta = event.position - drag_start_pos
			var new_x = camera_start_pos.x - drag_delta.x
			# Aplicamos el movimiento a la cámara del mapa
			camera_2D.position.x = clamp(new_x, min_camera_x, max_camera_x)


	# 1. Dibujar un círculo donde está el mouse actualmente (Verde)
	
	# 2. Si estamos arrastrando, dibujar el punto de inicio (Rojo) y una línea


func _on_sub_viewport_container_mouse_exited() -> void:
	is_dragging = false

func geerate_new_map()->void:
	#layers_completed = 0
	#map_data = map_generator.generate_map()
	map_data = map_generator.map_data
	create_map()

func create_map() -> void:
	# Limpiamos todo antes de empezar
	line_points.clear() 
	for child in nodes.get_children():
		child.queue_free()

	# 1. Spawneamos los botones de los nodos
	for current_layer in map_data:
		for map_node in current_layer:
			# Solo spawneamos si el nodo tiene conexiones o es el Boss
			if map_node.next_map_nodes.size() > 0 or map_node.type == MapNode.Type.BOSS:
				_spawn_node(map_node)

	# 2. Posicionamiento visual del contenedor
	var map_width_pixels := map_generator.node_distance * (map_generator.columns - 1)
	visuals.position.x = get_viewport_rect().size.x * 0.1
	visuals.position.y = (get_viewport_rect().size.y - map_width_pixels) / 2

	# 3. Refrescamos el dibujo de las líneas
	lines.queue_redraw()

func _spawn_node(map_node: MapNode) -> void:
	var new_map_node_view := MAP_NODE.instantiate() as MapNodeButton
	nodes.add_child(new_map_node_view)
	new_map_node_view.node = map_node
	new_map_node_view.selected.connect(_on_map_node_selected)
	
	
	if !map_node.selected and map_generator.last_node and map_node.row <= map_generator.last_node.row +1:
		new_map_node_view.deactivate()

func _connect_lines(map_node: MapNode) -> void:
	# Esta función ahora solo llena el array global
	var offset := Vector2(25, 0)
	for next in map_node.next_map_nodes:
		line_points.append(map_node.position + offset)
		line_points.append(next.position - offset)

var line_points : PackedVector2Array = []



func update_visual_lines():
	var master_line = $Visuals/Lines as Line2D
	master_line.points = line_points 


	
func _on_map_node_selected(map_node :MapNode)->void:
	for map_node_view :MapNodeButton in nodes.get_children():
		if map_node_view.node.row == map_node.row:
			map_node_view.available = false
			map_node_view.node.disabled = true
	
	map_node.disabled = false	
	map_node.selected = true		
	map_generator.last_node = map_node
	GameState.save_run(GameState.MAP_SCENE_PATH)
	


func unlock_layer(layer:int = layers_completed)->void:
	for map_node_view : MapNodeButton in nodes.get_children():
		if map_node_view.node.row == layer:
			map_node_view.available = true

func unlock_next_layers() -> void:
	for map_node_view : MapNodeButton in nodes.get_children():
		if not map_generator.last_node:
			unlock_layer(0)
		elif map_generator.last_node.next_map_nodes.has(map_node_view.node):
			map_node_view.available = true

func show_map() -> void:
	show()
	camera_2D.enabled = true

func hide_map() -> void:
	hide()
	camera_2D.enabled = false
