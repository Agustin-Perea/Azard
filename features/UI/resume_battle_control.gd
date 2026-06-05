extends Control

@onready var panel : PanelContainer = $Panel

@onready var resume_label : Label = $Panel/VBoxContainer/Panel2/VBoxContainer/HBoxContainer/Resume_Labels
@onready var resume_money_label : Label = $Panel/VBoxContainer/Panel2/VBoxContainer/HBoxContainer/Resume_Money

@onready var total_label : Label = $Panel/VBoxContainer/Panel2/VBoxContainer/HBoxContainer2/Desctiption
@onready var total_money_label : Label = $Panel/VBoxContainer/Panel2/VBoxContainer/HBoxContainer2/Desctiption2

@onready var continue_button : Button = $Panel/VBoxContainer/Button

var labels_template : Array[String] = [
	"Enemies slayed %s", "$%s",
	"Rerolls Remain %s", "$%s",
	"Turns (5 - %s turns)", "$%s",
	"Interests($1 each $5)", "$%s",
	"TOTAL", " $%s"
]

var labels : Array[String] = []
var mi_tween : Tween
var animacion_terminada : bool = false

func _ready() -> void:
	# Para probarlo dentro de la misma clase si lo ejecutas por separado.
	continue_button.pressed.connect(on_button_pressed)
	BookEventBus.victory.connect(preparar_pantalla_victoria)



func on_victory()->void:
	UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.BookCaseState)
	UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.CASE)	

func on_button_pressed()->void:
	GameState.economy_component.grant_combat_victory_gold()
	on_victory()
	self.visible = false
	#BookEventBus.victory.emit()
	#call bookcase
	
func preparar_pantalla_victoria() -> void:
	var combat_data := GameState.economy_component.calculate_combat_gold_reward()
	continue_button.visible = false
	total_label.text = ""
	total_money_label.text = ""
	animacion_terminada = false
	
	panel.scale = Vector2.ZERO
	panel.modulate.a = 0.0
	
	if not panel.gui_input.is_connected(_on_panel_gui_input):
		panel.gui_input.connect(_on_panel_gui_input)
	
	# Obtenemos las estadísticas de los componentes globales
	var cant_enemigos = GameState.economy_component.enemies_slayed_on_battle
	var cant_rerolls = GameState.current_reroll
	var cant_turnos = GameState.economy_component.combat_turns_taken
	
	# Rellenamos el array formateando cada string con sus datos correspondientes
	labels = [
		labels_template[0] % str(cant_enemigos), str(combat_data.get("base", 0)),
		labels_template[2] % str(cant_rerolls),  str(combat_data.get("rerolls", 0)),
		labels_template[4] % str(cant_turnos),   str(combat_data.get("turns", 0)),
		labels_template[6],                      str(combat_data.get("interests", 0)),
		labels_template[8],                      str(combat_data.get("total", 0))
	]
	
	# Procesamos las primeras 4 filas (bloque superior)
	var texto_completo : String = ""
	var dinero_completo : String = ""
	for i in range(0, 8, 2):
		if i > 0:
			texto_completo += "\n"
			dinero_completo += "\n"
		texto_completo += labels[i]
		dinero_completo += "$" + labels[i+1] # Añadimos el símbolo de peso al dinero dinámicamente
	
	resume_label.text = texto_completo
	resume_money_label.text = dinero_completo
	resume_label.visible_characters = 0
	resume_money_label.visible_characters = 0
	
	await get_tree().process_frame
	panel.pivot_offset = panel.size / 2
	
	self.visible = true
	animar_interfaz()


func animar_interfaz() -> void:
	mi_tween = create_tween()
	mi_tween.finished.connect(func(): animacion_terminada = true)
	
	# FASE 1: APARICIÓN DEL PANEL
	mi_tween.tween_property(panel, "scale", Vector2.ONE, 0.5)\
		.from(Vector2.ZERO)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	mi_tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.3).from(0.0)
	mi_tween.chain().tween_interval(0.2)
	
	# FASE 2: TEXTO FILA POR FILA (Calculando el tamaño real con los símbolos '$' incluidos)
	var letras_texto_acumuladas : int = 0
	var letras_dinero_acumuladas : int = 0
	
	# Separamos las líneas reales generadas para medir sus caracteres exactos
	var lineas_texto = resume_label.text.split("\n")
	var lineas_dinero = resume_money_label.text.split("\n")
	
	for i in range(4):
		var largo_linea_texto = lineas_texto[i].length() + (1 if i > 0 else 0)
		var largo_linea_dinero = lineas_dinero[i].length() + (1 if i > 0 else 0)
		
		var nuevo_limite_texto = letras_texto_acumuladas + largo_linea_texto
		var nuevo_limite_dinero = letras_dinero_acumuladas + largo_linea_dinero
		
		var sub_tween = mi_tween.parallel()
		sub_tween.tween_property(resume_label, "visible_characters", nuevo_limite_texto, largo_linea_texto * 0.03).from(letras_texto_acumuladas)
		sub_tween.tween_property(resume_money_label, "visible_characters", nuevo_limite_dinero, largo_linea_dinero * 0.04).from(letras_dinero_acumuladas)
		
		letras_texto_acumuladas = nuevo_limite_texto
		letras_dinero_acumuladas = nuevo_limite_dinero
		mi_tween.chain().tween_interval(0.08)

	# FASE 3: TOTAL
	mi_tween.tween_callback(func():
		total_label.text = labels[8]
		total_money_label.text = "$" + labels[9]
		total_label.visible_characters = 0
		total_money_label.visible_characters = 0
	)
	
	var total_tween = mi_tween.parallel()
	total_tween.tween_property(total_label, "visible_characters", labels[8].length(), labels[8].length() * 0.04).from(0)
	total_tween.tween_property(total_money_label, "visible_characters", (labels[9].length() + 1), (labels[9].length() + 1) * 0.05).from(0)
	
	# FASE 4: BOTÓN CONTINUAR
	mi_tween.chain().tween_interval(0.2)
	mi_tween.tween_callback(func(): 
		continue_button.visible = true
		continue_button.modulate.a = 0.0
	)
	mi_tween.tween_property(continue_button, "modulate:a", 1.0, 0.25)


func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if not animacion_terminada:
			completar_animacion_inmediatamente()


func completar_animacion_inmediatamente() -> void:
	animacion_terminada = true
	
	if mi_tween and mi_tween.is_valid():
		mi_tween.kill()
	
	panel.scale = Vector2.ONE
	panel.modulate.a = 1.0
	
	resume_label.visible_characters = -1
	resume_money_label.visible_characters = -1
	
	total_label.text = labels[8]
	total_money_label.text = "$" + labels[9]
	total_label.visible_characters = -1
	total_money_label.visible_characters = -1
	
	continue_button.visible = true
	continue_button.modulate.a = 1.0
