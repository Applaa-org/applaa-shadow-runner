extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready():
	# Set wall appearance
	sprite.modulate = Color(0.6, 0.6, 0.7)