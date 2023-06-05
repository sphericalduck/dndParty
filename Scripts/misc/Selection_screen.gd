extends Control

@export_file var main_scene

@export var character_card_scene: PackedScene

func _ready():
	$VBoxContainer/start_button.pressed.connect(self.start_game)
	
	for r in $VBoxContainer/HBoxContainer.get_children():
		r.get_child(0).connect("pressed", Callable(self, "spawn_character_card").bind(r))

func spawn_character_card(rect: ColorRect):
	var c: Control = character_card_scene.instantiate()
	rect.add_child(c)
	
	rect.get_node("Button").visible = false

func start_game() -> void:
	for r in $VBoxContainer/HBoxContainer.get_children():
		if r.get_child_count() == 1:
			continue
		Global.actual_players.append(r.get_child(1).get_player())
		Global.actual_players[-1].f_n = r.get_child(1).get_player_name()
	
#	get_tree().change_scene_to_packed(main_scene)
#	Global.goto_scene(main_scene)
	get_tree().change_scene_to_file(main_scene)
