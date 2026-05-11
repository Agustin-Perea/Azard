extends SceneTree

func _init() -> void:
	var files := _definition_files()
	if files.size() != 32:
		push_error("Ball definition count mismatch: " + str(files.size()))
		quit(1)
		return
	var ids := {}
	for path in files:
		var text := FileAccess.get_file_as_string(path)
		var ball_id := _read_int_property(text, "ball_id")
		if ball_id <= 0:
			push_error("Ball without id: " + path)
			quit(1)
			return
		if ids.has(ball_id):
			push_error("Duplicated ball id: " + str(ball_id))
			quit(1)
			return
		ids[ball_id] = true
		if _read_string_property(text, "display_name").is_empty():
			push_error("Ball without definition display name: " + path)
			quit(1)
			return
		if _read_string_property(text, "description").is_empty():
			push_error("Ball without definition description: " + path)
			quit(1)
			return
		if not text.contains("ball_effect = SubResource("):
			push_error("Ball without effect reference: " + path)
			quit(1)
			return
	print("ball_catalog_ok:", files.size())
	quit(0)

func _definition_files() -> Array[String]:
	var files: Array[String] = []
	var roots := [
		"res://features/balls/definition/common",
		"res://features/balls/definition/uncommon",
		"res://features/balls/definition/rare",
		"res://features/balls/definition/epic",
		"res://features/balls/definition/legendary",
	]
	for root in roots:
		var dir := DirAccess.open(root)
		if dir == null:
			continue
		for file_name in dir.get_files():
			if file_name.ends_with(".tres"):
				files.append(root.path_join(file_name))
	return files

func _read_int_property(text: String, property_name: String) -> int:
	for line in text.split("\n"):
		var prefix := property_name + " = "
		if line.begins_with(prefix):
			return int(line.trim_prefix(prefix).strip_edges())
	return 0

func _read_string_property(text: String, property_name: String) -> String:
	for line in text.split("\n"):
		var prefix := property_name + " = "
		if line.begins_with(prefix):
			return line.trim_prefix(prefix).strip_edges().trim_prefix("\"").trim_suffix("\"")
	return ""
