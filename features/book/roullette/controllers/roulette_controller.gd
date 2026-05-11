extends Node
class_name RouletteController

const ROULETTE_STATS_PAGE := preload("res://features/book/views/roulette_stats_page.gd")
const STATS_LEFT_COVER_MESH := preload("res://resources/map/models/map_left_case.res")
const STATS_RIGHT_COVER_MESH := preload("res://resources/map/models/map_right_case.res")
const STATS_BOTTOM_COVER_MESH := preload("res://resources/map/models/map_bottom_case.res")
const BOOK_OPEN_SOUND := preload("res://resources/sounds/open_book.wav")
const BOOK_CLOSE_SOUND := preload("res://resources/sounds/kodack__closing-a-book.wav")

var rng := RandomNumberGenerator.new()
var score: float = 0

signal numberChanged
signal baseChanged
signal multiplicatorChanged(float)
signal totalChanged
@warning_ignore("unused_signal")
signal betResolved

var base: float = 0
var multiplier: float = 1 
var number_winner: int 
var winner_betfield_model : BetFieldModel
var result_field_id : int = 0
#signal spin_resolved(result_field_id: int, delta_score: float, total_score: folat)

@onready var roulette_control : RouletteControl = $left_cover

#esto para decidir donde va el multanim y cual highlightear
@onready var table_meshes : TableFieldsController = $right_cover/BetTable

@onready var ball_mesh : MeshInstance3D = $left_cover/roulette_ball

@onready var finish_button : SB_Button3D = $left_cover/FinishMoveButton
@onready var left_cover : Node3D = $left_cover
@onready var right_cover : Node3D = $right_cover
@onready var bottom_cover : Node3D = $bottom_cover
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var audio_stream : AudioStreamPlayer = $AudioStreamPlayer


var last_ball_used : BallRuntimeState = null
var stats_page
var stats_page_visible := false
var stats_page_transitioning := false
var stats_default_left_cover_mesh: Mesh
var stats_default_right_cover_mesh: Mesh
var stats_default_bottom_cover_mesh: Mesh
var stats_normal_nodes: Array[Node] = []
var stats_node_visibility: Dictionary = {}
var stats_collision_disabled: Dictionary = {}
var stats_button_enabled: Dictionary = {}

func _ready() -> void:
	BookEventBus.start_spin.connect(on_start_spin)
	stats_default_left_cover_mesh = left_cover.mesh
	stats_default_right_cover_mesh = right_cover.mesh
	stats_default_bottom_cover_mesh = bottom_cover.mesh
	_setup_stats_page()
	

	#rng.seed = ObjectPoolsDataBase.master_seed
	rng.randomize()
	#spin()
	#CombatEventBus.update_base_score.connect(update_base_score)
	#
	#CombatEventBus.add_multiplier.connect(add_multiplier)
	#CombatEventBus.add_base.connect(add_base)
	#CombatEventBus.apply_mult.connect(multiply_mult_score)
	#CombatEventBus.reset_score.connect(reset_score)

func update_base_score(new_base : int)->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			base = new_base
			baseChanged.emit()
			return true
	}))

func multiply_mult_score(add_mult : float)->void:
	#agrega un evento que multiplica el mult
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			multiplier *= add_mult
			multiplicatorChanged.emit(add_mult)
			return true
	}))
	

func on_start_spin(ball : BallRuntimeState) -> void:
	if stats_page_visible:
		_set_stats_page_visible(false)
	_set_stats_toggle_enabled(false)
	
	last_ball_used = ball
	BookEventBus.spin_started.emit()
	
	#agregar el base de la bola
	add_base(ball.ball_definition.base_damage)
	#cambiar el material de la bola de la ruleta
	ball_mesh.material_override = ball.ball_definition.ball_material
	#desactivar colisiones
	UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.RoulleteSpin)
	#para test local
	UiEventBus.change_collision_detection.emit(true)
	
	
	## Elegimos un field ganador al azar
	result_field_id = rng.randi_range(0, 36)

	# 2. Obtenemos el BetFieldModel ganador
	winner_betfield_model = GameState.bet_field_models[result_field_id]
	number_winner = winner_betfield_model.number
	
	
	roulette_control.spin(number_winner)
	#Este mesnsaje hara que la ruleta gire
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			numberChanged.emit()#esto cambia la visual del numero ganador
			return true#Deberia esperar el tween, osea el finish del spin
	}))
	
	#espera que el spin de la ruleta termine
	await roulette_control.spin_finished
	BookEventBus.spin_finished.emit()
	#muestra el numero ganador y sus equals
	table_meshes.activate_highlight_field(result_field_id)
	
	#cambia de estado, ahora pasa el estado de muestra de cambios
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.BetResolve)
			return true#Deberia esperar el tween, osea el finish del spin
	}))

	await get_tree().create_timer(1).timeout

	# Resolvemos apuestas, en la funcion se agregan eventos de animacion
	var delta_score := _resolve_bets(result_field_id)
	score = delta_score#bad
	
	#eventos finales post resolve, bolas y pasivos
	ball.ball_definition.ball_effect.on_post_resolved(self)
	
	#cambio de score
	changeScore()
	
	await get_tree().create_timer(1).timeout
	#habilita los clicks al completar
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			table_meshes.deactivate_highlight_field()
			UiEventBus.change_collision_detection_buttons.emit(false)
			_set_stats_toggle_enabled(true)
			return true
	}))
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			##PlayerUiEvents.bet_procesed.emit()
			return true#Deberia esperar el tween, osea el finish del spin
	}))
	
	
