extends Node

# --- Player Stats ---
var player_health: int = 100
var max_health: int = 100

# --- Weapons & Ammo ---
var has_melee: bool = false
var has_ledge_grab:bool = false
var zombie_defeated:bool = false
var has_pistol: bool = false
var pistol_ammo: int = 10

var has_shotgun: bool = false
var shotgun_ammo: int = 0

# --- Progression ---
var has_keycard: bool = false
var current_room: String = "room_1"


var spawn_door:String = ''


#dials
var has_melee_dial: bool = false
var starting_dial:bool = true
