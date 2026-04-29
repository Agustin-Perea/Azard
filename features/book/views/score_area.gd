extends Node3D
class_name ScoreArea

@onready var roulette_controller: RouletteController = $"../.."

@onready var number : Label3D = $NumberLabel
@onready var base_damage : Label3D = $BaseLabel
@onready var multiplicator : Label3D = $MultLabel
@onready var total_damage : Label3D = $TotalLabel

@export var Labels : Array[Label3D]
@export var amplitud: float = 0.3
@export var velocidad: float = 4.0
var posiciones_iniciales = {}

#@onready var book_buttons : Node3D = $"../LibroContornoButtons"
@onready var reroll_button : SB_Button3D = $"../RerollButton"
@onready var rerolls_count_label : Label3D = $RerollCount
@export var rerolls_count :int


var player_stats : StatsComponent
@onready var Life_bar : Sprite3D = $"../LifeView"
@onready var health_progress_bar : ProgressBar = $"../SubViewport/ProgressBar"
@onready var info : Label3D = $"../LifeText"

func _ready() -> void:

	roulette_controller.baseChanged.connect(_on_change_base)
	roulette_controller.multiplicatorChanged.connect(_on_change_mult)
	
	roulette_controller.totalChanged.connect(_on_change_total)
	roulette_controller.betResolved.connect(_on_bet_resolved)
	for label in Labels:
		# Guardamos la posición local original de cada label
		posiciones_iniciales[label] = label.position
	BookEventBus.spin_started.connect(number_disappear)
	BookEventBus.spin_finished.connect(number_appear)
	
	#PlayerUiEvents.disable_camera_buttons.connect(_on_spin_started)
	#PlayerUiEvents.bet_procesed.connect(_on_bet_completed)
	reroll_button.pressed.connect(_on_reroll_pressed)
	rerolls_count = GameState.max_reroll
	
	player_stats = GameState.player_stats
	player_stats.health_changed.connect(_on_health_changed)
	_on_health_changed()
	
func _on_health_changed()->void:
	info.text = str(player_stats.current_healt) + "/" + str(player_stats.max_healt)
	health_progress_bar.max_value = player_stats.max_healt
	health_progress_bar.value = player_stats.current_healt
	
func _on_change_base() -> void:
	base_damage.text = str(int(round(roulette_controller.base)))
	
#esto deberia tener anim
func _on_change_mult(mult : float) -> void:
	#esto debe ser un evento
	multiplicator.text = str(int(round(roulette_controller.multiplier)))
	#callear un popupmult a multiplicator.globalpos
	if mult > 0:
		var text := str("x",mult)
		BookEventBus.popuptext.emit(multiplicator.position,text)
	

func _on_change_total() -> void:
	total_damage.text = str(int(round(roulette_controller.score)))
	
func _on_change_number() -> void:
	number.text = str(int(round(roulette_controller.number_winner)))
	
func _on_spin_started() -> void:
	#book_buttons.position.y = 200
	reroll_button.visible = false#tambien desactivar el collider o que process este deshabilitado

func _on_bet_completed() -> void:
	#book_buttons.position.y = 0
	reroll_button.visible = true
	
func _on_bet_resolved() -> void:
	multiplicator.text = str(1)
	total_damage.text = str(0)
	
	
#animacion de las labels
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	var tiempo = Time.get_ticks_msec() / 1000.0
	
	for label in Labels:
		if posiciones_iniciales.has(label):
			# Calculamos el desfase basado en su posición global para que la onda fluya
			var desfase = label.global_position.x * 2
			var movimiento = sin((tiempo * velocidad) + desfase) * amplitud
			
			# IMPORTANTE: Sumamos el movimiento a la posición original
			# en lugar de reemplazarla por completo
			label.position.z = posiciones_iniciales[label].z + movimiento

var tween : Tween
func number_appear()->void:
	

	# Crear el Tween
	
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": true,
		"action": func():
			# Configuración inicial (invisible y pequeño)
			_on_change_number()
			tween = create_tween()
			number.modulate.a = 0.0
			number.scale = Vector3.ZERO
			
			#tween.finished.connect(func(): tween = null)
			# Animar ambas propiedades al mismo tiempo (paralelas)
			tween.set_parallel(true)
			
			# Animar el Alpha (Transparencia) de 0 a 1
			tween.tween_property(number, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC)
			
			# Animar la Escala de (0,0,0) a (1,1,1)
			tween.tween_property(number, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			return true
	}))
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": true,
		"action": func():
			return !tween.is_running()
	}))	


func number_disappear()->void:
	
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": true,
		"blocking" : false,
		"action": func():
			# Configuración inicial (invisible y pequeño)
			tween = create_tween()
			number.modulate.a = 1.0
			number.scale = Vector3.ONE
			
			#tween.finished.connect(func(): tween = null)
			# Animar ambas propiedades al mismo tiempo (paralelas)
			tween.set_parallel(true)
			
			# Animar el Alpha (Transparencia) de 0 a 1
			tween.tween_property(number, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_LINEAR)
			
			# Animar la Escala de (0,0,0) a (1,1,1)
			tween.tween_property(number, "scale", Vector3.ZERO, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
			return true
	}))	
	
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": true,
		"blocking" : false,
		"action": func():
			return !tween.is_running() 
	}))	
	 

func _on_reroll_pressed()->void:

	if rerolls_count > 0:
		rerolls_count -= 1
		rerolls_count_label.text = str(rerolls_count) + "/" + str(GameState.max_reroll)
		
		roulette_controller.reroll()
	
