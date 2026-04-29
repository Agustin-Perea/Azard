extends Node3D
class_name ChipContainer

@export var chip_scene: PackedScene
@onready var chip_origin: StaticBody3D = $ChipsOrigin
@export var offset_z: float = 0.2 # Espacio entre fichas sobre el eje z
@export var chip_scale: float = 1


var chip_elements_in_container : Array[ChipElement]

@onready var  audio_stream : AudioStreamPlayer = $"../../AudioStreamPlayer"

func _ready() -> void:
	
	spawn_chips(GameState.chips)

func spawn_chips(chips: Array[ChipModel]):
	for i in range(chips.size()):
		var new_chip = chip_scene.instantiate() as ChipElement
		# Configuramos la ficha con su data
		new_chip.assignChipId(i)
		
		chip_origin.add_child(new_chip)#son los child
		
		if new_chip.data.last_position == Vector3.ZERO:
			add_chip_to_container(new_chip)
		else:
			new_chip.global_position = new_chip.data.last_position
		# Posicionamiento ordenado: i * offset
		
		new_chip.audio_stream = audio_stream
		new_chip.scale = Vector3.ONE * chip_scale

func reorder_chips() -> void:
	for i in range(chip_elements_in_container.size()):
		chip_elements_in_container[i].position = Vector3(0, 0, (i+1) * offset_z)

func add_chip_to_container(new_chip : ChipElement)->void:
	if !chip_elements_in_container.has(new_chip):
		chip_elements_in_container.push_back(new_chip)
		new_chip.data.last_position = Vector3.ZERO
		new_chip.chip_moved.connect(chip_moved)
		new_chip.position = Vector3(0, 0, chip_elements_in_container.size() * offset_z)

func chip_moved(chip : ChipElement)->void:
	chip.chip_moved.disconnect(chip_moved)
	chip_elements_in_container.erase(chip)
	reorder_chips()

		
