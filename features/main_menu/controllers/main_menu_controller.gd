extends Control

const HELP_FONT := preload("res://resources/fonts/FuzzyBubbles-Bold.ttf")
const BALLS_DATABASE := preload("res://features/balls/database/balls_unlocked_database.tres")
const PASSIVE_ITEMS_DATABASE := preload("res://features/items/passive_items/database/passive_items_pool.tres")

const HELP_SECTIONS := [
	"Como jugar",
	"Combate",
	"Ruleta",
	"Bolas",
	"Objetos",
	"Tienda",
	"Mejoras",
	"Economia",
]
const HELP_SECTION_COLORS := {
	"Como jugar": Color(0.92, 0.93, 0.73, 1.0),
	"Combate": Color(0.95, 0.36, 0.42, 1.0),
	"Ruleta": Color(0.32, 0.78, 0.38, 1.0),
	"Bolas": Color(0.45, 0.72, 1.0, 1.0),
	"Objetos": Color(0.75, 0.52, 1.0, 1.0),
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
@onready var menu_buttons: VBoxContainer = $MenuContent/Buttons
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
var help_detail_overlay: Control
var help_detail_panel: PanelContainer
var help_detail_icon_host: Control
var help_detail_title: Label
var help_detail_meta: Label
var help_detail_body: Label
var help_detail_back_button: Button
var options_overlay: Control
var options_panel: PanelContainer
var options_button: Button
var options_back_button: Button
var music_slider: HSlider
var sfx_slider: HSlider
var music_value_label: Label
var sfx_value_label: Label
var fullscreen_button: Button

func _ready() -> void:
	var music_manager := get_node_or_null("/root/MusicManager")
	if music_manager != null:
		music_manager.call("play_menu_music")
	_apply_click_volume()
	if has_node("/root/SettingsManager"):
		SettingsManager.sfx_volume_changed.connect(_on_sfx_volume_changed)
	if has_node("/root/UiHud"):
		UiHud.visible = false
	UiEventBus.selection_button_visible.emit(false)
	UiEventBus.book_button_visible.emit(false)
	continue_button.disabled = not GameState.has_save()
	continue_button.modulate.a = 1.0 if GameState.has_save() else 0.45
	confirm_overlay.visible = false
	help_overlay.visible = false
	_setup_options()
	_setup_modal_button_styles()
	_setup_help()
	_create_help_detail_overlay()
	resized.connect(_layout_options_panel)

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
	if options_overlay != null:
		options_overlay.visible = false
	if help_detail_overlay != null:
		help_detail_overlay.visible = false
	help_overlay.visible = true
	_show_help_section(active_help_section)

func _on_help_back_button_pressed() -> void:
	_play_click()
	if help_detail_overlay != null and help_detail_overlay.visible:
		help_detail_overlay.visible = false
		return
	help_overlay.visible = false

func _go_to_scene(scene_path: String) -> void:
	if has_node("/root/UiHud"):
		UiHud.visible = true
	UiEventBus.change_scene_to.emit(scene_path)

func _play_click() -> void:
	if click_player != null:
		click_player.play()

func _on_sfx_volume_changed(_value: float) -> void:
	_apply_click_volume()

func _apply_click_volume() -> void:
	if click_player == null:
		return
	if has_node("/root/SettingsManager"):
		click_player.volume_db = SettingsManager.get_sfx_volume_db(CLICK_VOLUME_DB)
	else:
		click_player.volume_db = CLICK_VOLUME_DB

func _setup_options() -> void:
	options_button = Button.new()
	options_button.text = "Opciones"
	options_button.focus_mode = Control.FOCUS_NONE
	options_button.flat = true
	options_button.add_theme_font_override("font", HELP_FONT)
	options_button.add_theme_font_size_override("font_size", 34)
	options_button.add_theme_color_override("font_color", Color(1, 1, 1, 0.80))
	options_button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	options_button.add_theme_color_override("font_pressed_color", Color(0.913725, 0.929412, 0.733333, 1))
	options_button.add_theme_stylebox_override("normal", _make_menu_button_style(Color(0, 0, 0, 0)))
	options_button.add_theme_stylebox_override("hover", _make_menu_button_style(Color(1, 1, 1, 0.09)))
	options_button.add_theme_stylebox_override("pressed", _make_menu_button_style(Color(0, 0, 0, 0.16)))
	options_button.pressed.connect(_on_options_button_pressed)
	menu_buttons.add_child(options_button)
	menu_buttons.move_child(options_button, max(0, menu_buttons.get_child_count() - 2))
	_create_options_overlay()

func _create_options_overlay() -> void:
	options_overlay = Control.new()
	options_overlay.name = "OptionsOverlay"
	options_overlay.visible = false
	options_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(options_overlay)

	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0156863, 0.0117647, 0.0235294, 0.48)
	options_overlay.add_child(dim)

	options_panel = PanelContainer.new()
	options_panel.name = "Panel"
	options_panel.add_theme_stylebox_override("panel", _make_modal_panel_style())
	options_overlay.add_child(options_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 30)
	options_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 26)
	margin.add_child(content)

	var title := Label.new()
	title.text = "Opciones"
	title.add_theme_font_override("font", HELP_FONT)
	title.add_theme_font_size_override("font_size", 46)
	title.add_theme_color_override("font_color", Color(0.913725, 0.929412, 0.733333, 1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)

	content.add_child(_create_slider_row("Musica", true))
	content.add_child(_create_slider_row("Efectos", false))

	fullscreen_button = Button.new()
	fullscreen_button.focus_mode = Control.FOCUS_NONE
	fullscreen_button.custom_minimum_size = Vector2(0, 76)
	fullscreen_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fullscreen_button.add_theme_font_override("font", HELP_FONT)
	fullscreen_button.add_theme_font_size_override("font_size", 30)
	fullscreen_button.pressed.connect(_on_fullscreen_button_pressed)
	_style_modal_button(fullscreen_button, false)
	content.add_child(fullscreen_button)

	options_back_button = Button.new()
	options_back_button.text = "Volver"
	options_back_button.focus_mode = Control.FOCUS_NONE
	options_back_button.custom_minimum_size = Vector2(0, 76)
	options_back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_back_button.add_theme_font_override("font", HELP_FONT)
	options_back_button.add_theme_font_size_override("font_size", 30)
	options_back_button.pressed.connect(_on_options_back_button_pressed)
	_style_modal_button(options_back_button, false)
	content.add_child(options_back_button)

	_refresh_options_values()
	_layout_options_panel()

func _create_slider_row(title: String, music: bool) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_card_style(GLASS_CARD))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	content.add_child(header)

	var title_label := Label.new()
	title_label.text = title
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_override("font", HELP_FONT)
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.92))
	header.add_child(title_label)

	var value_label := Label.new()
	value_label.custom_minimum_size = Vector2(110, 0)
	value_label.add_theme_font_override("font", HELP_FONT)
	value_label.add_theme_font_size_override("font_size", 28)
	value_label.add_theme_color_override("font_color", Color(0.913725, 0.929412, 0.733333, 1))
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(value_label)

	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(0, 58)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.focus_mode = Control.FOCUS_NONE
	content.add_child(slider)

	if music:
		music_slider = slider
		music_value_label = value_label
		slider.value_changed.connect(_on_music_slider_changed)
	else:
		sfx_slider = slider
		sfx_value_label = value_label
		slider.value_changed.connect(_on_sfx_slider_changed)

	return panel

