# ******************************************************************************
#  keybind.gd
# ******************************************************************************
#                             This file is part of
#                                   Centrix
# ******************************************************************************
# Copyright (c) 2024-present University of Cabuyao
# 
# Developer 
# Shannja Ashley Malelang
#
# Advisers
# Paulo Edrozo
# Benjamin Delos Santos
# Albert Alforja
# ******************************************************************************

extends CharacterBody2D

# NODES ************************************************************************
@onready var _anim_blend: AnimationTree = get_node("anim_blend")

@onready var _rfx_blur: CPUParticles2D = get_node("roll_fx/blur")
@onready var _rfx_trail: CPUParticles2D = get_node("roll_fx/trail")

# PHYSICS **********************************************************************
# Speed.
const SPEED: float = 50.0

# Rolling Speed Mult.
const ROLL_SPEED_MULT: float = 2

# Current velocity.
var _vel: Vector2 = Vector2.ZERO

# Facilitates rolling.
var _enabled_roll: bool = false

# VIRTUAL **********************************************************************
func _ready() -> void:
	# Enable animation.
	_anim_blend.set_active(true)

func _physics_process(_delta: float) -> void:
	_manage_movement(_delta)
	_manage_animation()
	_manage_effects()

# CUSTOM ***********************************************************************
# Movement handler.
func _manage_movement(_delta: float) -> void:
	_vel = Vector2.ZERO
	
	# Take note of the movement.
	# Movement left to right.
	_vel.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	_vel.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	# Rolling.
	if Input.is_action_pressed("roll"):
		_enabled_roll = true
	elif Input.is_action_just_released("roll"):
		_enabled_roll = false
	
	# Apply the velocity and move.
	if _enabled_roll:
		velocity = _vel.normalized() * SPEED * ROLL_SPEED_MULT
	else:
		velocity = _vel.normalized() * SPEED
	
	move_and_slide()

# Animation handler.
func _manage_animation() -> void:
	# Movement and Idle.
	if _vel == Vector2.ZERO:
		_anim_blend.get("parameters/playback").travel("idle")
	else:
		# Set the frame to freeze.
		_anim_blend.set("parameters/idle/blend_position", _vel)
		
		# Animation for running.
		_anim_blend.get("parameters/playback").travel("running")
		_anim_blend.set("parameters/running/blend_position", _vel)
	
	# Transform to roll.
	if _enabled_roll:
		_anim_blend.get("parameters/playback").travel("rolling")

# Effect handler.
func _manage_effects() -> void:
	# Set trail whenever rolling is enabled.
	if _enabled_roll:
		# Checks if moving to enable the fx.
		var _is_moving: bool = true if _vel != Vector2.ZERO else false
		_rfx_trail.set_emitting(_is_moving)
		_rfx_blur.set_emitting(_is_moving)
	
	# Disable fx whenever rolling is not enabled.
	else:
		_rfx_trail.set_emitting(_enabled_roll)
		_rfx_blur.set_emitting(_enabled_roll)
