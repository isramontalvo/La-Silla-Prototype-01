extends Node2D

const DURATION := 0.22
const BURST_COLOR := Color(0.92, 0.18, 1.0)

var elapsed: float = 0.0


func _ready() -> void:
	z_index = 90
	queue_redraw()


func _process(delta: float) -> void:
	elapsed += delta

	if elapsed >= DURATION:
		queue_free()
		return

	queue_redraw()


func _draw() -> void:
	var progress := clampf(elapsed / DURATION, 0.0, 1.0)
	var expansion := 1.0 - pow(1.0 - progress, 2.0)
	var fade := 1.0 - progress

	draw_circle(
		Vector2.ZERO,
		lerpf(10.0, 20.0, expansion),
		Color(BURST_COLOR, 0.18 * fade)
	)
	draw_arc(
		Vector2.ZERO,
		lerpf(16.0, 48.0, expansion),
		0.0,
		TAU,
		32,
		Color(BURST_COLOR, 0.95 * fade),
		4.0,
		true
	)

	for ray_index in range(8):
		var direction := Vector2.RIGHT.rotated(ray_index * TAU / 8.0)
		var inner_radius := lerpf(12.0, 30.0, expansion)
		var outer_radius := lerpf(28.0, 58.0, expansion)
		draw_line(
			direction * inner_radius,
			direction * outer_radius,
			Color(BURST_COLOR, 0.85 * fade),
			4.0,
			true
		)
