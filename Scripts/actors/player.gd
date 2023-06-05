class_name Player
extends Fighter

enum states {WAIT, MOVING, INTERACTING, ATTACKING}
var state: states = states.WAIT

var GM: Node

var money: int
var items: Array[Item]

var quests: Array[Item]
var highlights_quests: Array[highlight]

var quests_filled: int
var skips_left: int = 3

signal finished(player)


@onready var UI = $UI

@onready var text_label = $UI/dialogueBox/HBoxContainer/Label
@onready var money_label = $UI/money/Label
@onready var skips_label = $UI/skips/Label
@onready var dialogue_box = $UI/dialogueBox
@onready var name_label = $UI/dialogueBox/name/Label

@onready var buttons = $UI/dialogueBox/HBoxContainer/choices
@onready var skip_button = $UI/dialogueBox/skip

@onready var tooltip_arrow = $arrow_moving
@onready var tooltip = $UI/tooltip

@onready var inventory = $UI/inventory

@onready var sprite_pos = $sprite

@onready var health_bar = $UI/healthBar/ProgressBar

var current_highlight: highlight

var curr_interacting: int = -1
var curr_hovering: int = -1

var show_inventory: bool

var skipped_turn: bool

var enemy: Fighter

func _ready():
	finished.connect(Callable(GM, "player_turn_finished").bind(self))
	
	for button in buttons.get_children():
		button.connect("pressed", Callable(self, "button_action").bind(button, false))
		button.connect("mouse_entered", Callable(self, "button_action").bind(button, true))
		
	for p in inventory.get_node("items").get_children():
		p.connect("mouse_entered", Callable(self, "button_action").bind(p, true))
		
	for p in inventory.get_node("quetes").get_children():
		p.connect("mouse_entered", Callable(self, "button_action").bind(p, true))
		
	skip_button.connect("pressed", Callable(self, "skipped"))
		
	money_label.text = str(money)
	
	sprite_pos.modulate = Color(randf(), randf(), randf(), 1.0)

func button_action(button, is_hovering: bool):
	var idx: String = button.name.rstrip("Button").rstrip("Panel")
	if idx == "":
		idx = "1"
	
	if is_hovering:
		curr_hovering = int(idx) - 1
	else:
		curr_interacting = int(idx) - 1

func skipped():
	skipped_turn = true
	terminate()

func terminate():
	curr_interacting = -1
	curr_hovering = 0
	finished.emit()

func set_buttons_visiblility(n: int, names: Array) -> void:
	for i in range(buttons.get_child_count()):
		if i < n:
			buttons.get_child(i).text = names[i]
			buttons.get_child(i).visible = true
			continue
		buttons.get_child(i).visible = false

func set_tooltip_visibility(it):
	var buttons_rect = buttons.get_rect()
	buttons_rect.position = buttons.global_position
	
	var inv_rect = inventory.get_rect()
	inv_rect.position = inventory.global_position
	
	if buttons_rect.has_point(get_viewport().get_mouse_position()) or (inv_rect.has_point(get_viewport().get_mouse_position()) and show_inventory):
		tooltip.visible = true
	else: 
		tooltip.visible = false
		
	if it is Item:
		tooltip.get_node("VBoxContainer/price/Label").text = str(it.price)
		tooltip.get_node("VBoxContainer/name").text = it.n
		tooltip.get_node("VBoxContainer/desc").text = it.description
	elif it is Attack:
		var percent = 0.0
		for i in items:
			percent += i.precision_powerup
		
		tooltip.get_node("VBoxContainer/price/Label").text = "--"
		tooltip.get_node("VBoxContainer/name").text = it.atk_name
		tooltip.get_node("VBoxContainer/desc").text = "dégâts : " + str(it.damage) + "\ntype : " + ("physique" if it.type == Attack.types.PHYSIC else "psychique") + "\nchance de réussir : " + str(clamp(it.success_chance+percent, 0.0, 1.0)*100) + "%"

func set_inventory_visibility():
	var it = inventory.get_node("items")
	var q = inventory.get_node("quetes")
	
	for i in range(it.get_child_count()):
		if i >= items.size():
			it.get_child(i).get_child(0).texture = null
			continue
			
		it.get_child(i).get_child(0).texture = items[i].icon
		
	for i in range(q.get_child_count()):
		if i >= quests.size():
			q.get_child(i).get_child(0).texture = null
			continue
			
		q.get_child(i).get_child(0).texture = quests[i].icon

func set_sprites_visiblility():
	for i in range(4):
		var s = get_node("quests/Sprite3D" + str(i))
		
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		s.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		s.scale = Vector3.ONE * 15.0
		if i >= quests.size() or state == states.WAIT:
			s.texture = null
			continue
		
		s.global_position = highlights_quests[i].global_position + Vector3(0.0, 10.0, 0.0)
		s.texture = quests[i].icon

func update_powerups():
	var add_ph: float = 0.0
	var add_mt: float = 0.0
	var res_ph: float = 0.0
	var res_mt: float = 0.0
	
	for it in items:
		if it.effect == Item.effects.ATTACK:
			if it.type == Attack.types.PHYSIC:
				add_ph += it.powerup
			else:
				add_mt += it.powerup
		else:
			if it.type == Attack.types.PHYSIC:
				res_ph += it.powerup
			else:
				res_mt += it.powerup
				
	add_magic_damage = add_mt
	add_physics_damage = add_ph
	add_magic_resistance = res_mt
	add_physics_resistance = res_ph

