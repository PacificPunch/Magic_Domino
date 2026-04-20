/// obj_game_controller_elem - Step Event

// Если игра окончена, прекращаем выполнение любой логики
if (global.game_over) exit;

// Логика хода ИИ (Компьютера)
// Компьютер ждет 1 секунду (60 кадров) перед своим ходом, чтобы игрок успел понять, что произошло
if (global.current_turn == "computer" && alarm[1] < 0 && !global.is_showing_starter) {
    alarm[1] = 60;
}

// Управление выходом (Возврат в главное меню)
if (keyboard_check_pressed(vk_escape)) {
    if (instance_exists(obj_domino_elem)) {
        with (obj_domino_elem) instance_destroy();
    }
    room_goto(rm_menu); // Убедитесь, что комната rm_menu существует
}

// --- ПРОВЕРКА НА "РЫБУ" (Elemental Fish) ---
// Рыба наступает, если базар пуст и ни у одного из игроков нет доступных ходов.
// Благодаря новой механике "двух стихий", тупики могут возникать по-новому, 
// так как теперь каждая половинка кости строго привязана к своей стихии.
if (ds_list_size(global.bazar) == 0) {
    
    // Вызываем обновленную функцию, которая уже умеет проверять element1 и element2
    var player_can_move = global.check_has_moves(global.player_hand);
    var computer_can_move = global.check_has_moves(global.computer_hand);
    
    if (!player_can_move && !computer_can_move) {
        if (!global.game_over) {
            global.resolve_fish(); // Объявляем ничью/победу по очкам
        }
    }
}