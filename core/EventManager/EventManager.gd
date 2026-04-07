extends Node
#esta clase es autoload

enum QueueType {ALL, GAME, EARLY }
var queues: Dictionary = {
	QueueType.GAME: [] as Array[GameEvent],
	QueueType.EARLY: [] as Array[GameEvent]
}
#esto porque en gamespeed x2 va todo x2 y quiza solo quieres que esto sea x2, aunque en realidad solo los tweens son los que tienen su velocidad
#actualmente no se usa
var speed_factor = 1.0 


@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	#para todas las colas
	for q_name in queues:
		var queue = queues[q_name]
		if queue.is_empty(): continue
		
		#el primer evento bloqueante impide la ejecucion de los siguientes mientras sean bloqueables
		var blocked = false
		var i = 0
		while i < queue.size():
			#evento de la cola
			var ev : GameEvent = queue[i]
			#revisa todos los eventos para ejecutar los no bloqueables
			if not blocked or ev.paralel:
				#si el evento esta completado retornara true
				var finished = ev.handle()
				if finished:
					queue.remove_at(i)
					continue # No incrementamos i porque el sig. evento ahora es i
				#si el evento es bloqueante
				if ev.blocking:
					blocked = true
			i += 1
#agrega un evento a la cola de eventos elegida, se puede agregar al frente para que se ejecute al siguiente frame
func add_event(type: QueueType, event: GameEvent, in_front : bool = false) -> void:
	if queues.has(type):
		if in_front:
			queues[type].push_front(event) # Lo añade al inicio (índice 0)
		else:
			queues[type].append(event)     # Lo añade al final
	
func clear_queue(type: QueueType = QueueType.ALL):
	if type == QueueType.ALL:
		for key in queues.keys():
			queues[key].clear()
	elif queues.has(type):
		queues[type].clear()
