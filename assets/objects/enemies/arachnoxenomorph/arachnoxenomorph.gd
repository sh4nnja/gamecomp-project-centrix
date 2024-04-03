# ******************************************************************************
# arachnoxenomorph.gd
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

# PHYSICS **********************************************************************
# Speed.
const SPEED: float = 45.0

# Distance before follow Slix.
var _chase_threshold: int = 20

# Current velocity.
var _vel: Vector2 = Vector2.ZERO

# Checks if Slix is in range.
var _detected_enemy: CharacterBody2D = null
var _can_chase: bool = false

# NODES ************************************************************************
@onready var _anim_blend: AnimationTree = get_node("anim_blend")

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
		_anim_blend.get("parameters/playback").travel("idle")
		_anim_blend.set("parameters/idle/blend_position", _vel)
		
	else:
		_anim_blend.get("parameters/playback").travel("stone")
	
	# Enable monster to chase player when done transforming.
	if _anim_blend.get("parameters/playback").get_current_node() == "idle":
		_can_chase = true
	else:
		_can_chase = false

# SIGNALS **********************************************************************
func _on_detection_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		_detected_enemy = _body

func _on_detection_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("Slix"):
		_detected_enemy = null
