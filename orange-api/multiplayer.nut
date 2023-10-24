import("orange-api/orange_api_util.nut")

api_table().get_players <- get_players

api_table().for_all_players <- function(func = function(){}) {
    if(type(func) == "string") func = compilestring(func)
    foreach(v in get_players()) rawcall(func, {Tux = v})
}