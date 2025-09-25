extends Control

signal change_scene(scene: String)

var is_transitioning: bool = false  # Controla se já está em transição

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#menu_ost.volume_db= -20
	#menu_ost.play()
	
	#var tween := create_tween()
	#tween.tween_property(menu_ost, "volume_db", 3, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
func _on_iniciar_pressed() -> void:
	if is_transitioning:
		return
	is_transitioning = true

	change_scene.emit("res://Scenes/tutorial.tscn") 
	get_tree().change_scene_to_file("res://Scenes/tutorial.tscn")

func _on_config_pressed() -> void:
	
	change_scene.emit("res://Scenes/config.tscn") 
	get_tree().change_scene_to_file("res://Scenes/config.tscn")


func _on_sair_pressed() -> void:
	#var fade_out_tween := create_tween()
	#fade_out_tween.tween_property(menu_ost, "volume_db", -4.0, 1.0) \ .set_trans(Tween.TRANS_SINE) \ .set_ease(Tween.EASE_IN_OUT)
	
	#await fade_out_tween.finished
	get_tree().quit() 
