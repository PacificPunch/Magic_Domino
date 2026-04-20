/// obj_domino_elem - Mouse Left Pressed

// Блокировка кликов во время анимации эффекта
if (variable_global_exists("effect_animating") && global.effect_animating) exit;

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

    // --- ПРОВЕРКА ВОЗМОЖНОСТИ ХОДА (НОВЫЕ ПРАВИЛА 2-Х СТИХИЙ) ---
    
    // Левый край: проверяем первую и вторую половинку отдельно
    var can_match_l = (global.left_end == -1 || global.left_element == ELEMENT.LOTOS);
    var can_l_v1 = (value1 == global.left_end || can_match_l) && (global.element_conflict[element1] != global.left_element || global.left_element == ELEMENT.LOTOS);
    var can_l_v2 = (value2 == global.left_end || can_match_l) && (global.element_conflict[element2] != global.left_element || global.left_element == ELEMENT.LOTOS);
    var can_l = is_lotos || can_l_v1 || can_l_v2;
                    
    // Правый край: проверяем первую и вторую половинку отдельно
    var can_match_r = (global.right_end == -1 || global.right_element == ELEMENT.LOTOS);
    var can_r_v1 = (value1 == global.right_end || can_match_r) && (global.element_conflict[element1] != global.right_element || global.right_element == ELEMENT.LOTOS);
    var can_r_v2 = (value2 == global.right_end || can_match_r) && (global.element_conflict[element2] != global.right_element || global.right_element == ELEMENT.LOTOS);
    var can_r = is_lotos || can_r_v1 || can_r_v2;
    
    // Выбор направления (если подходит к обоим разным краям)
    if (can_l && can_r && (global.left_end != global.right_end || global.left_element != global.right_element)) {
        global.choice_mode = true;
        global.selected_domino = id;
        y -= 60; // Приподнимаем кость визуально, чтобы показать режим выбора
    }
    else if (can_l) {
        global.play_domino(id, "left");
    }
    else if (can_r) {
        global.play_domino(id, "right");
    }
}