func spin() -> void:
	if stats_page_visible:
		_set_stats_page_visible(false)
	_set_stats_toggle_enabled(false)

	#aca sucede el reroll?	
	#CombatEventBus.changeToState.emit("RouletteState")
	#CombatEventBus.disableClickableAreas()
	BookEventBus.spin_started.emit()
	## Elegimos un field ganador al azar
	result_field_id = rng.randi_range(0, 36)

	# 2. Obtenemos el BetFieldModel ganador
	winner_betfield_model = GameState.bet_field_models[result_field_id]
	number_winner = winner_betfield_model.number
	roulette_control.spin(number_winner)
	#Este mesnsaje hara que la ruleta gire
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			numberChanged.emit()#esto cambia la visual del numero ganador
			return true#Deberia esperar el tween, osea el finish del spin
	}))
	
	#espera que el spin de la ruleta termine
	await roulette_control.spin_finished
	BookEventBus.spin_finished.emit()

	#cambia de estado, ahora pasa el estado de muestra de cambios
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			##CombatEventBus.changeToState.emit("BetResolveState")
			return true#Deberia esperar el tween, osea el finish del spin
	}))
	#como no espera aun :v
	##table_meshes.table_fields.highlight_equals_field(result_field_id-1)
	await get_tree().create_timer(.5).timeout

	# Resolvemos apuestas, en la funcion se agregan eventos de animacion
	var delta_score := _resolve_bets(result_field_id)
	score = delta_score#bad
	
	#eventos finales post resolve, bolas y pasivos
	##CombatEventBus.bet_resolved.emit()
	
	#cambio de score
	changeScore()
	
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			##CombatEventBus.enableClickableAreas()
			_set_stats_toggle_enabled(true)
			return true#Deberia esperar el tween, osea el finish del spin
	}))
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			##PlayerUiEvents.bet_procesed.emit()
			return true#Deberia esperar el tween, osea el finish del spin
	}))
		

func changeScore()->void:
	#agrega un evento de cambio de score
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			score = int(round(base)) * int(round(multiplier))#actualmente es solo esto
			totalChanged.emit() 
			return true
	}))

@warning_ignore("shadowed_variable")
func _resolve_bets(result_field_id: int) -> float:
	# Obtenemos el BetFieldModel ganador
	var winner_model = GameState.bet_field_models[result_field_id] as BetFieldModel
	
	var delta := 0.0
	##CombatEventBus.pre_resolve.emit()
	var active_bets = GameState.get_Bets() as Dictionary[int, Array]

	#mmmm
	winner_model.activateHighlight.emit()
	#table_meshes.table_fields.highlight_field(result_field_id-1)
	BookEventBus.bet_pre_resolve.emit(self)
	var count : int = 0
	for field_id in active_bets:
		var field := GameState.get_bet_field_model(field_id) as BetFieldModel
		var chip_stack: Array = active_bets[field_id]
		# Verificamos si este campo cumple la condición ganadora
		if (chip_stack.size() > 0 and field.ConditionStrategy.matches(winner_model, field)):
			for i in range(0, chip_stack.size()):
				EventManager.add_event(EventManager.QueueType.GAME, 
				GameEvent.new({
					"paralel": false,
					"action": func():
						multiplier += field.multiplier
						multiplicatorChanged.emit(0)#esto modifica globalmente el mult
						return true
				}))
				table_meshes.call_mult_anim(field_id)
				field.call_betfield_animation.emit() #eso especificamente pone una anim en el campo
				#aca se llama muchas veces sin razon
			
			if count > 0:
				pass
			
			BookEventBus.bet_resolved.emit(self)
			
			count+=1#tambien deberia aumentar la velocidad de enimacion
			delta = multiplier
	
	BookEventBus.bet_post_resolved.emit(self)
	#m
	return delta

func add_multiplier(mult: float)->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			multiplier += mult
			multiplicatorChanged.emit(mult)#esto modifica globalmente el mult
			return true
	}))
