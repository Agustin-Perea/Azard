extends Node3D
class_name HelpBookController

const PAGE_SOUND := preload("res://resources/sounds/open_book.wav")

const TEXT_DARK := Color(0.07, 0.05, 0.04, 1.0)
const TEXT_PURPLE := Color(0.34, 0.13, 0.48, 1.0)
const TEXT_BLUE := Color(0.12, 0.38, 0.66, 1.0)
const TEXT_GREEN := Color(0.12, 0.62, 0.18, 1.0)
const TEXT_GOLD := Color(0.82, 0.48, 0.02, 1.0)
const TEXT_RED := Color(0.82, 0.04, 0.08, 1.0)
const TEXT_MUTED := Color(0.33, 0.30, 0.24, 0.80)
const TEXT_WHITE := Color(1.0, 1.0, 1.0, 1.0)
const OUTLINE_LIGHT := Color(0.88, 0.94, 0.72, 0.75)
const TAB_IDLE := Color(0.56, 0.48, 0.33, 0.72)
const TAB_ACTIVE := Color(0.35, 0.16, 0.44, 0.95)
const TAB_LOCKED := Color(0.43, 0.39, 0.31, 0.55)
const NAV_COLOR := Color(0.42, 0.37, 0.30, 0.82)

const SECTION_NAMES := ["Bolas", "Trinkets", "Mejoras", "Tablero", "Economia", "Combate"]
const ROWS_PER_PAGE := 4

var left_cover: Node3D
var right_cover: Node3D
var left_root: Node3D
var right_root: Node3D
var section_root: Node3D
var content_root: Node3D
var nav_root: Node3D
var audio_player: AudioStreamPlayer3D

var active_section := "Bolas"
var content_page := 0
var section_buttons: Dictionary = {}
var content_pages: Array = []

func setup() -> void:
	left_cover = get_node_or_null("left_cover")
	right_cover = get_node_or_null("right_cover")
	if left_cover == null or right_cover == null:
		push_warning("HelpBookController needs left_cover and right_cover children.")
		return

	_create_roots()
	_create_audio()
	_create_section_buttons()
	_render()

func _create_roots() -> void:
	left_root = Node3D.new()
	left_root.name = "HelpBookLeftPage"
	left_cover.add_child(left_root)

	right_root = Node3D.new()
	right_root.name = "HelpBookRightPage"
	right_cover.add_child(right_root)

	section_root = Node3D.new()
	section_root.name = "HelpBookSections"
	left_root.add_child(section_root)

	content_root = Node3D.new()
	content_root.name = "HelpBookContent"
	right_root.add_child(content_root)

	nav_root = Node3D.new()
	nav_root.name = "HelpBookNav"
	right_root.add_child(nav_root)

func _create_audio() -> void:
	audio_player = AudioStreamPlayer3D.new()
	audio_player.name = "HelpBookAudio"
	audio_player.stream = PAGE_SOUND
	add_child(audio_player)

func _create_section_buttons() -> void:
	_create_label(left_root, "HelpTitle", Vector3(-0.88, 0.13, -1.86), "Guia", 24, TEXT_GREEN, OUTLINE_LIGHT, HORIZONTAL_ALIGNMENT_CENTER)
	_create_label(left_root, "SectionTitle", Vector3(-1.44, 0.13, -1.60), "Secciones", 12, TEXT_PURPLE, OUTLINE_LIGHT)

	var start_z := -1.40
	for i in SECTION_NAMES.size():
		var section := str(SECTION_NAMES[i])
		var button := _create_text_button(
			section_root,
			"HelpSection" + section,
			Vector3(-1.08, 0.132, start_z + (i * 0.17)),
			Vector3(0.90, 0.09, 0.12),
			section,
			9
		)
		section_buttons[section] = button
		button.pressed.connect(_on_section_pressed.bind(section))

	_create_label(
		left_root,
		"HelpHint",
		Vector3(-1.48, 0.13, -0.37),
		"Enciclopedia global.\nEl boton Info de batalla\nqueda para datos de la partida.",
		8,
		TEXT_MUTED,
		OUTLINE_LIGHT
	)

