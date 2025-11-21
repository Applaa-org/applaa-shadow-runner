extends Node

signal score_changed(new_score: int)
signal level_changed(level_name: String)
signal game_over
signal game_paused
signal level_complete

var score = 0
var current_level = 0
var is_game_over = false
var is_paused = false
var levels_completed = 0

var levels = [
	{"name": "City Streets", "theme": "city", "background": "#1a1a2e", "difficulty": 1},
	{"name": "Forest Path", "theme": "forest", "background": "#0d2818", "difficulty": 2},
	{"name": "Desert Dunes", "theme": "desert", "background": "#3e2723", "difficulty": 3},
	{"name": "Ice Mountains", "theme": "ice", "background": "#1a237e", "difficulty": 4},
	{"name": "Space Station", "theme": "space", "background": "#000000", "difficulty": 5}
]

func _ready():
	reset_game()

func add_score(points: int):
	score += points
	score_changed.emit(score)

func reset_game():
	score = 0
	current_level = 0
	is_game_over = false
	is_paused = false
	levels_completed = 0
	score_changed.emit(score)
	level_changed.emit(levels[current_level]["name"])

func next_level():
	current_level += 1
	levels_completed += 1
	
	if current_level >= levels.size():
		# Game completed!
		end_game()
	else:
		level_changed.emit(levels[current_level]["name"])
		level_complete.emit()

func complete_level():
	# Bonus points for completing level
	add_score(100 * (current_level + 1))
	next_level()

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

func get_current_level_data():
	if current_level < levels.size():
		return levels[current_level]
	return null