func _on_options_button_pressed() -> void:
	_play_click()
	confirm_overlay.visible = false
	help_overlay.visible = false
	options_overlay.visible = true
	_refresh_options_values()
	_layout_options_panel()

func _on_options_back_button_pressed() -> void:
	_play_click()
	options_overlay.visible = false

func _on_music_slider_changed(value: float) -> void:
	if music_value_label != null:
		music_value_label.text = str(int(round(value))) + "%"
	if has_node("/root/SettingsManager"):
		SettingsManager.set_music_volume(value / 100.0)

func _on_sfx_slider_changed(value: float) -> void:
	if sfx_value_label != null:
		sfx_value_label.text = str(int(round(value))) + "%"
	if has_node("/root/SettingsManager"):
		SettingsManager.set_sfx_volume(value / 100.0)

func _on_fullscreen_button_pressed() -> void:
	_play_click()
	if has_node("/root/SettingsManager"):
		SettingsManager.set_fullscreen(not SettingsManager.fullscreen)
	_refresh_options_values()

func _refresh_options_values() -> void:
	if not has_node("/root/SettingsManager"):
		return
	if music_slider != null:
		music_slider.set_value_no_signal(SettingsManager.get_music_volume_percent())
	if sfx_slider != null:
		sfx_slider.set_value_no_signal(SettingsManager.get_sfx_volume_percent())
	if music_value_label != null:
		music_value_label.text = str(SettingsManager.get_music_volume_percent()) + "%"
	if sfx_value_label != null:
		sfx_value_label.text = str(SettingsManager.get_sfx_volume_percent()) + "%"
	if fullscreen_button != null:
		fullscreen_button.text = "Pantalla completa: " + ("Si" if SettingsManager.fullscreen else "No")

