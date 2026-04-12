/// obj_bazar - Mouse Event: Left Pressed

if (global.game_over || global.current_turn != "player") exit;

// Нельзя брать с базара, если есть доступный ход
if (global.check_has_moves(global.player_hand)) exit;

if (ds_list_size(global.bazar) > 0) {
    var dom = global.bazar[| 0];
    ds_list_delete(global.bazar, 0);
    
    dom.owner = "player";
    ds_list_add(global.player_hand, dom);
    with (obj_player_hand) arrange_player_hand();
    
    // Запускаем таймер проверки (хватит ли этой взятой кости для хода, 
    // или базар опустел и нужно передать ход противнику)
    with (obj_game_controller) alarm[2] = 10;
}

