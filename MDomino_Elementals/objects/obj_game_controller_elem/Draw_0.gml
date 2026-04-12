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
    var text_y = global.table_center_y - 200; // Немного смещаем вверх, чтобы не перекрывать саму кость
    
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

    // Рисуем статус в углах экрана (опционально для удобства игрока)
    draw_set_halign(fa_left);
    _draw_element_info(50, 50, global.left_element, "Левый край");
    
    draw_set_halign(fa_right);
    _draw_element_info(1870, 50, global.right_element, "Правый край");
    
    draw_set_color(c_white);
    draw_set_halign(fa_left);
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
    draw_set_color(c_yellow);
    draw_text_transformed(global.table_center_x, global.table_center_y, global.end_message, 1.5, 1.5, 0);
    
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// --- 4. ШПАРГАЛКА ПО СТИХИЯМ (Таблица совместимости) ---
if (!global.game_over) {
    var _margin = 30;
    var _gui_x = 1920 - _margin;
    var _gui_y = 1030 - _margin;
    
    var _fnt = asset_get_index("fnt_bazar");
    if (font_exists(_fnt)) draw_set_font(_fnt);
    
    // 1. Подложка
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_roundrect_ext(_gui_x - 400, _gui_y - 260, _gui_x + 10, _gui_y + 10, 20, 20, false);
    draw_set_alpha(1.0);

    // 2. Заголовок
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(_gui_x - 195, _gui_y - 250, "СОВМЕСТИМОСТЬ");
    
    var _start_y = _gui_y - 205; 
    var _step = 32;              
    var _lx = _gui_x - 385;      

    draw_set_halign(fa_left);
    
    // --- СПИСОК ПРАВИЛ (Без спецсимволов) ---

    // ОГОНЬ
    draw_set_color(c_red);    draw_text(_lx, _start_y, "ОГОНЬ");
    draw_set_color(c_white);  draw_text(_lx + 105, _start_y, " + Ветер, Земля");

    // ВОДА
    draw_set_color(c_blue);   draw_text(_lx, _start_y + _step, "ВОДА");
    draw_set_color(c_white);  draw_text(_lx + 105, _start_y + _step, " + Ветер, Земля");

    // ВЕТЕР
    draw_set_color(c_aqua);   draw_text(_lx, _start_y + _step * 2, "ВЕТЕР");
    draw_set_color(c_white);  draw_text(_lx + 105, _start_y + _step * 2, " + Огонь, Вода");

    // ЗЕМЛЯ
    draw_set_color(c_orange); draw_text(_lx, _start_y + _step * 3, "ЗЕМЛЯ");
    draw_set_color(c_white);  draw_text(_lx + 105, _start_y + _step * 3, " + Огонь, Вода");

    // 3. СООБЩЕНИЕ ПРО ДУБЛИ
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_text(_gui_x - 195, _gui_y - 55, "ДУБЛИ - МОСТЫ\n(Универсальны)");

    // Сброс настроек
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
