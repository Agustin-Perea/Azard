extends RefCounted
class_name BallCatalog

const BALLS: Array[Dictionary] = [
	{"id": 1, "slug": "base_ball", "name": "BaseBall", "rarity": "common", "weight": 140, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [6, 9, 12]},
	{"id": 2, "slug": "duball", "name": "Duball", "rarity": "common", "weight": 140, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [2, 3, 4]},
	{"id": 3, "slug": "healt_ball", "name": "HealtBall", "rarity": "common", "weight": 135, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [1, 2, 3]},
	{"id": 4, "slug": "fire_ball", "name": "FireBall", "rarity": "common", "weight": 125, "attack_type": Constants.ATTACK_TYPE.HALF, "damage": [3, 4, 5]},
	{"id": 5, "slug": "poison_ball", "name": "PoisonBall", "rarity": "common", "weight": 125, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [2, 3, 4]},
	{"id": 6, "slug": "shield_ball", "name": "ShieldBall", "rarity": "common", "weight": 130, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [1, 2, 3]},
	{"id": 7, "slug": "red_ball", "name": "RedBall", "rarity": "common", "weight": 125, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [4, 5, 6]},
	{"id": 8, "slug": "black_ball", "name": "BlackBall", "rarity": "common", "weight": 125, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [4, 5, 6]},
	{"id": 9, "slug": "bounce_ball", "name": "BounceBall", "rarity": "uncommon", "weight": 90, "attack_type": Constants.ATTACK_TYPE.HALF, "damage": [2, 3, 4]},
	{"id": 10, "slug": "mirror_ball", "name": "MirrorBall", "rarity": "uncommon", "weight": 85, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [0, 0, 0]},
	{"id": 11, "slug": "leech_ball", "name": "LeechBall", "rarity": "uncommon", "weight": 85, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [3, 4, 5]},
	{"id": 12, "slug": "prime_ball", "name": "PrimeBall", "rarity": "uncommon", "weight": 80, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [2, 3, 4]},
	{"id": 13, "slug": "random_ball", "name": "RandomBall", "rarity": "uncommon", "weight": 80, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [8, 12, 16]},
	{"id": 14, "slug": "bank_ball", "name": "BankBall", "rarity": "uncommon", "weight": 80, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [2, 3, 4]},
	{"id": 15, "slug": "mute_ball", "name": "MuteBall", "rarity": "rare", "weight": 55, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [2, 3, 4]},
	{"id": 16, "slug": "gold_ball", "name": "GoldBall", "rarity": "rare", "weight": 50, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [3, 4, 5]},
	{"id": 17, "slug": "risk_ball", "name": "RiskBall", "rarity": "rare", "weight": 50, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [10, 14, 18]},
	{"id": 18, "slug": "crystal_ball", "name": "CrystalBall", "rarity": "rare", "weight": 45, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [3, 4, 5]},
	{"id": 19, "slug": "curse_ball", "name": "CurseBall", "rarity": "rare", "weight": 45, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [2, 3, 4]},
	{"id": 20, "slug": "storm_ball", "name": "StormBall", "rarity": "rare", "weight": 45, "attack_type": Constants.ATTACK_TYPE.ALL, "damage": [2, 3, 4]},
	{"id": 21, "slug": "zero_ball", "name": "ZeroBall", "rarity": "epic", "weight": 28, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [1, 2, 3]},
	{"id": 22, "slug": "rig_ball", "name": "RigBall", "rarity": "epic", "weight": 24, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [3, 4, 5]},
	{"id": 23, "slug": "echo_ball", "name": "EchoBall", "rarity": "epic", "weight": 24, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [0, 0, 0]},
	{"id": 24, "slug": "void_ball", "name": "VoidBall", "rarity": "epic", "weight": 22, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [6, 8, 10]},
	{"id": 25, "slug": "fortune_ball", "name": "FortuneBall", "rarity": "epic", "weight": 22, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [2, 3, 4]},
	{"id": 26, "slug": "grave_ball", "name": "GraveBall", "rarity": "epic", "weight": 20, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [5, 7, 9]},
	{"id": 27, "slug": "ascend_ball", "name": "AscendBall", "rarity": "legendary", "weight": 10, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [5, 7, 9]},
	{"id": 28, "slug": "jackpot_ball", "name": "JackpotBall", "rarity": "legendary", "weight": 8, "attack_type": Constants.ATTACK_TYPE.ALL, "damage": [8, 10, 12]},
	{"id": 29, "slug": "cataclysm_ball", "name": "CataclysmBall", "rarity": "legendary", "weight": 8, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [5, 7, 9]},
	{"id": 30, "slug": "fate_ball", "name": "FateBall", "rarity": "legendary", "weight": 7, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [0, 0, 0]},
	{"id": 31, "slug": "chrono_ball", "name": "ChronoBall", "rarity": "legendary", "weight": 6, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [0, 0, 0]},
	{"id": 32, "slug": "eclipse_ball", "name": "EclipseBall", "rarity": "legendary", "weight": 5, "attack_type": Constants.ATTACK_TYPE.SINGLE, "damage": [8, 10, 12]}
]

static func get_all() -> Array[Dictionary]:
	return BALLS

static func get_by_id(ball_id: int) -> Dictionary:
	for item in BALLS:
		if int(item.get("id", -1)) == ball_id:
			return item
	return {}