func _process(delta):
	for it in items:
		if it.heal_powerup > 0:
			health += it.heal_powerup
			health = clamp(health, 0, initial_health)
			items.erase(it)
		elif it.n == "sort de fuite":
			skips_left += 1
			items.erase(it)
			
	skips_label.text = str(skips_left)
	
	global_position = current_highlight.global_position
	
	health_bar.value = health / initial_health
	
	money_label.text = str(money)
	
	name_label.text = fighter_name
	
	
	var mousepos = get_viewport().get_mouse_position()
	tooltip.position = Vector2(
		clamp(mousepos.x - tooltip.size.x, 0.0, get_viewport().get_visible_rect().size.x - tooltip.size.x),
		clamp(mousepos.y - tooltip.size.y, 0.0, get_viewport().get_visible_rect().size.y - tooltip.size.y)
	)
#	tooltip.position = clamp(mousepos - tooltip.size, Vector2.ZERO, Vector2.ONE * get_viewport().get_visible_rect().size - tooltip.size)
	
	sprite_pos.global_position = current_highlight.global_position + Vector3(0.0, 15.0, 0.0)
	
	inventory.visible = show_inventory
	
	tooltip_arrow.visible = false
	
	set_sprites_visiblility()
	
	if state == states.WAIT:
		UI.visible = false
		
		curr_hovering = -1
		
		return
		
	UI.visible = true
	
	if Input.is_action_just_pressed("inv"):
		curr_hovering = 0
		show_inventory = not show_inventory
		
	set_inventory_visibility()
	
	if show_inventory:
		var it_rect = Rect2(inventory.get_node("items").global_position, inventory.get_node("items").size)
		var q_rect = Rect2(inventory.get_node("quetes").global_position, inventory.get_node("quetes").size)
		
		if it_rect.has_point(get_viewport().get_mouse_position()) and curr_hovering < items.size():
			set_tooltip_visibility(items[curr_hovering])
			
			if Input.is_action_just_pressed("delete_item"):
				items.remove_at(curr_hovering)
				curr_hovering = 0
			
		elif q_rect.has_point(get_viewport().get_mouse_position()) and curr_hovering < quests.size():
			set_tooltip_visibility(quests[curr_hovering])
			
		else:
			tooltip.visible = false
	else:
		tooltip.visible = false
	
	if state == states.MOVING:
		tooltip_arrow.visible = true
		skip_button.visible = false
		
		var buttons_names = Array()
		for i in range(current_highlight.connected_highlights.size()):
			buttons_names.append(current_highlight.connected_highlights[i].name)
		
		set_buttons_visiblility(current_highlight.connected_highlights.size(), buttons_names)
		
		text_label.text = "Déplacez-vous à la ville de votre choix."
		
		if not show_inventory:
			tooltip_arrow.global_position = current_highlight.connected_highlights[curr_hovering].global_position + Vector3(0.0, 10.0, 0.0)
		else:
			tooltip_arrow.visible = false
		
	else:
		skip_button.visible = true
	
	if state == states.ATTACKING:
#		skip_button.visible = true
		var button_names = Array()
		for i in range(attacks.size()):
			button_names.append(attacks[i].atk_name)
			
		set_buttons_visiblility(attacks.size(), button_names)
		
		text_label.text = enemy.get_text()
		
		if not show_inventory:
			set_tooltip_visibility(attacks[curr_hovering])
	
	if state == states.INTERACTING:
#		skip_button.visible = true
		var button_names = Array()
		
		if current_highlight.event.type == Event.types.SHOP:
			skip_button.visible = true
			
			var buttons_rect = buttons.get_rect()
			buttons_rect.position = buttons.global_position
			
			if not show_inventory:
				set_tooltip_visibility(current_highlight.event.items[curr_hovering])
			
			for i in range(current_highlight.event.items.size()):
				button_names.append(current_highlight.event.items[i].n)
				
			set_buttons_visiblility(current_highlight.event.items.size(), button_names)
		else:
			set_buttons_visiblility(2, ["Oui", "Non"])
		
		text_label.text = current_highlight.event.get_text(self)
		
#	elif (skips_left == 0 and state != states.INTERACTING):
#		skip_button.visible = false
	
	if curr_interacting == -1:
		return
		
	if state == states.MOVING:
		current_highlight = current_highlight.connected_highlights[curr_interacting]
		terminate()
		
	if state == states.ATTACKING:
		var roll = randi()%20
		var percent = float(roll)/20.0
		
		for it in items:
			percent -= it.precision_powerup
		
		var dmg = attack(enemy, curr_interacting, percent)
		
		curr_interacting = -1
		
		terminate()
		
#		if enemy.dead:
#			money += enemy.reward
#			terminate()
#			return
			
#		text_label.text = "Vous avez infligé " + str(dmg) + " points de dégats à " + enemy.fighter_name
#		print('a')
#		await get_tree().create_timer(1.0).timeout
#		print("b")

	if state == states.INTERACTING:
		if current_highlight.event.type == Event.types.SHOP:
			var it = current_highlight.event.items[curr_interacting]
			
			if it.price > money:
				curr_interacting = -1
				return
				
			money -= it.price
			items.append(it)
			
			terminate()
		else:
			if bool(curr_interacting):
				current_highlight.event.player_quests.erase(self)
			else:
				quests.append(current_highlight.event.player_quests.get(self))
				highlights_quests.append(current_highlight)
			
			terminate()
			
	update_powerups()
