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
# Adviser
# Paulo Edrozo
# ******************************************************************************

extends Node2D

# RESOURCE TYPES ***************************************************************
# Resource object.
var _resource: Resource = load("res://assets/objects/map/resources/base_resource.tscn")
var _false_resource: Resource = load("res://assets/objects/enemies/pseudo/pseudo.tscn")

# GOOZ *************************************************************************
var _gooz: Resource = load("res://assets/objects/enemies/gooz/gooz.tscn")

# Enum to know where the cell can spawn on this particular cell.
enum {
	CELL_CAN_SPAWN = 0,
	CELL_TOXIC = 2
}

# Enum to know what kind of stone will it spawn, a false stone or an actual resource stone.
enum {
	FALSE_RESOURCE = 0,
	TRUE_RESOURCE = 75,
}

# Enum for Gooz Spawning.
enum {
	GOOZ_SPAWN = 2,
	TOXIC_GOOZ = 35
}

# Chance of the resource to spawn. Example, there are 1 in 20 chance of spawning.
# Amount of favorable outcome / Amount of all outcomes = Chance.
# Don't make this lower than 10, it will go just fine, but slow loading.
var _resource_spawn_chance: int = TRUE_RESOURCE

# NODES ************************************************************************
@onready var _map: TileMap = get_node("world/map")
@onready var _objects: Node2D = get_node("objects")

@onready var _slix: CharacterBody2D = get_node("objects/slix")

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

# GAME UPDATES *****************************************************************
var slix_health: float
var items_collected: int

# VIRTUAL **********************************************************************
func _ready() -> void:
	# Spawn resources.
	_manage_resources()
	
	# Spawn Gooz across toxic lake.
	_manage_toxic_lake()

func _physics_process(_delta) -> void:
	_damage_toxic_lake(_slix)

# CUSTOM ***********************************************************************
# Resource spawning manager.
func _manage_resources():
	# Loop through each tile.
	for _tile in _map.get_used_cells(1):
		if _check_spawn_valid(_tile):
			_spawn_resources(_tile)

# Checks if the tile / cell is valid for resource spawning.
func _check_spawn_valid(_tile_pos: Vector2i) -> bool:
	var _output: bool = false
	# Gets if that tile / cell is from ID 0, or the tiles capable of spawning.
	if _map.get_cell_source_id(1, _tile_pos) == CELL_CAN_SPAWN:
		_output = true
	return _output

# Spawns the resources.
func _spawn_resources(_tile_pos: Vector2i) -> void:
	_rng.randomize()
	
	# Spawn resource.
	if _rng.randi_range(0, _resource_spawn_chance) == TRUE_RESOURCE:
		var _res_obj: Object = _resource.instantiate()
		
		# Add the resource object to the game.
		_objects.add_child(_res_obj, true)
		_res_obj.set_global_position(to_global(_map.map_to_local(_tile_pos)))
	
	# Spawn the Arachnoxenomorph.
	elif _rng.randi_range(0, _resource_spawn_chance) == FALSE_RESOURCE:
		var _res_obj: Object = _false_resource.instantiate()
		
		# Add the resource object to the game.
		_objects.add_child(_res_obj, true)
		_res_obj.set_global_position(to_global(_map.map_to_local(_tile_pos)))

# Spawn Gooz on toxic lakes randomly.
func _manage_toxic_lake() -> void:
	# Loop through each tile.
	for _tile in _map.get_used_cells(2):
		_spawn_gooz(_tile)

# Spawns the slime.
func _spawn_gooz(_tile_pos: Vector2i) -> void:
	_rng.randomize()
	
	# Spawn resource.
	if _rng.randi_range(0, TOXIC_GOOZ) == TOXIC_GOOZ:
		var _gooz_inst: Object = _gooz.instantiate()
		
		# Add the resource object to the game.
		_objects.add_child(_gooz_inst, true)
		_gooz_inst.set_global_position(to_global(_map.map_to_local(_tile_pos)))

# Toxic Lake.
func _damage_toxic_lake(_node: Node) -> void:
	# Gets the player position to check if its on the toxic lake tile.
	var _tile_data: int = _map.get_cell_source_id(0, _map.local_to_map(_node.get_position()))
	if _tile_data == CELL_TOXIC or _tile_data == GOOZ_SPAWN:
		pass
