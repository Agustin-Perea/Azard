class_name StateMachine extends Node

# referencia al nodo que vamos a controlar
@onready var controlled_node = self.owner

# estado por defecto
@export var default_state:BaseState

# estado actual
var current_state:BaseState = null

func _ready() -> void:
	## permite cambiar a cualquier estado pero desde cualquier clase, una consola por ejemplo
	UiEventBus.changeToState.connect(changeTo)
	
	##esto asegura que se llame cuando todos los nodos de la escena esten _ready()
	call_deferred("_state_default_start")
	
func _state_default_start() -> void:
	current_state = default_state
	_state_start()

#preparacion del nuevo estado y ejecucion de start()
func _state_start() -> void:
	# las llamadas a sistema consumen recursos, quitar en produccion
	#prints("StateMachine ", controlled_node.name, "start state", current_state.name)
	# configuracion del estado
	current_state.controlled_node = controlled_node
	current_state.state_machine = self
	current_state.start()

## busca el nodo hijo con el nombre de siguiente estado
func changeTo(new_state : String) -> void:
	if current_state and current_state.has_method("end"): current_state.end()
	current_state = get_node(new_state)
	_state_start()


#region CallBacks de GameLoop
##revisa que el estado tenga los metodos y los ejecuta
func _process(delta:float) -> void:
	if current_state and current_state.has_method("on_process"):
		current_state.on_process(delta)
		
func _physics_process(delta:float) -> void:
	if current_state and current_state.has_method("on_physics_process"):
		current_state.on_physics_process(delta)
		
func _input(event:InputEvent) -> void:
	if current_state and current_state.has_method("on_input"):
		current_state.on_input(event)
		
func _unhandled_input(event:InputEvent) -> void:
	if current_state and current_state.has_method("on_unhandled_input"):
		current_state.on_unhandled_input(event)
		
func _unhandled_key_input(event:InputEvent) -> void:
	if current_state and current_state.has_method("on_unhandled_key_input"):
		current_state.on_unhandled_key_input(event)
#endregion
	