func _render() -> void:
	_clear_node(content_root)
	_clear_node(nav_root)
	_update_section_button_state()

	content_pages = _get_section_pages(active_section)
	content_page = clampi(content_page, 0, max(0, content_pages.size() - 1))

	_create_label(
		content_root,
		"ContentTitle",
		Vector3(0.70, 0.13, -1.86),
		active_section,
		24,
		_get_section_color(active_section),
		OUTLINE_LIGHT,
		HORIZONTAL_ALIGNMENT_CENTER
	)

	if content_pages.is_empty():
		_create_label(content_root, "Empty", Vector3(0.08, 0.13, -1.45), "Sin informacion.", 11, TEXT_MUTED, OUTLINE_LIGHT)
		return

	_render_content_page(content_pages[content_page])
	_render_page_nav()

func _clear_node(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func _update_section_button_state() -> void:
	for section in section_buttons.keys():
		var section_name := str(section)
		var button := section_buttons[section_name] as SB_Button3D
		var bg := button.get_node_or_null("Background") as MeshInstance3D if button else null
		var label := button.get_node_or_null("Label3D") as Label3D if button else null
		if bg:
			var material := bg.material_override as StandardMaterial3D
			if material:
				material.albedo_color = TAB_ACTIVE if section_name == active_section else TAB_IDLE
		if label:
			label.modulate = TEXT_WHITE if section_name == active_section else _get_section_color(section_name)

func _render_content_page(page: Dictionary) -> void:
	var subtitle := str(page.get("subtitle", ""))
	if subtitle != "":
		_create_label(content_root, "Subtitle", Vector3(0.08, 0.13, -1.60), subtitle, 12, TEXT_GOLD, OUTLINE_LIGHT)

	var items: Array = page.get("items", [])
	var start_z := -1.42
	for i in items.size():
		var item: Dictionary = items[i]
		var row_z := start_z + (i * 0.30)
		var item_color: Color = item.get("color", TEXT_DARK)
		var title := str(item.get("title", ""))
		var body := str(item.get("body", ""))
		var marker := str(item.get("marker", ""))
		if marker != "":
			_create_marker(content_root, Vector3(0.09, 0.13, row_z - 0.02), item_color)
		_create_label(content_root, "RowTitle" + str(i), Vector3(0.18, 0.13, row_z - 0.04), title, 11, item_color, OUTLINE_LIGHT)
		_create_label(content_root, "RowBody" + str(i), Vector3(0.18, 0.13, row_z + 0.08), body, 8, TEXT_DARK, OUTLINE_LIGHT)

func _render_page_nav() -> void:
	if content_pages.size() <= 1:
		return

	var previous_button := _create_text_button(nav_root, "PreviousPageButton", Vector3(0.42, 0.132, -0.23), Vector3(0.28, 0.09, 0.12), "<", 10)
	previous_button.pressed.connect(_on_previous_page_pressed)
	var next_button := _create_text_button(nav_root, "NextPageButton", Vector3(1.03, 0.132, -0.23), Vector3(0.28, 0.09, 0.12), ">", 10)
	next_button.pressed.connect(_on_next_page_pressed)
	_create_label(
		nav_root,
		"PageCounter",
		Vector3(0.72, 0.13, -0.23),
		str(content_page + 1) + "/" + str(content_pages.size()),
		9,
		TEXT_DARK,
		OUTLINE_LIGHT,
		HORIZONTAL_ALIGNMENT_CENTER
	)

func _get_section_pages(section: String) -> Array:
	match section:
		"Bolas":
			return _ball_pages()
		"Trinkets":
			return _trinket_pages()
		"Mejoras":
			return _upgrade_pages()
		"Tablero":
			return _table_pages()
		"Economia":
			return _economy_pages()
		"Combate":
			return _combat_pages()
		_:
			return []

func _ball_pages() -> Array:
	return _chunk_items("Catalogo de bolas", [
		{"title": "Basic Ball | Common | Base 1 | 5 G", "body": "Bola simple para completar tiradas baratas.", "color": TEXT_DARK, "marker": "ball"},
		{"title": "Duball | Common | Base 2 | 5 G", "body": "Multiplica x2 el score al final del calculo.", "color": TEXT_DARK, "marker": "ball"},
		{"title": "ShieldBall | Common | Base 1 | 5 G", "body": "Otorga shield despues de golpear.", "color": TEXT_GREEN, "marker": "ball"},
		{"title": "PrimeBall | Uncommon | Base 1 | 6 G", "body": "Gana valor si cae en numero primo.", "color": TEXT_GREEN, "marker": "ball"},
		{"title": "CrystalBall | Rare | Base 3 | 7 G", "body": "Elige la mejor casilla cercana.", "color": TEXT_BLUE, "marker": "ball"},
		{"title": "FireBall | Common | Base 3 | 5 G", "body": "Dano al objetivo y splash a vecinos.", "color": TEXT_RED, "marker": "ball"},
		{"title": "Epic Ball | Epic | Base alta | 8 G", "body": "Espacio reservado para bolas epicas.", "color": TEXT_PURPLE, "marker": "ball"},
		{"title": "Legendary Ball | Legendary | 10 G", "body": "Espacio reservado para bolas legendarias.", "color": TEXT_GOLD, "marker": "ball"},
	])

func _trinket_pages() -> Array:
	return _chunk_items("Objetos pasivos y trinkets", [
		{"title": "Spiral Item", "body": "x1.5 por cada ficha activada en un campo distinto.", "color": TEXT_GREEN},
		{"title": "Multiplicador de ficha", "body": "Trinket planeado: mejora grupos usados varias veces.", "color": TEXT_PURPLE},
		{"title": "Bono de economia", "body": "Trinket planeado: mejora oro al terminar combate.", "color": TEXT_GOLD},
		{"title": "Defensa de turno", "body": "Trinket planeado: reduce dano recibido en ciertas condiciones.", "color": TEXT_BLUE},
		{"title": "Estado actual", "body": "La rama todavia no tiene sistema canonico de trinkets.", "color": TEXT_MUTED},
	])

func _upgrade_pages() -> Array:
	return _chunk_items("Mejoras de tablero", [
		{"title": "Cambio de campo | 4 G", "body": "Permite comprar un cambio de color/grupo del tablero.", "color": TEXT_GOLD},
		{"title": "Nivel de grupo", "body": "Cada compra futura subira el Lv del grupo y su valor.", "color": TEXT_PURPLE},
		{"title": "Individual", "body": "Base: 1/37. Valor inicial +36.", "color": TEXT_GOLD},
		{"title": "Rojo/Negro/Par/Impar/Mitades", "body": "Base: 18/37. Valor inicial +2.", "color": TEXT_BLUE},
		{"title": "Docenas/Columnas", "body": "Base: 12/37. Valor inicial +3.", "color": TEXT_GREEN},
		{"title": "Pocion | 5 G", "body": "Planeada para una version posterior, una por partida.", "color": TEXT_RED},
	])

func _table_pages() -> Array:
	return _chunk_items("Probabilidades y valores", [
		{"title": "Individual", "body": "1/37 | Lv 0 | +36", "color": TEXT_GOLD},
		{"title": "Rojo", "body": "18/37 | Lv 0 | +2", "color": TEXT_RED},
		{"title": "Negro", "body": "18/37 | Lv 0 | +2", "color": TEXT_DARK},
		{"title": "Par", "body": "18/37 | Lv 0 | +2", "color": TEXT_BLUE},
		{"title": "Impar", "body": "18/37 | Lv 0 | +2", "color": TEXT_PURPLE},
		{"title": "1-18 / 19-36", "body": "18/37 | Lv 0 | +2", "color": TEXT_DARK},
		{"title": "1st / 2nd / 3rd 12", "body": "12/37 | Lv 0 | +3", "color": TEXT_GREEN},
		{"title": "Columnas 1/2/3", "body": "12/37 | Lv 0 | +3", "color": TEXT_GOLD},
	])

func _economy_pages() -> Array:
	return _chunk_items("Oro y tienda", [
		{"title": "Enemigo comun", "body": "+5 G al ganar.", "color": TEXT_DARK},
		{"title": "Miniboss", "body": "+7 G al ganar.", "color": TEXT_PURPLE},
		{"title": "Boss", "body": "+10 G al ganar.", "color": TEXT_RED},
		{"title": "Rerolls sobrantes", "body": "+1 G por cada reroll no usado. La base es 3.", "color": TEXT_BLUE},
		{"title": "Bonus por turnos", "body": "max(0, 5 - turnos usados).", "color": TEXT_GREEN},
		{"title": "Precios de bolas", "body": "Common 5, Uncommon 6, Rare 7, Epic 8, Legendary 10.", "color": TEXT_GOLD},
		{"title": "Cambio de campo", "body": "Cuesta 4 G.", "color": TEXT_GOLD},
		{"title": "Pocion", "body": "Cuesta 5 G. Una por partida cuando se implemente.", "color": TEXT_RED},
	])

func _combat_pages() -> Array:
	return _chunk_items("Flujo de combate", [
		{"title": "Apostar", "body": "Coloca fichas en numeros o grupos antes de tirar.", "color": TEXT_BLUE},
		{"title": "Reroll", "body": "Cambia la bola disponible. Los rerolls sobrantes dan oro.", "color": TEXT_PURPLE},
		{"title": "Finish Move", "body": "Tira la bola y resuelve base, multiplicador y dano.", "color": TEXT_GREEN},
		{"title": "Popups", "body": "El popup aparece donde cae o donde se activa la ficha.", "color": TEXT_GOLD},
		{"title": "Victoria", "body": "Despues de vencer, se muestra resumen y economia.", "color": TEXT_GREEN},
		{"title": "Tienda", "body": "Luego del resumen se compran bolas o cambios de campo.", "color": TEXT_GOLD},
	])

func _chunk_items(subtitle: String, items: Array) -> Array:
	var pages := []
	for start in range(0, items.size(), ROWS_PER_PAGE):
		var end: int = min(start + ROWS_PER_PAGE, items.size())
		pages.append({
			"subtitle": subtitle,
			"items": items.slice(start, end),
		})
	return pages

func _on_section_pressed(section: String) -> void:
	if active_section == section:
		return
	active_section = section
	content_page = 0
	_play_page_sound()
	_render()

func _on_previous_page_pressed() -> void:
	if content_pages.size() <= 1:
		return
	content_page = max(0, content_page - 1)
	_play_page_sound()
	_render()

func _on_next_page_pressed() -> void:
	if content_pages.size() <= 1:
		return
	content_page = min(content_pages.size() - 1, content_page + 1)
	_play_page_sound()
	_render()

func _play_page_sound() -> void:
	if audio_player:
		audio_player.play()

func _get_section_color(section: String) -> Color:
	match section:
		"Bolas":
			return TEXT_BLUE
		"Trinkets":
			return TEXT_PURPLE
		"Mejoras":
			return TEXT_GREEN
		"Tablero":
			return TEXT_PURPLE
		"Economia":
			return TEXT_GOLD
		"Combate":
			return TEXT_RED
		_:
			return TEXT_MUTED

func _create_marker(parent: Node3D, marker_position: Vector3, color: Color) -> void:
	var marker := MeshInstance3D.new()
	marker.name = "Marker"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.035, 0.012, 0.035)
	marker.mesh = mesh
	marker.position = marker_position
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	marker.material_override = material
	parent.add_child(marker)

