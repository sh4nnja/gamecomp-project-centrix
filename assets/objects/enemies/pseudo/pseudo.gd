# ******************************************************************************
# pseudo.gd
# ******************************************************************************
#                             This file is part of
#                                   Centrix
# ******************************************************************************
# Copyright (c) 2024-present University of Cabuyao
# 
# Developers
# Shannja Ashley Malelang
# Miccael Jasper Tayas
# Jhovic Cortel
#
# Adviser
# Paulo Edrozo
# ******************************************************************************

extends CharacterBody2D

# DAMAGE ***********************************************************************
var _damage_fx: Resource = load("res://assets/global/sounds/fx/385046__mortisblack__damage.ogg")

# PHYSICS **********************************************************************
const SPEED: float = 65.0

var _chase_threshold: int = 20 # Distance before follow Slix.

var _vel: Vector2 = Vector2.ZERO # Current velocity.

# SKILLS ***********************************************************************
var _detected_enemy: CharacterBody2D = null # Checks if Slix is in range.
var _can_chase: bool = false

var _attacking: bool = false

var health: float = 100.0
var _hit: float = 5.0
var _attack_damage: float = 10.0

# NODES ************************************************************************
@onready var _anim_blend: AnimationTree = get_node("anim_blend")
@onready var _anim_alert: AnimatedSprite2D = get_node("alert")
@onready var _texture: AnimatedSprite2D = get_node("texture")

@onready var _sound: AudioStreamPlayer2D = get_node("sound")

# VIRTUAL **********************************************************************
func _ready() -> void:
	_anim_blend.set_active(true) # Enable animation.

func _physics_process(_delta: float) -> void:
	_manage_movement(_delta)
	_manage_animation()

# CUSTOM ***********************************************************************
# Movement handler.
func _manage_movement(_delta: float) -> void:
	velocity = Vector2.ZERO
	
	# Chase Slix.
	if _detected_enemy:
		if position.distance_to(_detected_enemy.global_position) > _chase_threshold:
			if _can_chase:
				velocity = position.direction_to(_detected_enemy.global_position) * SPEED
				_vel = velocity.normalized()
	
	move_and_slide()

# Animation handler.
func _manage_animation() -> void:
	# Enemy Detected.
	if _detected_enemy:
		# If enemy is in range.
		if _attacking:
			_anim_blend.get("parameters/playback").travel("attack")
			_anim_blend.set("parameters/attack/blend_position", _vel)
		else:
			# Check if there's movement.
			if _vel == Vector2.ZERO:
				# Set the frame to freeze.
				_anim_blend.get("parameters/playback").travel("idle")
				_anim_blend.set("parameters/idle/blend_position", _vel)
			else:
				if not position.distance_to(_detected_enemy.global_position) < _chase_threshold * 2:
					_anim_blend.get("parameters/playback").travel("crawl")
					_anim_blend.set("parameters/crawl/blend_position", _vel)
			
			# Sets Pseudo to look at the player before morphing.
			_anim_blend.set("parameters/stone_to_idle/blend_position", _vel)
	
	else:
		_anim_blend.set("parameters/idle_to_stone/blend_position", _vel)
		_anim_blend.get("parameters/playback").travel("stone")
	
	# Enable monster to chase player when done transforming.
	if _anim_blend.get("parameters/playback").get_current_node() == "idle" or _anim_blend.get("parameters/playback").get_current_node() == "crawl":
		_can_chase = true
	else:
		_can_chase = false
	
	if health <= 0:
		_anim_blend.get("parameters/playback").travel("dead")
		_anim_blend.set("parameters/dead/blend_position", _vel)

func damage(_multiplier: int = 1) -> void:
	if not _sound.is_playing():
		_sound.set_stream(_damage_fx)
		_sound.play()
	else:
		if _sound.get_stream() != _damage_fx:
			_sound.set_stream(_damage_fx)
			_sound.play()
	
	_texture.modulate = Color.html("ff0000")
	await get_tree().create_timer(0.1).timeout
	_texture.modulate = Color.html("ffffff")
	health -= _hit * _multiplier

func die() -> void:
	_anim_alert.play_backwards("alert")
	await _anim_alert.animation_finished
	_anim_alert.hide()
	process_mode = Node.PROCESS_MODE_DISABLED

func attack() -> void:
	if _detected_enemy:
		_detected_enemy.damage(_attack_damage)

# SIGNALS **********************************************************************
func _on_detection_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		set_collision_mask_value(1, true)
		_detected_enemy = _body
		_anim_alert.play("alert")

func _on_detection_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		set_collision_mask_value(1, false)
		_detected_enemy = null
		_anim_alert.play_backwards("alert")

# Attack on contact.
func _on_attack_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		_attacking = true

func _on_attack_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		_attacking = false