func _layout_options_panel() -> void:
	if options_panel == null:
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var aspect: float = viewport_size.x / maxf(viewport_size.y, 1.0)
	var narrow: bool = viewport_size.x < 1200.0 or aspect < 1.45
	if narrow:
		options_panel.anchor_left = 0.04
		options_panel.anchor_top = 0.06
		options_panel.anchor_right = 0.96
		options_panel.anchor_bottom = 0.94
	else:
		options_panel.anchor_left = 0.24
		options_panel.anchor_top = 0.16
		options_panel.anchor_right = 0.76
		options_panel.anchor_bottom = 0.84
	options_panel.offset_left = 0
	options_panel.offset_top = 0
	options_panel.offset_right = 0
	options_panel.offset_bottom = 0

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
	if help_detail_overlay != null:
		help_detail_overlay.visible = false
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
		"Objetos":
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
	_add_help_entry("Catalogo de bolas", "Estas son las bolas reales del proyecto. Toca una carta para ver icono, rareza, precio, tipo de ataque y descripcion completa.", Color(0.92, 0.93, 0.73, 1.0))
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
			var meta := _get_rarity_text(ball.rarity) + " | Base " + str(ball.base_damage) + " | " + _get_ball_attack_text(ball.attack_type)
			_add_catalog_card(
				ball_name,
				meta,
				_shorten_text(description),
				_get_rarity_color(ball.rarity),
				_create_ball_icon(ball, 66),
				_show_ball_detail.bind(ball)
			)

func _render_item_entries() -> void:
	_add_help_entry("Catalogo de objetos", "Los objetos son pasivos de run. Toca una carta para ver rareza, si acumula, peso y descripcion completa.", Color(0.92, 0.93, 0.73, 1.0))
	var items: Array = PASSIVE_ITEMS_DATABASE.all_items if PASSIVE_ITEMS_DATABASE != null else []
	if items.is_empty():
		_add_help_entry("Sin objetos cargados", "Todavia no hay una pool canonica de objetos pasivos.", Color(1, 1, 1, 0.70))
	else:
		for item in items:
			if item == null or item.passive_item_effect == null:
				continue
			var rarity_name := _get_item_rarity_name(item)
			var quantity_text := "x2 inicial test" if item.cumulative else "x1 inicial test"
			var meta := rarity_name + " | " + ("Acumula" if item.cumulative else "Unico") + " | " + quantity_text
			_add_catalog_card(
				item.passive_item_effect.name,
				meta,
				_shorten_text(item.passive_item_effect.description),
				_get_item_rarity_color(item),
				_create_item_icon(item, 66),
				_show_item_detail.bind(item)
			)

