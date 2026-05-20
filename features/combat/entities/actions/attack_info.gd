extends RefCounted
class_name AttackInfo

#debe
@export var damage: int

var attacker : Unit

var target : Unit

var type : Constants.ATTACK_TYPE

var splash_percent: float = 0.0
var poison_damage: int = 0
var poison_turns: int = 0
var bounce_hits: int = 0
var leech_percent: float = 0.0
var bank_gold_reward: int = 0
var mute_turns: int = 0
var self_damage: int = 0
var curse_vulnerable_percent: float = 0.0
var curse_turns: int = 0

#effectos A ENVIAR

#animacion a iniciar, cuando llega a un punto se llama a una funcion local que busca al controller para procesar este ataque
