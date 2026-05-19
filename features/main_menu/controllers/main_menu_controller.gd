extends Control

const HELP_FONT := preload("res://resources/fonts/FuzzyBubbles-Bold.ttf")
const BALLS_DATABASE := preload("res://features/balls/database/balls_unlocked_database.tres")
const PASSIVE_ITEMS_DATABASE := preload("res://features/items/passive_items/database/passive_items_pool.tres")

const HELP_SECTIONS := [
	"Como jugar",
	"Combate",
	"Ruleta",
	"Bolas",
	"Trinkets",
	"Tienda",
	"Mejoras",
	"Economia",
]
const HELP_SECTION_COLORS := {
	"Como jugar": Color(0.92, 0.93, 0.73, 1.0),
	"Combate": Color(0.95, 0.36, 0.42, 1.0),
	"Ruleta": Color(0.32, 0.78, 0.38, 1.0),
	"Bolas": Color(0.45, 0.72, 1.0, 1.0),
	"Trinkets": Color(0.75, 0.52, 1.0, 1.0),
	"Tienda": Color(0.96, 0.34, 0.62, 1.0),
	"Mejoras": Color(1.0, 0.72, 0.24, 1.0),
	"Economia": Color(1.0, 0.84, 0.20, 1.0),
}
const GLASS_BUTTON_NORMAL := Color(1.0, 1.0, 1.0, 0.07)
const GLASS_BUTTON_HOVER := Color(1.0, 1.0, 1.0, 0.15)
const GLASS_BUTTON_PRESSED := Color(0.0, 0.0, 0.0, 0.24)
const GLASS_BORDER := Color(0.913725, 0.929412, 0.733333, 0.24)
const GLASS_CARD := Color(0.035, 0.018, 0.040, 0.38)
const GLASS_CARD_PLANNED := Color(0.050, 0.030, 0.060, 0.26)

@onready var continue_button: Button = $MenuContent/Buttons/ContinueButton
@onready var confirm_overlay: Control = $ConfirmOverlay
@onready var help_overlay: Control = $HelpOverlay
@onready var help_tabs: VBoxContainer = $HelpOverlay/Panel/Margin/Content/Body/Sections
@onready var help_title: Label = $HelpOverlay/Panel/Margin/Content/Header/Title
@onready var help_body: VBoxContainer = $HelpOverlay/Panel/Margin/Content/Body/Scroll/HelpBody
@onready var help_back_button: Button = $HelpOverlay/Panel/Margin/Content/Header/BackButton
@onready var cancel_new_run_button: Button = $ConfirmOverlay/Panel/Content/Buttons/CancelNewRunButton
@onready var confirm_new_run_button: Button = $ConfirmOverlay/Panel/Content/Buttons/ConfirmNewRunButton
@onready var click_player: AudioStreamPlayer = $ClickPlayer

const CLICK_VOLUME_DB := -17.0

var active_help_section := "Como jugar"
var help_section_buttons: Dictionary = {}

func _ready() -> void:
	var music_manager := get_node_or_null("/root/MusicManager")
	if music_manager != null:
		music_manager.call("play_menu_music")
	click_player.volume_db = CLICK_VOLUME_DB
	if has_node("/root/UiHud"):
		UiHud.visible = false
	UiEventBus.selection_button_visible.emit(false)
	UiEventBus.book_button_visible.emit(false)
	continue_button.disabled = not GameState.has_save()
	continue_button.modulate.a = 1.0 if GameState.has_save() else 0.45
	confirm_overlay.visible = false
	help_overlay.visible = false
	_setup_modal_button_styles()
	_setup_help()

func _on_play_button_pressed() -> void:
	_play_click()
	if GameState.has_save():
		confirm_overlay.visible = true
		return
	_start_new_run()

func _on_confirm_new_run_button_pressed() -> void:
	_play_click()
	confirm_overlay.visible = false
	_start_new_run()

func _on_cancel_new_run_button_pressed() -> void:
	_play_click()
	confirm_overlay.visible = false

func _start_new_run() -> void:
	GameState.new_run()
	_go_to_scene(GameState.MAP_SCENE_PATH)

func _on_continue_button_pressed() -> void:
	if not GameState.has_save():
		return
	_play_click()
	if GameState.load_run():
		_go_to_scene(GameState.get_current_scene_path())
	else:
		continue_button.disabled = true
		continue_button.modulate.a = 0.45

func _on_quit_button_pressed() -> void:
	_play_click()
	get_tree().quit()

func _on_help_button_pressed() -> void:
	_play_click()
	confirm_overlay.visible = false
	help_overlay.visible = true
	_show_help_section(active_help_section)

func _on_help_back_button_pressed() -> void:
	_play_click()
	help_overlay.visible = false

