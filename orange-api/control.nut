::controls <- [
"left"
"right"
"up"
"down"
"jump"
"action"
"start"
"escape"
"menu-select"
"menu-select-space"
"menu-back"
"remove"
"cheat-menu"
"debug-menu"
"console"
"peek-left"
"peek-right"
"peek-up"
"peek-down"
]

api_table().wait_for_any_pressed <- function(player = 1) {
	local input = null
	while(input == null) {
		if(player < 1) {
			foreach(v in get_players()) foreach(w in controls) {
				if(v.get_input_pressed(w)) input = w
			}
		} else foreach(v in controls) if(get_sector()["Tux" + (player == 1 ? "" : player.tostring())].get_input_pressed(v)) input = v
		wait(0.01)
	}
	return input
}

api_table().anyone_pressed <- function(input) foreach(v in get_players()) if(v.get_input_pressed(input)) return v

api_table().anyone_held <- function(input) foreach(v in get_players()) if(v.get_input_held(input)) return v

api_table().anyone_released <- function(input) foreach(v in get_players()) if(v.get_input_released(input)) return v

api_table().anyone_axis <- function(negative, positive) {
	local axis = 0
	foreach(v in get_players()) {
		if(v.get_input_held(negative))
			axis--
		if(v.get_input_held(positive))
			axis++
	}
	if(axis == 0) {
		return 0
	} else return (axis > 0 ? 1 : -1)
}
