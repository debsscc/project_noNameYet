extends CharacterBody2D

@onready var shoot_point: Marker2D = $shoot_point

@export var velocidade := 150
@export var distancia_perseguir := 200.0
@export var distancia_minima := 60.0
@export var projectile_scene: PackedScene

@onready var anim = $AnimatedSprite2D
@onready var hitbox = $hitbox

@export var vida_maxima := 3
var vida_atual: int

var morto := false
var player: Node2D = null
var pode_atirar := true

func _ready():
	add_to_group("inimigos")
	vida_atual = vida_maxima

func _physics_process(delta):
	if morto:
		return  # Bloqueia tudo se já morreu
	
	if player == null:
		anim.play("idle")	
		velocity = Vector2.ZERO
		return

	var direcao = player.global_position - global_position
	var distancia = direcao.length()

	if distancia > distancia_perseguir:
		velocity = Vector2.ZERO
		anim.play("idle")
	elif distancia < distancia_minima:
		velocity = Vector2.ZERO
		anim.play("shoot")
		atirar()
	else:
		direcao = direcao.normalized()
		velocity = direcao * velocidade
		move_and_slide()
		anim.flip_h = direcao.x < 0
		anim.play("run")

	if vida_atual == 0:
		morrer()

func atirar():
	if not pode_atirar or projectile_scene == null or player == null:
		return

	pode_atirar = false

	var proj = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)

	proj.global_position = shoot_point.global_position
	proj.initialize((player.global_position - shoot_point.global_position).normalized())

	await get_tree().create_timer(0.8).timeout
	pode_atirar = true

func dano():
	vida_atual -= 1

func morrer():
	if morto:
		return
	morto = true
	velocity = Vector2.ZERO
	
	anim.play("death")
	await get_tree().create_timer(2).timeout
	queue_free()
	
func _on_hitbox_body_entered(body):
	if body.is_in_group("projetil"):
		dano() #da dano no inimigo
		body.queue_free() #faz sumir o projetil quando atinge o inimigo

func _on_player_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		atirar()
		
func _on_player_detection_area_body_exited(body):
	if body == player:
		player = null
