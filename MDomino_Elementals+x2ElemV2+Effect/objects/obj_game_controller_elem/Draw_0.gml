/// obj_game_controller_elem - Draw Event

// --- 1. ОТРИСОВКА ИНДИКАЦИИ СТАРТА ---
if (variable_global_exists("is_showing_starter") && global.is_showing_starter) {
    var msg = (global.current_turn == "player") ? "Ваш ход" : "Ход противника";
    var font_id = asset_get_index("fnt_bazar");
    if (font_exists(font_id)) draw_set_font(font_id);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var text_x = global.table_center_x;
    var text_y = global.table_center_y;
    var scale = 2; 
    
    draw_set_color(c_black);
    draw_text_transformed(text_x + 4, text_y + 4, msg, scale, scale, 0); // Тень
    draw_set_color(c_white);
    draw_text_transformed(text_x, text_y, msg, scale, scale, 0); // Текст
    
    draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_font(-1);
}

// --- 2.5 ПОДСКАЗКА ПО ЭФФЕКТАМ ---
if (!global.game_over) {
    var _eff_x = 20;
    var _eff_y = 20; // Теперь сверху
    var _spr = asset_get_index("spr_00");
    var _scale = 0.35; 
    var _spacing = 35; 
    
    var _draw_effect = function(_x, _y, _spr, _scale, _color, _text) {
        if (_spr != -1) {
            // Рисуем саму костяшку горизонтально
            draw_sprite_ext(_spr, 0, _x + 20, _y + 15, _scale, _scale, 90, c_white, 1.0);
            // Цветная заливка поверх костяшки
            draw_sprite_ext(_spr, 0, _x + 20, _y + 15, _scale, _scale, 90, _color, 0.4);
        }
        
        draw_set_font(asset_get_index("fnt_bazar"));
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        draw_set_color(c_black); draw_text(_x + 45 + 2, _y + 15 + 2, _text); // Тень
        draw_set_color(_color);  draw_text(_x + 45, _y + 15, _text); // Текст
    };
    
    _draw_effect(_eff_x, _eff_y, _spr, _scale, c_red, "Огонь - сжигает костяшки");
    _draw_effect(_eff_x, _eff_y + _spacing, _spr, _scale, c_blue, "Вода - дает доп ход");
    _draw_effect(_eff_x, _eff_y + _spacing * 2, _spr, _scale, c_aqua, "Ветер - сбрасывает кость из руки");
    _draw_effect(_eff_x, _eff_y + _spacing * 3, _spr, _scale, c_green, "Земля - заставляет противника взять кость");
    
    draw_set_valign(fa_top); // Сброс выравнивания
}

// --- 2. ВИЗУАЛИЗАЦИЯ АКТИВНЫХ СТИХИЙ ПО КРАЯМ ---
if (!global.game_over && ds_list_size(global.table_chain) > 0) {
    var _row_y = 1080 - 25 - 260 - 30;
    var _fnt = asset_get_index("fnt_bazar");
    if (font_exists(_fnt)) draw_set_font(_fnt);
    draw_set_halign(fa_left); draw_set_valign(fa_middle);
    
    // Собираем текст и цвет для обоих краёв
    var _lname = ""; var _lcolor = c_white;
    var _rname = ""; var _rcolor = c_white;
    switch(global.left_element) {
        case ELEMENT.EARTH: _lcolor = c_green; _lname = "Земля"; break;
        case ELEMENT.WATER: _lcolor = c_blue;  _lname = "Вода"; break;
        case ELEMENT.AIR:   _lcolor = c_aqua;  _lname = "Воздух"; break;
        case ELEMENT.FIRE:  _lcolor = c_red;   _lname = "Огонь"; break;
    }
    switch(global.right_element) {
        case ELEMENT.EARTH: _rcolor = c_green; _rname = "Земля"; break;
        case ELEMENT.WATER: _rcolor = c_blue;  _rname = "Вода"; break;
        case ELEMENT.AIR:   _rcolor = c_aqua;  _rname = "Воздух"; break;
        case ELEMENT.FIRE:  _rcolor = c_red;   _rname = "Огонь"; break;
    }
    
    var _ltext = ( global.left_element != ELEMENT.NONE) ? ("Левый: " + _lname) : "";
    var _rtext = (global.right_element != ELEMENT.NONE) ? ("Правый: " + _rname) : "";
    var _gap   = 80;
    var _x1    = 10;
    
    if (_ltext != "") {
        draw_set_color(c_black); draw_text(_x1 + 2, _row_y + 2, _ltext);
        draw_set_color(_lcolor); draw_text(_x1, _row_y, _ltext);
    }
    if (_rtext != "") {
        var _x2 = _x1 + ((_ltext != "") ? (string_width(_ltext) + _gap) : 0);
        draw_set_color(c_black); draw_text(_x2 + 2, _row_y + 2, _rtext);
        draw_set_color(_rcolor); draw_text(_x2, _row_y, _rtext);
    }
    draw_set_valign(fa_top);
}