func _add_catalog_card(title: String, meta: String, body: String, color: Color, icon: Control, callback: Callable) -> void:
	var button := Button.new()
	button.text = ""
	button.focus_mode = Control.FOCUS_NONE
	button.flat = false
	button.custom_minimum_size = Vector2(0, 112)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_stylebox_override("normal", _make_card_style(GLASS_CARD))
	button.add_theme_stylebox_override("hover", _make_card_style(Color(0.07, 0.04, 0.08, 0.52)))
	button.add_theme_stylebox_override("pressed", _make_card_style(Color(0.02, 0.01, 0.03, 0.68)))
	button.pressed.connect(callback)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 12)
	button.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	margin.add_child(row)

	row.add_child(icon)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 3)
	row.add_child(text_box)

	var title_label := Label.new()
	title_label.text = title
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_override("font", HELP_FONT)
	title_label.add_theme_font_size_override("font_size", 27)
	title_label.add_theme_color_override("font_color", color)
	text_box.add_child(title_label)

	var meta_label := Label.new()
	meta_label.text = meta
	meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	meta_label.add_theme_font_override("font", HELP_FONT)
	meta_label.add_theme_font_size_override("font_size", 20)
	meta_label.add_theme_color_override("font_color", Color(0.913725, 0.929412, 0.733333, 0.88))
	text_box.add_child(meta_label)

	var body_label := Label.new()
	body_label.text = body
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_override("font", HELP_FONT)
	body_label.add_theme_font_size_override("font_size", 18)
	body_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.72))
	text_box.add_child(body_label)

	_set_mouse_filter_recursive(margin, Control.MOUSE_FILTER_IGNORE)
	help_body.add_child(button)

func _create_help_detail_overlay() -> void:
	help_detail_overlay = Control.new()
	help_detail_overlay.name = "HelpDetailOverlay"
	help_detail_overlay.visible = false
	help_detail_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	help_detail_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	help_overlay.add_child(help_detail_overlay)

	var dim := ColorRect.new()
	dim.name = "DetailDim"
	dim.color = Color(0.0156863, 0.0117647, 0.0235294, 0.42)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	help_detail_overlay.add_child(dim)

	help_detail_panel = PanelContainer.new()
	help_detail_panel.name = "DetailPanel"
	help_detail_panel.anchor_left = 0.18
	help_detail_panel.anchor_top = 0.12
	help_detail_panel.anchor_right = 0.82
	help_detail_panel.anchor_bottom = 0.88
	help_detail_panel.add_theme_stylebox_override("panel", _make_modal_panel_style())
	help_detail_overlay.add_child(help_detail_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 28)
	help_detail_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 20)
	margin.add_child(content)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 24)
	content.add_child(header)

	help_detail_icon_host = Control.new()
	help_detail_icon_host.custom_minimum_size = Vector2(116, 116)
	header.add_child(help_detail_icon_host)

	var header_text := VBoxContainer.new()
	header_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_text.add_theme_constant_override("separation", 4)
	header.add_child(header_text)

	help_detail_title = Label.new()
	help_detail_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_detail_title.add_theme_font_override("font", HELP_FONT)
	help_detail_title.add_theme_font_size_override("font_size", 44)
	header_text.add_child(help_detail_title)

	help_detail_meta = Label.new()
	help_detail_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_detail_meta.add_theme_font_override("font", HELP_FONT)
	help_detail_meta.add_theme_font_size_override("font_size", 25)
	help_detail_meta.add_theme_color_override("font_color", Color(0.913725, 0.929412, 0.733333, 0.9))
	header_text.add_child(help_detail_meta)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)

	help_detail_body = Label.new()
	help_detail_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_detail_body.add_theme_font_override("font", HELP_FONT)
	help_detail_body.add_theme_font_size_override("font_size", 26)
	help_detail_body.add_theme_color_override("font_color", Color(1, 1, 1, 0.88))
	scroll.add_child(help_detail_body)

	help_detail_back_button = Button.new()
	help_detail_back_button.text = "Volver"
	help_detail_back_button.focus_mode = Control.FOCUS_NONE
	help_detail_back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	help_detail_back_button.add_theme_font_override("font", HELP_FONT)
	help_detail_back_button.add_theme_font_size_override("font_size", 30)
	help_detail_back_button.pressed.connect(_on_help_detail_back_pressed)
	_style_modal_button(help_detail_back_button, false)
	content.add_child(help_detail_back_button)

