/// obj_domino_elem - Alarm 11 (Инициализация данных)

// 1. Проверяем, является ли кость дублем (игнорирует конфликты стихий)
is_double = (value1 == value2);

// 2. Определяем стихию по спрайту, который назначил контроллер
var _spr_name = sprite_get_name(sprite_index);
if (ds_map_exists(global.domino_elemental_map, _spr_name)) {
    element = global.domino_elemental_map[? _spr_name];
} else {
    element = ELEMENT.NONE;
}