// --- 3. СООБЩЕНИЕ О ЗАВЕРШЕНИИ ИГРЫ ---
if (global.game_over && global.end_message != "") {
    draw_set_font(asset_get_index("fnt_bazar"));
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    
    draw_set_alpha(0.5); draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1.0);
    
    draw_set_color(c_black); draw_set_halign(fa_left); draw_set_valign(fa_top);
}

if (keyboard_check_direct(vk_tab)) {}

// --- 4. ШПАРГАЛКА ПО СТИХИЯМ (СЛЕВА) ---
if (!global.game_over) {
    var _gui_y = 1080 - 25; // Сдвинуто в самый низ экрана
    var _rect_left  = 0; var _rect_right = 440;
    var _center_x = (_rect_left + _rect_right) / 2; 
    
    var _fnt = asset_get_index("fnt_bazar");
    if (font_exists(_fnt)) draw_set_font(_fnt);
    
    draw_set_alpha(0.7); draw_set_color(c_black);
    draw_roundrect_ext(_rect_left - 20, _gui_y - 260, _rect_right, _gui_y + 25, 20, 20, false);
    draw_set_alpha(1.0);

    draw_set_color(c_white); draw_set_halign(fa_center); draw_set_valign(fa_top);
    draw_text(_center_x, _gui_y - 240, "СОВМЕСТИМОСТЬ");
    
    var _cx = _center_x; var _cy = _gui_y - 105; 
    var _r_v = 85; var _r_h = 120; 
    draw_set_valign(fa_middle); 

    draw_set_color(c_red);   draw_text(_cx, _cy - _r_v, "ОГОНЬ");
    draw_set_color(c_blue);  draw_text(_cx, _cy + _r_v, "ВОДА");
    draw_set_color(c_green); draw_text(_cx - _r_h, _cy, "ЗЕМЛЯ");
    draw_set_color(c_aqua);  draw_text(_cx + _r_h, _cy, "ВОЗДУХ");

    draw_set_color(c_lime);
    var _arr_size = 12; var _px = 25; var _py = 20;
    var _pad_v = _r_v - 15; var _pad_h = _r_h - 45;
    // Двухсторонние зеленые стрелки (Цикл совместимости)
    draw_arrow(_cx + _px, _cy - _pad_v, _cx + _pad_h, _cy - _py, _arr_size);   // ОГОНЬ → ВОЗДУХ
    draw_arrow(_cx + _pad_h, _cy - _py, _cx + _px, _cy - _pad_v, _arr_size);   // ВОЗДУХ → ОГОНЬ
    draw_arrow(_cx + _pad_h, _cy + _py, _cx + _px, _cy + _pad_v, _arr_size);   // ВОЗДУХ → ВОДА
    draw_arrow(_cx + _px, _cy + _pad_v, _cx + _pad_h, _cy + _py, _arr_size);   // ВОДА → ВОЗДУХ
    draw_arrow(_cx - _px, _cy + _pad_v, _cx - _pad_h, _cy + _py, _arr_size);   // ВОДА → ЗЕМЛЯ
    draw_arrow(_cx - _pad_h, _cy + _py, _cx - _px, _cy + _pad_v, _arr_size);   // ЗЕМЛЯ → ВОДА
    draw_arrow(_cx - _pad_h, _cy - _py, _cx - _px, _cy - _pad_v, _arr_size);   // ЗЕМЛЯ → ОГОНЬ
    draw_arrow(_cx - _px, _cy - _pad_v, _cx - _pad_h, _cy - _py, _arr_size);   // ОГОНЬ → ЗЕМЛЯ

    draw_set_color(c_red);
    var _red_v = 60; var _red_h = 75;
    draw_arrow(_cx, _cy - _red_v, _cx, _cy + _red_v, _arr_size); draw_arrow(_cx, _cy + _red_v, _cx, _cy - _red_v, _arr_size);
    draw_arrow(_cx - _red_h, _cy, _cx + _red_h, _cy, _arr_size); draw_arrow(_cx + _red_h, _cy, _cx - _red_h, _cy, _arr_size);

    draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
}

