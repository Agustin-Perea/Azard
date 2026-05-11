extends SubViewport

# Configuración
var base_aspect_ratio = 16.0 / 9.0
@export_range(0.1, 1.0) var render_scale: float = 0.5 # 0.5 = 50% de la resolución real

func _ready():
	# Importante: Para que no se vea "más cerca", 
	# el canvas_item_default_texture_filter debe estar en "Nearest" o "Linear"
	get_window().size_changed.connect(_on_window_resized)
	_on_window_resized()

func _on_window_resized():
	var window_size = get_window().size
	var target_size : Vector2i
	
	# 1. Calculamos el tamaño basado en el Aspect Ratio (tu lógica original)
	var window_aspect = float(window_size.x) / float(window_size.y)
	
	if window_aspect > base_aspect_ratio:
		target_size = Vector2i(int(window_size.y * base_aspect_ratio), window_size.y)
	else:
		target_size = Vector2i(window_size.x, int(window_size.x / base_aspect_ratio))
	
	# 2. Aplicamos el porcentaje de resolución (Downsampling)
	# Multiplicamos el tamaño objetivo por nuestra escala de renderizado
	self.size = Vector2(target_size) * render_scale
