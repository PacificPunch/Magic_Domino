/// obj_domino_elem - Mouse Left Pressed

// Блокировка кликов во время анимации старта
if (global.is_showing_starter) exit;

// Ходить можно только в свой ход и если игра не окончена
if (global.game_over || global.current_turn != "player") exit;

// --- 1. ЛОГИКА ВЫБОРА НАПРАВЛЕНИЯ (Choice Mode) ---
if (global.choice_mode) {
    if (owner == "table") {
        if (id == global.left_tile_id) {
            global.play_domino(global.selected_domino, "left");
            exit;
        }
        if (id == global.right_tile_id) {
            global.play_domino(global.selected_domino, "right");
            exit;
        }
    }
    exit;
}

// --- 2. ЛОГИКА ВЫБОРА КОСТИ В РУКЕ ---
if (owner == "player") {
    
    // Если стол пуст
    if (ds_list_size(global.table_chain) == 0) {
        global.play_domino(id, "first");
        exit;
    }

    // Проверка совместимости (Цифра + Стихия)
    // УБРАНО: is_double (теперь дубли подчиняются конфликтам стихий)
    var can_l = (value1 == global.left_end || value2 == global.left_end) && 
                (global.element_conflict[element] != global.left_element);
                
    var can_r = (value1 == global.right_end || value2 == global.right_end) && 
                (global.element_conflict[element] != global.right_element);
    
    // Выбор направления
    if (can_l && can_r && (global.left_end != global.right_end || global.left_element != global.right_element)) {
        global.choice_mode = true;
        global.selected_domino = id;
        y -= 60; 
    }
    else if (can_l) {
        global.play_domino(id, "left");
    }
    else if (can_r) {
        global.play_domino(id, "right");
    }
}