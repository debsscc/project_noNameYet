extends CharacterBody2D

@export var speed := 600.0
var direction: Vector2 = Vector2.ZERO

func initialize(dir: Vector2) -> void:
	direction = dir.normalized()
	look_at(global_position + direction)

func _ready():
	$AnimatedSprite2D.play()

func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		# Se colidir com algo, verifica se é o jogador
		if collision.get_collider().has_method("dano_jogador"):
			collision.get_collider().dano_jogador()
		queue_free()

func _on_life_timer_timeout():
	queue_free()

func _on_enemy_detection_area_body_entered(body):
	if body.has_method("dano_jogador"):
		body.dano_jogador()
		queue_free()
