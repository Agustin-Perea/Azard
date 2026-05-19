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
@onready var info : Label3D = $"../LifeText"

const TURN_LOG_MAX_LINES := 4
const LABEL_ROTATION := Vector3(-90.0, 0.0, 0.0)
const LETHAL_SKULL_REST_SCALE := Vector3.ONE * 0.36
const LETHAL_SKULL_PULSE_SCALE := Vector3.ONE * 0.42

var turn_log_title_label: Label3D
var turn_log_labels: Array[Label3D] = []
var turn_log_entries: Array = []
var turn_log_open := false
var turn_log_button: SB_Button3D
var turn_log_button_label: Label3D
var turn_log_tooltip_panel: MeshInstance3D
var damage_caption_label: Label3D
var turn_log_ignore_next_click := false
var turn_log_empty_entry := {"text": "Aun no hay datos del tiro", "color": Color(1, 1, 1, 0.70)}
var lethal_preview_tween: Tween
var total_damage_rest_scale := Vector3.ONE
var lethal_skull_icon: Label3D

func _ready() -> void:
	_setup_qol_labels()
	_create_lethal_skull_icon()
	total_damage_rest_scale = total_damage.scale

	roulette_controller.baseChanged.connect(_on_change_base)
	roulette_controller.multiplicatorChanged.connect(_on_change_mult)
	
	roulette_controller.totalChanged.connect(_on_change_total)
	roulette_controller.betResolved.connect(_on_bet_resolved)
	BookEventBus.turn_log_reset.connect(_on_turn_log_reset)
	BookEventBus.turn_log_entry.connect(_on_turn_log_entry)
	BookEventBus.turn_log_close_requested.connect(_close_turn_log)
	BookEventBus.lethal_preview_changed.connect(set_lethal_preview)
	BookEventBus.pending_attack_restored.connect(_on_pending_attack_restored)
	for label in Labels:
		# Guardamos la posición local original de cada label
		posiciones_iniciales[label] = label.position
	BookEventBus.spin_started.connect(number_disappear)
	BookEventBus.spin_finished.connect(number_appear)
	
	
	BookEventBus.player_turn.connect(disable_reroll)
	BookEventBus.player_turn.connect(disable_finish_button)
	BookEventBus.spin_started.connect(enable_reroll)
	BookEventBus.spin_started.connect(enable_finish_button)
	
	
	
	#PlayerUiEvents.disable_camera_buttons.connect(_on_spin_started)
	#PlayerUiEvents.bet_procesed.connect(_on_bet_completed)
	reroll_button.pressed.connect(_on_reroll_pressed)
	GameState.current_reroll = rerolls_count
	
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

func _setup_qol_labels() -> void:
	damage_caption_label = _create_qol_label("DamageCaption", Vector3(-1.66, 0.025, -0.66), "Daño", 20, Color(0.3529412, 0.1764706, 0.2784314, 1.0), 500.0)
	turn_log_tooltip_panel = _create_turn_log_tooltip_panel()
	turn_log_title_label = _create_qol_label("TurnLogTitle", Vector3(0.08, 0.115, -1.25), "Ultimo tiro", 11, Color(1.0, 0.72, 0.24, 1.0), 800.0)
	turn_log_title_label.visible = false
	for i in range(TURN_LOG_MAX_LINES):
		var line := _create_qol_label("TurnLogLine" + str(i), Vector3(-0.08, 0.115, -1.15 + (i * 0.10)), "", 9, Color(1, 1, 1, 0.82), 1200.0)
		line.visible = false
		turn_log_labels.append(line)
	_create_turn_log_button()

