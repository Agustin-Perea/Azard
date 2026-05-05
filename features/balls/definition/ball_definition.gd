extends Resource 
class_name BallDefinition

@export var ball_id: int = 0
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var rarity_type: Constants.BALL_RARITY = Constants.BALL_RARITY.RARITY_COMMON
@export var pool_weight: int = 140
@export var attack_profile_type: Constants.BALL_ATTACK_PROFILE = Constants.BALL_ATTACK_PROFILE.PROFILE_UNI_TARGET
@export var category_type: Constants.BALL_CATEGORY = Constants.BALL_CATEGORY.CATEGORY_DAMAGE
@export var target_type: Constants.BALL_TARGET = Constants.BALL_TARGET.TARGET_SINGLE
@export_multiline var design_notes: String = ""

var rarity: String = "common"
var attack_profile: String = "uni-target"
var category: String = "damage"
var attack_type: int = Constants.BALL_TARGET.TARGET_SINGLE

@export var base_damage: int
@export var level_1_damage: int = 0
@export var level_2_damage: int = 0
@export var level_3_damage: int = 0

@export var ball_material: StandardMaterial3D

@export var ball_effect: BallEffect

const SHORT_DESCRIPTIONS := {
	1: "Dano directo simple y consistente.",
	2: "Duplica el score final del golpe.",
	3: "Cura al jugador despues de golpear.",
	4: "Dano al objetivo y splash a vecinos.",
	5: "Aplica veneno al objetivo.",
	6: "Otorga shield despues de golpear.",
	7: "Gana dano si cae en rojo.",
	8: "Gana shield si cae en negro.",
	9: "Rebota dano entre enemigos.",
	10: "Copia parte del efecto de otra bola.",
	11: "Cura segun el dano infligido.",
	12: "Gana valor si cae en numero primo.",
	13: "Activa un efecto util al azar.",
	14: "Gana Gold al resolverse.",
	15: "Bloquea habilidades del enemigo.",
	16: "Escala con casillas doradas.",
	17: "Mucho dano, pero te lastima.",
	18: "Elige la mejor casilla cercana.",
	19: "Marca al enemigo para recibir mas dano.",
	20: "Encadena dano entre enemigos.",
	21: "Si cae en 0, 00 o 37, gana mucho valor.",
	22: "Empuja el resultado hacia un numero marcado.",
	23: "Repite parte de la bola anterior.",
	24: "Atraviesa escudos y defensas.",
	25: "Convierte Gold acumulado en dano.",
	26: "Ejecuta enemigos debilitados.",
	27: "Gana dano por variedad de bolas usadas.",
	28: "Jackpot fuerte si activa su condicion.",
	29: "Convierte tu shield en dano.",
	30: "Tira resultados extra y usa el mejor.",
	31: "Repite efectos recientes del combate.",
	32: "Combina condiciones incompatibles.",
}

func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	return "Ball"

func get_description() -> String:
	if SHORT_DESCRIPTIONS.has(ball_id):
		return str(SHORT_DESCRIPTIONS[ball_id])
	if not description.is_empty():
		return description
	return ""

func get_rarity_id() -> int:
	if rarity_type != Constants.BALL_RARITY.RARITY_COMMON or rarity.is_empty():
		return rarity_type
	return int(Constants.BALL_RARITY_BY_NAME.get(rarity.strip_edges().to_lower(), rarity_type))

func get_attack_profile_id() -> int:
	if attack_profile_type != Constants.BALL_ATTACK_PROFILE.PROFILE_UNI_TARGET or attack_profile.is_empty():
		return attack_profile_type
	var primary_profile := attack_profile.split(",", false)[0].strip_edges().to_lower()
	return int(Constants.BALL_ATTACK_PROFILE_BY_NAME.get(primary_profile, attack_profile_type))

func get_category_id() -> int:
	if category_type != Constants.BALL_CATEGORY.CATEGORY_DAMAGE or category.is_empty():
		return category_type
	var primary_category := category.split(",", false)[0].strip_edges().to_lower()
	return int(Constants.BALL_CATEGORY_BY_NAME.get(primary_category, category_type))

func get_target_type() -> int:
	if target_type != Constants.BALL_TARGET.TARGET_SINGLE or attack_type == Constants.BALL_TARGET.TARGET_SINGLE:
		return target_type
	return attack_type

func get_damage_for_level(level: int) -> int:
	if level <= 1 and level_1_damage > 0:
		return level_1_damage
	if level == 2 and level_2_damage > 0:
		return level_2_damage
	if level >= 3 and level_3_damage > 0:
		return level_3_damage
	return base_damage
