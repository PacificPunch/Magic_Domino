/// obj_domino_elem - Alarm 11 (Инициализация данных)

// 1. Проверяем, является ли кость дублем
is_double = (value1 == value2);

// 2. Определяем стихии по спрайту, который назначил контроллер
// Теперь кость получает МАССИВ из двух стихий (для каждой половинки)
var _spr_name = sprite_get_name(sprite_index);

if (variable_global_exists("domino_elemental_map") && ds_map_exists(global.domino_elemental_map, _spr_name)) {
    var _arr = global.domino_elemental_map[? _spr_name];
    
    // Проверяем, действительно ли нам пришел массив из 2-х стихий
    if (is_array(_arr)) {
        element1 = _arr[0];
        element2 = _arr[1];
    } else {
        // Бронебойная защита: если пришла только 1 стихия (старый код или ошибка)
        // назначаем её на обе половинки, чтобы игра не вылетела
        element1 = _arr;
        element2 = _arr;
    }
} else {
    // Если кость не найдена в словаре (например, пустышка spr_00)
    element1 = ELEMENT.NONE;
    element2 = ELEMENT.NONE;
}