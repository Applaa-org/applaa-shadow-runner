extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const SLIDE_DURATION = 1.0
const GRAVITY = 600.0

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var slide_collision = $SlideCollision

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_sliding = false
var slide_timer = 0.0
var has_shield = false
var on_ground = false

func _ready():
	slide_collision.disabled = true

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		on_ground = true
	
	# Handle slide
	if is_sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			stop_slide()
	
	# Handle jump - ONLY SPACEBAR
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_sliding:
		velocity.y = JUMP_VELOCITY
		on_ground = false
		$JumpSound.play()
	
	# Handle slide
	if Input.is_action_just_pressed("ui_down") and is_on_floor() and not is_sliding:
		start_slide()
	
	# Automatic running (slower)
	velocity.x = SPEED
	
	# Move and slide
	move_and_slide()

func start_slide():
	is_sliding = true
	slide_timer = SLIDE_DURATION
	sprite.scale.y = 0.5
	collision_shape.disabled = true
	slide_collision.disabled = false
	$SlideSound.play()

func stop_slide():
	is_sliding = false
	sprite.scale.y = 1.0
	collision_shape.disabled = false
	slide_collision.disabled = true

func enable_shield():
	has_shield = true
	$Shield.visible = true

func disable_shield():
	has_shield = false
	$Shield.visible = false

func take_damage():
	if not has_shield:
		# Player takes damage
		$HitSound.play()
		# Flash red
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.2).timeout
		sprite.modulate = Color.WHITE
	else:
		disable_shield()