class_name Fighter
extends Node3D

var health: float
@onready var initial_health: float = health

var magic_resistance: float
var physics_resistance: float

var add_magic_resistance: float
var add_physics_resistance: float

var add_magic_damage: float
var add_physics_damage: float

var attacks: Array[Attack]

var fighter_name: String = ""

var power_up: float = 0

var dead: bool = false

func hit(atk: Attack, add_ph, add_mt):
#	health -= (dmg + power_up)
	var dmg = 0.0
	
	if atk.type == Attack.types.MAGIC:
		health -= ((atk.damage+add_mt) / (magic_resistance+add_magic_resistance))
		dmg = ((atk.damage+add_mt) / (magic_resistance+add_magic_resistance))
		
	if atk.type == Attack.types.PHYSIC:
		health -= ((atk.damage+add_ph) / (physics_resistance+add_physics_resistance))
		dmg = ((atk.damage+add_ph) / (physics_resistance+add_physics_resistance))
		
	if health <= 0.0:
		dead = true
		
	return dmg

func attack(other: Fighter, idx, chance):
	if attacks[idx].success_chance < chance:
		return 0.0
	
	return other.hit(attacks[idx], add_physics_damage, add_magic_damage)

func get_text() -> String:
	var t = String()
	t = "Vous avez rencontré " + fighter_name + ", iel a " + str(health) + " points de vie "
	
	return t
