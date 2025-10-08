extends CharacterBody2D

@export var speed := 600.0
var direction := Vector2.ZERO

func initialize(dir: Vector2) -> void:
	direction = dir.normalized()
	look_at(global_position + direction)

func _ready():
	add_to_group("projetil")
	$AnimatedSprite2D.play()

func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		queue_free()
	else:
		position += direction * speed * delta

func _on_life_timer_timeout():
	queue_free()

#func _on_enemy_detection_area_body_entered(body):
	#if body.has_method("dano"):
		#body.dano()

func _on_enemy_body_entered(body) -> void:
	if body.has_method("dano"):
		body.dano()
		queue_free()

#func _on_enemy_area_entered(area: Area2D) -> void:
	#if area.has_method("dano"):
		#area.dano()
