extends Resource
class_name TrinketDefinition

@export var trinket_id: int = 0
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = true
@export var rarity_type: Constants.TRINKET_RARITY = Constants.TRINKET_RARITY.RARITY_COMMON
@export var pool_weight: int = 100
@export var trigger_types: Array[int] = []
@export var trigger_names: Array[String] = []
@export var status_type: Constants.TRINKET_STATUS = Constants.TRINKET_STATUS.STATUS_CONCEPT
@export_multiline var design_notes: String = ""
@export var effect_key: String = ""
@export var metadata: Dictionary = {}
@export var image_texture: AtlasTexture = preload("res://resources/passive items/images/base.tres")
@export var trinket_effect: Resource
@export var cumulative: bool = true

var rarity: String = "common"
var status: String = "concept"

func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	return "Trinket"

func get_description() -> String:
	return description

func get_rarity_id() -> int:
	if rarity_type != Constants.TRINKET_RARITY.RARITY_COMMON or rarity.is_empty():
		return rarity_type
	return int(Constants.TRINKET_RARITY_BY_NAME.get(rarity.strip_edges().to_lower(), rarity_type))

func get_trigger_ids() -> Array[int]:
	if not trigger_types.is_empty():
		var ids: Array[int] = []
		for trigger in trigger_types:
			ids.append(int(trigger))
		return ids
	var ids_from_names: Array[int] = []
	for trigger_name in trigger_names:
		var normalized := trigger_name.strip_edges().to_lower()
		if Constants.TRINKET_TRIGGER_BY_NAME.has(normalized):
			ids_from_names.append(int(Constants.TRINKET_TRIGGER_BY_NAME[normalized]))
	return ids_from_names

func get_pool_weight() -> int:
	return pool_weight

func get_effect_key() -> String:
	return effect_key

func get_status_id() -> int:
	return status_type

func is_stackable() -> bool:
	return stackable and cumulative
