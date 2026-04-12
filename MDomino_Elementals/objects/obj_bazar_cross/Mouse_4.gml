/// @description obj_bazar_cross - Mouse Left Pressed

// 1. ПРОВЕРКА УСЛОВИЙ
if (global.game_over) exit;
if (global.is_showing_starter) exit;

// Взять кость можно только если сейчас ход игрока, в базаре есть кости и нет ходов в руке
var can_take = (ds_list_size(global.bazar) > 0);
var current_hand = (global.current_turn == "player") ? global.player_hand : global.computer_hand;

if (can_take && !global.check_has_moves(current_hand)) {
    
    // 2. ЛОГИКА ВЗЯТИЯ КОСТИ
    var inst = global.bazar[| 0];
    ds_list_delete(global.bazar, 0);
    
    if (global.current_turn == "player") {
        inst.owner = "player";
        ds_list_add(global.player_hand, inst);
        
        // ОБНОВЛЕНО: Используем правильный объект руки для Креста
        if (instance_exists(obj_player_hand_cross)) {
            with (obj_player_hand_cross) arrange_player_hand();
        }
    } else {
        inst.owner = "computer";
        ds_list_add(global.computer_hand, inst);
        
        // ОБНОВЛЕНО: Используем правильный объект руки компьютера для Креста
        if (instance_exists(obj_computer_hand_cross)) {
            with (obj_computer_hand_cross) arrange_computer_hand();
        }
    }
    
    // 3. ОБНОВЛЕНИЕ СОСТОЯНИЯ ЧЕРЕЗ КОНТРОЛЛЕР
    // ИСПРАВЛЕНИЕ: Заменен obj_game_controller на obj_game_controller_cross
    if (instance_exists(obj_game_controller_cross)) {
        with (obj_game_controller_cross) alarm[2] = 10;
    }
}