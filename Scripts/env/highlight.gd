class_name highlight
extends Node3D

var connected_highlights: Array[highlight]
var event: Event

func knn(positions: Array, highlights: Array, idx: int, k: int):
	var top: Array
	
#	for i in range(k):
#		top.append((Vector3(positions[idx].x, 0.0, positions[idx].z) - Vector3(positions[i].x, 0.0, positions[i].z)).length_squared())
#		top_idx.append(i)
		
		
	for i in range(positions.size()):
		
		var dst = (Vector3(positions[idx].x, 0.0, positions[idx].z) - Vector3(positions[i].x, 0.0, positions[i].z)).length_squared()
		
		top.append([dst, i])
		
	connected_highlights.clear()
	top.sort_custom(Global.sort_ascending)
	
	for i in range(1, positions.size()):
		if connected_highlights.size() >= k - 1:
			break
			
		if highlights[top[i][1]].connected_highlights.size() >= k - 1:
			continue
			
		if self in highlights[top[i][1]].connected_highlights:
			continue
			
		connected_highlights.append(highlights[top[i][1]])
		highlights[top[i][1]].connected_highlights.append(self)
		
