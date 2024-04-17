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

extends CharacterBody2D

# NODES ************************************************************************
@onready var _texture: AnimatedSprite2D = get_node("texture")

# RESOURCE TYPES ***************************************************************
# High value resource chance.
var _high_tier_chance: int = 5

# Type of the resource.
# A single object that contains all the types of resources are finalized to save time.
var _type: int = 0

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

# Randomize type for a resource.
func _randomize_resource() -> int:
	var _output: int
	var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
	_rng.randomize()
	_rng.set_seed(_rng.randi())
	
	if _rng.randi_range(0, _high_tier_chance) == _high_tier_chance:
		_rng.randomize()
		_rng.set_seed(_rng.randi())
		_output = _rng.randi_range(0, 13)
	else:
		_rng.randomize()
		_rng.set_seed(_rng.randi())
		_output = _rng.randi_range(14, 19)
	
	return _output

func recover() -> int:
	queue_free()
	return _type
