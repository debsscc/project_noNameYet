extends Node

var player_data: PlayerData
var world_data: WorldData
var tiros_do_jogador := 0

func _ready():
	print("Global carregado!!!!")

func new_game():
	player_data = PlayerData.new()
	world_data = WorldData.new()

func save_game():
	ResourceSaver.save(player_data, "user://player_data.tres")
	ResourceSaver.save(world_data, "user://world_data.tres")
	print("Jogo salvo em:", ProjectSettings.globalize_path("user://"))

func load_game():
	if FileAccess.file_exists("user://player_data.tres") and FileAccess.file_exists("user://world_data.tres"):
		player_data = load("user://player_data.tres")
		world_data = load("user://world_data.tres")
		print("Jogo carregado omg.")
	else:
		print("Nenhum save encontrado:()")
