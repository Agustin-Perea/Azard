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
@onready var reroll_mesh : MeshInstance3D = $"../RerollButton/MeshInstance3D"

@onready var finish_button : SB_Button3D = $"../FinishMoveButton"
@onready var finish_button_mesh : MeshInstance3D = $"../FinishMoveButton/MeshInstance3D"



@onready var rerolls_count_label : Label3D = $RerollCount
@export var rerolls_count :int



var player_stats : StatsComponent
@onready var Life_bar : Sprite3D = $"../LifeView"
@onready var health_progress_bar : ProgressBar = $"../SubViewport/ProgressBar"
@onready var shield_rect : ColorRect = $"../SubViewport/ColorRect"
@onready var shield_icon : Sprite3D = $"../ShieldIcon"
@onready var shield_text : Label3D = $"../ShieldText"
@onready var info : Label3D = $"../LifeText"

@onready var turn_count : Label3D =$TurnCount

var player_turns : int = -1


var local_base : float = 0
var local_mult : float = 0

var local_pv : int = 0
var local_shield : int = 0
#deberia agregar los onadd y onmult aca con popup y sus valores visuales particulares

func _ready() -> void:

	roulette_controller.updateBase.connect(_on_change_base)
	roulette_controller.updateMult.connect(_on_change_mult)
	
	roulette_controller.base_added.connect(_on_add_base)
	roulette_controller.multiplicator_added.connect(_on_add_mult)
	roulette_controller.x_multiplicator.connect(_on_x_multiplier)
	
	roulette_controller.totalChanged.connect(_on_change_total)
	roulette_controller.betResolved.connect(_on_bet_resolved)
	for label in Labels:
		# Guardamos la posición local original de cada label
		posiciones_iniciales[label] = label.position
	BookEventBus.spin_started.connect(number_disappear)
	BookEventBus.spin_finished.connect(number_appear)
	
	
	BookEventBus.player_turn.connect(disable_reroll)
	BookEventBus.player_turn.connect(disable_finish_button)
	BookEventBus.spin_started.connect(enable_reroll)
	BookEventBus.spin_started.connect(enable_finish_button)
	
	BookEventBus.player_turn.connect(on_player_turn)
	
	reroll_button.pressed.connect(_on_reroll_pressed)
	GameState.current_reroll = rerolls_count
	
	rerolls_count = GameState.max_reroll
	GameState.current_reroll = rerolls_count
	rerolls_count_label.text = str(rerolls_count) + "/" + str(GameState.max_reroll)
	
	player_stats = GameState.player_stats
	player_stats.health_changed.connect(refresh_stats)
	player_stats.shield_added.connect(on_shield_added)
	player_stats.health_added.connect(on_health_added)
	player_stats.health_consumed.connect(on_healt_consumed)
	
	
	refresh_stats()

	
func on_player_turn()->void:
	player_turns += 1
	turn_count.text = str(player_turns)

func refresh_stats()->void:
	local_pv = player_stats.current_healt
	local_shield = player_stats.shield
	_on_health_changed()

func _on_health_changed()->void:
	info.text = str(local_pv) + "/" + str(player_stats.max_healt)
	health_progress_bar.max_value = player_stats.max_healt
	health_progress_bar.value = player_stats.current_healt
	
	if local_shield > 0:
		shield_rect.visible = true
		shield_icon.visible = true
		shield_text.visible = true
		shield_text.text = str(local_shield)
	else:
		shield_rect.visible = false
		shield_icon.visible = false
		shield_text.visible = false

func on_shield_added(shield_added : int)->void:
	
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			local_shield += shield_added
			_on_health_changed()
			player_stats.health_changed.emit()
			return true
	}))
	BookEventBus.popuptext.emit(shield_icon.global_position,str("+",shield_added))


func on_health_added(health_added : int)->void:
	
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			local_pv += health_added
			_on_health_changed()
			player_stats.health_changed.emit()
			return true
	}))
	BookEventBus.popuptext.emit(info.global_position,str("+",health_added))

func on_healt_consumed(health_consumed : int)->void:
	
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			local_pv += health_consumed
			_on_health_changed()
			return true
	}))
	BookEventBus.popuptext.emit(info.global_position,str("-",health_consumed))
	



func _on_add_base(base_added : float) -> void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			local_base += base_added
			base_damage.text = str(int(round(local_base)))
			return true
	}))
	BookEventBus.popuptext.emit(base_damage.global_position,str("+",int(round(base_added))))

func _on_add_mult(mult_added : float, popup :bool = true) -> void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			local_mult += mult_added
			multiplicator.text = str(int(round(local_mult)))
			return true
	}))	
	if popup:
		BookEventBus.popuptext.emit(multiplicator.position,str("+",int(round(mult_added))))
	
	
func _on_change_base() -> void:
	local_base = roulette_controller.base
	base_damage.text = str(int(round(roulette_controller.base)))

#esto deberia tener anim
func _on_change_mult() -> void:
	local_mult = roulette_controller.multiplier
	multiplicator.text = str(int(round(roulette_controller.multiplier)))



func _on_x_multiplier(x_mult : float)->void:
	var text := str("x",x_mult)
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			local_mult *= x_mult
			multiplicator.text = str(int(round(local_mult)))
			return true
	}))	
	BookEventBus.popuptext.emit(multiplicator.global_position,text)


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
		
	if rerolls_count <= 0:
		disable_reroll()
	GameState.current_reroll = rerolls_count

func disable_reroll()->void:
	reroll_mesh.get_active_material(0).set_shader_parameter("palette_offset",1.9)
	reroll_mesh.get_active_material(0).set_shader_parameter("palette_offset_y",0.1)

	reroll_button.enabled = false
	
func enable_reroll()->void:
	if rerolls_count > 0:
		reroll_mesh.get_active_material(0).set_shader_parameter("palette_offset",0)
		reroll_mesh.get_active_material(0).set_shader_parameter("palette_offset_y",0)
	reroll_button.enabled = true

func disable_finish_button()->void:
	finish_button_mesh.get_active_material(0).set_shader_parameter("palette_offset",1.9)
	finish_button_mesh.get_active_material(0).set_shader_parameter("palette_offset_y",0.1)
	finish_button.enabled = false
	
func enable_finish_button()->void:
	finish_button_mesh.get_active_material(0).set_shader_parameter("palette_offset",0.6)
	finish_button_mesh.get_active_material(0).set_shader_parameter("palette_offset_y",0.8)
	finish_button.enabled = true
