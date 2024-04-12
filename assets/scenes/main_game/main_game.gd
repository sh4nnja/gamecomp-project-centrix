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
var _resource: Resource = load("res://assets/objects/map/resources/base_resource.tscn")
var _false_resource: Resource = load("res://assets/objects/enemies/pseudo/pseudo.tscn")

# Chance of the resource to spawn. Example, there are 1 in 20 chance of spawning.
# Amount of favorable outcome / Amount of all outcomes = Chance.
# Don't make this lower than 10, it will go just fine, but slow loading.
var _resource_spawn_chance: int = TRUE_RESOURCE

# GOOZ *************************************************************************
var _gooz: Resource = load("res://assets/objects/enemies/gooz/gooz.tscn")

# Enum to know where the cell can spawn on this particular cell.
enum {
	CELL_CAN_SPAWN = 0,
	TOXIC_LAKE = 2
}

# Enum to know what kind of stone will it spawn, a false stone or an actual resource stone.
enum {
	FALSE_RESOURCE = 0,
	TRUE_RESOURCE = 45,
}

# Enum for Gooz Spawning.
enum {
	GOOZ_SPAWN = 0,
	TOXIC_GOOZ = 35
}

enum {
	ITEM = 300
}

# ITEM *************************************************************************
var _centennium_collection: Resource = load("res://assets/objects/map/items/centennium_collection.tscn")
var _item_count: int = 0

# Item spawn chance.
var _item_chance: int = ITEM

# The items.
var items: Array = []

# Get the position of the resources.
var _resource_spots_taken: Array[Vector2i] = []

# Position of the items.
var _item_spots_taken: Array[Vector2i] = []

# NODES ************************************************************************
@onready var _map: TileMap = get_node("world/map")
@onready var objects: Node2D = get_node("objects")

@onready var slix: CharacterBody2D = get_node("objects/slix")
@onready var _byte: CharacterBody2D = get_node("objects/byte")

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

# GAME UPDATES *****************************************************************
var slix_health: float
var slix_immunity: float

var byte_connected: bool 

var items_collected: int

# VIRTUAL **********************************************************************
func _ready() -> void:
	_manage_resources() # Spawn resources.
	_manage_toxic_lake() # Spawn Gooz across toxic lake.
	_manage_items()
	
	# For Debug.
	print("Items spawned: " + str(_item_count) + " / 100")
	print("Resources spawned (Fake and Real Resources): " + str(_resource_spots_taken.size()))

func _physics_process(_delta) -> void:
	_update_byte()
	_update_slix_stats() # Update slix stats such as health etc.
	_damage_toxic_lake(slix) # Damage Slix when in contact of the toxic lake.

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
		objects.add_child(_res_obj, true)
		_res_obj.set_global_position(to_global(_map.map_to_local(_tile_pos)))
		
		# Uploads the position to make sure no other items will spawn.
		_resource_spots_taken.append(_tile_pos)
	
	# Spawn Pseudo.
	elif _rng.randi_range(0, _resource_spawn_chance) == FALSE_RESOURCE:
		var _res_obj: Object = _false_resource.instantiate()
		
		# Add the resource object to the game.
		objects.add_child(_res_obj, true)
		_res_obj.set_global_position(to_global(_map.map_to_local(_tile_pos)))
		
		# Uploads the position to make sure no other items will spawn.
		_resource_spots_taken.append(_tile_pos)

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
		objects.add_child(_gooz_inst, true)
		_gooz_inst.set_global_position(to_global(_map.map_to_local(_tile_pos)))

func _manage_items() -> void:
	# Loop through each tile.
	for _tile in _map.get_used_cells(1):
		if not _resource_spots_taken.has(_tile):
			_spawn_items(_tile)

# Spawn the 100 items.
func _spawn_items(_tile_pos: Vector2i) -> void:
	_rng.randomize()
	
	if _item_count < 100:
		if _rng.randi_range(0, _item_chance) == ITEM:
			var _item_obj: Object = _centennium_collection.instantiate()
			
			# Add the resource object to the game.
			objects.add_child(_item_obj, true)
			_item_obj.set_item(_item_count)
			_item_obj.set_global_position(to_global(_map.map_to_local(_tile_pos)))
			
			# Get their unique identifiers for tracking.
			items.append(get_node(_item_obj.get_path()))
			_item_spots_taken.append(_tile_pos)
			
			_item_count += 1

# Toxic Lake.
func _damage_toxic_lake(_node: Node) -> void:
	# Gets the player position to check if its on the toxic lake tile.
	var _tile_data: int = _map.get_cell_source_id(2, _map.local_to_map(_node.get_position()))
	var _tile_data_2: int = _map.get_cell_source_id(0, _map.local_to_map(_node.get_position()))
	if (_tile_data == GOOZ_SPAWN or _tile_data == TOXIC_LAKE) or (_tile_data_2 == GOOZ_SPAWN or _tile_data_2 == TOXIC_LAKE):
		# Add toxic lake damage.
		_node.toxic_lake_deduction()

# Get Slix stats.
func _update_slix_stats() -> void:
	slix_health = slix.health
	slix_immunity = slix.reduced_toxicity
	items_collected = slix.item_collected

# Get Byte if connected.
func _update_byte() -> void:
	byte_connected = _byte.connected

# Get the nearest node. For Items.
func get_nearest_node(_nodes: Array, _player: Node) -> Array:
	var _output: Array
	var _nearest_node: Node = null
	var _nearest_distance = INF 
	
	for _node in _nodes:
		if _node:
			var _distance = _player.global_position.distance_to(_node.global_position)
			if _distance < _nearest_distance:
				_nearest_distance = _distance
				_nearest_node = _node
	
	_output = [_nearest_node,  _nearest_distance]
	return _output

# Pause tree.
func pause(_enabled: bool) -> void:
	get_tree().set_pause(_enabled)

