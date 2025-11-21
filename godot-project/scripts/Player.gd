extends CharacterBody2D

const SPEED = 80.0  # Very slow speed
const JUMP_VELOCITY = -200.0  # Easy jump
const SLIDE_DURATION = 1.5  # Long slide
const GRAVITY = 300.0  # Very low gravity

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var slide_collision = $SlideCollision
@onready var head = $Head
@onready var body = $Body
@onready var legs = $Legs

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_sliding = false
var slide_timer = 0.0
var has_shield = false
var is_jumping = false
var can_jump = true
var jump_cooldown = 0.0

func _ready():
	slide_collision.disabled = true
	setup_character_appearance()

func setup_character_appearance():
	# Make character look like a person
	# Head (circle)
	head.modulate = Color.FLORAL_WHITE
	head.position = Vector2(0, -20)
	
	# Body (rectangle)
	body.modulate = Color.BLUE
	body.position = Vector2(0, 0)
	
	# Legs (rectangle)
	legs.modulate = Color.DARK_BLUE
	legs.position = Vector2(0, 20)

func _physics_process(delta):
	# Apply gravity (very gentle)
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false
		can_jump = true
	
	# Handle jump cooldown
	if jump_cooldown > 0:
		jump_cooldown -= delta
		if jump_cooldown <= 0:
			can_jump = true
	
	# Handle slide
	if is_sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			stop_slide()
	
	# Handle jump - MULTIPLE INPUTS
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_sliding and can_jump:
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		can_jump = false
		jump_cooldown = 0.2
		animate_jump()
	
	# Handle slide
	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding:
		start_slide()
	
	# Automatic running (very slow)
	velocity.x = SPEED
	
	# Move and slide
	move_and_slide()
	
	# Update character animation
	update_character_animation()

func animate_jump():
	# Jump animation
	legs.scale.y = 0.8
	body.scale.y = 1.1
	await get_tree().create_timer(0.2).timeout
	legs.scale.y = 1.0
	body.scale.y = 1.0

func update_character_animation():
	# Simple walking animation
	if is_on_floor() and not is_sliding:
		var time = Time.get_time_dict_from_system().second
		legs.scale.x = 1.0 + sin(time * 10) * 0.1
		body.position.y = sin(time * 8) * 2

func start_slide():
	is_sliding = true
	slide_timer = SLIDE_DURATION
	sprite.scale.y = 0.5
	collision_shape.disabled = true
	slide_collision.disabled = false
	head.visible = false
	body.position.y = 10
	legs.position.y = 10

func stop_slide():
	is_sliding = false
	sprite.scale.y = 1.0
	collision_shape.disabled = false
	slide_collision.disabled = true
	head.visible = true
	body.position.y = 0
	legs.position.y = 20

func enable_shield():
	has_shield = true
	$Shield.visible = true

func disable_shield():
	has_shield = false
	$Shield.visible = false

func take_damage():
	if not has_shield:
		# Player takes damage
		animate_hit()
	else:
		disable_shield()

func animate_hit():
	# Flash red animation
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE