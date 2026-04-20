/// obj_game_controller_elem - Alarm 2 (Проверка состояния стола)

if (global.game_over) exit;

// 1. ПРОВЕРКА НА ОБЫЧНУЮ ПОБЕДУ (У кого-то закончились кости)
if (ds_list_size(global.player_hand) == 0) {
    global.game_over = true;
    global.end_message = "Вы победили!";
    alarm[3] = 10; // Вызов финального экрана
    exit;
} 
else if (ds_list_size(global.computer_hand) == 0) {
    global.game_over = true;
    global.end_message = "Противник победил!"; 
    alarm[3] = 10; // Вызов финального экрана
    exit;
}

// 2. ОПРЕДЕЛЯЕМ ТЕКУЩИЕ РУКИ
var current_hand = (global.current_turn == "player") ? global.player_hand : global.computer_hand;
var opp_hand = (global.current_turn == "player") ? global.computer_hand : global.player_hand;

// 3. ЛОГИКА ТУПИКОВ И ПЕРЕДАЧИ ХОДА (С учетом новых правил стихий)
if (!global.check_has_moves(current_hand)) {
    
    // Если ходов нет, проверяем Базар
    if (ds_list_size(global.bazar) == 0) {
        
        // У текущего игрока нет ходов и базар ПУСТ. Проверяем оппонента:
        if (!global.check_has_moves(opp_hand)) {
            // У обоих нет ходов - РЫБА (Ничья или победа по очкам)
            global.resolve_fish();
        } 
        else {
            // У оппонента ходы есть -> АВТОМАТИЧЕСКАЯ ПЕРЕДАЧА ХОДА
            if (global.current_turn == "player") {
                show_message("У вас нет доступных ходов, а базар пуст.\nХод переходит к противнику.");
                global.current_turn = "computer";
                alarm[1] = 30; // Передаем ход компьютеру
            } 
            else {
                show_message("У противника нет доступных ходов, а базар пуст.\nХод переходит к вам.");
                global.current_turn = "player";
                // Возвращаем ход игроку, просто ждем его клика
            }
        }
    } 
    else {
        // Базар НЕ пуст. Если сейчас ход компьютера, заставляем его "подумать" и взять кость
        if (global.current_turn == "computer") {
            alarm[1] = 30; 
        }
        // Если ход игрока, он должен сам кликнуть на базар (ничего не делаем)
    }
} 
else {
    // Ходы ЕСТЬ!
    // Если это ход компьютера, запускаем его логику
    if (global.current_turn == "computer") {
        alarm[1] = 30; 
    }
    // Если ход игрока, просто ждем, пока он перетащит кость
}