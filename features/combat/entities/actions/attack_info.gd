extends RefCounted
class_name AttackInfo

#debe
@export var damage: int

var attacker : Unit

var target : Unit

var type : Constants.ATTACK_TYPE

#effectos A ENVIAR

#animacion a iniciar, cuando llega a un punto se llama a una funcion local que busca al controller para procesar este ataque
