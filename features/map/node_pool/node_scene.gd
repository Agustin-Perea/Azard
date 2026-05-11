extends Resource
class_name NodeScene


@export_range(0,2) var tier :int
@export_range(0,10) var weight : int
#@export var battle_scene : PackedScene
# En lugar de PackedScene, guardamos la RUTA (String)
@export_file("*.tscn") var battle_scene_path : String

func get_battle_scene() -> PackedScene:
	if battle_scene_path != "":
		return load(battle_scene_path)
	return null
