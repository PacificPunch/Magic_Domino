/// obj_domino_elem - Draw Event
if (!visible) exit;

var draw_col = c_white;
var show_face = false;
var final_alpha = 1.0;

// --- 1. ОПРЕДЕЛЯЕМ ВИДИМОСТЬ ---
if (owner == "player" || owner == "table" || global.game_over) {
    show_face = true;
} else if (owner == "computer") {
    if (global.is_showing_starter && id == global.starter_tile) show_face = true;
    else show_face = false;
}

// --- 2. ЛОГИКА ЦВЕТА И ДОСТУПНОСТИ (НОВЫЕ ПРАВИЛА) ---
var can_play_left = false;
var can_play_right = false;

// Проверяем каждую половинку независимо
if (variable_global_exists("element_conflict")) {
    can_play_left = (value1 == global.left_end && global.element_conflict[element1] != global.left_element) || 
                    (value2 == global.left_end && global.element_conflict[element2] != global.left_element);
                    
    can_play_right = (value1 == global.right_end && global.element_conflict[element1] != global.right_element) || 
                     (value2 == global.right_end && global.element_conflict[element2] != global.right_element);
}

var is_playable = (ds_list_size(global.table_chain) == 0) || (can_play_left || can_play_right);

if (show_face) {
    draw_col = c_white; 

    // ПРАВИЛО ЯРКОСТИ: Затемняем недоступные кости
    if (owner == "player" && !global.game_over && !global.choice_mode) {
        if (global.current_turn == "player" && is_playable) {
            final_alpha = 1.0;
        } 
        else {
            draw_col = c_dkgray;
            final_alpha = 0.5;
        }
    }
    
    // МИГАНИЕ СТАРТОВОЙ КОСТИ
    if (global.is_showing_starter && id == global.starter_tile) {
        draw_col = c_white; 
        final_alpha = 0.3 + abs(sin(current_time * 0.005)) * 0.7; 
    }
}

// --- ВСПОМОГАТЕЛЬНАЯ ФУНКЦИЯ ДЛЯ РАМОК ---
var draw_rotated_frame = function(_x, _y, _angle, _color, _alpha) {
    var w = 35; var h = 67; // Размеры половины кости для рамки
    var angle_rad = degtorad(_angle);
    var cos_a = cos(angle_rad); var sin_a = sin(angle_rad);

    var x1 = _x + (-w * cos_a - (-h) * sin_a); var y1 = _y + (-w * sin_a + (-h) * cos_a);
    var x2 = _x + (w * cos_a - (-h) * sin_a);  var y2 = _y + (w * sin_a + (-h) * cos_a);
    var x3 = _x + (w * cos_a - h * sin_a);     var y3 = _y + (w * sin_a + h * cos_a);
    var x4 = _x + (-w * cos_a - h * sin_a);    var y4 = _y + (-w * sin_a + h * cos_a);

    draw_set_color(_color);
    draw_set_alpha(_alpha);
    var thickness = 4;
    draw_line_width(x1, y1, x2, y2, thickness);
    draw_line_width(x2, y2, x3, y3, thickness);
    draw_line_width(x3, y3, x4, y4, thickness);
    draw_line_width(x4, y4, x1, y1, thickness);
};

// --- 3. ИТОГОВАЯ ОТРИСОВКА ---
if (show_face) {
    // А) Основной спрайт кости (с точками)
    draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, image_angle, draw_col, final_alpha);
    
    // Б) ДВУХЦВЕТНАЯ ОТРИСОВКА СТИХИЙ
    if (element1 != ELEMENT.NONE || element2 != ELEMENT.NONE) {
        var _c1 = c_white; var _c2 = c_white;
        
        // Определяем цвет верхней половинки
        if (element1 == ELEMENT.EARTH) _c1 = c_green; else if (element1 == ELEMENT.WATER) _c1 = c_blue;
        else if (element1 == ELEMENT.AIR) _c1 = c_aqua; else if (element1 == ELEMENT.FIRE) _c1 = c_red;
        
        // Определяем цвет нижней половинки
        if (element2 == ELEMENT.EARTH) _c2 = c_green; else if (element2 == ELEMENT.WATER) _c2 = c_blue;
        else if (element2 == ELEMENT.AIR) _c2 = c_aqua; else if (element2 == ELEMENT.FIRE) _c2 = c_red;
        
        // Параметры спрайта для точного разделения
        var _sw = sprite_get_width(sprite_index);
        var _sh = sprite_get_height(sprite_index);
        var _cx = sprite_get_xoffset(sprite_index);
        var _cy = sprite_get_yoffset(sprite_index);
        var _half_h = _sh / 2;
        
        // Отрисовка верхней стихии (для value1)
        if (element1 != ELEMENT.NONE) {
            var dist_t = point_distance(0, 0, -_cx, -_cy);
            var dir_t  = point_direction(0, 0, -_cx, -_cy);
            var top_x = x + lengthdir_x(dist_t, dir_t + image_angle);
            var top_y = y + lengthdir_y(dist_t, dir_t + image_angle);
            draw_sprite_general(sprite_index, image_index, 0, 0, _sw, _half_h, top_x, top_y, 1, 1, image_angle, _c1, _c1, _c1, _c1, 0.4 * final_alpha);
        }
        
        // Отрисовка нижней стихии (для value2)
        if (element2 != ELEMENT.NONE) {
            var dist_b = point_distance(0, 0, -_cx, -_cy + _half_h);
            var dir_b  = point_direction(0, 0, -_cx, -_cy + _half_h);
            var bot_x = x + lengthdir_x(dist_b, dir_b + image_angle);
            var bot_y = y + lengthdir_y(dist_b, dir_b + image_angle);
            draw_sprite_general(sprite_index, image_index, 0, _half_h, _sw, _half_h, bot_x, bot_y, 1, 1, image_angle, _c2, _c2, _c2, _c2, 0.4 * final_alpha);
        }
    }

    // В) ПОДСВЕТКА ВЫБОРА НАПРАВЛЕНИЯ (Желтая рамка)
    if (global.choice_mode) {
        var is_choice_target = (owner == "table" && (id == global.left_tile_id || id == global.right_tile_id));
        var is_being_placed = (id == global.selected_domino);
        
        if (is_choice_target || is_being_placed) {
            var pulse = 0.4 + sin(current_time * 0.01) * 0.2;
            draw_rotated_frame(x, y, image_angle, c_yellow, pulse);
            draw_set_alpha(1.0); draw_set_color(c_white);
        }
    }

} else {
    // Рубашка
    draw_sprite_ext(spr_00, 0, x, y, 1, 1, image_angle, c_white, 1);
}

// --- 4. РАМКА ПОДСВЕТКИ (Зеленая рамка при наведении) ---
if (owner == "player" && is_playable && !global.choice_mode && global.current_turn == "player") {
    if (position_meeting(mouse_x, mouse_y, id)) {
        
        draw_rotated_frame(x, y, image_angle, c_lime, 1.0);
        
        if (ds_list_size(global.table_chain) > 0) {
            if (can_play_left && global.left_tile_id != noone && instance_exists(global.left_tile_id)) {
                draw_rotated_frame(global.left_tile_id.x, global.left_tile_id.y, global.left_tile_id.image_angle, c_lime, 1.0);
            }
            if (can_play_right && global.right_tile_id != noone && instance_exists(global.right_tile_id)) {
                draw_rotated_frame(global.right_tile_id.x, global.right_tile_id.y, global.right_tile_id.image_angle, c_lime, 1.0);
            }
        }
        
        draw_set_alpha(1.0); draw_set_color(c_white); 
    }
}