extends Control

@onready var selection_button  : Button = $SelectionButton
@onready var book_button : Button = $BookButton

var gold_label: Label
var coin_texture: Texture2D


func _ready() -> void:
	coin_texture = _make_coin_texture()
	UiEventBus.selection_button_visible.connect(on_selection_button_visible)
	UiEventBus.book_button_visible.connect(on_book_button_visible)
	_build_gold_hud()
	GameState.gold_changed.connect(_on_gold_changed)
	_on_gold_changed(GameState.run_gold)
	

func _on_selection_button_pressed() -> void:
	UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.NONE)#esto va al placeholder

	EventManager.add_event(EventManager.QueueType.GAME, GameEvent.new({
		"paralel": false,
		"action": func():
			UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.EnemySelection)
			return true
	}))
	
	

func _on_book_button_pressed() -> void:
	
	
	UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.BookState)
	EventManager.add_event(EventManager.QueueType.GAME, GameEvent.new({
		"paralel": false,
		"action": func():
			UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.ROULETTE)
			return true
	}))

func on_selection_button_visible(value: bool)-> void:
	selection_button.visible = value

func on_book_button_visible(value: bool)-> void:
	book_button.visible = value

func _build_gold_hud() -> void:
	var panel := PanelContainer.new()
	panel.name = "GoldHud"
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.position = Vector2(-180, 14)
	panel.size = Vector2(156, 46)
	panel.custom_minimum_size = Vector2(156, 46)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.045, 0.025, 0.94)
	style.border_color = Color(0.95, 0.74, 0.22, 1.0)
	style.set_border_width_all(3)
	style.set_corner_radius_all(9)
	panel.add_theme_stylebox_override("panel", style)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)

	var coin := PanelContainer.new()
	coin.custom_minimum_size = Vector2(30, 30)
	row.add_child(coin)

	var coin_style := StyleBoxFlat.new()
	coin_style.bg_color = Color(1.0, 0.76, 0.18, 1.0)
	coin_style.border_color = Color(0.42, 0.27, 0.05, 1.0)
	coin_style.set_border_width_all(2)
	coin_style.set_corner_radius_all(15)
	coin.add_theme_stylebox_override("panel", coin_style)

	var coin_texture := TextureRect.new()
	coin_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	coin_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin_texture.texture = self.coin_texture
	coin.add_child(coin_texture)

	gold_label = Label.new()
	gold_label.add_theme_color_override("font_color", Color.WHITE)
	gold_label.add_theme_font_size_override("font_size", 27)
	gold_label.custom_minimum_size = Vector2(66, 32)
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gold_label.text = "0"
	row.add_child(gold_label)

func _on_gold_changed(current_gold: int) -> void:
	if gold_label != null:
		gold_label.text = str(current_gold)

func _make_coin_texture() -> Texture2D:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y in range(64):
		for x in range(64):
			var offset: Vector2 = Vector2(float(x) - 31.5, float(y) - 31.5)
			var distance: float = offset.length()
			if distance > 30.0:
				image.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var rim: bool = distance > 24.0
			var shine: float = max(0.0, 1.0 - offset.distance_to(Vector2(-12.0, -14.0)) / 28.0)
			var shade: float = clamp((offset.y + 30.0) / 60.0, 0.0, 1.0)
			var color: Color = Color(0.96, 0.66, 0.12, 1.0).lerp(Color(0.55, 0.28, 0.04, 1.0), shade * 0.45)
			color = color.lerp(Color(1.0, 0.94, 0.52, 1.0), shine * 0.42)
			if rim:
				color = Color(0.64, 0.35, 0.06, 1.0).lerp(Color(1.0, 0.84, 0.28, 1.0), shine * 0.35)
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)
