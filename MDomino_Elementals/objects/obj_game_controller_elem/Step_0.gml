/// obj_game_controller_elem - Step Event

// Если игра окончена, прекращаем выполнение любой логики
if (global.game_over) exit;

// Логика хода ИИ (Компьютера)
// Компьютер начинает "думать" только если:
// 1. Сейчас его ход (current_turn == "computer")
// 2. Таймер задержки еще не запущен (alarm[1] < 0), чтобы не спамить попытками хода каждый кадр
// 3. Мы не находимся в режиме анимации показа стартовой кости
if (global.current_turn == "computer" && alarm[1] < 0 && !global.is_showing_starter) {
    // Устанавливаем задержку (напр. 60 кадров = 1 секунда), 
    // чтобы игрок видел, что компьютер "думает", а не ходит мгновенно.
    // Код самого поиска хода будет находиться в Alarm 1.
    alarm[1] = 60; 
}

// Управление выходом/перезагрузкой
if (keyboard_check_pressed(vk_escape)) {
    // При выходе в меню уничтожаем все экземпляры костяшек нового типа
    if (instance_exists(obj_domino_elem)) {
        with (obj_domino_elem) instance_destroy();
    }
    
    // Очистка динамических данных, если это необходимо
    // ds_list_clear(global.table_chain); 
    
    room_goto(rm_menu);
}

// Дополнительная проверка на "Рыбу" (Elemental Fish)
// Если базар пуст и у игрока нет ходов, и у компьютера нет ходов — вызываем финал.
// В Elemental Domino это случается чаще из-за конфликтов стихий.
if (ds_list_size(global.bazar) == 0) {
    var player_can_move = global.check_has_moves(global.player_hand);
    var computer_can_move = global.check_has_moves(global.computer_hand);
    
    if (!player_can_move && !computer_can_move) {
        if (!global.game_over) {
            global.resolve_fish();
        }
    }
}