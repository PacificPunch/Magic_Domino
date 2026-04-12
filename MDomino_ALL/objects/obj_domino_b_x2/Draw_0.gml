/// @desc obj_domino_b_x2 - Draw Event

if (!visible) exit;

var draw_col = c_white;
var show_face = false;

// --- 1. ОПРЕДЕЛЯЕМ ВИДИМОСТЬ (ЛИЦО ИЛИ РУБАШКА) ---
// В Блоке показываем лицо, если кость на столе, у игрока или игра окончена
if (owner == "player" || owner == "table" || global.game_over) {
    show_face = true;
} else if (owner == "computer") {
    // Показываем лицо бота только если это стартовая кость (анимация начала)
    if (global.is_showing_starter && id == global.starter_tile) show_face = true;
    else show_face = false;
}

// --- 2. ОПРЕДЕЛЯЕМ ЦВЕТ ---

// А) Затемнение недоступных костей (подсказка игроку)
if (owner == "player" && !global.game_over && !global.choice_mode) {
    var can_play = (ds_list_size(global.table_chain) == 0) || 
                   (value1 == global.left_end || value2 == global.left_end || 
                    value1 == global.right_end || value2 == global.right_end);
    
    // Если сейчас не наш ход или кость нельзя положить — красим в серый
    if (global.current_turn != "player" || !can_play) {
        draw_col = c_gray; 
    }
}

// Б) Эффект мигания для стартовой кости
if (global.is_showing_starter && id == global.starter_tile) {
    var flash = 0.7 + sin(current_time * 0.01) * 0.3;
    draw_col = make_color_rgb(255 * flash, 255 * flash, 255 * flash);
}

// В) Подсветка при выборе стороны (Choice Mode)
if (global.choice_mode) {
    var is_edge = (id == global.left_tile_id || id == global.right_tile_id);
    if (owner == "table" && is_edge) {
        draw_col = c_yellow; // Подсвечиваем доступные края стола
    }
    // Выбранная кость в руке остается белой
    if (id == global.selected_domino) draw_col = c_white; 
}

// --- 3. ИТОГОВАЯ ОТРИСОВКА ---
if (show_face) {
    // Рисуем спрайт костяшки (spr_01, spr_66 и т.д.)
    draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, image_angle, draw_col, 1);
} else {
    // Рисуем рубашку (используем спрайт 0-0 как заглушку или ваш спрайт рубашки)
    draw_sprite_ext(spr_00, 0, x, y, 1, 1, image_angle, c_white, 1);
}

// --- 4. РАМКА ПОДСВЕТКИ ПРИ НАВЕДЕНИИ ---
if (owner == "player" && !global.choice_mode && draw_col == c_white) {
    if (position_meeting(mouse_x, mouse_y, id)) {
        draw_set_color(c_yellow);
        // Рисуем прямоугольник вокруг костяшки
        // Размеры 33x65 подогнаны под кость 64x128
        draw_rectangle(x - 33, y - 65, x + 33, y + 65, true);
        draw_set_color(c_white);
    }
}

// --- 5. ЧИТ-КОД: ПРОСМОТР КОСТЕЙ КОМПЬЮТЕРА ---
if (keyboard_check(vk_tab) && owner == "computer") {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_lime); // Зеленый цвет для чит-подсказки
    
    var hint_text = string(value1) + ":" + string(value2);
    
    // Рисуем текст значения поверх рубашки
    draw_text_transformed(x, y, hint_text, 1.2, 1.2, 0);
    
    // Сброс настроек
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}