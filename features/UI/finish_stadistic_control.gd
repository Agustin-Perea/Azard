extends Control
class_name FinishStadisticsControl

@onready var balls_vbox_container : VBoxContainer = $HBoxContainer/Panel2/VBoxContainer/Panel2/VBoxContainer/VBoxContainer

@onready var passive_item_vbox_container : VBoxContainer = $HBoxContainer/Panel2/VBoxContainer/Panel3/VBoxContainer
@onready var continue_button : Button = $Button

@onready var stadistic_label : Label = $HBoxContainer/Panel/VBoxContainer/Panel2/VBoxContainer/HBoxContainer/stadistics_labels
@onready var stadistic_values : RichTextLabel = $HBoxContainer/Panel/VBoxContainer/Panel2/VBoxContainer/HBoxContainer/stadistic_values



const Passive_Item_TextureRect  = preload("res://features/UI/scenes/passive_item_texture_rect.tscn")
const Ball_Rect  = preload("res://features/UI/scenes/ball_rect.tscn")
const AURA_MATERIALS : Array[ShaderMaterial] = [
	preload(Constants.RARITY_MATERIAL_2D_ROUTES[Constants.RARITY.COMMON]),
	preload(Constants.RARITY_MATERIAL_2D_ROUTES[Constants.RARITY.RARE]),
	preload(Constants.RARITY_MATERIAL_2D_ROUTES[Constants.RARITY.EPIC]),
	preload(Constants.RARITY_MATERIAL_2D_ROUTES[Constants.RARITY.LEGENDARY])
]

func _ready() -> void:
	continue_button.pressed.connect(on_button_pressed)
	# 1. Escondemos el panel moviéndolo hacia arriba fuera de la pantalla al iniciar
	# Usamos global_position.y para asegurarnos de que salga por completo
	global_position.y = -size.y - 100 
	add_stadistic_values()
	add_passive_items()
	add_balls()


func aparecer() -> void:
	# 2. Creamos el Tween
	var tween = create_tween()
	
	# 3. Configuramos una transición suave (tipo rebote o desaceleración)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# 4. Animamos la propiedad 'global_position:y' hasta 0 en 0.8 segundos
	tween.tween_property(self, "global_position:y", 0.0, 0.8)


func add_passive_items() -> void:
	# 1. Limpiamos el contenedor por si acaso la función se llama más de una vez
	for child in passive_item_vbox_container.get_children():
		child.queue_free()
	
	# Si no hay ítems en la colección, no hacemos nada más
	if GameState.passiveItems_collection.is_empty():
		return

	# 2. Creamos el HBoxContainer que guardará los ítems en fila
	var hbox : HBoxContainer = HBoxContainer.new()
	# Opcional: añade separación entre los ítems dentro del HBox
	hbox.add_theme_constant_override("separation", 10) 
	
	# Añadimos el HBoxContainer al VBoxContainer principal de tu UI
	passive_item_vbox_container.add_child(hbox)

	# 3. Recorremos la colección de ítems usando un bucle 'for'
	for item in GameState.passiveItems_collection:
		# Instanciamos la escena precargada (el TextureRect con su Label)
		var item_instance = Passive_Item_TextureRect.instantiate()
		
		# 4. Asignamos la textura desde la definición del ítem
		if item.passive_item_definition and item.passive_item_definition.image_texture:
			item_instance.texture = item.passive_item_definition.image_texture
		
		# 5. Buscamos el Label interno y le asignamos la cantidad (quantity)
		# Nota: Asegúrate de que el nodo se llame exactamente "Label" dentro de tu escena
		var quantity_label : Label = item_instance.get_node_or_null("Label")
		if quantity_label:
			quantity_label.text = "x"+str(item.quantity)
		
		# 6. Añadimos el ítem ya configurado al HBoxContainer
		hbox.add_child(item_instance)


func on_button_pressed() -> void:
	GameState.end_run()
	UiEventBus.change_scene_to.emit(Constants.MAIN_MENU_SCENE_PATH)

