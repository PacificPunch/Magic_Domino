/// @description obj_domino_cross - Mouse Left Pressed

if (global.game_over) exit;
if (global.is_showing_starter) exit;
if (global.is_showing_starter) exit; // Запрещаем клики во время показа

// --- 1. РЕЖИМ ВЫБОРА СТОРОНЫ (клик по столу) ---
if (global.choice_mode) {
    if (owner == "table") {
        var chosen_side = "";
        // Определение сектора клика для первой кости
        if (id == global.ends.up.tile_id && id == global.ends.left.tile_id) {
            var dx = mouse_x - x; var dy = mouse_y - y;
            if (abs(dx) > abs(dy)) chosen_side = (dx > 0) ? "right" : "left";
            else chosen_side = (dy > 0) ? "down" : "up";
        } else {
            if (id == global.ends.up.tile_id) chosen_side = "up";
            else if (id == global.ends.down.tile_id) chosen_side = "down";
            else if (id == global.ends.left.tile_id) chosen_side = "left";
            else if (id == global.ends.right.tile_id) chosen_side = "right";
        }
        
        if (chosen_side != "") {
            var is_valid = false;
            for(var i=0; i<array_length(global.valid_sides); i++) {
                if (global.valid_sides[i] == chosen_side) { is_valid = true; break; }
            }
            if (is_valid) {
                global.valid_sides = []; 
                global.play_domino_cross(global.selected_domino, chosen_side);
            }
        }
    }
    if (owner != "player") { global.choice_mode = false; global.selected_domino = noone; global.valid_sides = []; }
    exit;
}

// --- 2. ВЫБОР КОСТИ ИЗ РУКИ ---
if (owner == "player" && global.current_turn == "player") {
    
    // Условие 1: Первый ход - только дубль
    if (ds_list_size(global.table_chain) == 0) {
        if (value1 == value2) global.play_domino_cross(id, "first");
        exit;
    }

    // Собираем данные о состоянии веток от центрального дубля
    var first_tile = global.table_chain[| 0];
    var sides = ["left", "right", "up", "down"];
    var free_at_start = []; // Какие стороны у первого дубля еще свободны
    var match_at_start = []; // К каким свободным сторонам дубля подходит эта кость
    
    for (var i = 0; i < 4; i++) {
        var s = sides[i];
        var s_data = variable_struct_get(global.ends, s);
        // Считаем сторону свободной у дубля, если крайняя кость этой ветки - сам дубль
        if (s_data.tile_id == first_tile && s_data.active) {
            array_push(free_at_start, s);
            if (value1 == s_data.val || value2 == s_data.val) array_push(match_at_start, s);
        }
    }

    // Проверяем все доступные ходы в принципе (для логики "если других ходов нет")
    var all_possible_moves = [];
    for (var i = 0; i < 4; i++) {
        var s_data = variable_struct_get(global.ends, sides[i]);
        if (s_data.active && (value1 == s_data.val || value2 == s_data.val)) array_push(all_possible_moves, sides[i]);
    }

    // --- ЛОГИКА ПРИОРИТЕТОВ ---

    // Условие 2: Вторая кость в игре всегда встает влево или вправо случайно (если обе свободны)
    if (ds_list_size(global.table_chain) == 1 && array_length(match_at_start) >= 1) {
        var h_match = [];
        if (value1 == global.ends.left.val || value2 == global.ends.left.val) array_push(h_match, "left");
        if (value1 == global.ends.right.val || value2 == global.ends.right.val) array_push(h_match, "right");
        
        if (array_length(h_match) > 0) {
            global.play_domino_cross(id, h_match[irandom(array_length(h_match)-1)]);
            exit;
        }
    }

    // Условие 3: Если других ходов нет и совпадает с дублем -> влево/вправо где свободно
    if (array_length(all_possible_moves) == array_length(match_at_start) && array_length(match_at_start) > 0) {
        var h_match = [];
        for(var i=0; i<array_length(match_at_start); i++) {
            if (match_at_start[i] == "left" || match_at_start[i] == "right") array_push(h_match, match_at_start[i]);
        }
        if (array_length(h_match) > 0) {
            global.play_domino_cross(id, h_match[irandom(array_length(h_match)-1)]);
            exit;
        }
        
        // Условие 4 & 5: Если горизонталь занята, но есть верх/низ у дубля (и других ходов нет)
        var v_match = [];
        for(var i=0; i<array_length(match_at_start); i++) {
            if (match_at_start[i] == "up" || match_at_start[i] == "down") array_push(v_match, match_at_start[i]);
        }
        if (array_length(v_match) > 0) {
            global.play_domino_cross(id, v_match[irandom(array_length(v_match)-1)]);
            exit;
        }
    }

    // Условие 6: Стандартная логика (если есть выбор между дублем и концом ветки, или все стороны дубля заняты)
    if (array_length(all_possible_moves) > 1) {
        global.choice_mode = true;
        global.selected_domino = id;
        global.valid_sides = all_possible_moves;
    } else if (array_length(all_possible_moves) == 1) {
        global.play_domino_cross(id, all_possible_moves[0]);
    }
}