/// obj_domino - Draw Event
if (!visible) exit;

var draw_col = c_white;
var show_face = false;

// --- 1. ОПРЕДЕЛЯЕМ ВИДИМОСТЬ (ЛИЦО ИЛИ РУБАШКА) ---
if (owner == "player" || owner == "table" || global.game_over) {
    show_face = true;
} else if (owner == "computer") {
    if (global.is_showing_starter && id == global.starter_tile) show_face = true;
    else show_face = false;
}

// --- 2. ОПРЕДЕЛЯЕМ ЦВЕТ ---

// А) Логика затемнения недоступных костей в руке игрока
if (owner == "player" && !global.game_over && !global.choice_mode) {
    var can_play = (ds_list_size(global.table_chain) == 0) || 
                   (value1 == global.left_end || value2 == global.left_end || 
                    value1 == global.right_end || value2 == global.right_end);
    
    if (global.current_turn != "player" || !can_play) {
        draw_col = c_gray; // Затемняем
    }
}

// Б) Логика мигания стартовой кости
if (global.is_showing_starter && id == global.starter_tile) {
    var flash = 0.7 + sin(current_time * 0.01) * 0.3;
    draw_col = make_color_rgb(255 * flash, 255 * flash, 255 * flash);
}

// В) Логика режима выбора (в Draw Event)
if (global.choice_mode) {
    var is_edge = (id == global.left_tile_id || id == global.right_tile_id);
    if (owner == "table" && is_edge) {
        draw_col = c_yellow; // Подсвечиваем КРАЯ
    }
    // Выбранную кость в руке НЕ красим в желтый, она просто поднята
    if (id == global.selected_domino) draw_col = c_white; 
}

// --- 3. ИТОГОВАЯ ОТРИСОВКА ---
if (show_face) {
    draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, image_angle, draw_col, 1);
} else {
    draw_sprite_ext(spr_00, 0, x, y, 1, 1, image_angle, c_white, 1);
}

// РАМКА ПОДСВЕТКИ ДЛЯ ИГРОКА (только когда нет режима выбора)
if (owner == "player" && !global.choice_mode && draw_col == c_white) {
    if (position_meeting(mouse_x, mouse_y, id)) {
        draw_set_color(c_yellow);
        draw_rectangle(x-33, y-65, x+33, y+65, true);
        draw_set_color(c_white);
    }
}

// --- ЧИТ-КОД: ТЕКСТОВАЯ ПОДСКАЗКА ---
if (keyboard_check(vk_tab) && owner == "computer") {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white); // Цвет текста подсказки
    
    // Можно настроить шрифт, если есть специальный, иначе стандартный
    // draw_set_font(fnt_small); 

    var hint_text = string(value1) + string(value2);
    
    // Рисуем текст чуть выше центра костяшки, чтобы он был заметен
    draw_text_transformed(x, y+86, hint_text, 1.5, 1.5, 0);
    
    // Сброс настроек рисования, чтобы не испортить остальную графику
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}