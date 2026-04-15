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

// --- 2. ЛОГИКА ЦВЕТА И ДОСТУПНОСТИ ---
// УБРАНО: is_double || (теперь дубли подчиняются общим правилам конфликтов стихий)
var can_play_left = (value1 == global.left_end || value2 == global.left_end) && 
                    (global.element_conflict[element] != global.left_element);
                    
var can_play_right = (value1 == global.right_end || value2 == global.right_end) && 
                     (global.element_conflict[element] != global.right_element);

var is_playable = (ds_list_size(global.table_chain) == 0) || (can_play_left || can_play_right);

if (show_face) {
    draw_col = c_white; 

    // ПРАВИЛО ЯРКОСТИ: Если ход игрока
    if (owner == "player" && !global.game_over && !global.choice_mode) {
        if (global.current_turn == "player" && is_playable) {
            final_alpha = 1.0;
        } 
        else {
            draw_col = c_dkgray; 
            final_alpha = 0.5;
        }
    }
}

// --- 3. ИТОГОВАЯ ОТРИСОВКА ---
if (show_face) {
    // А) Отрисовка основной кости
    draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, image_angle, draw_col, final_alpha);
    
    // Б) Индикатор стихии (Для всех костей, включая дубли)
    var elem_col = c_white;
    switch(element) {
        case ELEMENT.EARTH: elem_col = c_green; break;
        case ELEMENT.WATER: elem_col = c_blue;  break;
        case ELEMENT.AIR:   elem_col = c_aqua;  break;
        case ELEMENT.FIRE:  elem_col = c_red;   break;
    }
    
    if (element != ELEMENT.NONE) {
        // Используем масштаб 1.0, чтобы точки стояли точно друг на друге
        draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, image_angle, elem_col, 0.4 * final_alpha);
    }

    // --- В) ПОДСВЕТКА ПРИ ВЫБОРЕ НАПРАВЛЕНИЯ (ЖЕЛТАЯ РАМКА) ---
    if (global.choice_mode) {
        var is_choice_target = (owner == "table" && (id == global.left_tile_id || id == global.right_tile_id));
        var is_being_placed = (id == global.selected_domino);
        
        if (is_choice_target || is_being_placed) {
            var pulse = 0.4 + sin(current_time * 0.01) * 0.2;
            draw_set_alpha(pulse);
            draw_set_color(c_yellow); // Изменено на желтый для консистентности выбора
            
            var w = 35; var h = 67;
            var angle_rad = degtorad(image_angle);
            var cos_a = cos(angle_rad); var sin_a = sin(angle_rad);

            var x1 = x + (-w * cos_a - (-h) * sin_a); var y1 = y + (-w * sin_a + (-h) * cos_a);
            var x2 = x + (w * cos_a - (-h) * sin_a);  var y2 = y + (w * sin_a + (-h) * cos_a);
            var x3 = x + (w * cos_a - h * sin_a);     var y3 = y + (w * sin_a + h * cos_a);
            var x4 = x + (-w * cos_a - h * sin_a);    var y4 = y + (-w * sin_a + h * cos_a);

            var thickness = 4;
            draw_line_width(x1, y1, x2, y2, thickness);
            draw_line_width(x2, y2, x3, y3, thickness);
            draw_line_width(x3, y3, x4, y4, thickness);
            draw_line_width(x4, y4, x1, y1, thickness);
            
            draw_set_alpha(1.0);
            draw_set_color(c_white);
        }
    }

} else {
    // Рубашка
    draw_sprite_ext(spr_00, 0, x, y, 1, 1, image_angle, c_white, 1);
}

// --- 4. РАМКА ПОДСВЕТКИ (ПРИ НАВЕДЕНИИ В РУКЕ) ---
if (owner == "player" && is_playable && !global.choice_mode && global.current_turn == "player") {
    if (position_meeting(mouse_x, mouse_y, id)) {
        draw_set_color(c_lime); // Зеленая рамка при наведении на доступную кость
        draw_set_alpha(1);
        draw_rectangle(x-34, y-66, x+34, y+66, true);
        draw_set_alpha(1.0);
        draw_set_color(c_white);
    }
}