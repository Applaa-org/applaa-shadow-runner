extends Area2D

@export var power_type: String = "shield"

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

func _ready():
	body_entered.connect(_on_body_entered)
	animation_player.play("pulse")
	
	# Set sprite based on type
	match power_type:
		"shield":
			sprite.modulate = Color.CYAN
		"slowmo":
			sprite.modulate = Color.YELLOW
		"jetpack":
			sprite.modulate = Color.ORANGE

func _on_body_entered(body):
	if body.name == "Player":
		match power_type:
			"shield":
				body.enable_shield()
			"slowmo":
				GameManager.activate_slowmo()
			"jetpack":
				body.enable_jetpack()
		
		GameManager.add_score(50)
		$PowerUpSound.play()
		sprite.visible = false
		await get_tree().create_timer(0.3).timeout
		queue_free()