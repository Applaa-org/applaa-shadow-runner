extends Node2D

@export var section_length = 800
@export var min_gap = 200
@export var max_gap = 400

var obstacle_scene = preload("res://scenes/Obstacle.tscn")
var enemy_scene = preload("res://scenes/Enemy.tscn")
var coin_scene = preload("res://scenes/Coin.tscn")
var powerup_scene = preload("res://scenes/PowerUp.tscn")
var wall_scene = preload("res://scenes/Wall.tscn")
var moving_platform_scene = preload("res://scenes/MovingPlatform.tscn")

func generate_level(level_index: int):
	# Clear existing level
	for child in get_children():
		child.queue_free()
	
	var level_data = GameManager.levels[level_index]
	var difficulty = level_data["difficulty"]
	
	# Generate level sections based on difficulty
	var sections = 3 + difficulty
	for i in range(sections):
		generate_section(i * section_length, level_index, difficulty)

func generate_section(start_x: int, level_index: int, difficulty: int):
	# Generate platforms
	generate_platforms(start_x, level_index, difficulty)
	
	# Generate walls for higher difficulties
	if difficulty >= 3:
		generate_walls(start_x, difficulty)
	
	# Generate moving platforms for higher difficulties
	if difficulty >= 5:
		generate_moving_platforms(start_x, difficulty)
	
	# Generate obstacles
	generate_obstacles(start_x, level_index, difficulty)
	
	# Generate enemies
	generate_enemies(start_x, level_index, difficulty)
	
	# Generate collectibles
	generate_collectibles(start_x, level_index, difficulty)
	
	# Generate power-ups
	generate_powerups(start_x, level_index, difficulty)

func generate_platforms(start_x: int, level_index: int, difficulty: int):
	# Create main platform
	var platform = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(section_length, 50)
	collision.shape = shape
	platform.add_child(collision)
	platform.position = Vector2(start_x + section_length/2, 600)
	add_child(platform)
	
	# Add floating platforms for higher difficulties
	if difficulty >= 4:
		var num_floating = difficulty - 3
		for i in range(num_floating):
			var floating = StaticBody2D.new()
			var float_collision = CollisionShape2D.new()
			var float_shape = RectangleShape2D.new()
			float_shape.size = Vector2(100, 20)
			float_collision.shape = float_shape
			floating.add_child(float_collision)
			floating.position = Vector2(start_x + 200 + i * 200, 400 + i * 50)
			add_child(floating)

func generate_walls(start_x: int, difficulty: int):
	var num_walls = min(difficulty - 2, 3)
	for i in range(num_walls):
		var wall = wall_scene.instantiate()
		var x = start_x + 300 + i * 250
		var y = 300
		wall.position = Vector2(x, y)
		add_child(wall)

func generate_moving_platforms(start_x: int, difficulty: int):
	var num_moving = min(difficulty - 4, 2)
	for i in range(num_moving):
		var platform = moving_platform_scene.instantiate()
		var x = start_x + 400 + i * 300
		var y = 350
		platform.position = Vector2(x, y)
		platform.setup(Vector2(100, 0), 2.0)  # Move horizontally
		add_child(platform)

func generate_obstacles(start_x: int, level_index: int, difficulty: int):
	var num_obstacles = 2 + difficulty
	for i in range(num_obstacles):
		var obstacle = obstacle_scene.instantiate()
		var x = start_x + randi_range(100, section_length - 100)
		var y = randi_range(300, 500)
		
		obstacle.position = Vector2(x, y)
		
		# Vary obstacle types based on difficulty
		if difficulty <= 3:
			obstacle.obstacle_type = "low_barrier" if randf() < 0.5 else "barrier"
		elif difficulty <= 6:
			obstacle.obstacle_type = ["barrier", "low_barrier", "spike"][randi() % 3]
		else:
			obstacle.obstacle_type = ["barrier", "low_barrier", "spike", "moving_spike"][randi() % 4]
		
		add_child(obstacle)

func generate_enemies(start_x: int, level_index: int, difficulty: int):
	var num_enemies = 1 + (difficulty / 2)
	for i in range(num_enemies):
		var enemy = enemy_scene.instantiate()
		var x = start_x + randi_range(150, section_length - 150)
		var y = randi_range(200, 400)
		
		enemy.position = Vector2(x, y)
		
		# Adjust enemy behavior based on difficulty
		enemy.shoot_interval = max(0.5, 2.0 - (difficulty * 0.1))
		enemy.laser_speed = 300 + (difficulty * 50)
		
		add_child(enemy)

func generate_collectibles(start_x: int, level_index: int, difficulty: int):
	var num_coins = 5 + difficulty
	for i in range(num_coins):
		var coin = coin_scene.instantiate()
		var x = start_x + randi_range(50, section_length - 50)
		var y = randi_range(250, 450)
		
		coin.position = Vector2(x, y)
		coin.add_to_group("coins")
		add_child(coin)

func generate_powerups(start_x: int, level_index: int, difficulty: int):
	var num_powerups = min(1 + (difficulty / 3), 3)
	var power_types = ["shield", "slowmo", "jetpack", "magnet", "speed_boost"]
	
	for i in range(num_powerups):
		var powerup = powerup_scene.instantiate()
		var x = start_x + randi_range(200, section_length - 200)
		var y = randi_range(300, 500)
		
		powerup.position = Vector2(x, y)
		powerup.power_type = power_types[randi() % power_types.size()]
		add_child(powerup)