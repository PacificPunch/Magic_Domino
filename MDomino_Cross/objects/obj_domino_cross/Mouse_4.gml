/// obj_domino_cross - Mouse Left Pressed

if (global.game_over) exit;
if (global.is_showing_starter) exit;

// 1. ЛОГИКА ВЫБОРА СТОРОНЫ (если кость уже выбрана и мы кликаем по столу)
if (global.choice_mode) {
    if (owner == "table") {
        var chosen_side = "";
        if (id == global.ends.up.tile_id) chosen_side = "up";
        else if (id == global.ends.down.tile_id) chosen_side = "down";
        else if (id == global.ends.left.tile_id) chosen_side = "left";
        else if (id == global.ends.right.tile_id) chosen_side = "right";
        
        if (chosen_side != "") {
            // Проверяем, подходит ли выбранная ранее кость к этой ветке
            var target = variable_struct_get(global.ends, chosen_side);
            if (target.active && (global.selected_domino.value1 == target.val || global.selected_domino.value2 == target.val)) {
                global.play_domino_cross(global.selected_domino, chosen_side);
            }
        }
    }
    exit; // Выходим, чтобы не сработала логика ниже
}

// 2. ЛОГИКА ВЫБОРА КОСТИ ИЗ РУКИ
if (owner == "player" && global.current_turn == "player") {
    
    // ПЕРВЫЙ ХОД В ИГРЕ (Только дубль)
    if (ds_list_size(global.table_chain) == 0) {
        if (value1 == value2) {
            global.play_domino_cross(id, "first");
        }
        exit;
    }

    // Поиск подходящих АКТИВНЫХ веток
    var possible_sides = [];
    var side_names = ["up", "down", "left", "right"];
    
    for (var i = 0; i < 4; i++) {
        var s_name = side_names[i];
        var s_data = variable_struct_get(global.ends, s_name);
        if (s_data.active) {
            if (value1 == s_data.val || value2 == s_data.val) {
                array_push(possible_sides, s_name);
            }
        }
    }

    // Если подходит только к одной ветке — кладем сразу
    if (array_length(possible_sides) == 1) {
        global.play_domino_cross(id, possible_sides[0]);
    } 
    // Если подходит к нескольким — включаем режим выбора
    else if (array_length(possible_sides) > 1) {
        global.choice_mode = true;
        global.selected_domino = id;
    }
}