extends Node2D

@export var shoot_interval = 4.0  # Much slower shooting
@export var laser_speed = 150.0  # Much slower lasers
@export var detection_range = 200.0  # Shorter range

@onready var sprite = $Sprite2D
@onready var shoot_timer = $ShootTimer
@onready var detection_area = $DetectionArea

var player = null
var laser_scene = preload("res://scenes/Laser.tscn")

func _ready():
	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

func _process(delta):
	if player:
		# Look at player
		var direction = (player.global_position - global_position).normalized()
		sprite.rotation = direction.angle()

func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player = body
		shoot_timer.start()

func _on_detection_area_body_exited(body):
	if body.name == "Player":
		player = null
		shoot_timer.stop()

func _on_shoot_timer_timeout():
	if player:
		shoot_laser()

func shoot_laser():
	var laser = laser_scene.instantiate()
	get_parent().add_child(laser)
	laser.global_position = global_position
	
	var direction = (player.global_position - global_position).normalized()
	laser.setup(direction, laser_speed)
	
	$LaserSound.play()