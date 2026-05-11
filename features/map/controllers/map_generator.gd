class_name MapGenerator

@export var layer_distance : float = 380 #en pixeles
@export var node_distance : float = 200
@export var placement_randomness : float = 35 # en x y en y
@export var layers : int = 12 # rows

@export var columns : int = 5 #

@export var paths : int = 5 #

var rng: RandomNumberGenerator 

#global
var last_node : MapNode

var scene_pool_database : ScenePoolDatabase = ScenePoolDatabase.new()


#en realidad cada layer tiene sus nodos integrantes y su peso, hay genericos pero son modificables
@export var random_node_type_weights = {
	MapNode.Type.ENEMY: 125.0,
	MapNode.Type.EVENT: 125.0,
	MapNode.Type.REWARD: 25.0,
	MapNode.Type.MINIBOSS: 25.0,
	MapNode.Type.SHOP: 20.0,
}
var random_node_type_total_weight : float
#matriz de nodos del mapa
var map_data : Array[Array]

#func _ready() -> void:
	#BookEventBus.reload.connect(on_reaload)
	#on_reaload()

func _init() -> void:
	BookEventBus.reload.connect(on_reload)
	on_reload()

func on_reload()->void:
	rng = RandomNumberGenerator.new()
	rng.seed = GameState.master_seed
	last_node = null
	generate_map()
	
	
	
func generate_map() -> Array[Array]:
	map_data = generate_initial_grid()
	var starting_points := _get_random_starting_points()
	for j in starting_points:
		var current_j = j
		#genera una conexion con un nodo de la siguiente layer
		for i in layers-1:
			current_j = _setup_connection(i,current_j)
	
	
	_setup_random_room_weights()
	_setup_room_types()
	_setup_boss_room()
	#print(starting_points)

	return map_data

func print_debug_map()->void:
	
	
	var i:=0
	for layer in map_data:
		print("piso: %s" % i)
		i+=1
		var used_layers = layer.filter(
			func(map_node: MapNode): return map_node.next_map_nodes.size() > 0 or map_node.type == MapNode.Type.BOSS		)
		print(used_layers)

func generate_initial_grid()->Array[Array]:
	var result:Array[Array] = []
	
	for i in layers:
		var layer : Array[MapNode] = []
		for j in columns:
			var current_node := MapNode.new()
			var offset := Vector2(randf_range(-1,1),randf_range(-1,1)) * placement_randomness
			current_node.position = Vector2(i*layer_distance ,j * node_distance) + offset #CREA LAS POSICIONES
			current_node.row = i
			current_node.column = j
			current_node.next_map_nodes = []
			
			#boss_node
			if i == layers -1:
				current_node.position.x = (i)*layer_distance
			
			layer.append(current_node)
	
		result.append(layer)

	return result

func _get_random_starting_points()->Array[int]:
	var y_coordinates: Array[int]
	var unique_points : int = 0
	
	#asegura que al menos 2 nodos sean distintos, y se le asigna a cada nodo 1 path
	while unique_points < 2:
		unique_points = 0
		y_coordinates = []
		
		
		for i in paths:
			var starting_point := rng.randi_range(0, columns-1)
			if not y_coordinates.has(starting_point):
				unique_points+=1
			y_coordinates.append(starting_point)
		
	return y_coordinates
	
func _setup_connection(i:int,j:int)->int:
	var next_node : MapNode = null
	var current_node := map_data[i][j] as MapNode
	
	
	while not next_node or _would_cross_existing_path(i,j,next_node):
		#agrega nodos adyacentes  que no se caigan del layer o lo sobrepasen y que no se cruzen con un camino
		var random_j := clampi(rng.randi_range(j-1,j+1),0,columns-1)
		next_node = map_data[i+1][random_j] as MapNode
		
	current_node.next_map_nodes.append(next_node)
	
	return next_node.column
	
func _would_cross_existing_path(i,j,next_node)->bool:
	#revisa si algun vecino ya tiene asignado un nodo que puede cruzar caminos
	var left_neighbour : MapNode
	var right_neighbour : MapNode	
	# para j==0 no hay vecinos izquierdos 
	if j>0:
		left_neighbour = map_data[i][j-1]
	if j < columns-1:
		right_neighbour = map_data[i][j+1]	
	
	#en este caso el siguiente nodo apinta hacia el vecino derecho
	if right_neighbour and next_node.column > j:
		for right_next_node : MapNode in right_neighbour.next_map_nodes:
			if right_next_node.column < right_neighbour.column:
				return true
	#en este caso el siguiente nodo apinta hacia el vecino izquierdo
	if left_neighbour and next_node.column < j:
		for left_next_node : MapNode in left_neighbour.next_map_nodes:
			if left_next_node.column > left_neighbour.column:
				return true
	return false

func _setup_boss_room()->void:
	#centro de la ultima capa
	var middle:= floori(columns * 0.5)
	var boss_node := map_data[layers -1][middle] as MapNode
	
	for j in columns:
		var current_room = map_data[layers - 2][j] as MapNode
		if current_room.next_map_nodes:
			current_room.next_map_nodes = [] as Array[MapNode]
			current_room.next_map_nodes.append(boss_node)
	boss_node.type = MapNode.Type.BOSS
	_set_node_scene(boss_node)
	#print(map_data[layers -1][middle])

func _setup_random_room_weights()->void:
	random_node_type_total_weight = 0
	for node_weight in random_node_type_weights:
		random_node_type_total_weight += random_node_type_weights[node_weight]
	
	
func _setup_room_types()->void:
	#en el inicio siempre son enemigos
	for map_node : MapNode in map_data[0]:
		if map_node.next_map_nodes.size()>0:
			map_node.type = MapNode.Type.ENEMY
			_set_node_scene(map_node)
		
	#en la mitad siempre son recompenza
	for map_node : MapNode in map_data[floori((layers-1) * 0.5)]:
		if map_node.next_map_nodes.size()>0:
			map_node.type = MapNode.Type.REWARD
			_set_node_scene(map_node)
	
	#resto de salas
	for current_layer in map_data:
		for map_node : MapNode in current_layer:
			for next_node in map_node.next_map_nodes:
				if next_node.type == MapNode.Type.NOT_ASSIGNED:
					_set_room_randomly(next_node)				
	
func _set_room_randomly(node :MapNode)->void:
	var roll = rng.randf_range(0, random_node_type_total_weight - 1)
	var current_sum = 0
	var keys = random_node_type_weights.keys()
	for i in keys:
		var type = i
		current_sum += random_node_type_weights[i]
		if roll < current_sum:
			node.type = type
			_set_node_scene(node)
			return
	
func _set_node_scene(map_node : MapNode)->void:
	match map_node.type:
		MapNode.Type.ENEMY:
			map_node.node_scene = scene_pool_database.battle_pool._get_random_battle_for_tier(0)
		MapNode.Type.MINIBOSS:
			map_node.node_scene = scene_pool_database.battle_pool._get_random_battle_for_tier(0)
		MapNode.Type.BOSS:
			map_node.node_scene = scene_pool_database.battle_pool._get_random_battle_for_tier(0)
		MapNode.Type.REWARD:
			map_node.node_scene = scene_pool_database.battle_pool._get_random_battle_for_tier(0)
		MapNode.Type.EVENT:
			map_node.node_scene = scene_pool_database.battle_pool._get_random_battle_for_tier(0)
		MapNode.Type.SHOP:
			map_node.node_scene = scene_pool_database.battle_pool._get_random_battle_for_tier(0)
		_:
			map_node.node_scene = scene_pool_database.battle_pool._get_random_battle_for_tier(0)
