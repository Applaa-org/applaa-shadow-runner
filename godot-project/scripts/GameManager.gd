extends Node

signal score_changed(new_score: int)
signal level_changed(level_name: String)
signal game_over
signal game_paused
signal level_completed

var score = 0
var current_level = 0
var is_game_over = false
var is_paused = false
var slowmo_active = false
var slowmo_timer = 0.0
var levels_completed = 0
var high_score = 0

var levels = [
	{"name": "City Rooftops", "theme": "city", "background": "#1a1a2e", "difficulty": 1},
	{"name": "Old Ruins", "theme": "ruins", "background": "#3d2817", "difficulty": 2},
	{"name": "Jungle Temple", "theme": "jungle", "background": "#0d2818", "difficulty": 3},
	{"name": "Cyber World", "theme": "cyber", "background": "#0a0a0a", "difficulty": 4},
	{"name": "Crystal Caves", "theme": "crystal", "background": "#1a0033", "difficulty": 5},
	{"name": "Lava Fields", "theme": "lava", "background": "#330000", "difficulty": 6},
	{"name": "Ice Mountains", "theme": "ice", "background": "#e6f3ff", "difficulty": 7},
	{"name": "Desert Dunes", "theme": "desert", "background": "#ffcc66", "difficulty": 8},
	{"name": "Space Station", "theme": "space", "background": "#000033", "difficulty": 9},
	{"name": "Shadow Realm", "theme": "shadow", "background": "#0a0a0a", "difficulty": 10}
]

func _ready():
	# Load high score
	load_high_score()
	# Initialize game
	reset_game()

func _process(delta):
	if slowmo_active:
		slowmo_timer -= delta
		if slowmo_timer <= 0:
			deactivate_slowmo()
			Engine.time_scale = 1.0

func add_score(points: int):
	score += points
	score_changed.emit(score)
	
	# Update high score
	if score > high_score:
		high_score = score
		save_high_score()

func reset_game():
	score = 0
	current_level = 0
	is_game_over = false
	is_paused = false
	levels_completed = 0
	score_changed.emit(score)
	level_changed.emit(levels[current_level]["name"])

func next_level():
	levels_completed += 1
	level_completed.emit(levels[current_level]["name"])
	
	# Add completion bonus
	add_score(100 * levels[current_level]["difficulty"])
	
	current_level = (current_level + 1) % levels.size()
	level_changed.emit(levels[current_level]["name"])

func activate_slowmo():
	slowmo_active = true
	slowmo_timer = 3.0
	Engine.time_scale = 0.5

func deactivate_slowmo():
	slowmo_active = false
	Engine.time_scale = 1.0

func pause_game():
	is_paused = true
	get_tree().paused = true
	game_paused.emit()

func resume_game():
	is_paused = false
	get_tree().paused = false

func end_game():
	is_game_over = true
	game_over.emit()

func save_high_score():
	# Save to file (simplified)
	var file = FileAccess.open("user://high_score.save", FileAccess.WRITE)
	if file:
		file.store_var(high_score)
		file.close()

func load_high_score():
	# Load from file (simplified)
	var file = FileAccess.open("user://high_score.save", FileAccess.READ)
	if file:
		high_score = file.get_var()
		file.close()

func get_level_progress():
	return float(levels_completed) / float(levels.size())

func get_current_difficulty():
	return levels[current_level]["difficulty"]