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

// --- 2. ВИЗУАЛИЗАЦИЯ АКТИВНЫХ СТИХИЙ ПО КРАЯМ ---
if (!global.game_over && ds_list_size(global.table_chain) > 0) {
    var _draw_element_info = function(_x, _y, _elem, _label) {
        if (_elem == ELEMENT.NONE) return;
        var _color = c_white; var _name = "";
        switch(_elem) {
            case ELEMENT.EARTH: _color = c_green; _name = "Земля"; break; // Изменил на c_green для единства
            case ELEMENT.WATER: _color = c_blue;   _name = "Вода"; break;
            case ELEMENT.AIR:   _color = c_aqua;   _name = "Воздух"; break;
            case ELEMENT.FIRE:  _color = c_red;    _name = "Огонь"; break;
        }
        draw_set_font(asset_get_index("fnt_bazar"));
        draw_set_color(c_black); draw_text(_x + 2, _y + 2, _label + ": " + _name); // Тень
        draw_set_color(_color);  draw_text(_x, _y, _label + ": " + _name);
    }
    // Показываем стихии на обоих концах (можно настроить координаты _x, _y по вкусу)
    _draw_element_info(20, 20, global.left_element, "Левый край");
    _draw_element_info(20, 60, global.right_element, "Правый край");
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
    var _margin = 30; var _gui_y = 1030 - _margin;
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
    draw_arrow(_cx + _px, _cy - _pad_v, _cx + _pad_h, _cy - _py, _arr_size);
    draw_arrow(_cx + _pad_h, _cy + _py, _cx + _px, _cy + _pad_v, _arr_size);
    draw_arrow(_cx - _px, _cy + _pad_v, _cx - _pad_h, _cy + _py, _arr_size);
    draw_arrow(_cx - _pad_h, _cy - _py, _cx - _px, _cy - _pad_v, _arr_size);

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
    var _rd_right = 1920; var _rd_top = 560; 
    var _cx_d = (_rd_left + _rd_right) / 2;
    
    draw_set_alpha(0.7); draw_set_color(c_black);
    draw_roundrect_ext(_rd_left, _rd_top, _rd_right + 20, 1080 + 20, 20, 20, false);
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

                // --- ОТРИСОВКА ---
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