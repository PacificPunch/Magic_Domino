/// obj_game_controller_elem - Global Right Pressed (Отмена выбора)

// Если игрок нажал на кость, которая подходит к обоим краям стола, 
// и сейчас выбирает, какую стихию подсунуть противнику:
if (global.choice_mode) {
    
    // 1. Выключаем режим выбора направления
    global.choice_mode = false;
    
    // 2. Очищаем память от выбранной кости
    global.selected_domino = noone;
    
    // 3. Возвращаем кость на место (она была приподнята по оси Y)
    // Функция arrange_player_hand сама опустит все кости на нужный уровень
    if (instance_exists(obj_player_hand_elem)) {
        with (obj_player_hand_elem) {
            arrange_player_hand(); 
        }
    }
}