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

# PHYSICS **********************************************************************
# Speed.
const SPEED: float = 55.0

# Distance before follow Slix.
var _chase_threshold: int = 20

# Current velocity.
var _vel: Vector2 = Vector2.ZERO

# SKILLS ***********************************************************************
# Checks if Slix is in range.
var _detected_enemy: CharacterBody2D = null
var _can_chase: bool = false

var _attack: bool = false

var health: float = 100.0

# NODES ************************************************************************
@onready var _anim_blend: AnimationTree = get_node("anim_blend")
@onready var _anim_alert: AnimatedSprite2D = get_node("alert")

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
	if _detected_enemy != null:
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
		if _attack:
			_anim_blend.get("parameters/playback").travel("attack")
			_anim_blend.set("parameters/attack/blend_position", _vel)
		else:
			# Check if there's movement.
			if _vel == Vector2.ZERO:
				# Set the frame to freeze.
				_anim_blend.get("parameters/playback").travel("idle")
				_anim_blend.set("parameters/idle/blend_position", _vel)
			else:
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
	
func _die() -> void:
	queue_free()

# SIGNALS **********************************************************************
func _on_detection_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		_detected_enemy = _body
		_anim_alert.play("alert")

func _on_detection_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		_detected_enemy = null
		_anim_alert.play_backwards("alert")

# Attack on contact.
func _on_attack_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Slix") or _detected_enemy:
		_attack = true

func _on_attack_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("Slix") or _detected_enemy:
		_attack = false