func _show_ball_detail(ball: BallDefinition) -> void:
	if ball == null:
		return
	var effect = ball.ball_effect
	var ball_name: String = effect.name if effect != null and effect.name != "" else ball.resource_path.get_file().get_basename()
	var description: String = effect.description if effect != null else "Sin descripcion."
	var color := _get_rarity_color(ball.rarity)
	_show_help_detail(
		ball_name,
		_get_rarity_text(ball.rarity) + " | Base " + str(ball.base_damage) + " | Precio " + str(ball.base_price) + " G | Peso " + str(ball.weight),
		"Tipo de ataque: " + _get_ball_attack_text(ball.attack_type) + "\n\n" + description,
		color,
		_create_ball_icon(ball, 108)
	)

func _show_item_detail(item: PassiveItemDefinition) -> void:
	if item == null or item.passive_item_effect == null:
		return
	var color := _get_item_rarity_color(item)
	var test_quantity := 2 if item.cumulative else 1
	_show_help_detail(
		item.passive_item_effect.name,
		_get_item_rarity_name(item) + " | " + ("Acumulable" if item.cumulative else "Unico") + " | Peso " + str(item.weight),
		"Cantidad inicial para test: x" + str(test_quantity) + "\n\n" + item.passive_item_effect.description,
		color,
		_create_item_icon(item, 108)
	)

func _show_help_detail(title: String, meta: String, body: String, color: Color, icon: Control) -> void:
	_clear_children(help_detail_icon_host)
	help_detail_icon_host.add_child(icon)
	help_detail_title.text = title
	help_detail_title.add_theme_color_override("font_color", color)
	help_detail_meta.text = meta
	help_detail_body.text = body
	help_detail_overlay.visible = true

func _on_help_detail_back_pressed() -> void:
	help_detail_overlay.visible = false

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func _set_mouse_filter_recursive(node: Node, filter: int) -> void:
	if node is Control:
		(node as Control).mouse_filter = filter
	for child in node.get_children():
		_set_mouse_filter_recursive(child, filter)

func _shorten_text(text: String, max_length := 130) -> String:
	var clean_text := text.replace("\n", " ").strip_edges()
	if clean_text.length() <= max_length:
		return clean_text
	return clean_text.substr(0, max_length - 3).strip_edges() + "..."

func _create_ball_icon(ball: BallDefinition, size: int) -> Control:
	var icon := PanelContainer.new()
	icon.custom_minimum_size = Vector2(size, size)
	icon.add_theme_stylebox_override("panel", _make_round_icon_style(_get_ball_icon_color(ball), _get_rarity_color(ball.rarity), max(3, int(size / 16))))
	return icon

func _create_item_icon(item: PassiveItemDefinition, size: int) -> Control:
	var icon := PanelContainer.new()
	icon.custom_minimum_size = Vector2(size, size)
	icon.add_theme_stylebox_override("panel", _make_round_icon_style(Color(0.21, 0.07, 0.20, 0.92), _get_item_rarity_color(item), max(3, int(size / 16))))

	var texture := TextureRect.new()
	texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	texture.offset_left = 8
	texture.offset_top = 8
	texture.offset_right = -8
	texture.offset_bottom = -8
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.texture = item.image_texture
	icon.add_child(texture)
	return icon

