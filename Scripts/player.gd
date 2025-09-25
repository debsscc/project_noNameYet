extends CharacterBody2D

class_name player

# Configurações de movimento
@export var velocidade = 80.0
@export var multiplicador_corrida = 1.8
@onready var camera = $camera_player
@onready var sprite_animado: AnimatedSprite2D = $animation_player
@onready var shoot_point = $shoot_point
@onready var shoot_point_position_x = shoot_point.position.x

# Variáveis de controle
var pode_interagir = true
var animacao_parado = ""
var pode_se_mover = true
var esta_correndo = false
var esta_atirando = false

# Sistema de tiro
var pode_atirar = true
#var municao = 10
#var municao_maxima = 10
#var municao_pente = 30
#var pentes = 3
var morto := false

# Sistema de vida
@export var vida_maxima: int = 90
@export var vida_atual: int = vida_maxima
var invencivel: bool = false
@export var tempo_invencibilidade: float = 1.0

signal interagir(dono)

func _physics_process(delta: float) -> void:
	if morto:
		return 
	# Pausa movimentação durante ações
	if esta_atirando:
		velocity = Vector2.ZERO
		move_and_slide()  
		return
		
	# Verifica inputs de correr
	esta_correndo = (
		Input.is_action_pressed("walk_direita") or
		Input.is_action_pressed("walk_esquerda") or
		Input.is_action_pressed("runnin_direita") or
		Input.is_action_pressed("running_esquerda")
	)
	
	# Movimentação normal
	var direcao_x = Input.get_axis("walk_esquerda", "walk_direita")
	var direcao = Vector2(direcao_x, 0)
	
	var velocidade_atual = velocidade * (multiplicador_corrida if esta_correndo else 1.0)

	if direcao != Vector2.ZERO and pode_se_mover:
		velocity = direcao.normalized() * velocidade_atual
		sprite_animado.play("run")
		
		if direcao.x < 0:
			sprite_animado.flip_h = true
			shoot_point.position.x = -shoot_point_position_x
		elif direcao.x > 0:
			sprite_animado.flip_h = false
			shoot_point.position.x = shoot_point_position_x
	else:
		velocity = Vector2.ZERO
		sprite_animado.play("idle")
	
	move_and_slide()

func dano_jogador():
	vida_atual -= 10

	# Define direção com base na orientação do player
	var dir = Vector2.RIGHT
	if not sprite_animado.flip_h:
		dir = Vector2.RIGHT
	else:
		dir = Vector2.LEFT
	#projectile.initialize(dir)

	await sprite_animado.animation_finished
	esta_atirando = false

	if velocity == Vector2.ZERO:
		sprite_animado.play("idle")
	else:
		sprite_animado.play("run")

func _exit_tree():
	# Para todos os sons ao sair da cena para evitar que continuem tocando
	pass
	
func morrer():
	if morto:
		return
	morto = true
	print("jogador foi morto")
	velocity = Vector2.ZERO
	
	#sprite_animado.play("morte")
	#death.play()
	await get_tree().create_timer(2).timeout
	get_tree().reload_current_scene()
