extends Node

var items_number: int = 20

var items: Array[Item]

var classes: Array[p_template]

var actual_players: Array[p_template]

var winner: p_template

class p_template:
	var n: String
	var f_n: String
	
	var ic: CompressedTexture2D
	
	var hp: float
	
	var ph_r: float
	var mt_r: float
	
	var attacks: Array[Attack]

func sort_ascending(a, b):
	if a[0] < b[0]:
		return true
	return false
	
func sort_ascending_item(a,b):
	if a.price < b.price:
		return true
	return false

func _ready():
	get_parent().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	
#	for i in range(items_number):
#		var it = Item.new(randi()%20, "sample item" + str(i), load("res://icon.svg"))
#		it.icon = load("res://icon.svg")
#
#		items.append(it)

	#---------- CREATION DES ITEMS -----------------

	var it = Item.new( #épée en bois
		1,
		"épée en bois",
		Attack.types.PHYSIC,
		1.0,
		Item.effects.ATTACK,
		load("res://Art/Sprites/Items/epee_bois.png"),
		"deux planches de bois assemblées par un simple clou.\najoute +1 de dégâts aux attaques physiques"
	)
	items.append(it)
	
	it = Item.new( #pendentif de concentration
		3,
		"pendentif de concentration",
		Attack.types.MAGIC,
		2.0,
		Item.effects.ATTACK,
		load("res://Art/Sprites/Items/pendentif.png"),
		"une gemme plus claire que de l’eau de source.\najoute +2 de dégâts aux attaques psychiques"
	)
	items.append(it)
	
	it = Item.new( #cimeterre ornemental
		3,
		"cimeterre ornemental",
		Attack.types.PHYSIC,
		2.0,
		Item.effects.ATTACK,
		load("res://Art/Sprites/Items/cimeterre.png"),
		"une lame courbée au tranchant singulier, ornée d’une magnifique gemme dans le pommeau.\najoute +2 de dégâts aux attaques physiques"
	)
	items.append(it)
	
	it = Item.new( #talisman de protection
		3,
		"talisman de protection",
		Attack.types.MAGIC,
		1.0,
		Item.effects.RESISTANCE,
		load("res://Art/Sprites/Items/talisman.png"),
		"un petit sac d’ingredients couvert de runes a moitié effacées.\najoute +1 de résistance aux attaques psychiques"
	)
	items.append(it)
	
	it = Item.new( #tenue robuste
		4,
		"tenue robuste",
		Attack.types.PHYSIC,
		2.0,
		Item.effects.RESISTANCE,
		load("res://Art/Sprites/Items/tenue_robuste.png"),
		"la peau est épaisse et donne une carrure menaçante.\najoute +2 de résistance aux attaques physiques"
	)
	items.append(it)
	
	it = Item.new( #robe runique
		8,
		"robe runique",
		Attack.types.MAGIC,
		3.0,
		Item.effects.RESISTANCE,
		load("res://Art/Sprites/Items/robe_runique.png"),
		"une robe rose ornée d’étoiles bleues et de runes blanches.\najoute +3 de résistance aux attaques psychiques"
	)
	items.append(it)
	
	it = Item.new( #cote de maille
		8,
		"cote de maille",
		Attack.types.PHYSIC,
		3.0,
		Item.effects.RESISTANCE,
		load("res://Art/Sprites/Items/cote_mailles.png"),
		"une pièce de maille finement assemblée qui protège le torse et les bras.\najoute +3 de résistance aux attaques physiques"
	)
	items.append(it)
	
	it = Item.new( #joyau d'atlantis
		12,
		"joyau d'atlantis",
		Attack.types.MAGIC,
		4.0,
		Item.effects.RESISTANCE,
		load("res://Art/Sprites/Items/joyau.png"),
		"un sapphire de couleur obsidienne qui semble absorber de l’energie.\najoute +4 de résistance aux attaques psychiques"
	)
	items.append(it)
	
	it = Item.new( #plastron en écailles
		12,
		"plastron en écailles",
		Attack.types.PHYSIC,
		4.0,
		Item.effects.RESISTANCE,
		load("res://Art/Sprites/Items/plastron.png"),
		"une seule écaille du leviathan qui est assez grande pour servir de plastron.\najoute +4 de résistance aux attaques physiques"
	)
	items.append(it)
	
	it = Item.new( #grimoire de la déesse
		12,
		"grimoire de la déesse",
		Attack.types.MAGIC,
		6.0,
		Item.effects.ATTACK,
		load("res://Art/Sprites/Items/grimoire.png"),
		"un grimoire étrange, sa couleur et sa texture changent en fonction de l’utilisateur.\najoute +6 de dégâts aux attaques psychiques"
	)
	items.append(it)
	
	it = Item.new( #épée de fer
		12,
		"épée de fer",
		Attack.types.PHYSIC,
		6.0,
		Item.effects.ATTACK,
		load("res://Art/Sprites/Items/epee_fer.png"),
		"une épée d’une trempe miraculeuse à l'apparence modeste.\najoute +6 de dégâts aux attaques physiques"
	)
	items.append(it)
	
	it = Item.new( #porte bonheur
		5,
		"porte-bonheur",
		0, #n'a pas d'importance, valeur par défaut de 0
		0.0,
		0,
		load("res://Art/Sprites/Items/porte_bonheur.png"),
		"un drôle de médaillon doré.\najoute +10% de chance de réussite à toute attaque"
	)
	it.precision_powerup = 0.10
	items.append(it)
	
	it = Item.new( #verre téléscopique
		8,
		"verre téléscopique",
		0, #n'a pas d'importance, valeur par défaut de 0
		0.0,
		0,
		load("res://Art/Sprites/Items/verre_telescopique.png"),
		"une rondelle de verre avec une armature dorée qui permet d’agrandir une image.\najoute +30% de chance de réussite à toute attaque"
	)
	it.precision_powerup = 0.30
	items.append(it)
	
	it = Item.new( #médaillon informe
		15,
		"médaillon informe",
		0, #n'a pas d'importance, valeur par défaut de 0
		0.0,
		0,
		load("res://Art/Sprites/Items/medaillon_informe.png"),
		"bijou inconnu venant probablement d'une autre dimension.\najoute +50% de chance de réussite à toute attaque"
	)
	it.precision_powerup = 0.50
	items.append(it)
	
	it = Item.new( #potion de soin
		3,
		"potion de soin",
		0, #n'a pas d'importance, valeur par défaut de 0
		0.0,
		0,
		load("res://Art/Sprites/Items/potion.png"),
		"potion aux reflets violacés.\nrégénère 5 points de vie"
	)
	it.heal_powerup = 5
	items.append(it)
	
	it = Item.new( #sort de fuite
		10,
		"sort de fuite",
		0, #n'a pas d'importance, valeur par défaut de 0
		0.0,
		0,
		load("res://Art/Sprites/Items/medaillon_informe.png"),
		"un portail vers une autre dimension qui vous permetterait de vous échapper le temps d'un instant.\nvous permet de passer un combat"
	)
	items.append(it)
	
	items.sort_custom(sort_ascending_item)
	
	#----------- CREATION DES CLASSES ----------------
		
	var c = p_template.new()
	c.n = "Guerrier"
	c.ic = load("res://Art/Sprites/Characters/fighter.png")
	c.hp = 15
	c.ph_r = 4
	c.mt_r = 2
	
	var a = Attack.new()
	a.type = Attack.types.PHYSIC
	a.atk_name = "taille"
	a.damage = 4.0
	a.success_chance = 0.85
	
	c.attacks.append(a)
	
	a = Attack.new()
	a.type = Attack.types.PHYSIC
	a.atk_name = "estoc"
	a.damage = 7.0
	a.success_chance = 0.45
	
	c.attacks.append(a)
	
	a = Attack.new()
	a.type = Attack.types.MAGIC
	a.atk_name = "concentration"
	a.damage = 2.0
	a.success_chance = 0.5
	
	c.attacks.append(a)
	
	
	classes.append(c)
	
	
	c = p_template.new()
	c.n = "Barbare"
	c.ic = load("res://Art/Sprites/Characters/barbarian.png")
	c.hp = 13
	c.ph_r = 5
	c.mt_r = 1
	
	a = Attack.new()
	a.type = Attack.types.PHYSIC
	a.atk_name = "matraque"
	a.damage = 5.0
	a.success_chance = 0.75
	
	c.attacks.append(a)
	
	a = Attack.new()
	a.type = Attack.types.PHYSIC
	a.atk_name = "charge"
	a.damage = 8.5
	a.success_chance = 0.4
	
	c.attacks.append(a)
	
	classes.append(c)
	
	
	c = p_template.new()
	c.n = "Clerc"
	c.ic = load("res://Art/Sprites/Characters/clerc.png")
	c.hp = 15
	c.ph_r = 2
	c.mt_r = 4
	
	a = Attack.new()
	a.type = Attack.types.MAGIC
	a.atk_name = "châtiment"
	a.damage = 4.0
	a.success_chance = 0.7
	
	c.attacks.append(a)
	
	a = Attack.new()
	a.type = Attack.types.MAGIC
	a.atk_name = "ouragan"
	a.damage = 8.0
	a.success_chance = 0.45
	
	c.attacks.append(a)
	
	a = Attack.new()
	a.type = Attack.types.PHYSIC
	a.atk_name = "riposte"
	a.damage = 3.0
	a.success_chance = 0.8
	
	c.attacks.append(a)
	
	classes.append(c)
	
	
	c = p_template.new()
	c.n = "Mage"
	c.ic = load("res://Art/Sprites/Characters/wizard.png")
	c.hp = 13
	c.ph_r = 1
	c.mt_r = 5
	
	a = Attack.new()
	a.type = Attack.types.MAGIC
	a.atk_name = "boule de feu"
	a.damage = 7.0
	a.success_chance = 0.7
	
	c.attacks.append(a)
	
	a = Attack.new()
	a.type = Attack.types.MAGIC
	a.atk_name = "intervention divine"
	a.damage = 12.0
	a.success_chance = 0.3
	
	c.attacks.append(a)
	
	classes.append(c)
