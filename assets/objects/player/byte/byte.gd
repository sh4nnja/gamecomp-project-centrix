# ******************************************************************************
# byte.gd
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
# Advisers
# Paulo Edrozo
# ******************************************************************************

extends CharacterBody2D

# NODES ************************************************************************
@onready var _anim_blend: AnimationTree = get_node("anim_blend")

# PHYSICS **********************************************************************
# Speed.
const SPEED: float = 35.0

# Distance before follow Slix.
var _chase_threshold: int = 20

# Slix.
var _slix: CharacterBody2D = null

# Current velocity.
var _vel: Vector2 = Vector2.ZERO

# VIRTUAL **********************************************************************
func _ready() -> void:
	# Enable animation.
	_anim_blend.set_active(true)
	
	# Get Slix to be followed.
	_get_slix()

func _physics_process(_delta: float) -> void:
	_manage_movement(_delta)
	_manage_animation()

# CUSTOM ***********************************************************************
# Find Slix in world.
func _get_slix() -> void:
	_slix = get_parent().get_node("slix")

# Movement handler.
func _manage_movement(_delta: float) -> void:
	velocity = Vector2.ZERO
	
	# Moves Byte when Slix is faraway.
	if position.distance_to(_slix.global_position) > _chase_threshold and _slix != null:
		velocity = position.direction_to(_slix.global_position) * SPEED
		_vel = velocity.normalized()
	
	move_and_slide()

func _manage_animation() -> void:
	_anim_blend.set("parameters/float/blend_position", _vel)
