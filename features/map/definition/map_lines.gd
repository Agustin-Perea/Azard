extends Node2D

@onready var map_root = owner
# Usa cualquier imagen, incluso el icon.svg de Godot sirve
@export var line_texture : Texture = preload("res://resources/map/map_lines/black.png") 


func _draw() -> void:
	# IMPORTANTE: Recalculamos los puntos aquí para asegurar que 
	# solo dibujamos lo que el generador validó.
	map_root.line_points.clear()

	# Recorremos la matriz de datos para buscar conexiones reales
	for layer in map_root.map_data:
		for node in layer:
			if node.next_map_nodes.size() > 0:
				map_root._connect_lines(node)

	if map_root.line_points.size() < 2:
		return

	var width = 10.0
	var color = Color.WHITE 

	for i in range(0, map_root.line_points.size() - 1, 2):
		var p1 = map_root.line_points[i]
		var p2 = map_root.line_points[i+1]

		var dir = (p2 - p1).normalized()
		var perp = Vector2(-dir.y, dir.x) * (width / 2.0)

		var points = PackedVector2Array([
			p1 + perp,
			p2 + perp,
			p2 - perp,
			p1 - perp
		])

		var uvs = PackedVector2Array([
			Vector2(0, 0),
			Vector2(1, 0),
			Vector2(1, 1),
			Vector2(0, 1)
		])

		# El dibujo se hace por segmento independiente
		draw_primitive(points, PackedColorArray([color]), uvs, line_texture)
