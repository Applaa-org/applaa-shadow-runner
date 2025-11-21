extends Node2D

@export var section_length = 400  # Very short sections
@export var min_gap = 400  # Lots of spacing
@export var max_gap = 600  # Lots of spacing

var obstacle_scene = preload("res://scenes/Obstacle.tscn")
var enemy_scene = preload("res://scenes/Enemy.tscn")
var coin_scene = preload("res://scenes/Coin.tscn")
var powerup_scene = preload("res://scenes/PowerUp.tscn")

func generate_level(level_index: int):
	# Clear existing level
	for child in get_children():
		child.queue_free()
	
	# Generate very few sections
	var sections = 2
	for i in range(sections):
		generate_section(i * section_length, level_index)

func generate_section(start_x: int, level_index: int):
	# Generate platforms
	generate_platforms(start_x, level_index)
	
	# Generate almost no obstacles
	generate_obstacles(start_x, level_index)
	
	# Generate almost no enemies
	generate_enemies(start_x, level_index)
	
	# Generate lots of coins
	generate_collectibles(start_x, level_index)
	
	# Generate lots of power-ups
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
	# Generate almost no obstacles
	var num_obstacles = randi_range(0, 1)  # Sometimes no obstacles
	for i in range(num_obstacles):
		var obstacle = obstacle_scene.instantiate()
		var x = start_x + randi_range(200, section_length - 200)
		var y = 540  # Only low obstacles
		
		obstacle.position = Vector2(x, y)
		obstacle.obstacle_type = "low_barrier"  # Only easy low barriers
		add_child(obstacle)

func generate_enemies(start_x: int, level_index: int):
	# Generate almost no enemies
	var num_enemies = randi_range(0, 1)  # Sometimes no enemies
	for i in range(num_enemies):
		var enemy = enemy_scene.instantiate()
		var x = start_x + randi_range(250, section_length - 250)
		var y = 400
		
		enemy.position = Vector2(x, y)
		enemy.shoot_interval = 8.0  # Extremely slow shooting
		enemy.laser_speed = 60.0  # Extremely slow lasers
		add_child(enemy)

func generate_collectibles(start_x: int, level_index: int):
	# Generate many coins for easy scoring
	var num_coins = randi_range(10, 15)
	for i in range(num_coins):
		var coin = coin_scene.instantiate()
		var x = start_x + randi_range(50, section_length - 50)
		var y = randi_range(300, 450)
		
		coin.position = Vector2(x, y)
		coin.add_to_group("coins")
		add_child(coin)

func generate_powerups(start_x: int, level_index: int):
	# Generate many power-ups for easier gameplay
	var num_powerups = randi_range(3, 5)
	var power_types = ["shield"]
	
	for i in range(num_powerups):
		var powerup = powerup_scene.instantiate()
		var x = start_x + randi_range(100, section_length - 100)
		var y = randi_range(350, 450)
		
		powerup.position = Vector2(x, y)
		powerup.power_type = power_types[randi() % power_types.size()]
		add_child(powerup)