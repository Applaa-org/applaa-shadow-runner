extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const SLIDE_DURATION = 0.8
const GRAVITY = 980.0

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var slide_collision = $SlideCollision

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_sliding = false
var slide_timer = 0.0
var has_shield = false
var has_jetpack = false
var jetpack_timer = 0.0
var is_jumping = false
var jump_hold_time = 0.0
var max_jump_hold = 0.3

func _ready():
	slide_collision.disabled = true

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false
		jump_hold_time = 0.0
	
	# Handle slide
	if is_sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			stop_slide()
	
	# Handle jetpack
	if has_jetpack:
		jetpack_timer -= delta
		if jetpack_timer <= 0:
			disable_jetpack()
		else:
			velocity.y = -200  # Jetpack lift
	
	# Handle jump with hold mechanic
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_sliding:
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		$JumpSound.play()
	
	# Continue jumping while holding (long jump)
	if Input.is_action_pressed("jump") and is_jumping and jump_hold_time < max_jump_hold:
		velocity.y = JUMP_VELOCITY * 0.7  # Reduced gravity during hold
		jump_hold_time += delta
	
	# Handle slide
	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding:
		start_slide()
	
	# Automatic running
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

func enable_jetpack():
	has_jetpack = true
	jetpack_timer = 4.0
	$Jetpack.visible = true
	$JetpackParticles.emitting = true

func disable_jetpack():
	has_jetpack = false
	$Jetpack.visible = false
	$JetpackParticles.emitting = false

func take_damage():
	if not has_shield:
		# Player takes damage
		$HitSound.play()
		# Flash red
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE
	else:
		disable_shield()