/// obj_game_controller - Global Right Pressed
if (global.choice_mode) {
    global.choice_mode = false;
    global.selected_domino = noone;
    
    // Возвращаем кости игрока в ровный ряд (сбрасываем поднятую Y)
    with (obj_player_hand_b) {
        arrange_player_hand(); // Убедитесь, что название функции совпадает с вашей
    }
}