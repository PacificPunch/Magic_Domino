/// obj_bazar_x2 - Mouse Event: Left Pressed

if (global.game_over || global.current_turn != "player") exit;

// Нельзя брать с базара, если есть доступный ход
if (global.check_has_moves(global.player_hand)) exit;


if (ds_list_size(global.bazar) > 0) {
    var dom = global.bazar[| 0];
    ds_list_delete(global.bazar, 0);
    
    dom.owner = "player";
    ds_list_add(global.player_hand, dom);
    with (obj_player_hand_x2) { arrange_player_hand();}
    // ПРИНУДИТЕЛЬНОЕ ОБНОВЛЕНИЕ:
    dom.visible = true; // Сразу делаем видимой
    
    if (instance_exists(obj_player_hand_x2)) {
        // Вызываем расстановку напрямую через точку (более надежно в новых версиях GMS)
        obj_player_hand_x2.arrange_player_hand();
        
        // Запускаем микро-задержку для повторной расстановки (гарантирует появление)
        obj_player_hand_x2.alarm[0] = 1; 
    }
    
    // Проверка хода через контроллер
    with (obj_game_controller) alarm[2] = 10;
}