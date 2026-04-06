/// obj_domino - Mouse Left Pressed

// 1. ПРОВЕРКА ГОТОВНОСТИ (Чтобы не было ошибок)
if (global.is_showing_starter) exit;
if (!variable_global_exists("choice_mode")) exit;

// 2. ЛОГИКА ВЫБОРА
if (global.choice_mode) {
    // Если мы в режиме выбора стороны (лево/право)
    if (owner == "table") {
        if (id == global.left_tile_id || id == global.right_tile_id) {
            var side = (id == global.left_tile_id) ? "left" : "right";
            global.play_domino(global.selected_domino, side);
        }
    }
} else {
    // Если мы выбираем кость из руки
    if (owner == "player" && global.current_turn == "player") {
        
        // Проверка: можно ли вообще положить эту кость
        var can_play = (ds_list_size(global.table_chain) == 0) ||
                       (value1 == global.left_end || value2 == global.left_end || 
                        value1 == global.right_end || value2 == global.right_end);
        
        if (can_play) {
            // Если подходит к обоим концам — включаем режим выбора
            var match_left = (value1 == global.left_end || value2 == global.left_end);
            var match_right = (value1 == global.right_end || value2 == global.right_end);
            
            if (match_left && match_right && ds_list_size(global.table_chain) > 0) {
                global.choice_mode = true;
                global.selected_domino = id;
            } else {
                // Если подходит только к одному — кладем сразу
                var side = match_left ? "left" : "right";
                if (ds_list_size(global.table_chain) == 0) side = "first";
                global.play_domino(id, side);
            }
        }
    }
}