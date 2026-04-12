/// obj_domino_elem - Mouse Left Pressed

// Блокировка кликов во время анимации старта
if (global.is_showing_starter) exit;

// Ходить можно только в свой ход и если игра не окончена
if (global.game_over || global.current_turn != "player") exit;

// --- 1. ЛОГИКА ВЫБОРА НАПРАВЛЕНИЯ (Choice Mode) ---
// Если игрок уже нажал на кость и теперь кликает по краям стола
if (global.choice_mode) {
    if (owner == "table") {
        // Клик по левому краю стола
        if (id == global.left_tile_id) {
            global.play_domino(global.selected_domino, "left");
            exit;
        }
        // Клик по правому краю стола
        if (id == global.right_tile_id) {
            global.play_domino(global.selected_domino, "right");
            exit;
        }
    }
    // Если кликнули не по краям, выходим (отмена в Global Right Click)
    exit;
}

// --- 2. ЛОГИКА ВЫБОРА КОСТИ В РУКЕ ---
if (owner == "player") {
    
    // Если стол пуст (первый ход игрока)
    if (ds_list_size(global.table_chain) == 0) {
        global.play_domino(id, "first");
        exit;
    }

    // Проверка совместимости ELEMENTAL (Цифра + Стихия)
    // Условие: (Есть нужная цифра) И (Это дубль ИЛИ стихия не конфликтует с краем)
    var can_l = (value1 == global.left_end || value2 == global.left_end) && 
                (is_double || global.element_conflict[element] != global.left_element);
                
    var can_r = (value1 == global.right_end || value2 == global.right_end) && 
                (is_double || global.element_conflict[element] != global.right_element);
    
    // Активируем режим выбора, если кость подходит к обоим краям и они разные по значению/стихии
    if (can_l && can_r && (global.left_end != global.right_end || global.left_element != global.right_element)) {
        global.choice_mode = true;
        global.selected_domino = id;
        y -= 60; // Визуально приподнимаем кость в руке
    }
    // Если подходит только к левому краю
    else if (can_l) {
        global.play_domino(id, "left");
    }
    // Если подходит только к правому краю
    else if (can_r) {
        global.play_domino(id, "right");
    }
}