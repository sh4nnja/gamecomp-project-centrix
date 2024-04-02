# ******************************************************************************
# main_game.gd
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
# Benjamin Delos Santos
# Albert Alforja
# ******************************************************************************

extends Node2D

# RESOURCE TYPES ***************************************************************
# Resource object.
var _resource: Resource = load("res://assets/objects/resources/base_resource.tscn")

# Enum to know that the cell can spawn on this particular cell.
enum {
	CELL_CAN_SPAWN = 0
}

# The max amount of resource to be spawned at the map.
var _resource_max_amount: int = 2500

# Chance of the resource to spawn. Example, there are 0 to 50 chance of spawning.
# Favorable outcome (We need 0 to spawn) / 50 = 0.02 chance of spawning.
var _resource_spawn_chance: int = 35

# Count of spawned resources.
var _counter: int = 0

# NODES ************************************************************************
@onready var _map: TileMap = get_node("world/map")
@onready var _objects: Node2D = get_node("objects")

# VIRTUAL **********************************************************************
func _ready():
	# Spawn resources.
	_manage_resources()

# CUSTOM ***********************************************************************
# Resource spawning manager.
func _manage_resources() -> void:
	# Loop through each tile.
	for _tile in _map.get_used_cells(1):
		if _check_spawn_valid(_tile):
			_spawn_resources(_tile, _counter)
	
	print(_counter)

# Checks if the tile / cell is valid for resource spawning.
func _check_spawn_valid(_tile_pos: Vector2i) -> bool:
	var _output: bool = false
	# Gets if that tile / cell is from ID 0, or the tiles capable of spawning.
	if _map.get_cell_source_id(1, _tile_pos) == CELL_CAN_SPAWN:
		_output = true
	
	return _output

# Spawns the resources.
func _spawn_resources(_tile_pos: Vector2i, _spawn_count: int) -> void:
	var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
	
	# Makes sure that the spawn count is less that resource count.
	if _spawn_count < _resource_max_amount:
		_rng.randomize()
		if _rng.randi_range(0, _resource_spawn_chance) == 0:
			var _res_obj: Object = _resource.instantiate()
			
			# Add the resource object to the game.
			_objects.add_child(_res_obj, true)
			_res_obj.set_global_position(to_global(_map.map_to_local(_tile_pos)))
			
			# Update counter.
			_counter += 1