func _go_to_scene(scene_path: String) -> void:
	if has_node("/root/UiHud"):
		UiHud.visible = true
	UiEventBus.change_scene_to.emit(scene_path)

func _play_click() -> void:
	if click_player != null:
		click_player.play()

func _setup_help() -> void:
	help_section_buttons.clear()
	for section in HELP_SECTIONS:
		var button := Button.new()
		button.text = section
		button.focus_mode = Control.FOCUS_NONE
		button.flat = false
		button.custom_minimum_size = Vector2(295, 72)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_override("font", HELP_FONT)
		button.add_theme_font_size_override("font_size", 26)
		button.add_theme_color_override("font_color", Color(1, 1, 1, 0.86))
		button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
		button.add_theme_color_override("font_pressed_color", HELP_SECTION_COLORS.get(section, Color.WHITE))
		button.add_theme_stylebox_override("normal", _make_button_style(GLASS_BUTTON_NORMAL, GLASS_BORDER))
		button.add_theme_stylebox_override("hover", _make_button_style(GLASS_BUTTON_HOVER, Color(0.913725, 0.929412, 0.733333, 0.42)))
		button.add_theme_stylebox_override("pressed", _make_button_style(GLASS_BUTTON_PRESSED, HELP_SECTION_COLORS.get(section, Color.WHITE)))
		button.pressed.connect(_on_help_section_pressed.bind(section))
		help_tabs.add_child(button)
		help_section_buttons[section] = button
	_show_help_section(active_help_section)

func _on_help_section_pressed(section: String) -> void:
	_show_help_section(section)

func _show_help_section(section: String) -> void:
	active_help_section = section
	help_title.text = section
	help_title.add_theme_color_override("font_color", HELP_SECTION_COLORS.get(section, Color.WHITE))
	for button_section in help_section_buttons.keys():
		var button := help_section_buttons[button_section] as Button
		var active := str(button_section) == section
		button.add_theme_color_override("font_color", Color(1, 1, 1, 1) if active else Color(1, 1, 1, 0.68))
		button.add_theme_stylebox_override("normal", _make_button_style(Color(1, 1, 1, 0.18) if active else GLASS_BUTTON_NORMAL, HELP_SECTION_COLORS.get(str(button_section), GLASS_BORDER) if active else GLASS_BORDER))
	for child in help_body.get_children():
		child.queue_free()
	match section:
		"Como jugar":
			_render_help_entries(_get_how_to_play_entries())
		"Combate":
			_render_help_entries(_get_combat_entries())
		"Ruleta":
			_render_table_entries()
		"Bolas":
			_render_ball_entries()
		"Trinkets":
			_render_item_entries()
		"Tienda":
			_render_help_entries(_get_shop_entries())
		"Mejoras":
			_render_help_entries(_get_upgrade_entries())
		"Economia":
			_render_help_entries(_get_economy_entries())

func _render_help_entries(entries: Array) -> void:
	for entry in entries:
		var data := entry as Dictionary
		_add_help_entry(
			str(data.get("title", "")),
			str(data.get("body", "")),
			data.get("color", Color(1, 1, 1, 1)),
			bool(data.get("planned", false))
		)

func _render_table_entries() -> void:
	_add_help_entry("Como se lee", "Probabilidad = casillas que cumplen / 37 posibles resultados. Lv empieza en 0; mas adelante las compras subiran esos valores.", Color(0.92, 0.93, 0.73, 1.0))
	var rows := [
		{"title": "Individual", "body": "1/37 | Lv 0 | activa +36", "color": Color(1.0, 0.72, 0.24, 1.0)},
		{"title": "Rojo", "body": "18/37 | Lv 0 | activa +2", "color": Color(0.95, 0.05, 0.16, 1.0)},
		{"title": "Negro", "body": "18/37 | Lv 0 | activa +2", "color": Color(0.09, 0.06, 0.08, 1.0)},
		{"title": "Par", "body": "18/37 | Lv 0 | activa +2", "color": Color(0.30, 0.60, 1.0, 1.0)},
		{"title": "Impar", "body": "18/37 | Lv 0 | activa +2", "color": Color(0.76, 0.45, 1.0, 1.0)},
		{"title": "1-18 / 19-36", "body": "18/37 | Lv 0 | activa +2", "color": Color(1.0, 1.0, 1.0, 1.0)},
		{"title": "1st 12 / 2nd 12 / 3rd 12", "body": "12/37 | Lv 0 | activa +3", "color": Color(0.32, 0.78, 0.38, 1.0)},
		{"title": "Columnas 1 / 2 / 3", "body": "12/37 | Lv 0 | activa +3", "color": Color(1.0, 0.72, 0.24, 1.0)},
	]
	_render_help_entries(rows)

