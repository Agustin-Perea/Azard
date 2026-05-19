extends Node
class_name RouletteController

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


var last_ball_used : BallRuntimeState = null

func _ready() -> void:
	BookEventBus.start_spin.connect(on_start_spin)
	

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
	
	last_ball_used = ball
	BookEventBus.turn_log_reset.emit()
	BookEventBus.turn_log_entry.emit("Bola: " + _get_ball_log_name(ball) + " | Base +" + str(ball.ball_definition.base_damage), Color(0.45, 0.72, 1.0, 1.0))
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
	BookEventBus.turn_log_entry.emit("Resultado: " + str(number_winner), Color(0.32, 0.78, 0.38, 1.0))
	#muestra el numero ganador y sus equals
	table_meshes.highlight_winning_result(result_field_id)
	
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
			BookEventBus.turn_log_entry.emit("Daño final: " + str(int(round(score))), Color(0.95, 0.36, 0.42, 1.0))
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
				var activated_chip_id := int(chip_stack[i])
				var multiplier_added := field.multiplier
				var log_text := _get_field_log_name(field) + ": +" + _format_number(multiplier_added) + " mult"
				EventManager.add_event(EventManager.QueueType.GAME, 
				GameEvent.new({
					"paralel": false,
					"action": func():
						multiplier += field.multiplier
						multiplicatorChanged.emit(0)#esto modifica globalmente el mult
						BookEventBus.bet_chip_activated.emit(activated_chip_id)
						BookEventBus.turn_log_entry.emit(log_text, Color(1.0, 0.72, 0.24, 1.0))
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
	
	if count == 0:
		BookEventBus.turn_log_entry.emit("Sin fichas activadas", Color(1, 1, 1, 0.60))
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

func _get_ball_log_name(ball: BallRuntimeState) -> String:
	if ball == null or ball.ball_definition == null or ball.ball_definition.ball_effect == null:
		return "Bola"
	if ball.ball_definition.ball_effect.name == "":
		return "Bola"
	return ball.ball_definition.ball_effect.name

func _get_field_log_name(field: BetFieldModel) -> String:
	if field == null or field.ConditionStrategy == null:
		return "Ficha"
	if field.ConditionStrategy is StraightUpCondition:
		return "Individual " + str(field.number)
	if field.ConditionStrategy is RedCondition:
		return "Rojo"
	if field.ConditionStrategy is BlackCondition:
		return "Negro"
	if field.ConditionStrategy is EvenCondition:
		return "Par"
	if field.ConditionStrategy is OddCondition:
		return "Impar"
	if field.ConditionStrategy is FirstHalfCondition:
		return "1-18"
	if field.ConditionStrategy is SecondHalfCondition:
		return "19-36"
	if field.ConditionStrategy is FirstRowCondition:
		return "1st 12"
	if field.ConditionStrategy is SecondRowCondition:
		return "2nd 12"
	if field.ConditionStrategy is ThirdRowCondition:
		return "3rd 12"
	if field.ConditionStrategy is FirstColumnCondition:
		return "Columna 1"
	if field.ConditionStrategy is SecondColumnCondition:
		return "Columna 2"
	if field.ConditionStrategy is ThirdColumnCondition:
		return "Columna 3"
	return "Ficha"

func _format_number(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return str(value)
