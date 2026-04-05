/// obj_game_controller - Step Event

if (global.game_over) exit;

// Компьютер начнет "думать" только если:
// 1. Сейчас его ход
// 2. Таймер хода еще не запущен (alarm[1] < 0)
// 3. МЫ НЕ ПОКАЗЫВАЕМ СТАРТОВУЮ КОСТЬ (!global.is_showing_starter)
if (global.current_turn == "computer" && alarm[1] < 0 && !global.is_showing_starter) {
    alarm[1] = 60; // Задержка в 1 секунду перед ходом
}

if (keyboard_check_pressed(vk_escape)) {
    // Чистим списки перед уходом
    if (ds_exists(global.player_hand, ds_type_list)) ds_list_destroy(global.player_hand);
    if (ds_exists(global.computer_hand, ds_type_list)) ds_list_destroy(global.computer_hand);
    if (ds_exists(global.bazar, ds_type_list)) ds_list_destroy(global.bazar);
    if (ds_exists(global.table_chain, ds_type_list)) ds_list_destroy(global.table_chain);
    
    // Удаляем объекты, чтобы при новом старте не было дублей
    with (obj_domino) instance_destroy();

    room_goto(rm_menu); // Возвращаемся в главное меню
}