extends RefCounted
class_name GameEvent

#bloquea los eventos que sigan despues de este
var blocking: bool = true
#ignora el bloqueo de eventos, funciona como si fuera paralelo
var paralel: bool = false

#uso para esperar antes de resolver el evento
var delay: float = 0.0

#
var timer: float = 0.0

#la funcion a ejecutar
var action: Callable # Aquí guardamos la función 
var started := false



func _init(config: Dictionary):
	#si no encuentra la key en el diccionario devuelve true
	blocking = config.get("blocking", true)
	paralel = config.get("paralel", true)

	delay = config.get("delay", 0.0)
	action = config.get("action", func(): return true)
	
	timer = delay

func handle(delta: float) -> bool:
	# 1. delay inicial
	if timer > 0.0:
		timer -= delta
		return false

	# 2. ejecutar acción UNA sola vez si quieres control
	if not started:
		started = true

	var result = action.call()

	return result
