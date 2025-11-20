extends Area2D

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

func _ready():
	body_entered.connect(_on_body_entered)
	animation_player.play("float")

func _on_body_entered(body):
	if body.name == "Player":
		GameManager.add_score(10)
		$CoinSound.play()
		sprite.visible = false
		await get_tree().create_timer(0.3).timeout
		queue_free()