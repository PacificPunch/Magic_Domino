/// obj_game_controller_b - Alarm 1 (Ход компьютера)

if (global.game_over || global.current_turn != "computer") exit;

var played = false;

// 1. Ищем ход
for (var i = 0; i < ds_list_size(global.computer_hand); i++) {
    var dom = global.computer_hand[| i];
    
    if (ds_list_size(global.table_chain) == 0) {
        global.play_domino(dom, "first"); 
        played = true; 
        break;
    } else {
        if (dom.value1 == global.left_end || dom.value2 == global.left_end) {
            global.play_domino(dom, "left");
            played = true; 
            break;
        } else if (dom.value1 == global.right_end || dom.value2 == global.right_end) {
            global.play_domino(dom, "right");
            played = true; 
            break;
        }
    }
}

// 2. Бот не смог сходить (Базара нет, пропускаем ход)
if (!played) {
    show_message("Компьютер не может сделать ход и пропускает его!");
    global.current_turn = "player";
    
    // Передаем эстафету проверки стола (возможно это рыба)
    alarm[2] = 10;
}