/// obj_game_controller_cross - Alarm 2 (Проверка состояния игры)

// 1. ПРОВЕРКА ПОБЕДЫ ПО ПУСТОЙ РУКЕ
// Проверяем игрока
if (ds_list_size(global.player_hand) == 0) {
    global.game_over = true;
    global.end_message = "ПОБЕДА!\nВы выложили все кости.";
    alarm[3] = 30; // Переход к экрану финала
    exit;
}

// Проверяем компьютер
if (ds_list_size(global.computer_hand) == 0) {
    global.game_over = true;
    global.end_message = "ПРОИГРЫШ!\nПротивник избавился от всех костей.";
    alarm[3] = 30;
    exit;
}

// 2. ПРОВЕРКА НА "РЫБУ" (Блокировка игры)
// Рыба возможна только если базар пуст
if (ds_list_size(global.bazar) == 0) {
    var player_has_moves = global.check_has_moves(global.player_hand);
    var computer_has_moves = global.check_has_moves(global.computer_hand);
    
    // Если ни у кого нет ходов — вызываем расчет очков
    if (!player_has_moves && !computer_has_moves) {
        global.resolve_fish();
        exit;
    }
}

// 3. ПРОВЕРКА НЕОБХОДИМОСТИ ИДТИ В БАЗАР (Для хода компьютера)
// Если сейчас ход компьютера, и у него нет ходов, а в базаре что-то есть — заставляем его брать
if (global.current_turn == "computer" && !global.game_over) {
    if (!global.check_has_moves(global.computer_hand)) {
        if (ds_list_size(global.bazar) > 0) {
            // Запускаем таймер, чтобы компьютер взял кость из базара
            alarm[1] = 30; 
        } else {
            // Если базара нет и ходов нет — передаем ход игроку (пропуск хода)
            global.current_turn = "player";
            // Повторно проверяем состояние через мгновение
            alarm[2] = 5;
        }
    } else {
        // Если ходы есть — запускаем "раздумья" компьютера
        if (alarm[1] < 0) alarm[1] = 45;
    }
}

// 4. ПОДСКАЗКА ДЛЯ ИГРОКА
// Если ход игрока и у него нет ходов
if (global.current_turn == "player" && !global.game_over) {
    if (!global.check_has_moves(global.player_hand)) {
        if (ds_list_size(global.bazar) == 0) {
            // Автоматический пропуск хода игроком, если ходить нечем и базара нет
            global.current_turn = "computer";
            alarm[2] = 10;
        }
        // Если базар есть, контроллер просто ждет клика игрока по объекту obj_bazar_cross
    }
}