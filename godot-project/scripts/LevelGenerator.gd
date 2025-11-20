extends Node2D

@export var section_length = 800
@export var min_gap = 200
@export var max_gap = 400

var obstacle_scene = preload("res://scenes/Obstacle.tscn")
var enemy_scene = preload("res://scenes/Enemy.tscn")
var coin_scene = preload("res://scenes/Coin.tscn")
var powerup_scene = preload("res://scenes/PowerUp.tscn")

func generate_level(level_index: int):
	# Clear existing level
	for child in get_children():
		child.queue_free()
	
	# Generate level sections
	var sections = 5
	for i in range(sections):
		generate_section(i * section_length, level_index)

func generate_section(start_x: int, level_index: int):
	# Generate platforms
	generate_platforms(start_x, level_index)
	
	# Generate obstacles
	generate_obstacles(start_x, level_index)
	
	# Generate enemies
	generate_enemies(start_x, level_index)
	
	# Generate collectibles
	generate_collectibles(start_x, level_index)
	
	# Generate power-ups
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
	var num_obstacles = randi_range(2, 4)
	for i in range(num_obstacles):
		var obstacle = obstacle_scene.instantiate()
		var x = start_x + randi_range(100, section_length - 100)
		var y = randi_range(300, 500)
		
		obstacle.position = Vector2(x, y)
		obstacle.obstacle_type = "low_barrier" if randf() < 0.5 else "barrier"
		add_child(obstacle)

func generate_enemies(start_x: int, level_index: int):
	var num_enemies = randi_range(1, 3)
	for i in range(num_enemies):
		var enemy = enemy_scene.instantiate()
		var x = start_x + randi_range(150, section_length - 150)
		var y = randi

_range(200, 400)
		
		enemy.position = Vector2(x, y)
		add_child(enemy)

func generate_collectibles(start_x: int, level_index: int):
	var num_coins = randi_range(5, 8)
	for i in range(num_coins):
		var coin = coin_scene.instantiate()
		var x = start_x + randi_range(50, section_length - 50)
		var y = randi_range(250, 450)
		
		coin.position = Vector2(x, y)
		add_child(coin)

func generate_powerups(start_x: int, level_index: int):
	var num_powerups = randi_range(1, 2)
	var power_types = ["shield", "slowmo", "jetpack"]
	
	for i in range(num_powerups):
		var powerup = powerup_scene.instantiate()
		var x = start_x + randi_range(200, section_length - 200)
		var y = randi_range(300, 500)
		
		powerup.position = Vector2(x, y)
		powerup.power_type = power_types[randi() % power_types.size()]
		add_child(powerup)