func _create_text_button(parent: Node3D, button_name: String, button_position: Vector3, button_size: Vector3, label_text: String, font_size: int) -> SB_Button3D:
	var button := SB_Button3D.new()
	button.name = button_name
	button.position = button_position

	var background := MeshInstance3D.new()
	background.name = "Background"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(button_size.x, 0.012, button_size.z)
	background.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = NAV_COLOR
	background.material_override = material
	button.add_child(background)

	var label := _create_label(
		button,
		"Label3D",
		Vector3(0.0, 0.020, 0.002),
		label_text,
		font_size,
		TEXT_WHITE,
		Color(0.08, 0.06, 0.04, 0.85),
		HORIZONTAL_ALIGNMENT_CENTER
	)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D"
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(button_size.x, 0.08, button_size.z)
	collision_shape.shape = box_shape
	button.add_child(collision_shape)

	parent.add_child(button)
	button.input_event.connect(button._on_input_event)
	button.mouse_entered.connect(button._on_mouse_entered)
	button.mouse_exited.connect(button._on_mouse_exited)
	return button

func _create_label(
	parent: Node3D,
	label_name: String,
	label_position: Vector3,
	label_text: String,
	label_font_size: int,
	label_color: Color,
	outline_color: Color,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> Label3D:
	var label := Label3D.new()
	label.name = label_name
	label.position = label_position
	label.rotation_degrees.x = -90.0
	label.text = label_text
	label.font_size = label_font_size
	label.modulate = label_color
	label.outline_size = 1
	label.outline_modulate = outline_color
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.no_depth_test = true
	parent.add_child(label)
	return label
