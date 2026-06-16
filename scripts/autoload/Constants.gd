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
const RARITY_MATERIAL_2D_ROUTES : Dictionary = {
	RARITY.COMMON: "res://resources/materials/auras/2d/common_aura_material_2d.tres",
	RARITY.RARE: "res://resources/materials/auras/2d/rare_aura_material_2d.tres",
	RARITY.EPIC: "res://resources/materials/auras/2d/epic_aura_material_2d.tres",
	RARITY.LEGENDARY: "res://resources/materials/auras/2d/legendary_aura_material_2d.tres"
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

enum BET_FIELD_CONDITION {
	STRAIGHT_UP,
	FIRST_HALF,
	EVEN,
	RED,
	BLACK,
	ODD,
	SECOND_HALF,
	ROW_1ST,
	ROW_2ND,
	ROW_3RD,
	COLUMN_1ST,
	COLUMN_2ND,
	COLUMN_3RD,
	NONE,
	ALL
}
const BET_FIELD_CONDITION_NAMES := {
	BET_FIELD_CONDITION.STRAIGHT_UP: "Apuesta Directa",
	BET_FIELD_CONDITION.FIRST_HALF: "1-18",
	BET_FIELD_CONDITION.EVEN: "EVEN",
	BET_FIELD_CONDITION.RED: "RED",
	BET_FIELD_CONDITION.BLACK: "BLACK",
	BET_FIELD_CONDITION.ODD: "ODD",
	BET_FIELD_CONDITION.SECOND_HALF: "19-36",
	BET_FIELD_CONDITION.ROW_1ST: "1ST 12",
	BET_FIELD_CONDITION.ROW_2ND: "2ND 12",
	BET_FIELD_CONDITION.ROW_3RD: "3RD 12",
	BET_FIELD_CONDITION.COLUMN_1ST: "2 to 1, 1ST",
	BET_FIELD_CONDITION.COLUMN_2ND: "2 to 1, 2ND",
	BET_FIELD_CONDITION.COLUMN_3RD: "2 to 1, 3RD",
	BET_FIELD_CONDITION.NONE: "NONE",
	BET_FIELD_CONDITION.ALL: "ALL"
}
#scene routes
const TEST_SCENE = "res://RouletteCombat.tscn"
const MAP_SCENE_PATH := "res://features/map/views/map_scene.tscn"
const MAIN_MENU_SCENE_PATH := "res://scenes/menu/main_menu.tscn"


const MUSIC_MENU := {
	"path": "res://resources/sounds/2010_June_HypnoticChill_17-Eric Matyas.mp3",
	"volume": -14.0,
	"offset": 0
}

const MUSIC_COMBAT := {
	"path": "res://resources/sounds/2010_June_HypnoticChill_17-Eric Matyas.mp3",
	"volume": -12.0,
	"offset": 0.0
}

const MUSIC_SHOP := {
	"path": "res://resources/sounds/along_the_way-congus bongus.ogg",
	"volume": -12.0, # Ajusta el volumen base que necesites para la tienda
	"offset": 0
}
const MUSIC_EVENT := {
	"path": "res://resources/sounds/Puzzle Game 3-Eric Matyas.mp3",
	"volume": -12.0, # Ajusta el volumen base que necesites para la tienda
	"offset": 1.5
}
const MUSIC_FINISH := {
	"path": "res://resources/sounds/The Stream in Our Hollow-Eric Matyas.mp3",
	"volume": -12.0, # Ajusta el volumen base que necesites para la tienda
	"offset": 0.0
}
const MUSIC_BOSS := {
	"path": "res://resources/sounds/redlightdistrict-JSKNYC.ogg",
	"volume": 0.0, # Ajusta el volumen base que necesites para la tienda
	"offset": 0.0
}
