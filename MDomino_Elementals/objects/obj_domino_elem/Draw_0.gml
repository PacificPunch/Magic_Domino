/// obj_domino_elem - Draw Event
if (!visible) exit;

var draw_col = c_white;
var show_face = false;
var final_alpha = 1.0;

// --- 1. ОПРЕДЕЛЯЕМ ВИДИМОСТЬ (ЛИЦО ИЛИ РУБАШКА) ---
if (owner == "player" || owner == "table" || global.game_over) {
    show_face = true;
} else if (owner == "computer") {
    if (global.is_showing_starter && id == global.starter_tile) show_face = true;
    else show_face = false;
}

// --- 2. ЛОГИКА ЦВЕТА И ЯРКОСТИ (ELEMENTAL) ---

// Проверяем доступность хода для подсветки
var can_play_left = (value1 == global.left_end || value2 == global.left_end) && 
                    (is_double || global.element_conflict[element] != global.left_element);
                    
var can_play_right = (value1 == global.right_end || value2 == global.right_end) && 
                     (is_double || global.element_conflict[element] != global.right_element);

var is_playable = (ds_list_size(global.table_chain) == 0) || (can_play_left || can_play_right);

if (show_face) {
    // А) ПРАВИЛО ДУБЛЕЙ: Все дубли — ярко-желтые (универсальные мосты)
    if (is_double) {
        draw_col = c_yellow;
    } 
    else {
        draw_col = c_white;
    }

    // Б) ПРАВИЛО ЯРКОСТИ: Если сейчас ход игрока и кость в руке
    if (owner == "player" && !global.game_over && !global.choice_mode) {
        if (global.current_turn == "player" && is_playable) {
            // Доступные кости делаем максимально яркими
            final_alpha = 1.0;
            // Если это не желтый дубль, можно чуть-чуть подсветить саму текстуру
            if (!is_double) draw_col = c_white; 
        } 
        else {
            // Недоступные кости сильно затемняем и делаем прозрачнее
            draw_col = c_dkgray; 
            final_alpha = 0.5;
        }
    }
}

// В) Логика мигания стартовой кости (сохраняем)
if (global.is_showing_starter && id == global.starter_tile) {
    var flash = 0.7 + sin(current_time * 0.01) * 0.3;
    draw_col = merge_color(draw_col, c_white, flash);
}

// Г) Подсветка краев стола в режиме выбора
if (global.choice_mode && owner == "table") {
    var is_edge = (id == global.left_tile_id || id == global.right_tile_id);
    if (is_edge) draw_col = c_yellow;
}

// --- 3. ИТОГОВАЯ ОТРИСОВКА ---
if (show_face) {
    // Рисуем основную кость
    draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, image_angle, draw_col, final_alpha);
    
    // Рисуем индикатор стихии (только для обычных костей, дубли и так желтые)
    if (!is_double) {
        var elem_col = c_white;
        switch(element) {
            case ELEMENT.EARTH: elem_col = c_orange; break;
            case ELEMENT.WATER: elem_col = c_blue;   break;
            case ELEMENT.AIR:   elem_col = c_aqua;   break;
            case ELEMENT.FIRE:  elem_col = c_red;    break;
        }
        // Рисуем цветной ореол стихии внутри кости (мягкое наложение)
        draw_sprite_ext(sprite_index, image_index, x, y, 0.95, 0.95, image_angle, elem_col, 0.3 * final_alpha);
    }
} else {
    // Рубашка для компьютера/базара
    draw_sprite_ext(spr_00, 0, x, y, 1, 1, image_angle, c_white, 1);
}

// --- 4. ЭФФЕКТ НАВЕДЕНИЯ (Только для доступных костей) ---
if (owner == "player" && is_playable && !global.choice_mode && global.current_turn == "player") {
    if (position_meeting(mouse_x, mouse_y, id)) {
        draw_set_color(c_yellow);
        draw_set_alpha(0.5);
        // Рисуем рамку вокруг яркой кости
        draw_rectangle(x-34, y-66, x+34, y+66, true);
        draw_set_alpha(1.0);
    }
}