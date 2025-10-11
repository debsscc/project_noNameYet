extends Node2D
class_name Fantasma

# -- Export e variáveis --
@export var velocidade_seguir: float = 5.0
@export var distancia_lateral: float = 20.0 #o maximo clicando no input do especial
@export var tempo_paralisia: float = 2.0
@export var passos: int = 6
@export var tempo_entre_passos: float = 0.1
@export var distancia_max_posessao: float = 200 #distancia max em X
@onready var max_hold_time: float = 1.5

# -- Estados --
var animando: bool = false
var modo_ataque: bool = false
var tempo_press: float = 0.0
var posicao_inicial: Vector2 = Vector2.ZERO
var cursor_posicao: Vector2 = Vector2.ZERO

# -- Referências --
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var jogador_ref = get_parent()
@onready var area_ataque: Area2D = $animation_fantasma/Area2D  
#@onready var sprite: AnimatedSprite2D = $animation_fantasma

func _ready() -> void:
	#desliga monitor quando presente
	if area_ataque:
		area_ataque.monitoring = false

# -- Funções auxiliares --
func _process(delta: float) -> void:
	#Detecta input especial
	if Input.is_action_just_pressed("especial") and not animando:
		iniciar_possessao()
	
	#enquanto segura, atualiza tempo_press e avança animação do meio
	if Input.is_action_just_pressed("especial") and modo_ataque:
		tempo_press += delta
		var anim_name := "possessao_medoi"
		if anim_player and anim_player.get_animation(anim_name):
			if anim_player.current_animation != anim_name or not anim_player.is_playing():
				anim_player.play(anim_name)
			var anim_res = anim_player.get_animation(anim_name)
			var anim_len = anim_res.length
			var t = clamp(tempo_press / max_hold_time, 0.0, 1.0)
			anim_player.seek(t * anim_len) #posiciona o timeline proporcionalmente
	else:
		#fallback
		pass
	if Input.is_action_just_released("especial") and modo_ataque:
		finalizar_possessao()
		
	#comportamento normal de movimentação do fantasma
	if animando:
		return
	if not modo_ataque:
		seguir_jogador(delta)
	else:
		pass

# -- Sequência de possessão --
func iniciar_possessao() -> void:
	animando = true
	modo_ataque = true
	posicao_inicial = global_position
	tempo_press = 0.0
	if anim_player:
		anim_player.play("possessao_inicial")
		while  anim_player.is_playing():
			await get_tree().process_frame
		
		anim_player.play("possessao_medoi") 
	animando = false
	
func finalizar_possessao() -> void:
	if anim_player:
		anim_player.pause()
	var pos_final := global_position
	if anim_player:
		anim_player.play("possessao_final")
		while anim_player.is_playing():
			await get_tree().process_frame
	
	await verificar_acerto_ou_erro()
	
	if anim_player:
		anim_player.play("RESET")
		while anim_player.is_playing():
			await get_tree().process_frame

	global_position = posicao_inicial
	modo_ataque = false
	animando = false
	tempo_press = 0.0
	
func seguir_jogador(delta: float) -> void:
	if not jogador_ref:
		return
	
	var dir = jogador_ref.scale.x if jogador_ref else 1.0
	var alvo = jogador_ref.global_position + Vector2(distancia_lateral * sign(dir), -10.0)
	global_position = global_position.lerp(alvo, velocidade_seguir * delta)

func verificar_acerto_ou_erro() -> void:
	if not area_ataque:
		return
	
	var bodies = area_ataque.get_overlapping_bodies()
	var afetados: Array = []
	
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

func _retornar_para_jogador() -> void:
	anim_player.play("RESET")  
	await anim_player.animation_finished
	modo_ataque = false

#func efeito_erro() -> void:
	#anim_player.play("erro")  # Caso queira uma animação visual de falha
