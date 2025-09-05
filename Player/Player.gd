extends KinematicBody2D

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120
export var FRICTION = 500

export var MAX_STAMINA = 100
export var ROLL_STAMINA_COST = 20
export var STAMINA_REGEN_RATE = 10  # Stamina regained per second

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var stamina = MAX_STAMINA  
var enemiesCount = 0

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var bgmusic = $bgmusic
onready var staminaRegenTimer = $StaminaRegenTimer  
onready var staminaDisplay = get_tree().get_root().find_node("staminaDisplay", true, false)  
onready var healEffect = $Effects
onready var warning = $warning
onready var enemyCountLabel = $warning/message

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector
	bgmusic.play()

	update_stamina()
	healEffect.visible = false
	warning.hide()
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move()

	# Rolling only if enough stamina
	if Input.is_action_just_pressed("Roll") and stamina >= ROLL_STAMINA_COST:
		state = ROLL
		stamina -= ROLL_STAMINA_COST  # Deduct stamina
		staminaRegenTimer.start()  # Restart stamina regen timer
		update_stamina()

	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func move():
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	velocity *= 0.8
	state = MOVE

func attack_animation_finished():
	state = MOVE

func _on_Hurtbox_area_entered(area):
	if state == ROLL:
		return

	stats.health -= area.damage
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)

func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")

func _on_StaminaRegenTimer_timeout():
	stamina = min(stamina + STAMINA_REGEN_RATE, MAX_STAMINA)
	if stamina < MAX_STAMINA:
		staminaRegenTimer.start()
	update_stamina()

func update_stamina():
	if staminaDisplay and staminaDisplay.has_method("update_stamina"):
		staminaDisplay.update_stamina(stamina)


func healEffects():

	healEffect.visible = true
	healEffect.play("heal")
	yield(healEffect, "animation_finished")
	healEffect.visible = false


func _on_EnemyDetector_body_entered(body):
	return
	warning.show()
	enemiesCount += 1
	enemyCountLabel.text = str(enemiesCount) + " Enemies Nearby"


func _on_EnemyDetector_body_exited(body):
	return
	enemiesCount -= 1
	if enemiesCount <= 0:
		warning.hide()
		enemyCountLabel.text = str(enemiesCount) + " Enemies Nearby"
