extends Node2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("inimigos"):
		if body.has_method("take_paralisia"):
			body.take_paralisia()
	elif body.is_in_group("objetos"):
		if body.has_method("interage"):
			body.interage()
			
