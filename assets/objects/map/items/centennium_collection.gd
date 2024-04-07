# ******************************************************************************
# centennium_collection.gd
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

# NODES ************************************************************************
@onready var _texture: AnimatedSprite2D = get_node("texture")
@onready var _shape: CollisionShape2D = get_node("shape")

# ITEM NUMBER ******************************************************************
var item_number: int = 0
var item_name: String = ""
var item_description: String = ""

# VIRTUAL **********************************************************************
func _ready() -> void:
	_set_item()

# CUSTOM ***********************************************************************
func _set_item() -> void:
	_texture.set_frame(item_number)
	item_name = ""
	item_description = ""
 
func recover() -> int:
	queue_free()
	return item_number
