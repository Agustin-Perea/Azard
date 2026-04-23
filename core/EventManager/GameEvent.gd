extends RefCounted
class_name GameEvent

#bloquea los eventos que sigan despues de este
var blocking: bool = true
#ignora el bloqueo de eventos, funciona como si fuera paralelo
var paralel: bool = false

#no lo uso para nada pero deberia iniciar el evento luego de un delay
var delay: float = 0.0

#
var timer: float = 0.0

#la funcion a ejecutar
var action: Callable # Aquí guardamos la función 

func _init(config: Dictionary):
	blocking = config.get("blocking", true)
	paralel = config.get("paralel", false)

	#delay = config.get("delay", 0.0)
	action = config.get("action", func(): return true)


func handle() -> bool:
	return action.call() # Debe devolver true al terminar
