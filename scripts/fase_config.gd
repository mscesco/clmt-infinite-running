class_name FaseConfig

static var FASES: Dictionary = {
	1: { "vel_base": 300.0, "vel_teto": 400.0, "aceleracao": 3.0, "spike_pair_chance": 0.25 },
	2: { "vel_base": 360.0, "vel_teto": 500.0, "aceleracao": 4.0, "spike_pair_chance": 0.40 },
	3: { "vel_base": 440.0, "vel_teto": 620.0, "aceleracao": 5.0, "spike_pair_chance": 0.55 },
}

static func get_fase(fase: int) -> Dictionary:
	var f: int = clampi(fase, 1, 3)
	return FASES[f]
