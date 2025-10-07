extends CharacterBody2D

class_name Player

# -- Configurações de movimento --
@export var velocidade: float = 80.0
@export var multiplicador_corrida: float = 5.0
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
var invencivel: bool = false
@export var tempo_invencibilidade: float = 1.0

func _ready() -> void:
	vida_atual = vida_maxima
	# Garante que comece com a animação idle
	sprite_animado.play("idle")

func _physics_process(delta: float) -> void:
	if morto:
		return
	
	print("is_on_floor(): ", is_on_floor(), " | Velocity Y: ", velocity.y)

	# Jumping
	if not is_on_floor():
		velocity.y += gravidade * delta
	else:
		velocity.y = 0  # Reseta a gravidade quando no chão
		
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -forca_pulo #pula!
	
	
	
	# Pausa movimentação durante ações
	if esta_atirando:
		velocity.x = 0
		move_and_slide()
		# Atualiza animação mesmo quando atirando
		atualizar_animacoes()
		return
	
	# Verifica inputs de movimento
	var direcao_x = Input.get_axis("walk_esquerda", "walk_direita")
	
	# Aplica movimento horizontal
	if pode_se_mover:
		velocity.x = direcao_x * velocidade
	else:
		velocity.x = 0
	
	move_and_slide()
	atualizar_animacoes()

func atualizar_animacoes() -> void:
	if morto:
		return
		
	if is_on_floor():
		if velocity.x != 0:
			# Andando/correndo
			sprite_animado.play("run")
			# Vira o sprite na direção do movimento
			if velocity.x > 0:
				sprite_animado.flip_h = false
			elif velocity.x < 0:
				sprite_animado.flip_h = true
		else:
			# Parado
			sprite_animado.play("idle")
	else:
		# No ar
		if velocity.y < 0:
			sprite_animado.play("jump")  # Subindo
		else:
			sprite_animado.play("jump")  # Descendo (ou "fall" se tiver)

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
