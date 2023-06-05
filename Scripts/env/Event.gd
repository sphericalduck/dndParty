class_name Event
extends Node

enum types {QUEST, SHOP}
var type: types

var event_name

var player_quests: Dictionary

var items: Array[Item]

func _init(t: types):
	type = t

func get_text(p: Player) -> String:
	if type == types.SHOP:
		return "Vous êtes au magasin " + event_name
		
	if player_quests.get(p) == null:
		var it = Global.items.pick_random()
		player_quests[p] = it
		
		return "Vous parlez à " + event_name + ", il vous demande de lui apporter un " + it.n
		
	if player_quests.get(p) in p.items:
		p.quests_filled += 1
		p.money += 50
		
		return "Vous avez apporté " + player_quests.get(p).n + " à "  + event_name + ", il vous récompense avec 50 rubis"
		
	return "Vous devez apporter " + player_quests.get(p).n + " à " + event_name
