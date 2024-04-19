# ******************************************************************************
# flooze.gd
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
const SPEED: float = 35.0

var _chase_threshold: int = 20 # Distance before follow Slix.

var _vel: Vector2 = Vector2.ZERO # Current velocity.

# SKILLS ***********************************************************************
var _detected_enemy: CharacterBody2D = null
var _explode: bool = false

var _attack_damage: float = 15.0
var health: float = 20.0
var hit: float = 20.0

# NODES ************************************************************************
@onready var _anim_blend: AnimationTree = get_node("anim_blend")
@onready var _anim_alert: AnimatedSprite2D = get_node("alert")
@onready var _texture: AnimatedSprite2D = get_node("texture")
@onready var _toxic_fx: CPUParticles2D = get_node("toxic_fx")
@onready var _shape: CollisionShape2D = get_node("shape")

@onready var _sound: AudioStreamPlayer2D = get_node("sound")

# VIRTUAL **********************************************************************
func _ready() -> void:
	# Enable animation.
	_anim_blend.set_active(true)

func _physics_process(_delta: float) -> void:
	_manage_movement(_delta)
	_manage_animation()

# CUSTOM ***********************************************************************
# Movement handler.
func _manage_movement(_delta: float) -> void:
	velocity = Vector2.ZERO
	
	# Chase Slix.
	if _detected_enemy != null and not _explode:
		if position.distance_to(_detected_enemy.global_position) > _chase_threshold:
			velocity = position.direction_to(_detected_enemy.global_position) * SPEED
			_vel = velocity.normalized()
	
	move_and_slide()

# Animation handler.
func _manage_animation() -> void:
	if not _explode:
		_anim_blend.get("parameters/playback").travel("idle")
		_anim_blend.set("parameters/idle/blend_position", _vel)
		
		_explode = health <= 0
	else:
		_shape.set_disabled(true)
		_anim_blend.get("parameters/playback").travel("explode")
		_anim_blend.set("parameters/explode/blend_position", _vel)

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
	health -= hit * _multiplier

func die() -> void:
	_anim_alert.play_backwards("alert")
	await _anim_alert.animation_finished
	queue_free()

func explode() -> void:
	_toxic_fx.set_emitting(true)
	if _detected_enemy:
		_detected_enemy.damage(_damage_by_dist())

# Calculate damage based on distance.
func _damage_by_dist() -> float:
	var _output: float = 0
	var _norm_dist = global_position.distance_to(_detected_enemy.global_position) / 75
	var _falloff = 1.0 - pow(_norm_dist, 2)
	
	_output = _attack_damage * _falloff
	# Moves back to 0 if damage is negative.
	if _output < 0:
		_output = 0
	
	return _output

# SIGNALS **********************************************************************
func _on_detection_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		_detected_enemy = _body
		set_collision_mask_value(2, true)
		_anim_alert.play("alert")

func _on_detection_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		_detected_enemy = null
		set_collision_mask_value(2, false)
		_anim_alert.play_backwards("alert")

# Explode on contact.
func _on_attack_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		_explode = true
		_anim_alert.play_backwards("alert")
		await _anim_alert.animation_finished
		_anim_alert.hide()
