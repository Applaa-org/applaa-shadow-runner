extends AnimatableBody2D

@export var move_distance = Vector2(100, 0)
@export var move_speed = 2.0

var start_position: Vector2
var target_position: Vector2
var move_time = 0.0

func setup(distance: Vector2, speed: float):
	move_distance = distance
	move_speed = speed

func _ready():
	start_position = global_position
	target_position = start_position + move_distance

func _physics_process(delta):
	move_time += delta * move_speed
	var t = (sin(move_time) + 1.0) / 2.0  # Oscillate between 0 and 1
	global_position = start_position.lerp(target_position, t)