func _create_turn_log_button() -> void:
	turn_log_button = SB_Button3D.new()
	turn_log_button.name = "TurnLogInfoButton"
	turn_log_button.position = Vector3(-0.17, 0.04, -0.69)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "ButtonRing"
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.105
	mesh.bottom_radius = 0.105
	mesh.height = 0.035
	mesh.radial_segments = 28
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.34, 0.16, 0.28, 1.0)
	mesh_instance.material_override = material
	turn_log_button.add_child(mesh_instance)

	var center_mesh_instance := MeshInstance3D.new()
	center_mesh_instance.name = "ButtonCenter"
	var center_mesh := CylinderMesh.new()
	center_mesh.top_radius = 0.073
	center_mesh.bottom_radius = 0.073
	center_mesh.height = 0.041
	center_mesh.radial_segments = 28
	center_mesh_instance.mesh = center_mesh
	var center_material := StandardMaterial3D.new()
	center_material.albedo_color = Color(0.97, 0.0, 0.45, 1.0)
	center_mesh_instance.material_override = center_material
	turn_log_button.add_child(center_mesh_instance)

	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.32, 0.12, 0.32)
	collision.shape = shape
	turn_log_button.add_child(collision)
	add_child(turn_log_button)
	turn_log_button.collision_shape = collision
	turn_log_button.input_event.connect(turn_log_button._on_input_event)
	turn_log_button.pressed.connect(_on_turn_log_button_pressed)

	turn_log_button_label = Label3D.new()
	turn_log_button_label.name = "TurnLogInfoLabel"
	turn_log_button_label.text = "i"
	turn_log_button_label.font_size = 19
	turn_log_button_label.modulate = Color(0.99, 0.99, 0.95, 1.0)
	turn_log_button_label.outline_size = 2
	turn_log_button_label.outline_modulate = Color(0.12, 0.06, 0.10, 0.92)
	turn_log_button_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_log_button_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	turn_log_button_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	turn_log_button_label.width = 180.0
	turn_log_button_label.no_depth_test = true
	turn_log_button_label.position = Vector3(-0.008, 0.032, 0.015)
	turn_log_button_label.rotation_degrees = LABEL_ROTATION
	turn_log_button.add_child(turn_log_button_label)

func _create_turn_log_tooltip_panel() -> MeshInstance3D:
	var panel := MeshInstance3D.new()
	panel.name = "TurnLogTooltipPanel"
	panel.position = Vector3(0.24, 0.075, -1.03)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.82, 0.025, 0.58)
	panel.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.70, 0.72, 0.48, 0.96)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	panel.material_override = material
	panel.visible = false
	add_child(panel)
	return panel

func _create_qol_label(label_name: String, local_position: Vector3, label_text: String, label_font_size: int, color: Color, label_width: float) -> Label3D:
	var label := Label3D.new()
	label.name = label_name
	label.text = label_text
	label.font_size = label_font_size
	label.modulate = color
	label.outline_size = 2
	label.outline_modulate = Color(0.12, 0.06, 0.10, 0.92)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.width = label_width
	label.no_depth_test = true
	label.render_priority = 30
	label.position = local_position
	label.rotation_degrees = LABEL_ROTATION
	add_child(label)
	return label

func _create_lethal_skull_icon() -> void:
	lethal_skull_icon = Label3D.new()
	lethal_skull_icon.name = "LethalSkullIcon"
	lethal_skull_icon.text = "☠"
	lethal_skull_icon.font_size = 60
	lethal_skull_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lethal_skull_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lethal_skull_icon.outline_size = 4
	lethal_skull_icon.outline_modulate = Color(0.05, 0.18, 0.12, 1.0)
	lethal_skull_icon.width = 120.0
	lethal_skull_icon.position = total_damage.position + Vector3(0.26, 0.018, -0.020)
	lethal_skull_icon.rotation_degrees = LABEL_ROTATION
	lethal_skull_icon.scale = LETHAL_SKULL_REST_SCALE
	lethal_skull_icon.modulate = Color(0.50, 1.0, 0.68, 1.0)
	lethal_skull_icon.no_depth_test = true
	lethal_skull_icon.render_priority = 32
	lethal_skull_icon.visible = false
	add_child(lethal_skull_icon)
	posiciones_iniciales[lethal_skull_icon] = lethal_skull_icon.position

