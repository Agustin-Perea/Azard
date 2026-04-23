extends SceneTree

const BetFieldsDefault := preload("res://features/book/bet_fields/runtime/bet_fields_default.tres")

func _init() -> void:
	var fields := BetFieldsDefault.fields
	var result_ids := _result_field_ids(fields)
	if result_ids.size() != 37:
		push_error("Roulette result field count mismatch: " + str(result_ids.size()))
		quit(1)
		return
	for field_id in result_ids:
		var field = fields[field_id]
		if field == null:
			push_error("Roulette result id points to null field: " + str(field_id))
			quit(1)
			return
		if not _is_straight_up(field):
			push_error("Roulette result id points to non-straight field: " + str(field_id))
			quit(1)
			return
		if field.number < 0 or field.number > 36:
			push_error("Roulette result has unsupported number: " + str(field.number))
			quit(1)
			return
	if int(result_ids.back()) > 36:
		push_error("Roulette max result field exceeds visual wheel: " + str(result_ids.back()))
		quit(1)
		return
	print("roulette_result_domain_ok:", result_ids.size())
	quit(0)

func _result_field_ids(fields: Array) -> Array[int]:
	var ids: Array[int] = []
	for field_id in range(fields.size()):
		var field = fields[field_id]
		if field != null and _is_straight_up(field):
			ids.append(field_id)
	return ids

func _is_straight_up(field) -> bool:
	if field.ConditionStrategy == null:
		return false
	var script := field.ConditionStrategy.get_script() as Script
	return script != null and script.resource_path.ends_with("StraightUpCondition.gd")
