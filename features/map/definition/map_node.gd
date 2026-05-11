extends Resource
class_name MapNode
#seran instanciados por el mapgenerator
enum Type {NOT_ASSIGNED, ENEMY, REWARD, EVENT, MINIBOSS, SHOP, BOSS}

@export var type : Type#el tipo tambien tiene un sprite2d animable y modificable
@export var row : int
@export var column : int
@export var position : Vector2
@export var next_map_nodes : Array[MapNode]
@export var selected : bool = false 
@export var disabled : bool = false


@export var node_scene : NodeScene

#para testing, saber si se genero el nodo
func _to_string() -> String:
	return "%s (%s%s)" % [column, Type.keys()[type][0],Type.keys()[type][1]]
