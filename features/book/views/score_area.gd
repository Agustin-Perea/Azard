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
const BASE_POPUP_OFFSET := Vector3(0.0, 0.0, 0.0)
const MULT_POPUP_OFFSET := Vector3(-0.12, 0.0, 0.08)

#@onready var book_buttons : Node3D = $"../LibroContornoButtons"
@onready var reroll_button : SB_Button3D = $"../RerollButton"
@onready var rerolls_count_label : Label3D = $RerollCount
@onready var turn_count_label : Label3D = $TrunCount
@onready var player_health_view : Sprite3D = $"../LifeView"
@onready var player_health_bar : ProgressBar = $"../SubViewport/ProgressBar"
@onready var player_health_label : Label3D = $"../LifeText"
@export var rerolls_count :int

var connected_player_stats: StatsComponent


func _ready() -> void:
	roulette_controller.baseChanged.connect(_on_change_base)
	roulette_controller.basePopupRequested.connect(_on_base_popup_requested)
	roulette_controller.multiplicatorChanged.connect(_on_change_mult)
	
	roulette_controller.totalChanged.connect(_on_change_total)
	roulette_controller.betResolved.connect(_on_bet_resolved)
	_on_change_base()
	_on_change_mult(0)
	_on_change_total()
	for label in Labels:
		# Guardamos la posición local original de cada label
		posiciones_iniciales[label] = label.position
	BookEventBus.spin_started.connect(number_disappear)
	BookEventBus.spin_finished.connect(number_appear)
	
	#PlayerUiEvents.disable_camera_buttons.connect(_on_spin_started)
	#PlayerUiEvents.bet_procesed.connect(_on_bet_completed)
	reroll_button.pressed.connect(_on_reroll_pressed)
	GameState.rerolls_changed.connect(_on_rerolls_changed)
	_on_rerolls_changed(GameState.current_reroll, GameState.max_reroll)
	if not GameState.initialized.is_connected(_connect_player_health):
		GameState.initialized.connect(_connect_player_health)
	if not BookEventBus.player_turn_started.is_connected(_on_player_turn_started):
		BookEventBus.player_turn_started.connect(_on_player_turn_started)
	_connect_player_health()
	_refresh_turn_count()
	

func _on_change_base() -> void:
	base_damage.text = str(int(round(roulette_controller.base)))

func _on_base_popup_requested(delta: float) -> void:
	if delta > 0.0:
		var popup := roulette_controller.get_node_or_null("PopUpText")
		if popup != null and popup.has_method("animate_now"):
			popup.animate_now(base_damage.position + BASE_POPUP_OFFSET, "+%.1f" % delta, false)
		else:
			BookEventBus.popuptext.emit(base_damage.position + BASE_POPUP_OFFSET, "+%.1f" % delta, false)
	
#esto deberia tener anim
func _on_change_mult(mult : float) -> void:
	multiplicator.text = str(int(round(roulette_controller.multiplier)))
	if mult > 0.0:
		BookEventBus.popuptext.emit(multiplicator.position + MULT_POPUP_OFFSET, "x" + str(mult), false)
	

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
	multiplicator.text = str(0)
	total_damage.text = str(0)

func _on_rerolls_changed(current_reroll: int, max_reroll: int) -> void:
	rerolls_count = current_reroll
	rerolls_count_label.text = str(current_reroll) + "/" + str(max_reroll)

func _connect_player_health() -> void:
	if connected_player_stats != null and connected_player_stats.health_changed.is_connected(_on_player_health_changed):
		connected_player_stats.health_changed.disconnect(_on_player_health_changed)
	connected_player_stats = GameState.player_stats
	if connected_player_stats != null and not connected_player_stats.health_changed.is_connected(_on_player_health_changed):
		connected_player_stats.health_changed.connect(_on_player_health_changed)
	_on_player_health_changed()

func _on_player_health_changed() -> void:
	var stats := connected_player_stats
	if stats == null:
		stats = GameState.player_stats
	if stats == null:
		return
	var max_health: int = max(1, stats.max_healt)
	var current_health: int = clamp(stats.current_healt, 0, max_health)
	player_health_bar.max_value = max_health
	player_health_bar.value = current_health
	player_health_label.text = "%d/%d" % [current_health, max_health]
	player_health_view.visible = true
	player_health_label.visible = true

func _on_player_turn_started() -> void:
	call_deferred("_refresh_turn_count")

func _refresh_turn_count() -> void:
	if turn_count_label != null:
		turn_count_label.text = str(GameState.combat_turns_taken)
	
	
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
	roulette_controller.reroll()
	
