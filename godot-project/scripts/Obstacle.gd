extends StaticBody2D

@export var obstacle_type: String = "barrier"

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready():
	# Set appearance based on type
	match obstacle_type:
		"barrier":
			sprite.modulate = Color.RED
		"low_barrier":
			sprite.scale.y = 0.5
			sprite.modulate = Color.ORANGE