// --- 5. ПАНЕЛЬ ВСЕХ ДОМИНО (СПРАВА - ДВУХЦВЕТНЫЙ ТРЕКЕР) ---
if (!global.game_over) {
    var _panel_w = 350; 
    var _rd_left = 1920 - _panel_w; 
    var _rd_right = 1920; 
    
    var _rd_h = 474; // 50 (top) + 6*62 (rows) + 27 (half domino) + 25 (bottom padding)
    var _rd_top = 1080 - _rd_h; 
    var _cx_d = (_rd_left + _rd_right) / 2;
    
    draw_set_alpha(0.7); draw_set_color(c_black);
    draw_roundrect_ext(_rd_left, _rd_top, _rd_right + 20, 1080, 20, 20, false);
    draw_set_alpha(1.0);
    
    var _scale = 0.42; var _pad_x = 48; var _pad_y = 62;
    var _grid_start_y = _rd_top + 50; 
    
    for (var i = 0; i <= 6; i++) {
        var _v2 = 6 - i; var _row_w = i * _pad_x; var _start_x = _cx_d - (_row_w / 2);
        for (var _v1 = 6; _v1 >= _v2; _v1--) {
            var _spr_name = "spr_" + string(min(_v1, _v2)) + string(max(_v1, _v2));
            var _spr = asset_get_index(_spr_name);
            
            if (_spr != -1) {
                var _dx = _start_x + ((6 - _v1) * _pad_x);
                var _dy = _grid_start_y + (i * _pad_y);
                
                // --- СЧИТЫВАЕМ ДВЕ СТИХИИ ---
                var _e1 = ELEMENT.NONE; var _e2 = ELEMENT.NONE;
                if (ds_map_exists(global.domino_elemental_map, _spr_name)) {
                    var _val = global.domino_elemental_map[? _spr_name];
                    if (is_array(_val)) { _e1 = _val[0]; _e2 = _val[1]; } 
                    else { _e1 = _val; _e2 = _val; } // Защита от старых сохранений
                }

                // Проверка видимости
                var _is_played = false; var _known = false;
                if (variable_global_exists("table_chain")) {
                    for(var k = 0; k < ds_list_size(global.table_chain); k++) {
                        var _t = global.table_chain[| k];
                        if ((_t.value1 == _v1 && _t.value2 == _v2) || (_t.value1 == _v2 && _t.value2 == _v1)) {
                            _is_played = true; _known = true; break;
                        }
                    }
                }
                if (!_is_played && variable_global_exists("player_hand")) {
                    for(var k = 0; k < ds_list_size(global.player_hand); k++) {
                        var _p = global.player_hand[| k];
                        if ((_p.value1 == _v1 && _p.value2 == _v2) || (_p.value1 == _v2 && _p.value2 == _v1)) {
                            _known = true; break;
                        }
                    }
                }
                // История сыгранных/уничтоженных: если кость уже была сыграна или сброшена, остаёмся известной навсегда
                if (!_known && variable_global_exists("known_dominos")) {
                    if (ds_map_exists(global.known_dominos, _spr_name)) _known = true;
                }
                if (!_known) {
                    with (obj_domino_elem) {
                        if (effect_blink_timer > 0) {
                            if ((value1 == _v1 && value2 == _v2) || (value1 == _v2 && value2 == _v1)) {
                                other._known = true;
                                break;
                            }
                        }
                    }
                }

                var _base_alpha = _is_played ? 0.6 : 1.0;
                draw_sprite_ext(_spr, 0, _dx, _dy, _scale, _scale, 0, c_white, _base_alpha);
                
                // ДВУХЦВЕТНАЯ ЗАЛИВКА
                if (_known || show_cheat_colors) {
                    var _colors = [c_white, c_white];
                    var _elems = [_e1, _e2];
                    for(var m=0; m<2; m++) {
                        switch(_elems[m]) {
                            case ELEMENT.EARTH: _colors[m] = c_green; break;
                            case ELEMENT.WATER: _colors[m] = c_blue;  break;
                            case ELEMENT.AIR:   _colors[m] = c_aqua;  break;
                            case ELEMENT.FIRE:  _colors[m] = c_red;   break;
                        }
                    }
                    // Рисуем верхнюю половинку
                    draw_sprite_general(_spr, 0, 0, 0, 64, 64, _dx - (32*_scale), _dy - (64*_scale), _scale, _scale, 0, _colors[0], _colors[0], _colors[0], _colors[0], 0.4 * _base_alpha);
                    // Рисуем нижнюю половинку
                    draw_sprite_general(_spr, 0, 0, 64, 64, 64, _dx - (32*_scale), _dy, _scale, _scale, 0, _colors[1], _colors[1], _colors[1], _colors[1], 0.4 * _base_alpha);
                }
            }
        }
    }
}