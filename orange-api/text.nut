enum keys { // i hate how i have to define these so many times
	TEXT
	SWAP
	FUNC
	BACK
	CUSTOM
	EXIT
}

enum values {
	NULL
	INT
	FLOAT
	STRING
	BOOL
	ENUM
}

enum errors {
	OK
	INFO
	WARNING
	ERROR
}

import("orange-api/orange_api_util.nut")

function get_pressed(...) {
	foreach(v in vargv) if(sector.Tux.get_input_pressed(v)) return true
	return false
}
function get_held(...) {
	foreach(v in vargv) if(sector.Tux.get_input_held(v)) return true
	return false
}
function get_released(...) {
	foreach(v in vargv) if(sector.Tux.get_input_released(v)) return true
	return false
}

class OMenuText extends OObject {
	current_item = 0

	current_menu = {}
	last_menu = {}

	start_info = ""

	thread = null
	constructor(name) {
		base.constructor(name)
		set_font("big")
		set_text("Guh")
		start_cutscene()
		thread = OThread(thread_func.bindenv(this))
		thread.call()
		sector.liborange.get_signal("console_response").connect(temp_string.bindenv(this))
	}

	function temp_string(text) if(current_menu[current_item].orange_API_key == keys.CUSTOM && current_menu[current_item].orange_API_value == values.STRING) current_menu[current_item].string = text

	function thread_func() {
		while(wait(0.01) == null && !get_pressed("escape", "menu-back")) {

			if(get_pressed("up", "peek-up")) current_item--
			if(get_pressed("down", "peek-down")) current_item++

			if(get_pressed("action", "menu-select", "menu-select-space", "jump")) menu_select()
			if(get_pressed("left", "peek-left")) menu_select(-1)
			if(get_pressed("right", "peek-right")) menu_select(1)

			if(current_item < 0) current_item = current_menu.len() - 1
			if(current_item >= current_menu.len()) current_item = 0

			if(current_menu[current_item].orange_API_key == keys.TEXT) if(get_pressed("up", "peek-up")) {
				current_item--
			} else current_item++

			draw_menu()
		}
		exit()
	}

	function draw_menu() {
		local drawtext = ""
		local drawnum = 0

		local largest_drawline = ""

		foreach(i, v in current_menu) {
			local drawline = (drawnum == current_item ? "> " : "  ")
			switch(v.orange_API_key) {
				case keys.CUSTOM:
					drawline += v.text + " : "
					switch(v.orange_API_value) {
						case values.NULL:
							drawline += "<null>"
							break
						case values.INT:
							drawline += v.num
							break
						case values.FLOAT:
							drawline += v.num + (v.num == v.num.tointeger() ? ".0" : "")
							break
						case values.STRING:
							drawline += v.prefix + v.string + v.suffix
							break
						case values.BOOL:
							drawline += v.bool ? v.true_text : v.false_text
							break
						case values.ENUM:
							drawline += "<- " + v.enums[v.index][0] + "->"
							break
						default:
							drawline += "<unknown>"
							break
					}
					break
				default:
					drawline += v.text
			}
			drawtext += drawline + (drawnum == current_item ? " <" : "") + "\n\n"

			if(drawline.len() > largest_drawline.len()) largest_drawline = drawline

			drawnum++
		}
		set_text(start_info + "\n\n" + drawtext)
		return largest_drawline
	}

	function menu_select(dir = 0) {
		local drawnum = 0
		foreach(i, v in current_menu) {
			if(drawnum == current_item) {
				switch(v.orange_API_key) {
					case keys.SWAP:
						swap_menu(v.menu)
						break
					case keys.FUNC:
						run_function(v.func)
						break
					case keys.BACK:
						go_back()
						break
					case keys.EXIT:
						exit()
						break
					case keys.CUSTOM:
						switch(v.orange_API_value) {
							case values.INT:
							case values.FLOAT:
								if(get_held("left", "peek-left")) {
									if(v.num > v.min) {
										v.num -= v.inc
									} else v.num = v.min
								}
								if(get_held("right", "peek-right")) {
									if(v.num < v.max) {
										v.num += v.inc
									} else v.num = v.max
								}
								break
							case values.STRING:
									// handled at temp_string()
								break
							case values.BOOL:
								v.bool = !v.bool
								break
							case values.ENUM:
								v.index += (dir == 0 ? 1 : dir)
								if(v.index > v.enums.len() - 1) v.index = 0
								if(v.index < 0) v.index = v.enums.len() - 1
								break
						}
				}
			}
			drawnum++
		}
	}

	function exit() set_visible(false)

	function swap_menu(new_menu) {
		current_item = 0
		last_menu = current_menu
		current_menu = clone new_menu
	}

	function get_item_from_name(name) foreach(v in current_menu) if(v.text == name) return v

	function run_function(func) (type(func) == "string" ? compilestring(func) : func).bindenv(this)()

	function go_back() swap_menu(last_menu)

	function display_info(message, type) OThread(function[this](message, type) {
		local start_thing = ""
		switch(type) {
			case errors.OK:
				start_thing = "Success: "
			break
			case errors.WARNING:
				start_thing = "Warning: "
			break
			case errors.ERROR:
				start_thing = "Error: "
			break
		}
		start_info = start_thing + message
		wait(5)
		start_info = ""
	}).call(message, type)
}

api_table().MenuText <- OMenuText
