extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const DOUBLE_JUMP_VELOCITY = -450.0
const WALL_JUMP_VELOCITY = Vector2(-300, -400)
const SLIDE_DURATION = 0.8
const GRAVITY = 980.0

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var slide_collision = $SlideCollision
@onready var wall_detector_left = $WallDetectorLeft
@onready var wall_detector_right = $WallDetectorRight

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_sliding = false
var slide_timer = 0.0
var has_shield = false
var has_jetpack = false
var jetpack_timer = 0.0
var has_magnet = false
var magnet_timer = 0.0
var has_speed_boost = false
var speed_boost_timer = 0.0
var is_jumping = false
var jump_hold_time = 0.0
var max_jump_hold = 0.3
var jumps_remaining = 2
var can_double_jump = true
var is_on_wall = false
var wall_side = 0  # -1 for left, 1 for right

func _ready():
	slide_collision.disabled = true

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false
		jump_hold_time = 0.0
		jumps_remaining = 2
	
	# Check wall collisions
	check_wall_collision()
	
	# Handle slide
	if is_sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			stop_slide()
	
	# Handle power-ups
	handle_powerups(delta)
	
	# Handle jump with hold mechanic
	if Input.is_action_just_pressed("jump"):
		handle_jump()
	
	# Continue jumping while holding (long jump)
	if Input.is_action_pressed("jump") and is_jumping and jump_hold_time < max_jump_hold:
		velocity.y = JUMP_VELOCITY * 0.7  # Reduced gravity during hold
		jump_hold_time += delta
	
	# Handle slide
	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding:
		start_slide()
	
	# Handle pause
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	
	# Calculate speed with boost
	var current_speed = SPEED
	if has_speed_boost:
		current_speed *= 1.5
	
	# Automatic running
	velocity.x = current_speed
	
	# Move and slide
	move_and_slide()
	
	# Handle coin magnet
	if has_magnet:
		attract_coins()

func handle_jump():
	if is_on_floor() and not is_sliding:
		# Normal jump
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		jump_hold_time = 0.0
		$JumpSound.play()
	elif can_double_jump and jumps_remaining > 1 and not is_on_wall:
		# Double jump
		velocity.y = DOUBLE_JUMP_VELOCITY
		jumps_remaining -= 1
		$DoubleJumpSound.play()
		create_double_jump_particles()
	elif is_on_wall:
		# Wall jump
		velocity = WALL_JUMP_VELOCITY * Vector2(wall_side, 1)
		$WallJumpSound.play()
		create_wall_jump_particles()

func check_wall_collision():
	var was_on_wall = is_on_wall
	is_on_wall = false
	wall_side = 0
	
	if wall_detector_left.is_colliding():
		is_on_wall = true
		wall_side = -1
	elif wall_detector_right.is_colliding():
		is_on_wall = true
		wall_side = 1
	
	# Reset jumps when touching wall
	if is_on_wall and not was_on_wall:
		jumps_remaining = 2

func handle_powerups(delta):
	# Handle jetpack
	if has_jetpack:
		jetpack_timer -= delta
		if jetpack_timer <= 0:
			disable_jetpack()
		else:
			velocity.y = -200
			create_jetpack_particles()
	
	# Handle magnet
	if has_magnet:
		magnet_timer -= delta
		if magnet_timer <= 0:
			disable_magnet()
	
	# Handle speed boost
	if has_speed_boost:
		speed_boost_timer -= delta
		if speed_boost_timer <= 0:
			disable_speed_boost()

func start_slide():
	is_sliding = true
	slide_timer = SLIDE_DURATION
	sprite.scale.y = 0.5
	collision_shape.disabled = true
	slide_collision.disabled = true
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

func enable_magnet():
	has_magnet = true
	magnet_timer = 6.0
	$MagnetEffect.visible = true

func disable_magnet():
	has_magnet = false
	$MagnetEffect.visible = false

func enable_speed_boost():
	has_speed_boost = true
	speed_boost_timer = 3.0
	sprite.modulate = Color.YELLOW

func disable_speed_boost():
	has_speed_boost = false
	sprite.modulate = Color.WHITE

func attract_coins():
	var coins = get_tree().get_nodes_in_group("coins")
	for coin in coins:
		var distance = global_position.distance_to(coin.global_position)
		if distance < 150:
			var direction = (global_position - coin.global_position).normalized()
			coin.global_position += direction * 500 * get_process_delta_time()

func create_double_jump_particles():
	for i in range(8):
		var particle = $DoubleJumpParticles.duplicate()
		add_child(particle)
		particle.position = Vector2(player.width/2, player.height)
		particle.emitting = true
		await get_tree().create_timer(1.0).timeout
		particle.queue_free()

func create_wall_jump_particles():
	for i in range(6):
		var particle = $WallJumpParticles.duplicate()
		add_child(particle)
		particle.position = Vector2(wall_side * 20, player.height/2)
		particle.emitting = true
		await get_tree().create_timer(1.0).timeout
		particle.queue_free()

func create_jetpack_particles():
	# Handled by the particle system
	pass

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

func toggle_pause():
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		GameManager.pause_game()
	else:
		GameManager.resume_game()