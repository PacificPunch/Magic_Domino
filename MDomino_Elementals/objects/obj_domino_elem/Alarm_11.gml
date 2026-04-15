/// obj_domino_elem - Alarm 1 (Инициализация данных)

// 1. Проверяем, является ли кость дублем
is_double = (value1 == value2);

// 2. Определяем стихию по спрайту, который назначил контроллер
// Теперь все кости (включая дубли) подчиняются правилам конфликтов стихий
var _spr_name = sprite_get_name(sprite_index);
if (ds_map_exists(global.domino_elemental_map, _spr_name)) {
    element = global.domino_elemental_map[? _spr_name];
} else {
    element = ELEMENT.NONE;
}