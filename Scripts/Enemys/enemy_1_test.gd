extends CharacterBody2D

@onready var shoot_point: Marker2D = $shoot_point

@export var velocidade = 80.0
@export var distance_perseguir := 200.0
@export var distance_minima := 60.0
@export var projectile_scene: PackedScene 

@onready var anim = $AnimatedSprite2D

@export var vida_maxima := 3
var vida_atual: int

@onready var hitbox = $hitbox

var morto := false
var player : Node2D = null
var pode_atirar := true

func _ready():
	vida_atual = vida_maxima
	print("Vida atual:", vida_atual)
	
func _physics_process(delta):
	if morto:
		return #Bloqueia se já morreu
	
	if player == null:
		anim.play("idle")
		velocity = Vector2.ZERO
		return
	
	var direction = player.global_position - global_position
	var distance = direction.length()
	
	if distance > distance_perseguir:
		velocity = Vector2.ZERO
		anim.play("idle")
	elif distance < distance_minima:
		velocity = Vector2.ZERO
		anim.play("shoot")
		shoot()
	else:
		direction = direction.normalized()
		velocity = direction * velocidade
		move_and_slide()
		anim.flip_h = direction.x < 0
		anim.play("run")
	
	if vida_atual == 0:
		dying()
		
func shoot():
	if not pode_atirar or projectile_scene == null or player == null:
			return
	
	pode_atirar = false
	
	var proj = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	
	proj.global_position = shoot_point.global_position
	proj.initialize((player.global_position - shoot_point.global_position).normalized())
	
	await get_tree().create_timer(0.8).timeout
	pode_atirar = true

func damage():
	vida_atual -= 1

func dying():
	if morto:
		return
	morto = true
	print ("morri")
	velocity = Vector2.ZERO
	anim.play("death")
	await get_tree().create_timer(2).timeout
	queue_free()
	#music.stop()

func _on_hitbox_body_entered(body):
	if body.is_in_group("projetil"):
		body.queue_free()

func _on_player_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		shoot()
		#music.play() se tiver som de combate
