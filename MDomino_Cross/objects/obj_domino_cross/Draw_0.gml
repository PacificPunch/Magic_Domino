/// obj_domino_cross - Draw Event

// 1. Отрисовка самой кости
draw_self();

// 2. Логика подсветки доступных ходов в руке игрока
if (owner == "player" && global.current_turn == "player" && !global.game_over) {
    
    var can_be_played = false;
    
    if (ds_list_size(global.table_chain) == 0) {
        // Если стол пуст, подсвечиваем только дубли
        if (value1 == value2) can_be_played = true;
    } else {
        // Проверяем по всем 4 направлениям Креста
        var side_names = ["up", "down", "left", "right"];
        for (var i = 0; i < 4; i++) {
            var s_data = variable_struct_get(global.ends, side_names[i]);
            // Если ветка активна и значения совпадают
            if (s_data.active && (value1 == s_data.val || value2 == s_data.val)) {
                can_be_played = true;
                break; 
            }
        }
    }

    // Если кость можно выложить — рисуем желтую рамку или свечение
    if (can_be_played) {
        draw_set_alpha(0.4);
        gpu_set_blendmode(bm_add); // Режим наложения для эффекта свечения
        draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_yellow, 0.5);
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1.0);
    }
}

// 3. Дополнительная индикация для выбора стороны (choice_mode)
if (global.choice_mode && global.selected_domino == id) {
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale + 0.1, image_yscale + 0.1, image_angle, c_aqua, 0.6);
}