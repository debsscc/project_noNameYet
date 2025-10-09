extends Node2D
class_name Fantasma

# -- Export e variáveis --
var animando: bool = false
@export var passos : int = 6
@export var tempo_entre_passos: float = 0.1

var modo_ataque: bool = false

# -- Referências --
@onready var jogador_ref = get_parent()
@onready var area_ataque: Area2D = $Area2D  
@onready var sprite: AnimatedSprite2D = $animation_fantasma

func _ready():
	jogador_ref = get_parent()
	modo_ataque = false
	if area_ataque:
		area_ataque.monitoring = false

# -- Funções auxiliares --
func _entrar_no_chao() -> void:
	var pos_inicial = global_position
	var pos_final = pos_inicial + Vector2(0, altura_entrada)
	var duracao = 0.25
	var tempo = 0.0
	while tempo < duracao:
		tempo += get_process_delta_time()
		var t = tempo / duracao
		sprite.position = pos_inicial.lerp(pos_final, t)
		await get_tree().process_frame
	sprite.visible = false

func _spawn_cursor() -> void:
	if cursor: 
		cursor.visible = true
		cursor.global_position = jogador_ref.global_position + Vector2(distancia_lateral * sign(jogador_ref.scale.x), 0)
		cursor_posicao = cursor.global_position
		await get_tree().create_timer(0.2).timeout

func _andar_passos() -> void:
	for i in range(passos):
		print("Passo", i + 1)
		await get_tree().create_timer(tempo_entre_passos).timeout

func _surgir_do_chao() -> void:
	sprite.visible = true
	var pos_inicial = cursor.global_position + Vector2(0, altura_entrada)
	var pos_final = cursor.global_position
	var duracao = 0.25
	var tempo = 0.0
	while tempo < duracao:
		tempo += get_process_delta_time()
		var t = tempo / duracao
		sprite.global_position = pos_inicial.lerp(pos_final, t)
		await get_tree().process_frame

func verificar_acerto_ou_erro() -> void:
	if not area_ataque:
		return
	var bodies = area_ataque.get_overlapping_bodies()
	var afetados = []
	for c in bodies:
		if c in afetados:
			continue
		if c.is_in_group("inimigos"):
			if c.has_method("paralisar"):
				c.paralisar(tempo_paralisia)
			else:
				c.paralisado = true
				await get_tree().create_timer(tempo_paralisia).timeout
				if is_instance_valid(c):
					c.paralisado = false
		elif c.is_in_group("interativo"):
			if c.has_method("interagir"):
				c.interagir()
		afetados.append(c)

func efeito_erro() -> void:
	var pos_inicial = global_position
	var pos_final = jogador_ref.global_position + Vector2(-distancia_lateral * sign(jogador_ref.scale.x), -20.0)
	var duracao = 0.35
	var tempo = 0.0
	while tempo < duracao:
		tempo += get_process_delta_time()
		var t = tempo / duracao
		var altura = sin(t * PI) * 12.0
		global_position = pos_inicial.lerp(pos_final, t) + Vector2(0.0, -altura)
		await get_tree().process_frame
	animando = false

func _retornar_para_jogador() -> void:
	var pos_inicial = global_position
	var pos_final = jogador_ref.global_position + Vector2(-distancia_lateral * sign(jogador_ref.scale.x), -10.0)
	var duracao = 0.2
	var tempo = 0.0
	while tempo < duracao:
		tempo += get_process_delta_time()
		var t = tempo / duracao
		global_position = pos_inicial.lerp(pos_final, t)
		await get_tree().process_frame
	animando = false



func _process(delta: float) -> void:
	if animando:
		return
	if not modo_ataque:
		seguir_jogador(delta)
	else:
		global_position = global_position.lerp(cursor_posicao, 8.0 * delta)

func seguir_jogador(delta: float) -> void:
	if not jogador_ref:
		return
	var dir = jogador_ref.scale.x if jogador_ref else 1.0
	var alvo = jogador_ref.global_position + Vector2(distancia_lateral * sign(dir), -10.0)
	global_position = global_position.lerp(alvo, velocidade_seguir * delta)

func executar_ataque() -> void:
	if animando:
		return
	animando = true
	modo_ataque = true

	if area_ataque:
		area_ataque.monitoring = true
	
	await _entrar_no_chao()
	await _spawn_cursor()
	await _andar_passos()
	await _surgir_do_chao()
	await verificar_acerto_ou_erro()
	
	if area_ataque:
		area_ataque.monitoring = false
	
	animando = false
	modo_ataque = false

func animar_ataque() -> void:
	if animando:
		return
	animando = true

	var pos_inicial = global_position
	var pos_final = cursor_posicao  # corrigido typo aqui
	var duracao = 0.25
	var tempo = 0.0
	while tempo < duracao:
		tempo += get_process_delta_time()
		var t = tempo / duracao
		global_position = pos_inicial.lerp(pos_final, t)
		await get_tree().process_frame

	verificar_acerto_ou_erro()
	animando = false
