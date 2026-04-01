extends Node

const COMBAT_STATE_NAMES: Dictionary = {
	"EnemySelection" : "EnemySelection",
	"Preparation" : "Preparation",
	"PlayerAttack" : "PlayerAttack",
	"EnemyTurn" : "EnemyTurn",
	"Victory" : "Victory",
	"Defeat" : "Defeat"
}

const RARITY_ID: Dictionary = {
	"COMMON" : 1,
	"RARE" : 2,
	"EPIC" : 3,
	"LEGENDARY" : 4,
}

const ATTACK_TYPE: Dictionary = {
	"SINGLE" : 1,
	"HALF" : 2,
	"ALL" : 3,
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