func _on_turn_log_reset() -> void:
	turn_log_entries.clear()
	turn_log_open = false
	turn_log_ignore_next_click = false
	_refresh_turn_log()

func _on_turn_log_entry(text: String, color: Color) -> void:
	turn_log_entries.append({"text": text, "color": color})
	while turn_log_entries.size() > TURN_LOG_MAX_LINES:
		turn_log_entries.pop_front()
	_refresh_turn_log()

func _refresh_turn_log() -> void:
	var visible_entries := turn_log_entries
	if turn_log_open and visible_entries.is_empty():
		visible_entries = [turn_log_empty_entry]
	if turn_log_tooltip_panel != null:
		turn_log_tooltip_panel.visible = turn_log_open
	if turn_log_title_label != null:
		turn_log_title_label.visible = turn_log_open
	for i in range(turn_log_labels.size()):
		var label := turn_log_labels[i]
		if turn_log_open and i < visible_entries.size():
			var entry := visible_entries[i] as Dictionary
			label.text = str(entry.get("text", ""))
			label.modulate = entry.get("color", Color(1, 1, 1, 0.82))
			label.visible = true
		else:
			label.text = ""
			label.visible = false

func _on_turn_log_button_pressed() -> void:
	turn_log_open = not turn_log_open
	turn_log_ignore_next_click = turn_log_open
	_refresh_turn_log()

func _close_turn_log() -> void:
	if not turn_log_open:
		return
	turn_log_open = false
	turn_log_ignore_next_click = false
	_refresh_turn_log()

func _input(event: InputEvent) -> void:
	if not turn_log_open:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if turn_log_ignore_next_click:
			turn_log_ignore_next_click = false
			return
		_close_turn_log()
	
	
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

	if lethal_skull_icon != null and lethal_skull_icon.visible and posiciones_iniciales.has(lethal_skull_icon):
		var skull_desfase = lethal_skull_icon.global_position.x * 2
		var skull_movimiento = sin((tiempo * velocidad) + skull_desfase) * amplitud
		lethal_skull_icon.position.z = posiciones_iniciales[lethal_skull_icon].z + skull_movimiento

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
		GameState.current_reroll = rerolls_count
		
		roulette_controller.reroll()
		
	if rerolls_count <= 0:
		disable_reroll()

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

func _on_pending_attack_restored() -> void:
	enable_finish_button()
	enable_reroll()

func set_lethal_preview(active: bool) -> void:
	if lethal_preview_tween != null:
		lethal_preview_tween.kill()
		lethal_preview_tween = null
	total_damage.scale = total_damage_rest_scale
	if lethal_skull_icon != null and posiciones_iniciales.has(lethal_skull_icon):
		lethal_skull_icon.position = posiciones_iniciales[lethal_skull_icon]
	if not active:
		total_damage.modulate = Color(1, 1, 1, 1)
		if lethal_skull_icon != null:
			lethal_skull_icon.visible = false
		return
	total_damage.modulate = Color(0.18, 0.95, 0.50, 1.0)
	if lethal_skull_icon != null:
		lethal_skull_icon.visible = true
		lethal_skull_icon.scale = LETHAL_SKULL_REST_SCALE
	lethal_preview_tween = create_tween()
	lethal_preview_tween.set_parallel(true)
	lethal_preview_tween.tween_property(total_damage, "scale", total_damage_rest_scale * 1.08, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if lethal_skull_icon != null:
		lethal_preview_tween.tween_property(lethal_skull_icon, "scale", LETHAL_SKULL_PULSE_SCALE, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	lethal_preview_tween.chain().tween_property(total_damage, "scale", total_damage_rest_scale, 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if lethal_skull_icon != null:
		lethal_preview_tween.chain().tween_property(lethal_skull_icon, "scale", LETHAL_SKULL_REST_SCALE, 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
