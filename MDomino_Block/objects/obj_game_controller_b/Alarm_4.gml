/// obj_game_controller_b - Alarm 4
global.is_showing_starter = false;
global.starter_tile = noone;

// Если сейчас ход бота, даем ему команду ходить через секунду
if (global.current_turn == "computer") {
    alarm[2] = 60; 
}