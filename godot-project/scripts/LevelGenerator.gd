extends Node2D

@export var section_length = 600
@export var min_gap = 300
@export var max_gap = 500

var obstacle_scene = preload("res://scenes/Obstacle.tscn")
var enemy_scene = preload("res://scenes/Enemy.tscn")
var coin_scene = preload("res://scenes/Coin.tscn")
var powerup_scene = preload("res://scenes/PowerUp.tscn")

var levels = [
	{
		"name": "City Streets",
		"theme": "city",
		"background": "#1a1a2e",
		"platformColor": "#16213e",
		"obstacleColor": "#e94560",
		"difficulty": 1,
		"obstacleCount": 2,
		"enemyCount": 1,
		"coinCount": 10,
		"powerupCount": 2
	},
	{
		"name": "Forest Path",
		"theme": "forest",
		"background": "#0d2818",
		"platformColor": "#1e3a2e",
		"obstacleColor": "#4a7c59",
		"difficulty": 2,
		"obstacleCount": 3,
		"enemyCount": 2,
		"coinCount": 12,
		"powerupCount": 3
	},
	{
		"name": "Desert Dunes",
		"theme": "desert",
		"background": "#3e2723",
		"platformColor": "#5d4037",
		"obstacleColor": "#ff6f00",
		"difficulty": 3,
		"obstacleCount": 4,
		"enemyCount": 2,
		"coinCount": 15,
		"powerupCount": 3
	},
	{
		"name": "Ice Mountains",
		"theme": "ice",
		"background": "#1a237e",
		"platformColor": "#283593",
		"obstacleColor": "#64b5f6",
		"difficulty": 4,
		"obstacleCount": 5,
		"enemyCount": 3,
		"coinCount": 18,
		"powerupCount": 4
	},
	{
		"name": "Space Station",
		"theme": "space",
		"background": "#000000",
		"platformColor": "#1a1a1a",
		"obstacleColor": "#ff00ff",
		"difficulty": 5,
		"obstacleCount": 6,
		"enemyCount": 4,
		"coinCount": 20,
		"powerupCount": 4
	}
]

func generate_level(level_index: int):
	# Clear existing level
	for child in get_children():
		child.queue_free()
	
	if level_index >= levels.size():
		return
	
	var level_data = levels[level_index]
	var sections = 3
	
	for i in range(sections):
		generate_section(i * section_length, level_data)

func generate_section(start_x: int, level_data: Dictionary):
	# Generate platforms
	generate_platforms(start_x, level_data)
	
	# Generate obstacles
	generate_obstacles(start_x, level_data)
	
	# Generate enemies
	generate_enemies(start_x, level_data)
	
	# Generate collectibles
	generate_collectibles(start_x, level_data)
	
	# Generate power-ups
	generate_powerups(start_x, level_data)

func generate_platforms(start_x: int, level_data: Dictionary):
	# Create main platform
	var platform = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(section_length, 50)
	collision.shape = shape
	platform.add_child(collision)
	platform.position = Vector2(start_x + section_length/2, 600)
	add_child(platform)

func generate_obstacles(start_x: int, level_data: Dictionary):
	var num_obstacles = level_data.obstacleCount
	var obstacle_types = ["low_barrier", "high_barrier", "moving"]
	
	for i in range(num_obstacles):
		var obstacle = obstacle_scene.instantiate()
		var x = start_x + randi_range(150, section_length - 150)
		var y = 540
		
		if i % 2 == 1:
			y = 450  # High obstacle
		
		obstacle.position = Vector2(x, y)
		obstacle.obstacle_type = obstacle_types[randi() % obstacle_types.size()]
		add_child(obstacle)

func generate_enemies(start_x: int, level_data: Dictionary):
	var num_enemies = level_data.enemyCount
	
	for i in range(num_enemies):
		var enemy = enemy_scene.instantiate()
		var x = start_x + randi_range(200, section_length - 200)
		var y = randi_range(300, 400)
		
		enemy.position = Vector2(x, y)
		enemy.shoot_interval = 4.0 - (level_data.difficulty * 0.5)
		enemy.laser_speed = 100.0 + (level_data.difficulty * 20)
		add_child(enemy)

func generate_collectibles(start_x: int, level_data: Dictionary):
	var num_coins = level_data.coinCount
	
	for i in range(num_coins):
		var coin = coin_scene.instantiate()
		var x = start_x + randi_range(50, section_length - 50)
		var y = randi_range(300, 450)
		
		coin.position = Vector2(x, y)
		coin.add_to_group("coins")
		add_child(coin)

func generate_powerups(start_x: int, level_data: Dictionary):
	var num_powerups = level_data.powerupCount
	var power_types = ["shield", "speed", "magnet"]
	
	for i in range(num_powerups):
		var powerup = powerup_scene.instantiate()
		var x = start_x + randi_range(100, section_length - 100)
		var y = randi_range(350, 450)
		
		powerup.position = Vector2(x, y)
		powerup.power_type = power_types[randi() % power_types.size()]
		add_child(powerup)