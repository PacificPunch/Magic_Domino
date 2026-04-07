/// obj_domino - Mouse Left Pressed

if (global.is_showing_starter) exit;

if (global.game_over || global.current_turn != "player") exit;

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

if (owner == "player") {
    var can_l = (value1 == global.left_end || value2 == global.left_end);
    var can_r = (value1 == global.right_end || value2 == global.right_end);
    
    // Активируем выбор только если края РАЗНЫЕ
    if (can_l && can_r && (global.left_end != global.right_end)) {
        global.choice_mode = true;
        global.selected_domino = id;
        y -= 60;
    }
    // В остальных случаях (включая первый ход) используем автоматику
    else if (ds_list_size(global.table_chain) == 0) {
        global.play_domino(id, "first");
    }
    else if (can_l) global.play_domino(id, "left");
    else if (can_r) global.play_domino(id, "right");
}