func _render_ball_entries() -> void:
	_add_help_entry("Bolas actuales", "La tienda y el mazo usan estas definiciones reales del proyecto. Base es el dano que aporta la bola antes de resolver fichas y multiplicadores.", Color(0.92, 0.93, 0.73, 1.0))
	var balls: Array = BALLS_DATABASE.all_balls if BALLS_DATABASE != null else []
	if balls.is_empty():
		_add_help_entry("Sin bolas cargadas", "No se encontro una base de bolas disponible.", Color(1, 1, 1, 0.70))
	else:
		for ball in balls:
			if ball == null:
				continue
			var effect = ball.ball_effect
			var ball_name: String = effect.name if effect != null and effect.name != "" else ball.resource_path.get_file().get_basename()
			var description: String = effect.description if effect != null else ""
			var body := _get_rarity_text(ball.rarity) + " | Base " + str(ball.base_damage) + " | Precio " + str(ball.base_price) + " G"
			if description != "":
				body += "\n" + description
			_add_help_entry(ball_name, body, _get_rarity_color(ball.rarity))
	_add_help_entry("Bolas futuras", "PrimeBall, CrystalBall, ShieldBall, FireBall, epicas y legendarias van a aparecer aca cuando entren al pool canonico.", Color(1.0, 0.72, 0.24, 1.0), true)

func _render_item_entries() -> void:
	_add_help_entry("Trinkets actuales", "Los trinkets modifican la resolucion de la ruleta mientras estan en tu run.", Color(0.92, 0.93, 0.73, 1.0))
	var items: Array = PASSIVE_ITEMS_DATABASE.all_items if PASSIVE_ITEMS_DATABASE != null else []
	if items.is_empty():
		_add_help_entry("Sin objetos cargados", "Todavia no hay una pool canonica de objetos pasivos.", Color(1, 1, 1, 0.70))
	else:
		for item in items:
			if item == null or item.passive_item_effect == null:
				continue
			_add_help_entry(item.passive_item_effect.name, item.passive_item_effect.description, Color(0.75, 0.52, 1.0, 1.0))
	_add_help_entry("Trinkets futuros", "La ayuda va a listar trinkets y mejoras nuevas cuando sus definiciones existan en la rama principal.", Color(1.0, 0.72, 0.24, 1.0), true)

func _add_help_entry(title: String, body: String, color: Color, planned := false) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_card_style(GLASS_CARD_PLANNED if planned else GLASS_CARD))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	margin.add_child(content)

	var title_label := Label.new()
	title_label.text = title + ("  - Proximamente" if planned else "")
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_override("font", HELP_FONT)
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", color)
	content.add_child(title_label)

	var body_label := Label.new()
	body_label.text = body
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_override("font", HELP_FONT)
	body_label.add_theme_font_size_override("font_size", 19)
	body_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.84) if not planned else Color(1, 1, 1, 0.58))
	content.add_child(body_label)

	help_body.add_child(panel)

func _get_how_to_play_entries() -> Array:
	return [
		{"title": "Objetivo", "body": "Avanza por el mapa, vence enemigos, gana oro, mejora tu pool y llega mas lejos en la run.", "color": Color(0.32, 0.78, 0.38, 1.0)},
		{"title": "Mapa", "body": "Elegis un nodo disponible. Los combates llevan al libro de batalla; tiendas y recompensas aparecen entre peleas.", "color": Color(0.45, 0.72, 1.0, 1.0)},
		{"title": "Run guardada", "body": "Continuar carga la run guardada. Play empieza una run nueva y pide confirmacion si ya existe una partida.", "color": Color(1.0, 0.84, 0.20, 1.0)},
		{"title": "Derrota", "body": "Si perdes, la run termina y el boton Continuar queda apagado hasta empezar otra.", "color": Color(0.95, 0.36, 0.42, 1.0)},
	]

func _get_combat_entries() -> Array:
	return [
		{"title": "Turno", "body": "Apostas fichas, podes gastar rerolls para cambiar la bola, y terminas el movimiento para tirar.", "color": Color(0.45, 0.72, 1.0, 1.0)},
		{"title": "Base y multiplicador", "body": "La bola suma dano base. Las fichas activadas por la casilla donde cae la bola suman valor al multiplicador o al resultado segun la regla del campo.", "color": Color(0.32, 0.78, 0.38, 1.0)},
		{"title": "Rerolls", "body": "Arrancas con 3 rerolls. Los que sobren al ganar suman oro.", "color": Color(0.75, 0.52, 1.0, 1.0)},
		{"title": "Resumen de victoria", "body": "Despues de vencer se muestra dano, turnos, vida, rerolls y el detalle de oro ganado antes de ir a la tienda.", "color": Color(1.0, 0.84, 0.20, 1.0)},
	]