func add_base(base_added: float)->void:
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			base += base_added
			baseChanged.emit()#esto modifica globalmente el mult
			return true
	}))

#reset_score
func reset_score()->void:
	score = 0
	multiplier = 0
	base = 0
	baseChanged.emit()
	multiplicatorChanged.emit(0)
	totalChanged.emit() 

#reroll
func reroll()->void:
	if last_ball_used:
		##CombatEventBus.reroll.emit(self)
		reset_score()
		#cambio de visuals o animacion
		
		#llama al estado de Spin de Ruleta
		on_start_spin(last_ball_used)

func _setup_stats_page() -> void:
	stats_page = ROULETTE_STATS_PAGE.new()
	stats_page.name = "RouletteStatsPage"
	add_child(stats_page)
	stats_page.setup(left_cover, right_cover)
	stats_page.toggle_requested.connect(_on_stats_page_toggle_requested)
	_cache_stats_normal_nodes()

func _cache_stats_normal_nodes() -> void:
	stats_normal_nodes.clear()
	stats_node_visibility.clear()
	stats_collision_disabled.clear()
	stats_button_enabled.clear()

	for child in left_cover.get_children():
		if child == stats_page.left_root or child == stats_page.get_toggle_button():
			continue
		_cache_stats_node(child)

	for child in right_cover.get_children():
		if child == stats_page.right_root:
			continue
		_cache_stats_node(child)

	_cache_stats_node(bottom_cover)

func _cache_stats_node(node: Node) -> void:
	if node is Node3D or node is CanvasItem:
		stats_normal_nodes.append(node)
		stats_node_visibility[node] = node.visible
	_cache_stats_interactive_state(node)

func _cache_stats_interactive_state(node: Node) -> void:
	if node is CollisionShape3D:
		stats_collision_disabled[node] = node.disabled
	if node is SB_Button3D:
		stats_button_enabled[node] = node.enabled
	for child in node.get_children():
		_cache_stats_interactive_state(child)

func _on_stats_page_toggle_requested() -> void:
	if stats_page_transitioning:
		return
	_transition_stats_page(not stats_page_visible)

func _transition_stats_page(value: bool) -> void:
	if animation_player == null:
		_set_stats_page_visible(value)
		return

	stats_page_transitioning = true
	_set_stats_toggle_enabled(false)
	animation_player.play("book_animations/book_close")
	_play_stats_page_sound(BOOK_CLOSE_SOUND)

	EventManager.add_event(EventManager.QueueType.GAME,
	GameEvent.new({
		"paralel": false,
		"action": func():
			return !animation_player.is_playing()
	}))

	EventManager.add_event(EventManager.QueueType.GAME,
	GameEvent.new({
		"paralel": false,
		"action": func():
			_set_stats_page_visible(value)
			animation_player.play("book_animations/book_open")
			_play_stats_page_sound(BOOK_OPEN_SOUND)
			return true
	}))

	EventManager.add_event(EventManager.QueueType.GAME,
	GameEvent.new({
		"paralel": false,
		"action": func():
			return !animation_player.is_playing()
	}))

	EventManager.add_event(EventManager.QueueType.GAME,
	GameEvent.new({
		"paralel": false,
		"action": func():
			stats_page_transitioning = false
			_set_stats_toggle_enabled(true)
			return true
	}))

func _set_stats_page_visible(value: bool) -> void:
	if value == stats_page_visible:
		stats_page.set_page_visible(value)
		return
	if value:
		_cache_stats_normal_nodes()

	stats_page_visible = value
	_set_stats_page_background(value)
	stats_page.set_page_visible(value)

	for node in stats_normal_nodes:
		node.visible = false if value else bool(stats_node_visibility.get(node, true))

	for collision_shape in stats_collision_disabled.keys():
		collision_shape.disabled = true if value else bool(stats_collision_disabled[collision_shape])

	for button in stats_button_enabled.keys():
		button.enabled = false if value else bool(stats_button_enabled[button])

	if value:
		UiEventBus.deactivate_descriptions.emit()

func _set_stats_toggle_enabled(value: bool) -> void:
	if stats_page:
		stats_page.set_toggle_enabled(value)

func _set_stats_page_background(value: bool) -> void:
	if value:
		left_cover.mesh = STATS_LEFT_COVER_MESH
		right_cover.mesh = STATS_RIGHT_COVER_MESH
		bottom_cover.mesh = STATS_BOTTOM_COVER_MESH
	else:
		left_cover.mesh = stats_default_left_cover_mesh
		right_cover.mesh = stats_default_right_cover_mesh
		bottom_cover.mesh = stats_default_bottom_cover_mesh

func _play_stats_page_sound(sound: AudioStream) -> void:
	if audio_stream == null:
		return
	audio_stream.stream = sound
	audio_stream.play()
