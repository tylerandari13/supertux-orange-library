// items are to be listed in order of importance. if a script needs stuff from another script to function put it above
foreach(file in [
	"orange_api_util"
	"text"
	"badguy"
	"bumper"
	"button"
	"camera"
	"class"
	"console"
	"control"
	"grumbel"
	"location"
	"misc"
	"multiplayer"
	"oobject"
	"rand"
	"scriptloader"
	"signal"
	"table"
	"test"
	"thread"
	"tilemap"
	"trampoline"
]) import("orange-api/" + file + ".nut")
