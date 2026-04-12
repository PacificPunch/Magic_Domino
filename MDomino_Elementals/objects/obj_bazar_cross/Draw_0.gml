/// @description obj_bazar_cross - Draw Event

// 1. ОПРЕДЕЛЕНИЕ ЦВЕТА БАЗАРА
// По умолчанию базар белый (белый цвет в GMS2 не меняет оригинальный спрайт)
var bazar_color = c_gray;

if (global.current_turn == "player" && !global.game_over) {
    // Проверяем, есть ли у игрока доступные ходы
    var has_moves = global.check_has_moves(global.player_hand);
    
    if (has_moves) {
        // Если ходить МОЖНО — базар серый (неактивный)
        bazar_color = c_gray;
    } else {
        // Если ходить НЕЛЬЗЯ — базар белый (активный/подсвеченный)
        bazar_color = c_white;
		draw_set_color(c_black);
    }
}

// 2. ОТРИСОВКА СПРАЙТА С НУЖНЫМ ЦВЕТОМ
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, bazar_color, 1);

// 3. ОТРИСОВКА ТЕКСТА (КОЛИЧЕСТВО КОСТЕЙ)
draw_set_font(fnt_bazar);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
//draw_set_color(c_black);

// Рисуем количество оставшихся костей в центре базара
draw_text(x, y, string(ds_list_size(global.bazar)));

/*// 4. ДОПОЛНИТЕЛЬНАЯ ИНДИКАЦИЯ (если нужно взять кость)
if (global.current_turn == "player" && !global.game_over) {
    if (!global.check_has_moves(global.player_hand) && ds_list_size(global.bazar) > 0) {
        // Если хода нет и кости есть — можно добавить небольшую рамку для привлечения внимания
        draw_set_alpha(0.3);
        draw_rectangle_color(bbox_left, bbox_top, bbox_right, bbox_bottom, c_yellow, c_yellow, c_yellow, c_yellow, false);
        draw_set_alpha(1.0);
    }
}
*/