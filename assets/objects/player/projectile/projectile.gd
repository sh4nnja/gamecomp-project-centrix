# ******************************************************************************
# projectile.gd
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

extends Area2D

# NODES ************************************************************************
@onready var _texture: Sprite2D = get_node("texture")

# PHYSICS **********************************************************************
const SPEED = 350

# VIRTUAL **********************************************************************
func _physics_process(_delta: float) -> void:
	_manage_movement(_delta)

# CUSTOM ***********************************************************************
func _manage_movement(_delta: float) -> void:
	position += transform.x * SPEED * _delta

func change_texture(_color: Color):
	_texture.modulate = _color

func _remove_bullet() -> void:
	queue_free()

# SIGNALS **********************************************************************
func _on_body_entered(_body: Node2D) -> void:
	if not _body.is_in_group("Slix") and not _body.is_in_group("Resource") and not _body.is_in_group("Items"):
		_body.damage()
		queue_free()
