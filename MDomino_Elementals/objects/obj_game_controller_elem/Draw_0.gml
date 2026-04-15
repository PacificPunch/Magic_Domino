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


// Управление выходом
if (keyboard_check_direct(vk_tab)) {}

// --- 4. ШПАРГАЛКА ПО СТИХИЯМ (ТЕПЕРЬ СЛЕВА) ---
if (!global.game_over) {
    var _margin = 30;
    var _gui_y = 1030 - _margin;
    
    // Координаты подложки (ЛЕВАЯ СТОРОНА)
    var _rect_left  = 0;
    var _rect_right = 440;
    var _center_x = (_rect_left + _rect_right) / 2; 
    
    var _fnt = asset_get_index("fnt_bazar");
    if (font_exists(_fnt)) draw_set_font(_fnt);
    
    // 1. Подложка (с небольшим вылетом влево для красоты)
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_roundrect_ext(_rect_left - 20, _gui_y - 260, _rect_right, _gui_y + 25, 20, 20, false);
    draw_set_alpha(1.0);

    // 2. Заголовок
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(_center_x, _gui_y - 240, "СОВМЕСТИМОСТЬ");
    
    // Центр круга
    var _cx = _center_x;
    var _cy = _gui_y - 105; 
    var _r_v = 85;  // Вертикальный радиус
    var _r_h = 120; // Горизонтальный радиус
    
    draw_set_valign(fa_middle); 

    // Отрисовка слов
    draw_set_color(c_red);   draw_text(_cx, _cy - _r_v, "ОГОНЬ");
    draw_set_color(c_blue);  draw_text(_cx, _cy + _r_v, "ВОДА");
    draw_set_color(c_green); draw_text(_cx - _r_h, _cy, "ЗЕМЛЯ");
    draw_set_color(c_aqua);  draw_text(_cx + _r_h, _cy, "ВОЗДУХ");

    // Зеленые стрелки (c_lime)
    draw_set_color(c_lime);
    var _arr_size = 12; 
    var _px = 25; var _py = 20;
    var _pad_v = _r_v - 15; var _pad_h = _r_h - 45;
    
    draw_arrow(_cx + _px, _cy - _pad_v, _cx + _pad_h, _cy - _py, _arr_size);
    draw_arrow(_cx + _pad_h, _cy + _py, _cx + _px, _cy + _pad_v, _arr_size);
    draw_arrow(_cx - _px, _cy + _pad_v, _cx - _pad_h, _cy + _py, _arr_size);
    draw_arrow(_cx - _pad_h, _cy - _py, _cx - _px, _cy - _pad_v, _arr_size);

    // Красные стрелки (Конфликты)
    draw_set_color(c_red);
    var _red_v = 60; var _red_h = 75;
    draw_arrow(_cx, _cy - _red_v, _cx, _cy + _red_v, _arr_size);
    draw_arrow(_cx, _cy + _red_v, _cx, _cy - _red_v, _arr_size);
    draw_arrow(_cx - _red_h, _cy, _cx + _red_h, _cy, _arr_size);
    draw_arrow(_cx + _red_h, _cy, _cx - _red_h, _cy, _arr_size);

    draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
}

// --- 6. ПАНЕЛЬ ВСЕХ ДОМИНО (СПРАВА - КОМПАКТНЫЙ ТАКТИЧЕСКИЙ ТРЕКЕР) ---
if (!global.game_over) {
    // Координаты подложки
    var _panel_w = 350; 
    var _rect_left_d = 1920 - _panel_w; 
    var _rect_right_d = 1920;
    var _rect_bottom_d = 1080;
    
    // ИЗМЕНЕНИЕ: Подняли верхнюю границу подложки, чтобы кости не вылезали (было 600)
    var _rect_top_d = 560; 
    var _cx_d = (_rect_left_d + _rect_right_d) / 2;
    
    // 1. Подложка
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    // Рисуем с небольшим запасом сверху и справа для скругления
    draw_roundrect_ext(_rect_left_d, _rect_top_d, _rect_right_d + 20, _rect_bottom_d + 20, 20, 20, false);
    draw_set_alpha(1.0);
    
    // 2. Параметры сетки
    var _scale = 0.42; 
    var _pad_x = 48; 
    var _pad_y = 62;
    
    // Оставляем отступ 25 пикселей от нового верхнего края подложки
    var _grid_start_y = _rect_top_d + 50; 
    
    for (var i = 0; i <= 6; i++) {
        var _v2 = 6 - i;
        var _row_w = i * _pad_x;
        var _start_x = _cx_d - (_row_w / 2);
        
        for (var _v1 = 6; _v1 >= _v2; _v1--) {
            var _val_min = min(_v1, _v2);
            var _val_max = max(_v1, _v2);
            var _spr_name = "spr_" + string(_val_min) + string(_val_max);
            var _spr = asset_get_index(_spr_name);
            
            if (_spr != -1) {
                var _col_idx = 6 - _v1;
                var _dx = _start_x + (_col_idx * _pad_x);
                var _dy = _grid_start_y + (i * _pad_y);
                
                // Получаем стихию
                var _elem = ELEMENT.NONE;
                if (variable_global_exists("domino_elemental_map") && ds_map_exists(global.domino_elemental_map, _spr_name)) {
                    _elem = global.domino_elemental_map[? _spr_name];
                }
                
                var _col = c_white;
                switch(_elem) {
                    case ELEMENT.EARTH: _col = c_green; break;
                    case ELEMENT.WATER: _col = c_blue;  break;
                    case ELEMENT.AIR:   _col = c_aqua;  break;
                    case ELEMENT.FIRE:  _col = c_red;   break;
                }

                // Логика видимости
                var _is_played = false; 
                var _in_player_hand = false; 
                
                if (variable_global_exists("table_chain")) {
                    for(var k = 0; k < ds_list_size(global.table_chain); k++) {
                        var _t = global.table_chain[| k];
                        if ((_t.value1 == _v1 && _t.value2 == _v2) || (_t.value1 == _v2 && _t.value2 == _v1)) {
                            _is_played = true; 
                            break;
                        }
                    }
                }
                
                if (!_is_played && variable_global_exists("player_hand")) {
                    for(var k = 0; k < ds_list_size(global.player_hand); k++) {
                        var _p = global.player_hand[| k];
                        if ((_p.value1 == _v1 && _p.value2 == _v2) || (_p.value1 == _v2 && _p.value2 == _v1)) {
                            _in_player_hand = true; 
                            break;
                        }
                    }
                }

                // --- ОТРИСОВКА ---
                var _base_alpha = _is_played ? 0.6 : 1.0;
                
                draw_sprite_ext(_spr, 0, _dx, _dy, _scale, _scale, 0, c_white, _base_alpha);
                
                if ((_is_played || _in_player_hand) && _elem != ELEMENT.NONE) {
                    draw_sprite_ext(_spr, 0, _dx, _dy, _scale, _scale, 0, _col, 0.4 * _base_alpha);
                }
            }
        }
    }
}














