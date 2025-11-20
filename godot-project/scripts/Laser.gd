extends Area2D

var speed = 400.0
var direction = Vector2.ZERO
var lifetime = 3.0

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready():
	body_entered.connect(_on_body_entered)

func setup(dir: Vector2, spd: float):
	direction = dir.normalized()
	speed = spd
	sprite.rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta
	lifetime -= delta
	
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage()
		queue_free()
	elif body.is_in_group("obstacle"):
		queue_free()