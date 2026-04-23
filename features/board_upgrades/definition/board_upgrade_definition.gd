extends Resource
class_name BoardUpgradeDefinition

@export var board_upgrade_id: int = 0
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = true
@export var rarity_type: Constants.BOARD_UPGRADE_RARITY = Constants.BOARD_UPGRADE_RARITY.RARITY_COMMON
@export var pool_weight: int = 100
@export var upgrade_type: Constants.BOARD_UPGRADE_TYPE = Constants.BOARD_UPGRADE_TYPE.TYPE_POINT_MODIFICATION
@export var status_type: Constants.BOARD_UPGRADE_STATUS = Constants.BOARD_UPGRADE_STATUS.STATUS_CONCEPT
@export_multiline var design_notes: String = ""
@export var effect_key: String = ""
@export var metadata: Dictionary = {}
@export var image_texture: AtlasTexture = preload("res://resources/passive items/images/base.tres")
@export var board_upgrade_effect: Resource
@export var cumulative: bool = true

func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	return "Board Upgrade"

func get_description() -> String:
	return description

func get_rarity_id() -> int:
	return rarity_type

func get_pool_weight() -> int:
	return pool_weight

func get_effect_key() -> String:
	return effect_key

func get_status_id() -> int:
	return status_type

func get_type_id() -> int:
	return upgrade_type

func is_stackable() -> bool:
	return stackable and cumulative
