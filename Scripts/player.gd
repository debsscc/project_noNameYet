extends CharacterBody2D

class_name Player

# -- Configurações de movimento --
@export var velocidade: float = 80.0
@export var multiplicador_corrida: float = 2.0
@export var forca_pulo: float = 200.0
@export var gravidade: float = 600.0

# -- Referências --
@onready var camera: Camera2D = $camera_player
@onready var sprite_animado: AnimatedSprite2D = $animation_player
@onready var shoot_point: Node2D = $shoot_point

# -- Variáveis de controle --
var pode_interagir: bool = true
var animacao_parado: String = "idle"
var pode_se_mover: bool = true
var esta_correndo: bool = false
var esta_atirando: bool = false
var morto: bool = false

# -- Sistema de tiro --
var pode_atirar: bool = true

# -- Sistema de vida --
@export var vida_maxima: int = 3
var vida_atual: int

# -- Sinal pra UI --
signal vida_alterada(vida_atual)

func _ready() -> void:
	vida_atual = vida_maxima
	# Garante que comece com a animação idle
	vida_alterada.emit(vida_atual)
	sprite_animado.play("idle")

func _physics_process(delta: float) -> void:
	if morto:
		return
	# Aplica gravidade
	if not is_on_floor():
		velocity.y += gravidade * delta
	else:
		velocity.y = 0  # Reseta a gravidade quando no chão
	
	# Pulo
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -forca_pulo
	
	# Pausa movimentação durante ações
	if esta_atirando:
		velocity.x = 0
		move_and_slide()
		# Atualiza animação mesmo quando atirando
		atualizar_animacoes()
		return
	
	# Verifica inputs de movimento
	var direcao_x = 0.0
	
	# Sistema de corrida - verifica inputs específicos de corrida
	if Input.is_action_pressed("runnin_direita"):
		direcao_x = 1.0
		esta_correndo = true
	elif Input.is_action_pressed("running_esquerda"):
		direcao_x = -1.0
		esta_correndo = true
	else:
		# Movimento normal (andando)
		direcao_x = Input.get_axis("walk_esquerda", "walk_direita")
		esta_correndo = false
	
	# Aplica movimento horizontal
	if pode_se_mover:
		var velocidade_atual = velocidade
		
		# Aplica multiplicador de corrida se estiver correndo
		if esta_correndo:
			velocidade_atual *= multiplicador_corrida
		
		velocity.x = direcao_x * velocidade_atual
	else:
		velocity.x = 0
	
	move_and_slide()
	atualizar_animacoes()

# -- Função de Dano --
func dano_jogador() -> void:
	if morto:
		return
		
	# Aplica dano
	vida_atual -= 1
	vida_alterada.emit(vida_atual)
	
	print("Jogador Tomou dano Vida: ", vida_atual)
	
	# Verifica morte
	if vida_atual <= 0:
		morrer()
		return
	
	# Efeito de piscar ao tomar dano
	comecar_piscar()

func comecar_piscar() -> void:
	# Pisca o sprite por 0.5 segundos
	var duracao_piscar = 0.5
	var tempo_decorrido = 0.0
	var intervalo_piscar = 0.1
	
	while tempo_decorrido < duracao_piscar:
		sprite_animado.visible = !sprite_animado.visible
		await get_tree().create_timer(intervalo_piscar).timeout
		tempo_decorrido += intervalo_piscar
	
	# Garante que fique visível no final
	sprite_animado.visible = true

func curar(cura: int = 1) -> void:
	vida_atual = min(vida_atual + cura, vida_maxima)
	vida_alterada.emit(vida_atual)
	print("Jogador curado! Vida: ", vida_atual)

func atualizar_animacoes() -> void:
	if morto:	
		return
	
	# Atualiza direção do sprite baseado no input ou velocidade
	var direcao_x = 0.0
	
	# Prioriza o input de corrida para determinar a direção
	if Input.is_action_pressed("runnin_direita"):
		direcao_x = 1.0
	elif Input.is_action_pressed("running_esquerda"):
		direcao_x = -1.0
	else:
		# Usa o axis normal se não estiver correndo
		direcao_x = Input.get_axis("walk_esquerda", "walk_direita")
	
	# Vira o sprite baseado na direção
	if direcao_x > 0:
		sprite_animado.flip_h = false
	elif direcao_x < 0:
		sprite_animado.flip_h = true
	
	if is_on_floor():
		if velocity.x != 0:
			# Andando ou correndo
			if esta_correndo:
				sprite_animado.play("run")
			else:
				sprite_animado.play("run")
		else:
			# Parado
			sprite_animado.play("idle")
	else:
		# No ar
		if velocity.y < 0:
			sprite_animado.play("jump")
		else:
			sprite_animado.play("jump")

func morrer() -> void:
	if morto:
		return
	morto = true
	velocity = Vector2.ZERO
	print("Jogador foi morto")
	
	if sprite_animado.has_animation("morte"):
		sprite_animado.play("morte")
	
	await get_tree().create_timer(2).timeout
	get_tree().reload_current_scene()

func _exit_tree() -> void:
	pass
