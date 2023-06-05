extends Node3D

@export var player_scene: PackedScene
@export var player_count: int

@export_file var ending_scene

@export var starting_money: int

@export var enemy_spawn_chance: float

@export var terrain_path: NodePath

@export var camera_speed: float

@onready var camera = $SpringArm3D/Camera3D

var highlights: Array

var players: Array[Player]
var enemies: Array[Enemy]

var turn_over: bool = true

func _ready():
#	print(get_node(terrain_path).highlights.get_children().size())
	await get_node(terrain_path).initialize()
	highlights = get_node(terrain_path).create_highlights()
	
	for i in range(Global.actual_players.size()):
		var p: Player = player_scene.instantiate()
		var p_tmp: Global.p_template = Global.actual_players[i]
		
		p.GM = self
		p.current_highlight = highlights.pick_random()
		
		p.fighter_name = Global.actual_players[i].f_n
		p.magic_resistance = p_tmp.mt_r
		p.physics_resistance = p_tmp.ph_r
		p.health = p_tmp.hp
		p.money = starting_money
		
		p.attacks = p_tmp.attacks
		
		add_child(p)
		
		players.append(p)

func player_turn_finished(player: Player):
	player.state = player.states.WAIT
	
func find_enemy(A,B) -> int:
	for i in range(enemies.size()):
		var e: Enemy = enemies[i]
		
		if not (e.highlightA == A or e.highlightB == A):
			continue
			
		if not (e.highlightA == B or e.highlightB == B):
			continue
			
		return i
	return -1
	
func remove_player(p: Player):
	players.erase(p)
	p.queue_free()
	
func check_enemies() -> void:
	for i in range(enemies.size()):
		var e: Enemy = enemies[i]
		if not e.dead:
			continue
			
		enemies.pop_at(i)
		e.queue_free()
	
func player_attack(p: Player):
	while true:
		p.state = Player.states.ATTACKING
		
		while p.state != Player.states.WAIT:
			await get_tree().process_frame
			
		if p.skipped_turn:
			p.skipped_turn = false
			p.skips_left -= 1
			break
			
		if p.enemy.dead:
			if p.enemy is Player:
				remove_player(p.enemy)
				p.money += p.enemy.money
			else:
				p.money += p.enemy.reward
			break
			
		if not p.enemy is Player:
			p.enemy.play(p)
			
		else:
			p.enemy.state = Player.states.ATTACKING
			p.enemy.enemy = p
		
			while p.enemy.state != Player.states.WAIT:
				await get_tree().process_frame
		
		if p.dead:
			remove_player(p)
			break
	
func player_at(curr_p: Player):
	for p in players:
		if p == curr_p:
			continue
		if p.current_highlight == curr_p.current_highlight:
			return p
	return null
	
func _process(delta):
	rotation.y += delta * camera_speed
	
#	if not Input.is_action_just_pressed("ui_focus_next"):
#		return
		
	if not turn_over:
		return
		
	for i in range(players.size()):
		turn_over = false
		
		var p = players[i]
		p.rotation.y = randf() * 2 * PI
		
		var p_origin = p.current_highlight
		
		p.state = Player.states.MOVING
		while p.state != Player.states.WAIT:
			await get_tree().process_frame
			
			
		var is_enemy = find_enemy(p_origin, p.current_highlight)
			
		if enemy_spawn_chance > randf() and is_enemy == -1:
			var e = Enemy.new(p_origin, p.current_highlight, 5)
			
			e.magic_resistance = 1.0
			e.physics_resistance = 2.0
			e.health = 7.0
			e.fighter_name = "quoicoubaka"
			
			var a = Attack.new()
			a.type = Attack.types.PHYSIC
			a.atk_name = "blue lobster"
			a.damage = 3.0
			a.success_chance = 0.7
			
			e.attacks.append(a)
			
			enemies.append(e)
			
			is_enemy = enemies.size() - 1
			
			
		if is_enemy != -1:
			p.enemy = enemies[is_enemy]
					
			await player_attack(p)
				
		check_enemies()
		
		var other_player = player_at(p)
		if other_player:
			p.enemy = other_player
					
			await player_attack(p)
			
		if p.is_queued_for_deletion():
			continue
				
				
		p.get_node("SpringArm3D/Camera3D").current = true
		camera.current = false
				
		if p.current_highlight.event:
			p.state = Player.states.INTERACTING
			
			while p.state != Player.states.WAIT:
				await get_tree().process_frame
				
				
		p.get_node("SpringArm3D/Camera3D").current = false

	if players.size() == 1:
		for pl in Global.actual_players:
			if pl.f_n != players[0].fighter_name:
				continue
			Global.winner = pl
			break
			
		Global.actual_players.clear()

#		Global.goto_scene(ending_scene)
		get_tree().change_scene_to_file(ending_scene)

	camera.current = true
	turn_over = true
