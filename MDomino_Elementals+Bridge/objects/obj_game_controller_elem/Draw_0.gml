/// obj_game_controller_elem - Draw Event

// --- 1. ОТРИСОВКА ИНДИКАЦИИ СТАРТА ---
if (variable_global_exists("is_showing_starter") && global.is_showing_starter) {
    
    var msg = (global.current_turn == "player") ? "Ваш ход" : "Ход противника";
    
    var font_id = asset_get_index("fnt_bazar");
    if (font_exists(font_id)) {
        draw_set_font(font_id);
    }
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var text_x = global.table_center_x;
    var text_y = global.table_center_y;
    
    var scale = 2; 
    
    // Тень
    draw_set_color(c_black);
    draw_text_transformed(text_x + 4, text_y + 4, msg, scale, scale, 0);
    
    // Текст
    draw_set_color(c_white);
    draw_text_transformed(text_x, text_y, msg, scale, scale, 0);
    
    // Сброс настроек
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
}

// --- 2. ВИЗУАЛИЗАЦИЯ АКТИВНЫХ СТИХИЙ (Elemental Helper) ---
// Рисуем небольшие иконки или цветовые индикаторы по краям экрана, 
// чтобы игрок видел, какая стихия сейчас "блокирует" концы цепочки.

if (!global.game_over && ds_list_size(global.table_chain) > 0) {
    var _draw_element_info = function(_x, _y, _elem, _label) {
        if (_elem == ELEMENT.NONE) return;
        
        var _color = c_white;
        var _name = "";
        switch(_elem) {
            case ELEMENT.EARTH: _color = c_orange; _name = "Земля"; break;
            case ELEMENT.WATER: _color = c_blue;   _name = "Вода"; break;
            case ELEMENT.AIR:   _color = c_aqua;   _name = "Воздух"; break;
            case ELEMENT.FIRE:  _color = c_red;    _name = "Огонь"; break;
        }
        
        draw_set_font(asset_get_index("fnt_bazar"));
        draw_set_color(c_black);
        draw_text(_x + 2, _y + 2, _label + ": " + _name); // Тень
        draw_set_color(_color);
        draw_text(_x, _y, _label + ": " + _name);
    }

}

// --- 3. СООБЩЕНИЕ О ЗАВЕРШЕНИИ ИГРЫ ---
if (global.game_over && global.end_message != "") {
    draw_set_font(asset_get_index("fnt_bazar"));
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Затемнение фона
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1.0);
    
    // Текст финала
 //   draw_set_color(c_yellow);
 //   draw_text_transformed(global.table_center_x, global.table_center_y, global.end_message, 1.5, 1.5, 0);
    
    draw_set_color(c_black);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// --- 4. ШПАРГАЛКА ПО СТИХИЯМ (Таблица совместимости) ---
if (!global.game_over) {
    var _margin = 30;
    var _gui_x = 1920 - _margin;
    var _gui_y = 1030 - _margin;
    
    // Границы подложки
    var _rect_left  = _gui_x - 410;
    var _rect_right = _gui_x + 30;
    // Точный центр подложки по горизонтали
    var _center_x = (_rect_left + _rect_right) / 2; 
    
    var _fnt = asset_get_index("fnt_bazar");
    if (font_exists(_fnt)) draw_set_font(_fnt);
    
    // 1. Подложка
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_roundrect_ext(_rect_left, _gui_y - 260, _rect_right, _gui_y + 25, 20, 20, false);
    draw_set_alpha(1.0);

    // 2. Заголовок
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(_center_x, _gui_y - 245, "СОВМЕСТИМОСТЬ");
    
    var _start_y = _gui_y - 205; 
    var _step = 35;              

    // Вспомогательная функция с АВТО-ЦЕНТРОВКОЙ
    var _draw_colored_row_centered = function(_yy, _cx_box, _main_name, _main_col, _s1, _c1, _s2, _c2) {
        // СТРОГОЕ СООТВЕТСТВИЕ: считаем ширину именно тех строк, что рисуем ниже
        var _sep1 = " : ";
        var _sep2 = "и ";
        var _total_w = string_width(_main_name) + string_width(_sep1) + string_width(_s1) + string_width(_sep2) + string_width(_s2);
        
        // Начальная точка X (левый край строки для её центровки)
        var _curr_x = _cx_box - (_total_w / 2);
        
        draw_set_halign(fa_left); 

        // Основной элемент
        draw_set_color(_main_col);
        draw_text(_curr_x, _yy, _main_name);
        _curr_x += string_width(_main_name);
        
        // Разделитель 1
        draw_set_color(c_white);
        draw_text(_curr_x, _yy, _sep1);
        _curr_x += string_width(_sep1);
        
        // Первый совместимый
        draw_set_color(_c1);
        draw_text(_curr_x, _yy, _s1);
        _curr_x += string_width(_s1);
        
        // Разделитель 2
        draw_set_color(c_white);
        draw_text(_curr_x, _yy, _sep2);
        _curr_x += string_width(_sep2);
        
        // Второй совместимый
        draw_set_color(_c2);
        draw_text(_curr_x, _yy, _s2);
    }

    // --- ОТРИСОВКА СПИСКА ПРАВИЛ ---

    _draw_colored_row_centered(_start_y, _center_x, "ОГОНЬ", c_red, "ВОЗДУХ ", c_aqua, "ЗЕМЛЯ", c_green);
    _draw_colored_row_centered(_start_y + _step, _center_x, "ВОДА", c_blue, "ВОЗДУХ ", c_aqua, "ЗЕМЛЯ", c_green);
    _draw_colored_row_centered(_start_y + _step * 2, _center_x, "ВОЗДУХ", c_aqua, "ОГОНЬ ", c_red, "ВОДА", c_blue);
    _draw_colored_row_centered(_start_y + _step * 3, _center_x, "ЗЕМЛЯ", c_green, "ОГОНЬ ", c_red, "ВОДА", c_blue);

    // 3. СООБЩЕНИЕ ПРО ДУБЛИ
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    // Позиция Y немного подкорректирована, чтобы надпись была в нижней части новой подложки
    draw_text(_center_x, _gui_y - 45, "ДУБЛИ - МОСТЫ\n(УНИВЕРСАЛЬНЫ)");

    // Сброс настроек
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}