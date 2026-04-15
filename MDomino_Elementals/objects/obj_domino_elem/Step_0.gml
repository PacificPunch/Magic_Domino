/// obj_domino_elem - Step Event

if (owner != "player") exit;
if (global.is_showing_starter) exit;
if (!variable_global_exists("game_over") || !variable_global_exists("current_turn")) exit;
if (global.game_over || global.current_turn != "player") exit;

// 1. Начало перетаскивания
if (mouse_check_button_pressed(mb_left) && position_meeting(mouse_x, mouse_y, id)) {
    if (!global.choice_mode) {
        dragging = true;
        selected = true;
        offset_x = x - mouse_x;
        offset_y = y - mouse_y;
        depth = -300;
    }
}

// 2. Процесс движения
if (dragging) {
    x = mouse_x + offset_x;
    y = mouse_y + offset_y;
}

// 3. Момент отпускания
if (mouse_check_button_released(mb_left) && dragging) {
    dragging = false;
    selected = false;
    depth = -200;
    var placed = false;
    
    if (ds_list_size(global.table_chain) == 0) {
        global.play_domino(id, "first");
        placed = true;
    } 
    else {
        // --- ПРОВЕРКА ВОЗМОЖНОСТИ ХОДА ---
        
        // Левый край: Цифра совпадает И стихия НЕ конфликтует (Дубли теперь проверяются так же)
        var match_left = (value1 == global.left_end || value2 == global.left_end) && 
                         (global.element_conflict[element] != global.left_element);
                         
        // Правый край: Цифра совпадает И стихия НЕ конфликтует
        var match_right = (value1 == global.right_end || value2 == global.right_end) && 
                          (global.element_conflict[element] != global.right_element);

        if (match_left && match_right && (global.left_end != global.right_end)) {
            global.choice_mode = true;
            global.selected_domino = id;
            y = global.table_center_y + 250; 
            placed = true; 
        } 
        else if (match_left) { 
            global.play_domino(id, "left"); 
            placed = true; 
        }
        else if (match_right) { 
            global.play_domino(id, "right"); 
            placed = true; 
        }
    }
    
    if (!placed) {
        if (instance_exists(obj_player_hand_elem)) {
            with (obj_player_hand_elem) arrange_player_hand();
        }
    }
}