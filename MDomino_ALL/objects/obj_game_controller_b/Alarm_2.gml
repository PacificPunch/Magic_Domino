/// obj_game_controller_b - Alarm 2 (Проверка состояния стола)

if (global.game_over) exit;

// 1. Проверка на обычную победу (кто-то избавился от всех костей)
if (ds_list_size(global.player_hand) == 0) {
    global.game_over = true;
    global.end_message = "Вы победили!";
    alarm[3] = 10;
    exit;
} else if (ds_list_size(global.computer_hand) == 0) {
    global.game_over = true;
    global.end_message = "Противник победил!";
    alarm[3] = 10;
    exit;
}

// 2. Проверка возможности сделать ход (режим Блок)
var current_hand = (global.current_turn == "player") ? global.player_hand : global.computer_hand;
var opp_hand = (global.current_turn == "player") ? global.computer_hand : global.player_hand;

if (!global.check_has_moves(current_hand)) {
    // У текущего игрока нет ходов
    if (!global.check_has_moves(opp_hand)) {
        // Если у противника ТОЖЕ нет ходов — это Рыба!
        global.resolve_fish();
    } else {
        // У текущего нет, но у противника есть. Пропускаем ход!
        if (global.current_turn == "player") {
            show_message("Пас.\nУ вас нет доступных ходов.\nВы пропускаете ход!");
            global.current_turn = "computer";
            alarm[1] = 30; // Запускаем логику компа
        } else {
            // Сюда попадем редко, т.к. пропуск бота мы уже отработали в Alarm 1
            // Но для подстраховки:
            global.current_turn = "player";
        }
    }
} else {
    // Ходы есть, игра идет своим чередом
    if (global.current_turn == "computer") {
        alarm[1] = 30; 
    }
}