func add_stadistic_values()->void:
	stadistic_values.text = ""
	stadistic_values.text += str(GameState.master_seed) + "\n"
	stadistic_values.text += str(GameState.player_stats.current_healt)+ "/" + str(GameState.player_stats.max_healt) + "\n"
	stadistic_values.text += "[wave]" + str(GameState.stadistics_component.max_damage) + "[/wave]\n"	
	stadistic_values.text += str(GameState.stadistics_component.gold_earned) + "\n"
	stadistic_values.text += str(GameState.stadistics_component.gold_spent) +  "\n"
	stadistic_values.text += str(GameState.stadistics_component.enemies_slain) + "\n"	
	stadistic_values.text += str(GameState.stadistics_component.bosses_slain) + "\n"
	if GameState.map_generator.last_node:
		stadistic_values.text += str(GameState.map_generator.last_node.row) + "\n"
	else:
		stadistic_values.text += "0\n"

func add_balls() -> void:
	# 1. Limpiamos el contenedor principal por si acaso
	for child in balls_vbox_container.get_children():
		child.queue_free()
		
	if GameState.balls_deck.all_balls.is_empty():
		return

	# 2. Variables de control para las filas de máximo 6 elementos
	var current_hbox : HBoxContainer = null
	var balls_in_current_row : int = 0
	
	# 3. Recorremos absolutamente todas las bolas del mazo
	for i in range(GameState.balls_deck.all_balls.size()):
		# Cada 6 bolas (o al inicio), creamos un nuevo contenedor horizontal
		if balls_in_current_row == 0 or balls_in_current_row >= 6:
			current_hbox = HBoxContainer.new()
			current_hbox.add_theme_constant_override("separation", 12) # Separación entre bolas
			balls_vbox_container.add_child(current_hbox)
			balls_in_current_row = 0 # Reiniciamos el contador de la fila actual
		
		var ball_data = GameState.balls_deck.all_balls[i]
		var ball_definition = ball_data.ball_definition
		
		# Instanciamos el ColorRect principal (Ball_Rect)
		var ball_instance = Ball_Rect.instantiate()
		current_hbox.add_child(ball_instance)
		balls_in_current_row += 1
		
		if not ball_definition:
			continue
			
		# --- CONFIGURACIÓN DE LA TEXTURA/PERSPECTIVA (ball_texture) ---
		var ball_texture_node : ColorRect = ball_instance.get_node_or_null("ball_texture")
		if ball_texture_node and ball_texture_node.material is ShaderMaterial:
			# Duplicamos el ShaderMaterial para que sea único e independiente
			var unique_ball_material : ShaderMaterial = ball_texture_node.material.duplicate()
			var base_material = ball_definition.ball_material
			
			if base_material:
				var albedo_color = base_material.get("albedo_color")
				var albedo_texture = base_material.get("albedo_texture")
				
				if albedo_color != null:
					unique_ball_material.set_shader_parameter("albedo", albedo_color)
					
				if albedo_texture != null:
					unique_ball_material.set_shader_parameter("usar_textura", true)
					unique_ball_material.set_shader_parameter("textura_esfera", albedo_texture)
				else:
					unique_ball_material.set_shader_parameter("usar_textura", false)
			else:
				unique_ball_material.set_shader_parameter("usar_textura", false)
					
			ball_texture_node.material = unique_ball_material

		# --- CONFIGURACIÓN DEL AURA (ball_aura) ---
		var ball_aura_node : ColorRect = ball_instance
		if ball_aura_node:

			# Obtenemos la rareza directamente del @export del recurso
			var rarity_value = ball_definition.rarity 
			
			# Aseguramos que sea un índice válido dentro de tu array de auras
			if rarity_value >= 0 and rarity_value < AURA_MATERIALS.size():
				var aura_base_material = AURA_MATERIALS[rarity_value]
				if aura_base_material:
					# Duplicamos para que el shader de la lava/aura corra a destiempo en cada bola
					ball_aura_node.material = aura_base_material.duplicate()
