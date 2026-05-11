extends Resource
class_name PassiveItemDefinition


@export var image_texture: AtlasTexture = preload("res://resources/passive items/images/base.tres")#en realidad con el id deberia conseguir el sprite del atlas

@export var passive_item_effect : PassiveItemEffect

@export var cumulative : bool = true 
