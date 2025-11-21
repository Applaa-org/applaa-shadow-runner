extends Node2D

@export var section_length = 600  # Shorter sections
@export var min_gap = 300         # More spaced out
@export var max_gap = 500

var obstacle_scene = preload("res://scenes/Obstacle.tscn")
var enemy_scene = preload("res://scenes/Enemy.tscn")
var coin_scene = preload("res://scenes/Coin.tscn")
var powerup_scene = preload("res://scenes/PowerUp.tscn")

func generate_level(level_index: int):
	# Clear existing level
	for child in get_children():
		child.queue_free()
	
	# Generate simple level sections
	var sections = 3  # Fewer sections
	for i in range(sections):
		generate_section(i * section_length, level_index)

func generate_section(start_x: int, level_index: int):
	# Generate platforms
	generate_platforms(start_x, level_index)
	
	# Generate fewer obstacles
	generate_obstacles(start_x, level_index)
	
	# Generate fewer enemies
	generate_enemies(start_x, level_index)
	
	# Generate more coins (easier scoring)
	generate_collectibles(start_x, level_index)
	
	# Generate more power-ups
	generate_powerups(start_x, level_index)

func generate_platforms(start_x: int, level_index: int):
	# Create main platform
	var platform = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(section_length, 50)
	collision.shape = shape
	platform.add_child(collision)
	platform.position = Vector2(start_x + section_length/2, 600)
	add_child(platform)

func generate_obstacles(start_x: int, level_index: int):
	# Generate very few obstacles
	var num_obstacles = 2  # Only 2 obstacles
	for i in range(num_obstacles):
		var obstacle = obstacle_scene.instantiate()
		var x = start_x + 200 + i * 300  # More spaced out
		var y = 540
		
		obstacle.position = Vector2(x, y)
		obstacle.obstacle_type = "low_barrier"  # Only low barriers (easier)
		add_child(obstacle)

func generate_enemies(start_x: int, level_index: int):
	# Generate very few enemies
	var num_enemies = 1  # Only 1 enemy
	for i in range(num_enemies):
		var enemy = enemy_scene.instantiate()
		var x = start_x + 400
		var y = 300
		
		enemy.position = Vector2(x, y)
		add_child(enemy)

func generate_collectibles(start_x: int, level_index: int):
	# Generate more coins (easier to score)
	var num_coins = 8  # More coins
	for i in range(num_coins):
		var coin = coin_scene.instantiate()
		var x = start_x + 100 + i * 60  # Closer together
		var y = 350
		
		coin.position = Vector2(x, y)
		add_child(coin)

func generate_powerups(start_x: int, level_index: int):
	# Generate more power-ups
	var num_powerups = 2  # More power-ups
	var power_types = ["shield", "slowmo"]
	
	for i in range(num_powerups):
		var powerup = powerup_scene.instantiate()
		var x = start_x + 250 + i * 200
		var y = 400
		
		powerup.position = Vector2(x, y)
		powerup.power_type = power_types[i % power_types.size()]
		add_child(powerup)