class_name Item
extends Node

var type: Attack.types

enum effects {ATTACK, RESISTANCE}
var effect: effects

var powerup: float
var precision_powerup: float
var heal_powerup: float

var price: int
var n: String

var description: String

var icon: CompressedTexture2D

func _init(p, na, t, power, e, ic, desc):
	price = p
	n = na
	type = t
	
	powerup = power
	
	effect = e
	
	icon = ic
	description = desc
