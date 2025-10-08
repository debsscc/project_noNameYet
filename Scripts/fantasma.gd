extends Node2D
class_name Fantasma

@export var velocidade_seguir: float = 5.0
@export var distancia_lateral: float = 20.0
@export var tempo_paralisia: float = 2.0

var jogador_ref: Node2D = null
var modo_ataque: bool = false
var cursor_posicao: Vector2 = Vector2.ZERO
var animando: bool = false

@onready var area_ataque: Area2D = $Area2D  # garanta que exista um Area2D filho chamado "Area2D"

func _ready():
	# espera que o fantasma seja filho do Player: se não for, ajuste a referência ao jogador conforme sua cena
	jogador_ref = get_parent()
	modo_ataque = false

func _process(delta: float) -> void:
	if animando:
		return
	if not modo_ataque:
		seguir_jogador(delta)
	else:
		# segue suavemente para a posição do cursor enquanto mira
		global_position = global_position.lerp(cursor_posicao, 8.0 * delta)

func seguir_jogador(delta: float) -> void:
	if not jogador_ref:
		return
	var dir = jogador_ref.scale.x if jogador_ref else 1.0
	var alvo = jogador_ref.global_position + Vector2(distancia_lateral * sign(dir), -10.0)
	global_position = global_position.lerp(alvo, velocidade_seguir * delta)

func executar_ataque() -> void:
	# disparo: o jogador já definiu cursor_posicao
	modo_ataque = false
	animar_ataque()

func animar_ataque() -> void:
	animando = true

	var pos_inicial = global_position
	var pos_final = cursor_posicao  # o fantasma irá até o cursor
	var duracao = 0.25
	var tempo = 0.0
	while tempo < duracao:
		tempo += get_process_delta_time()
		var t = tempo / duracao
		# movimento direto (pode trocar por tween)
		global_position = pos_inicial.lerp(pos_final, t)
		await get_tree().process_frame

	# Após chegar ao ponto do ataque, checa acerto
	verificar_acerto_ou_erro()

func verificar_acerto_ou_erro() -> void:
	# usa Area2D para saber se tem inimigos sobrepostos no momento do impacto
	var bodies := []
	if area_ataque:
		bodies = area_ataque.get_overlapping_bodies()
	# procurar o primeiro corpo que esteja no grupo "inimigos"
	var alvo_inimigo = null
	for b in bodies:
		if b and b.is_in_group("inimigos"):
			alvo_inimigo = b
			break

	if alvo_inimigo:
		# acertou: tenta chamar método paralisar() se existir, senão usa flag
		if alvo_inimigo.has_method("paralisar"):
			alvo_inimigo.paralisar(tempo_paralisia)
		else:
			alvo_inimigo.paralisado = true
			await get_tree().create_timer(tempo_paralisia).timeout
			if is_instance_valid(alvo_inimigo):
				alvo_inimigo.paralisado = false
		# volta atrás do jogador com uma pequena animação
		_retornar_para_jogador()
	else:
		# errou -> animação de confusão / salto e retorno
		efeito_erro()

func _retornar_para_jogador() -> void:
	# anima retorno rápido atrás do jogador
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

func efeito_erro() -> void:
	# salto curto e volta
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
