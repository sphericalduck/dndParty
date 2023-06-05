extends Fighter
class_name Enemy

var highlightA: highlight
var highlightB: highlight

var reward: int

func _init(A, B, r):
	highlightA = A
	highlightB = B
	reward = r

func play(player: Player):
	var roll = randi() % 20
	
	attack(player, randi()%attacks.size(), float(roll) / 20.0)
