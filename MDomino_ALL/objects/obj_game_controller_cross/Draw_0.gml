/// obj_game_controller - Draw Event

// Если сейчас активно мигание стартовой кости
if (variable_global_exists("is_showing_starter") && global.is_showing_starter) {
    
    var msg = (global.current_turn == "player") ? "Ваш ход" : "Ход противника";
    
    var font_id = asset_get_index("fnt_bazar");
    if (font_exists(font_id)) {
        draw_set_font(font_id);
    }
    
    // Выравниваем текст по центру
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Вычисляем координаты: ровно по центру экрана по осям X и Y
    var text_x = global.table_center_x;
    var text_y = global.table_center_y; 
    
    // Масштаб текста
    var scale = 2; 
    
    // 1. Рисуем черную тень со смещением
    draw_set_color(c_black);
    draw_text_transformed(text_x + 4, text_y + 4, msg, scale, scale, 0);
    
    // 2. Рисуем сам белый текст поверх тени
    draw_set_color(c_white);
    draw_text_transformed(text_x, text_y, msg, scale, scale, 0);
    
    // Сброс настроек отрисовки
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
}