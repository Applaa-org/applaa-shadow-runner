extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -350.0
const DOUBLE_JUMP_VELOCITY = -300.0
const TRIPLE_JUMP_VELOCITY = -280.0
const SLIDE_DURATION = 1.0
const GRAVITY = 500.0
const MAGNET_RANGE = 150.0

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
var has_speed_boost = false
var has_magnet = false
var has_super_jump = false
var is_jumping = false
var can_jump = true
var can_double_jump = true
var can_triple_jump = true
var jump_cooldown = 0.0
var speed_boost_timer = 0.0
var magnet_timer = 0.0
var super_jump_timer = 0.0
var jump_count = 0

func _ready():
	slide_collision.disabled = true
	setup_character_appearance()

func setup_character_appearance():
	# Make character look amazing
	head.modulate = Color.FLORAL_WHITE
	head.position = Vector2(0, -20)
	body.modulate = Color.CYAN
	body.position = Vector2(0, 0)
	legs.modulate = Color.BLUE_VIOLET
	legs.position = Vector2(0, 20)

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false
		can_jump = true
		can_double_jump = true
		can_triple_jump = true
		jump_count = 0
	
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
	
	# Handle power-up timers
	if has_speed_boost:
		speed_boost_timer -= delta
		if speed_boost_timer <= 0:
			has_speed_boost = false
	
	if has_magnet:
		magnet_timer -= delta
		if magnet_timer <= 0:
			has_magnet = false
	
	if has_super_jump:
		super_jump_timer -= delta
		if super_jump_timer <= 0:
			has_super_jump = false
	
	# Handle triple jump
	if Input.is_action_just_pressed("jump") and not is_sliding:
		if is_on_floor() and can_jump:
			# First jump
			var jump_power = JUMP_VELOCITY
			if has_super_jump:
				jump_power *= 1.5
			velocity.y = jump_power
			is_jumping = true
			can_jump = false
			jump_cooldown = 0.1
			jump_count = 1
			animate_jump()
		elif can_double_jump and jump_count == 1:
			# Double jump
			var jump_power = DOUBLE_JUMP_VELOCITY
			if has_super_jump:
				jump_power *= 1.3
			velocity.y = jump_power
			can_double_jump = false
			jump_count = 2
			animate_double_jump()
		elif can_triple_jump and jump_count == 2:
			# Triple jump
			var jump_power = TRIPLE_JUMP_VELOCITY
			if has_super_jump:
				jump_power *= 1.2
			velocity.y = jump_power
			can_triple_jump = false
			jump_count = 3
			animate_triple_jump()
	
	# Handle slide
	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding:
		start_slide()
	
	# Automatic running with speed boost
	var current_speed = SPEED
	if has_speed_boost:
		current_speed *= 1.5
	velocity.x = current_speed
	
	# Move and slide
	move_and_slide()
	
	# Update character animation
	update_character_animation()
	
	# Collect nearby coins with magnet
	if has_magnet:
		attract_coins()

func attract_coins():
	var coins = get_tree().get_nodes_in_group("coins")
	for coin in coins:
		var distance = global_position.distance_to(coin.global_position)
		if distance <= MAGNET_RANGE:
			var direction = (global_position - coin.global_position).normalized()
			coin.global_position += direction * 500 * get_process_delta_time()

func animate_jump():
	# Jump animation
	legs.scale.y = 0.8
	body.scale.y = 1.1
	await get_tree().create_timer(0.2).timeout
	legs.scale.y = 1.0
	body.scale.y = 1.0

func animate_double_jump():
	# Double jump animation with flip
	sprite.scale.x = 1.2
	sprite.rotation = 0.2
	await get_tree().create_timer(0.1).timeout
	sprite.scale.x = 1.0
	sprite.rotation = 0

func animate_triple_jump():
	# Triple jump animation with spin
	sprite.rotation = 0.5
	sprite.scale.x = 1.3
	sprite.scale.y = 0.8
	await get_tree().create_timer(0.15).timeout
	sprite.rotation = 0
	sprite.scale.x = 1.0
	sprite.scale.y = 1.0

func update_character_animation():
	# Enhanced walking animation
	if is_on_floor() and not is_sliding:
		var time = Time.get_time_dict_from_system().second
		legs.scale.x = 1.0 + sin(time * 12) * 0.15
		body.position.y = sin(time * 10) * 3
		head.position.y = -20 + sin(time * 8) * 2

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

func enable_speed_boost():
	has_speed_boost = true
	speed_boost_timer = 6.0

func enable_magnet():
	has_magnet = true
	magnet_timer = 15.0

func enable_super_jump():
	has_super_jump = true
	super_jump_timer = 10.0

func disable_shield():
	has_shield = false
	$Shield.visible = false

func take_damage():
	if not has_shield:
		animate_hit()
	else:
		disable_shield()

func animate_hit():
	# Flash red animation
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE