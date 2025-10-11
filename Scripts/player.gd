extends CharacterBody2D

class_name Player

# -- Configurações de movimento --
@export var velocidade: float = 80.0
@export var multiplicador_corrida: float = 2.0
@export var forca_pulo: float = 200.0
@export var gravidade: float = 600.0

# -- Referências e Especial --
@onready var sprite_animado: AnimatedSprite2D = $animation_player
@onready var fantasma: Fantasma = $Fantasma
@onready var linha: Line2D = $Line2D
@export var time_max: float = 1.5
@export var distancia_max: float = 200.0

var especial_possessao := false
var time_holding := 0.0

@onready var shoot_point: Node2D = $ShootPoint
@onready var shoot_point_position_x = shoot_point.position.x

# -- Sistema de vida --
@export var vida_maxima: int = 30
@export var vida_atual: int = vida_maxima

# -- Sistema de tiro --
@export var projectile_scene: PackedScene
var pode_atirar: bool = true
var municao = 10
var municao_maxima = 10
var municao_pente = 5
var pentes = 1

# -- Sons --

# -- Variáveis de controle --
var pode_interagir: bool = true
var animacao_parado: String = "idle"
var pode_se_mover: bool = true
var esta_correndo: bool = false
var esta_atirando: bool = false
var morto: bool = false

# -- Sinais --
signal vida_alterada(vida_atual)

func _ready() -> void:
	vida_atual = vida_maxima
	vida_alterada.emit(vida_atual)
	sprite_animado.play("idle")
	
	if sprite_animado.sprite_frames.has_animation("jump"):
		sprite_animado.sprite_frames.set_animation_loop("jump", false)

	if fantasma:
		fantasma.modo_ataque = false
		fantasma.cursor_posicao = fantasma.global_position

func _physics_process(delta: float) -> void:
	if vida_atual <= 0:
		morrer()
	
	if morto:
		return
	
	# Aplica gravidade
	if not is_on_floor():
		velocity.y += gravidade * delta
	else:
		velocity.y = 0
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -forca_pulo
	
	# Verifica inputs de movimento
	var direcao_x = 0.0
	
	if Input.is_action_pressed("runnin_direita"):
		direcao_x = 1.0
		esta_correndo = true
	elif Input.is_action_pressed("running_esquerda"):
		direcao_x = -1.0
		esta_correndo = true
	else:
		direcao_x = Input.get_axis("walk_esquerda", "walk_direita")
		esta_correndo = false
	
	# Aplica movimento horizontal
	if pode_se_mover:
		var velocidade_atual = velocidade
		if esta_correndo:
			velocidade_atual *= multiplicador_corrida
		velocity.x = direcao_x * velocidade_atual
	else:
		velocity.x = 0
	
	move_and_slide()
	
	#Atualiza a linha entre o jogador e fantasma
	atualizar_line()
	

	# -------------------------
	# Ataque de possessão
	# -------------------------
	if Input.is_action_pressed("especial"):
		if not especial_possessao:
			especial_possessao = true
			time_holding = 0.0

		time_holding += delta
		var t = min(time_holding / time_max, 1.0)
		fantasma.modo_ataque = true
		fantasma.cursor_posicao = fantasma.global_position + Vector2(
	lerp(float(50), float(distancia_max), float(t)) * (-1 if sprite_animado.flip_h else 1),
	0
)
	elif especial_possessao:
		especial_possessao = false
		fantasma.iniciar_possessao()
		
func atualizar_line():
	if linha and fantasma:
		linha.clear_points()
		linha.add_point(Vector2.ZERO)
		linha.add_point(to_local(fantasma.global_position))
		linha.modulate.a = 0.4 + 0.2 * sin(Time.get_ticks_msec() / 250.0)

	# Controles de tiro
	if Input.is_action_just_pressed("shoot") and municao > 0:
		shoot()
		
	atualizar_animacoes()
	update_life()

# -- Dano do jogador --
func _on_hurtbox_area_entered(area: Area2D) -> void:
	var alvo = area.get_parent()
	if alvo.is_in_group("projetil_inimigo"):  # só projéteis do inimigo
		print("dano aplicado ao player via area:", alvo.name)
		dano_jogador()
		alvo.queue_free()


func _on_hurtbox_body_entered(body: Node2D) -> void:
	var alvo = body.get_parent()
	if alvo.is_in_group("projetil_inimigo") or alvo.is_in_group("inimigos"):
		print("dano aplicado ao player via body:", alvo.name)
		dano_jogador()
		if alvo.is_in_group("projetil_inimigo"):
			alvo.queue_free()

# -- Função de Dano --
func dano_jogador() -> void:
	if morto:
		return
		
	# Aplica dano
	vida_atual -= 10
	vida_alterada.emit(vida_atual)
	
	comecar_piscar()
	
	if vida_atual <= 0:
		morrer()
		
	
# Efeito de piscar ao tomar dano
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

func shoot():	
	if municao <= 0:
		return

	esta_atirando = true
	Global.tiros_do_jogador += 1
	municao -= 1

	# Instancia o projétil
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = shoot_point.global_position

	# Define direção do projétil
	var dir = Vector2.RIGHT if not sprite_animado.flip_h else Vector2.LEFT
	projectile.initialize(dir)

	if sprite_animado.sprite_frames.has_animation("jump"):
		sprite_animado.play("jump")
	
	await get_tree().create_timer(0.2).timeout
	esta_atirando = false


func update_life():
	if vida_atual == 3:
		pass
	if vida_atual == 2:
		pass
	if vida_atual == 1:
		pass
	if vida_atual == 0:
		#life_sprite.set_frame(1)
		morrer()

func atualizar_animacoes() -> void:
	if morto or esta_atirando:	
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
		shoot_point.position.x = shoot_point_position_x
	elif direcao_x < 0:
		sprite_animado.flip_h = true
		shoot_point.position.x = -shoot_point_position_x
	
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
	#if morto:
		#return
	morto = true
	velocity = Vector2.ZERO	
	
	if sprite_animado.sprite_frames.has_animation("idle"):
		sprite_animado.play("idle")
	
	await get_tree().create_timer(2).timeout
	
	get_tree().quit()

#func save_checkpoint():
	#checkpoint_position = global_position
	#print("Checkpoint salvo em:", checkpoint_position)
	
#func respawn_to_checkpoint():
	#global_position = checkpoint_position
	#print("Respawn para:", checkpoint_position)

#func _exit_tree() -> void:
	# Para todos os sons ao sair da cena para evitar que continuem tocando
	
