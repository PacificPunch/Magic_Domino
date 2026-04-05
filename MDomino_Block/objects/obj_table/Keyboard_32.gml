/// Событие: Key Press - Space (Взять из базара)

// Если игра окончена или сейчас не ход игрока — кнопка не работает
if (global.game_over || global.current_turn != "player") exit;

// По правилам домино: если есть чем ходить с руки, брать с базара нельзя
if (global.check_has_moves(global.player_hand)) exit;

// Если на базаре еще остались костяшки
if (ds_list_size(global.bazar) > 0) {
    // Берем верхнюю кость
    var dom = global.bazar[| 0];
    ds_list_delete(global.bazar, 0);
    
    // Передаем ее игроку
    dom.owner = "player";
    ds_list_add(global.player_hand, dom);
    
    // Раскладываем кости в руке заново, чтобы новая костяшка встала на место
    with (obj_player_hand) arrange_player_hand();
    
    // Запускаем таймер проверки (alarm 2 проверит, можем ли мы теперь сходить
    // или нам нужно тянуть еще / передавать ход)
    with (obj_game_controller) alarm[2] = 10;
}