/// obj_game_controller - Alarm 1 (Ход компьютера)

if (global.game_over || global.current_turn != "computer") exit;

var played = false;

// 1. Ищем ход
for (var i = 0; i < ds_list_size(global.computer_hand); i++) {
    var dom = global.computer_hand[| i];
    if (ds_list_size(global.table_chain) == 0) {
        global.play_domino(dom, "first"); played = true; break;
    } else {
        if (dom.value1 == global.left_end || dom.value2 == global.left_end) {
            global.play_domino(dom, "left"); played = true; break;
        } else if (dom.value1 == global.right_end || dom.value2 == global.right_end) {
            global.play_domino(dom, "right"); played = true; break;
        }
    }
}

// 2. Если хода нет и на базаре что-то есть - берем
if (!played) {
    if (ds_list_size(global.bazar) > 0) {
        var draw_dom = global.bazar[| 0];
        ds_list_delete(global.bazar, 0);
        draw_dom.owner = "computer";
        ds_list_add(global.computer_hand, draw_dom);
        with (obj_computer_hand) arrange_computer_hand();
        
        alarm[1] = 30; // Пробуем сходить еще раз
    } else {
        // Сюда комп доходит редко, так как Alarm 2 перехватывает пустой базар раньше.
        // Но для подстраховки:
        alarm[2] = 10;
    }
}