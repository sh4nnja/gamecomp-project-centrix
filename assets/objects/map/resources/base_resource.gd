# ******************************************************************************
# base_resource.gd
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

extends StaticBody2D

# NODES ************************************************************************
@onready var _texture: AnimatedSprite2D = get_node("texture")
@onready var _shape: CollisionShape2D = get_node("shape")

# RESOURCE TYPES ***************************************************************
# High value resource chance.
var _high_tier_chance: int = 5

# Type of the resource.
# A single object that contains all the types of resources are finalized to save time.
var _type: int = 0

# Collection of resource values per each type of resource.
#var _resource_values: Array[Vector2] = [
	#
#]

# Value.
var value: Array = []

# COLLISION SIZE ***************************************************************
# Preset collision size and position for the resources.
var _collision_sizes: Array[Array] = [
	[Vector2(21, 5), Vector2(-0.5, 9.5)],
	[Vector2(15, 4), Vector2(-0.5, 8)],
	[Vector2(16, 3), Vector2(0, 4.5)],
	[Vector2(17, 4), Vector2(-0.5, 9)],
	[Vector2(20, 10), Vector2(0, 6)],
	[Vector2(20, 10), Vector2(0, 6)],
	[Vector2(20, 10), Vector2(0, 6)],
	[Vector2(20, 10), Vector2(0, 6)],
	[Vector2(20, 10), Vector2(0, 6)]
]

# VIRTUAL **********************************************************************
func _ready() -> void:
	_manage_resource_type()

# CUSTOM ***********************************************************************
# Manage type of resource.
func _manage_resource_type() -> void:
	# Gets a random resource.
	_type = _randomize_resource()
	
	# Sets the texture of that item.
	_texture.set_frame(_type)
	_shape.get_shape().set_size(_collision_sizes[_type][0])
	_shape.set_position(_collision_sizes[_type][1])

# Randomize type for a resource.
func _randomize_resource() -> int:
	var _output: int
	var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
	_rng.randomize()
	
	if _rng.randi_range(0, _high_tier_chance) == _high_tier_chance:
		_output = _rng.randi_range(0, 3)
	else:
		_output = _rng.randi_range(4, 8)
	
	return _output
