/// obj_bazar_cross - Draw Event

draw_self();

draw_set_font(fnt_bazar);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);

// Отображаем количество костей в базаре
draw_text(x, y, string(ds_list_size(global.bazar)));

// Логика подсветки (индикация, нужно ли игроку идти в базар)
if (global.current_turn == "player" && !global.game_over) {
    
    // Проверяем, есть ли у игрока ходы по новым правилам Креста
    var has_moves = global.check_has_moves(global.player_hand);
    
    // Если ходов нет и базар не пуст — подсвечиваем кнопку базара
    if (!has_moves && ds_list_size(global.bazar) > 0) {
        draw_set_alpha(0.3);
        draw_rectangle_color(bbox_left, bbox_top, bbox_right, bbox_bottom, c_yellow, c_yellow, c_yellow, c_yellow, false);
        draw_set_alpha(1.0);
        
        draw_text(x, y + 40, "ВОЗЬМИТЕ КОСТЬ");
    }
}