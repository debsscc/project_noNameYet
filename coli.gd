extends Area2D
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("inimigos"):
		if body.has_method("take_paralisia"):
			body.take_paralisia()
	elif body.is_in_group("objetos"):
		if body.has_method("interage"):
			body.interage()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "dano":
		animation_player.play("idle")
