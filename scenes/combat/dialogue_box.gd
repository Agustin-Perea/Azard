extends Control
class_name DialogueBox

@export var char_delay: float = 0.05

@onready var text: RichTextLabel = $RichTextLabel
@onready var timer: Timer = $Timer

# --- NUEVOS REFERENCIAS DE NODOS ---
@onready var button_next: Button = $ButtonNext      # Botón para pasar el texto / saltar la animación
@onready var button_option: Button = $ButtonOption  # Botón que muestra las respuestas de button_lines

signal dialogue_finished

var dialogue_lines: Array[String] = [
	"Hola intruso!",
	"Veo que buscas la [wave]ascencion[/wave], es un camino muy peligroso que no todos puedan alcanzar, sabes?",
	"Realmente crees estar listo para continuar?",
	"Bien, tu entusiasmo me dice que estas listo",
	"[wave]EN GUARDIA!![/wave]"
]

var button_lines: Array[String] = [
	"...",
	"Si",
	"Por Supuesto",
	"...",
	"Listo"
]

var current_line: int = 0
var writing: bool = false

func _ready() -> void:
	timer.timeout.connect(_show_next_character)
	text.visible_characters = 0
	
	# Conectar las señales de ambos botones
	button_next.pressed.connect(_on_button_next_pressed)
	button_option.pressed.connect(_on_button_option_pressed)
	
	# Ocultar el botón de opciones al inicio
	button_option.hide()
	
	start_dialogue(dialogue_lines)

# --- CONTROL DE BOTONES ---

# Este botón maneja el "adelantar" o pasar de largo si se presiona la pantalla/teclado
func _on_button_next_pressed() -> void:
	if writing:
		# Si está escribiendo, salta directamente al final del texto actual
		_finish_writing_instantly()
	else:
		# Si ya terminó de escribir, este botón no hace nada (espera a que elijan la opción)
		pass

# Este botón solo se presiona cuando el texto terminó y el jugador elige su respuesta
func _on_button_option_pressed() -> void:
	button_option.hide() # Lo ocultamos para la siguiente línea
	button_next.show()   # Reactivamos el botón de saltar texto
	next_line()

# --- LÓGICA DEL DIÁLOGO ---

func start_dialogue(lines: Array[String]) -> void:
	dialogue_lines = lines
	current_line = 0
	_show_line()

func next_line() -> void:
	current_line += 1

	if current_line == dialogue_lines.size()-2:
		MusicManager.stop_music()
	if current_line >= dialogue_lines.size():
		end_dialogue()
		MusicManager.play_music(Constants.MUSIC_BOSS)
		return

	_show_line()

func _show_line() -> void:
	text.text = dialogue_lines[current_line]
	text.visible_characters = 0
	writing = true

	timer.wait_time = char_delay
	timer.start()

func _show_next_character() -> void:
	text.visible_characters += 1

	# text.get_total_character_count() a veces cuenta los tags de BBCode, 
	# es más seguro comparar contra la longitud del texto procesado.
	if text.visible_characters >= text.get_parsed_text().length():
		_on_line_finished()

# Función para cuando el texto termina de escribirse naturalmente o por skip
func _on_line_finished() -> void:
	timer.stop()
	writing = false
	text.visible_characters = -1 # Se asegura de mostrar todo (incluyendo efectos)
	
	# Cambiamos el estado de los botones
	button_next.hide() # Ya no hay nada que adelantar
	
	# Si existe una línea de botón asignada para este diálogo, la mostramos
	if current_line < button_lines.size():
		button_option.text = button_lines[current_line]
		button_option.show()
	else:
		# Fail-safe por si te quedas sin textos de botones
		button_option.text = "..."
		button_option.show()

func _finish_writing_instantly() -> void:
	_on_line_finished()

func end_dialogue() -> void:
	dialogue_finished.emit()
	timer.stop()
	text.clear()
	button_option.hide()
	button_next.hide()
