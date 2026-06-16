extends Node3D
class_name PotionButton

@export var listens : StatsComponent

@onready var feedback : Label3D = $FeedBack_Message

@onready var button_collision : CollisionShape3D = $Button/CollisionShape3D

var pv_to_add : int
func _ready() -> void:
	@warning_ignore("unused_parameter")
	listens = GameState.player_stats
	UiEventBus.change_book_page.connect(func(arg : Constants.BOOK_PAGE): update_feedback())
	update_feedback()

func update_feedback() ->void:
	if listens:
		activate()
		var pv_difference := listens.max_healt - listens.current_healt
		if pv_difference > 0:
			var pv_added := listens.max_healt * 0.2
			pv_to_add =  pv_difference if pv_difference < pv_added else int(pv_added)
			feedback.text = "20% ({valor} PV)".format({"valor": pv_to_add})
		else:
			deactivate()

func deactivate() -> void:
	button_collision.disabled = true
	self.visible = false

func activate() -> void:
	button_collision.disabled = false
	self.visible = true


func _on_button_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if GameState.economy_component.can_afford(5):
			GameState.economy_component.spend_run_gold(5)
			listens.add_life(pv_to_add,false)
		deactivate()
