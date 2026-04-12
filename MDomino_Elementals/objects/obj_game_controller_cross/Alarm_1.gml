/// @description obj_game_controller_cross - Alarm 1 (ИИ Креста)

if (global.game_over) exit;

var hand = global.computer_hand;
var first_tile = global.table_chain[| 0];
var sides = ["left", "right", "up", "down"];

// --- ШАГ 1: ПЕРВЫЙ ХОД В ИГРЕ ---
if (ds_list_size(global.table_chain) == 0) {
    for (var i = 0; i < ds_list_size(hand); i++) {
        var inst = hand[| i];
        if (inst.value1 == inst.value2) {
            global.play_domino_cross(inst, "first");
            exit;
        }
    }
}

// --- ШАГ 2: СБОР ДОСТУПНЫХ ХОДОВ ПО КАТЕГОРИЯМ ---
var match_start_hor = []; // К первому дублю: влево/вправо
var match_start_ver = []; // К первому дублю: вверх/вниз
var match_other = [];     // К остальным концам веток

for (var i = 0; i < ds_list_size(hand); i++) {
    var inst = hand[| i];
    for (var j = 0; j < 4; j++) {
        var s_name = sides[j];
        var s_data = variable_struct_get(global.ends, s_name);
        
        if (s_data.active && (inst.value1 == s_data.val || inst.value2 == s_data.val)) {
            // Проверяем, является ли текущий конец первым дублем
            if (s_data.tile_id == first_tile) {
                if (s_name == "left" || s_name == "right") 
                    array_push(match_start_hor, { tile: inst, side: s_name });
                else 
                    array_push(match_start_ver, { tile: inst, side: s_name });
            } else {
                array_push(match_other, { tile: inst, side: s_name });
            }
        }
    }
}

// --- ШАГ 3: РЕАЛИЗАЦИЯ ПРИОРИТЕТОВ ---

// 1. Приоритет: Горизонтальные стороны первого дубля
if (array_length(match_start_hor) > 0) {
    var move = match_start_hor[irandom(array_length(match_start_hor) - 1)];
    global.play_domino_cross(move.tile, move.side);
    exit;
}

// 2. Приоритет: Вертикальные стороны первого дубля
if (array_length(match_start_ver) > 0) {
    var move = match_start_ver[irandom(array_length(match_start_ver) - 1)];
    global.play_domino_cross(move.tile, move.side);
    exit;
}

// 3. Приоритет: Все остальные доступные ветки
if (array_length(match_other) > 0) {
    // Среди обычных ходов ИИ всё еще пытается сначала выкинуть дубль, чтобы закрыть ветку игроку
    var move_to_make = match_other[0];
    for (var k = 0; k < array_length(match_other); k++) {
        if (match_other[k].tile.value1 == match_other[k].tile.value2) {
            move_to_make = match_other[k];
            break;
        }
    }
    global.play_domino_cross(move_to_make.tile, move_to_make.side);
    exit;
}

// --- ШАГ 4: ЕСЛИ ХОДОВ НЕТ ---
if (ds_list_size(global.bazar) > 0) {
    with (obj_bazar_cross) event_perform(ev_mouse, ev_left_press);
} else {
    // Пас
    global.current_turn = "player";
    alarm[2] = 10;
}