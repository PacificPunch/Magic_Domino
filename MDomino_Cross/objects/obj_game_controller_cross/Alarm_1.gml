/// obj_game_controller_cross - Alarm 1 (Ход компьютера)

if (global.game_over) exit;

var hand = global.computer_hand;
var possible_moves = []; // Массив структур {tile, side}

var sides = ["up", "down", "left", "right"];

// Если это самый первый ход
if (ds_list_size(global.table_chain) == 0) {
    for (var i = 0; i < ds_list_size(hand); i++) {
        var inst = hand[| i];
        if (inst.value1 == inst.value2) {
            global.play_domino_cross(inst, "first");
            exit;
        }
    }
}

// Поиск доступных ходов по всем веткам
for (var i = 0; i < ds_list_size(hand); i++) {
    var inst = hand[| i];
    for (var j = 0; j < 4; j++) {
        var side_name = sides[j];
        var side_data = variable_struct_get(global.ends, side_name);
        if (side_data.active && (inst.value1 == side_data.val || inst.value2 == side_data.val)) {
            array_push(possible_moves, { tile: inst, side: side_name });
        }
    }
}

if (array_length(possible_moves) > 0) {
    // Приоритет: если есть дубль среди возможных ходов — ставим его (перекрываем ветку)
    var move_to_make = possible_moves[0];
    for (var k = 0; k < array_length(possible_moves); k++) {
        var m = possible_moves[k];
        if (m.tile.value1 == m.tile.value2) {
            move_to_make = m;
            break;
        }
    }
    global.play_domino_cross(move_to_make.tile, move_to_make.side);
} else {
    // Если ходов нет — идем в базар
    if (ds_list_size(global.bazar) > 0) {
        with (obj_bazar_cross) event_perform(ev_mouse, ev_left_press);
    } else {
        // Если и в базаре пусто — пас/проверка на рыбу
        global.current_turn = "player";
        alarm[2] = 10;
    }
}