func _get_upgrade_entries() -> Array:
	return [
		{"title": "Cambio de campo", "body": "Cuesta 4 G. Cambia colores o grupos del tablero cuando aparece en tienda.", "color": Color(1.0, 0.72, 0.24, 1.0)},
		{"title": "Niveles de grupo", "body": "Planeado: comprar mejoras del mismo grupo subira su Lv y el valor que suma al activarse.", "color": Color(0.32, 0.78, 0.38, 1.0), "planned": true},
		{"title": "Pocion", "body": "Planeado: costara 5 G y sera una por partida cuando entre al sistema canonico.", "color": Color(0.95, 0.36, 0.42, 1.0), "planned": true},
	]

func _get_shop_entries() -> Array:
	return [
		{"title": "Bolas", "body": "La tienda puede ofrecer bolas para sumar al pool. El precio depende de la rareza.", "color": Color(0.45, 0.72, 1.0, 1.0)},
		{"title": "Trinkets", "body": "Planeado: objetos pasivos que cambian reglas de la run o potencian jugadas.", "color": Color(0.75, 0.52, 1.0, 1.0), "planned": true},
		{"title": "Mejoras", "body": "Cambios del tablero y futuras subidas de nivel para grupos de apuestas.", "color": Color(1.0, 0.72, 0.24, 1.0)},
		{"title": "Pocion", "body": "Planeado: costara 5 G y sera una compra unica por partida.", "color": Color(0.96, 0.34, 0.62, 1.0), "planned": true},
	]

func _get_economy_entries() -> Array:
	return [
		{"title": "Oro por enemigo", "body": "Comun +5 G, miniboss +7 G, boss +10 G.", "color": Color(1.0, 0.84, 0.20, 1.0)},
		{"title": "Rerolls sobrantes", "body": "+1 G por cada reroll que no hayas usado al ganar.", "color": Color(0.45, 0.72, 1.0, 1.0)},
		{"title": "Bonus por turnos", "body": "Bonus = max(0, 5 - turnos usados). Ganar rapido paga mas.", "color": Color(0.32, 0.78, 0.38, 1.0)},
		{"title": "Precios de bolas", "body": "Common 5 G, Rare 7 G, Epic 8 G, Legendary 10 G. Si se agrega Uncommon sera 6 G.", "color": Color(0.75, 0.52, 1.0, 1.0)},
		{"title": "Tienda", "body": "Compra bolas o cambios de campo. Si no tenes oro suficiente, la compra no deberia iniciar drag ni consumir la accion.", "color": Color(0.92, 0.93, 0.73, 1.0)},
	]

func _get_rarity_text(rarity: int) -> String:
	match rarity:
		Constants.RARITY.COMMON:
			return "Common"
		Constants.RARITY.RARE:
			return "Rare"
		Constants.RARITY.EPIC:
			return "Epic"
		Constants.RARITY.LEGENDARY:
			return "Legendary"
		_:
			return "Rareza ?"

func _get_rarity_color(rarity: int) -> Color:
	return Constants.RARITY_COLORS.get(rarity, Color(1, 1, 1, 1))

func _setup_modal_button_styles() -> void:
	_style_modal_button(help_back_button, false)
	_style_modal_button(cancel_new_run_button, false)
	_style_modal_button(confirm_new_run_button, true)

func _style_modal_button(button: Button, primary: bool) -> void:
	if button == null:
		return
	button.flat = false
	button.custom_minimum_size = Vector2(176, 62)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 0.96) if primary else Color(1, 1, 1, 0.78))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(0.913725, 0.929412, 0.733333, 1.0))
	var accent := Color(0.95, 0.36, 0.42, 0.54) if primary else GLASS_BORDER
	var normal_color := Color(0.95, 0.36, 0.42, 0.18) if primary else GLASS_BUTTON_NORMAL
	var hover_color := Color(0.95, 0.36, 0.42, 0.28) if primary else GLASS_BUTTON_HOVER
	button.add_theme_stylebox_override("normal", _make_button_style(normal_color, accent))
	button.add_theme_stylebox_override("hover", _make_button_style(hover_color, Color(0.913725, 0.929412, 0.733333, 0.46)))
	button.add_theme_stylebox_override("pressed", _make_button_style(GLASS_BUTTON_PRESSED, accent))

func _make_button_style(color: Color, border_color := Color(1, 1, 1, 0.13)) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_left = 22
	style.content_margin_top = 14
	style.content_margin_right = 22
	style.content_margin_bottom = 14
	return style

func _make_card_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.913725, 0.929412, 0.733333, 0.16)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	return style
