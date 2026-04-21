extends Camera2D

@export var target: NodePath
@export var speed := 1000.0           # quanto maior, mais rápido segue
@export var look_ahead_distance := 0.0 # opcional: distância de "antecipação"
@export var use_look_ahead := true

var _target_node: Node2D

func _ready():
	if target:
		_target_node = get_node_or_null(target)

func _physics_process(delta):
	if not _target_node:
		return
	var desired := _target_node.global_position
	if use_look_ahead and _target_node.has_method("get_velocity"):
		var vel = _target_node.call("get_velocity")
		if vel is Vector2 and vel.length() > 0.01:
			desired += vel.normalized() * look_ahead_distance
	# usa move_toward para suavizar a movimentação
	global_position = global_position.move_toward(desired, speed * delta)
