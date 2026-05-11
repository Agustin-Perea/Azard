extends Node

const COMBAT_STATE_NAMES: Dictionary = {
	"EnemySelection" : "SelectionState",
	"BookState" : "BookState",
	"BookCaseState" : "BookCase",
	"RoulleteSpin" : "RouletteState",
	"BetResolve" : "BetResolve",
	"Victory" : "Victory",
	"Defeat" : "Defeat",
	"StandBy" : "StandBy",
}

const RARITY_ID: Dictionary = {
	"COMMON" : 1,
	"RARE" : 2,
	"EPIC" : 3,
	"LEGENDARY" : 4,
}
enum RARITY {
	COMMON,
	RARE,
	EPIC,
	LEGENDARY
}
const RARITY_COLORS : Dictionary = {
	RARITY.COMMON: Color(0.886, 0.929, 1.0, 1.0),
	RARITY.RARE: Color(0.2, 0.5, 1.0),
	RARITY.EPIC: Color(0.7, 0.5, 1.0),
	RARITY.LEGENDARY: Color(1.0, 0.85, 0.2)
}
const RARITY_MATERIAL_ROUTES : Dictionary = {
	RARITY.COMMON: "res://resources/materials/auras/common_aura_material.tres",
	RARITY.RARE: "res://resources/materials/auras/rare_aura_material.tres",
	RARITY.EPIC: "res://resources/materials/auras/epic_aura_material.tres",
	RARITY.LEGENDARY: "res://resources/materials/auras/legendary_aura_material.tres"
}
enum ATTACK_TYPE {
	SINGLE,
	HALF,
	ALL
}

enum BOOK_PAGE {
	ROULETTE,
	CASE,
	MAP,
	NONE
}

#betfields colors
enum BET_FIELD_COLOR {
	GREEN,
	RED,
	BLACK,
}
enum BET_FIELD_PARITY {
	EVEN,
	ODD,
	NONE
}
enum BET_FIELD_HALF_TABLE {
	LESS_18,
	GREATER_19,
	NONE
}
enum BET_FIELD_COLUMN {
	COLUMN_1ST,
	COLUMN_2ND,
	COLUMN_3RD,
	NONE
}
enum BET_FIELD_ROW {
	ROW_1ST,
	ROW_2ND,
	ROW_3RD,
	NONE
}
#scene routes
const TEST_SCENE = "res://RouletteCombat.tscn"
const MAP_SCENE = "res://MapGeneration/map_scene.tscn"