func _make_round_icon_style(fill: Color, border: Color, border_width := 4) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 999
	style.corner_radius_top_right = 999
	style.corner_radius_bottom_right = 999
	style.corner_radius_bottom_left = 999
	return style

func _get_ball_icon_color(ball: BallDefinition) -> Color:
	if ball != null and ball.ball_material != null:
		var material_color := ball.ball_material.albedo_color
		if material_color.a > 0.05:
			return material_color
	return Color.WHITE

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
		{"title": "Objetos", "body": "Pasivos que cambian reglas de la run o potencian jugadas. Algunos acumulan y otros son unicos.", "color": Color(0.75, 0.52, 1.0, 1.0)},
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

func _get_ball_attack_text(attack_type: int) -> String:
	match attack_type:
		Constants.ATTACK_TYPE.SINGLE:
			return "1 objetivo"
		Constants.ATTACK_TYPE.HALF:
			return "Mitad"
		Constants.ATTACK_TYPE.ALL:
			return "Todos"
		_:
			return "Ataque ?"

func _get_item_rarity_name(item: PassiveItemDefinition) -> String:
	var item_name := _get_item_name(item)
	var uncommon_items := [
		"Vision", "BallPouch", "SafetyNet", "GoldenDust", "EchoPin", "ToxicInk",
		"ChainCoil", "TableSigil", "VitalThread", "LuckyThread", "LuckyClover",
	]
	var rare_items := [
		"OmegaRoll", "TrinketStrap", "IronShell", "RouletteChalk", "HighRollerBadge",
		"BloodContract", "DealerGloves", "GoldPocket", "GraveWax", "SplitLedger",
		"LoadedDice",
	]
	var epic_items := [
		"ThirdChip", "GoldenLedger", "WeightedWheel", "TwinFuse", "DeadmansSwitch",
		"LoadedMark", "FortuneIdol", "Mitosis", "HouseWin", "RobaAlmas",
	]
	var legendary_items := [
		"HouseKey", "CrownOfOdds", "RoyalTreasury", "FinalBetSeal", "EyeOfFortune",
		"LastCoin", "PerfectCrime", "GoldenReversal", "CasinoCrown", "HouseAlwaysWins",
	]
	if uncommon_items.has(item_name):
		return "Uncommon"
	if rare_items.has(item_name):
		return "Rare"
	if epic_items.has(item_name):
		return "Epic"
	if legendary_items.has(item_name):
		return "Legendary"
	return _get_rarity_text(item.rarity if item != null else Constants.RARITY.COMMON)

func _get_item_rarity_color(item: PassiveItemDefinition) -> Color:
	match _get_item_rarity_name(item):
		"Uncommon":
			return Color(0.36, 1.0, 0.48, 1.0)
		"Rare":
			return Constants.RARITY_COLORS.get(Constants.RARITY.RARE, Color(0.2, 0.5, 1.0, 1.0))
		"Epic":
			return Constants.RARITY_COLORS.get(Constants.RARITY.EPIC, Color(0.7, 0.5, 1.0, 1.0))
		"Legendary":
			return Constants.RARITY_COLORS.get(Constants.RARITY.LEGENDARY, Color(1.0, 0.85, 0.2, 1.0))
		_:
			return Constants.RARITY_COLORS.get(Constants.RARITY.COMMON, Color(1, 1, 1, 1))

func _get_item_name(item: PassiveItemDefinition) -> String:
	if item != null and item.passive_item_effect != null and item.passive_item_effect.name != "":
		return item.passive_item_effect.name
	if item != null and item.resource_path != "":
		return item.resource_path.get_file().get_basename()
	return ""

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

func _make_menu_button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_left = 28
	style.content_margin_top = 8
	style.content_margin_right = 28
	style.content_margin_bottom = 8
	return style

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

func _make_modal_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0627451, 0.027451, 0.0705882, 0.76)
	style.border_color = Color(0.913725, 0.929412, 0.733333, 0.32)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	return style
