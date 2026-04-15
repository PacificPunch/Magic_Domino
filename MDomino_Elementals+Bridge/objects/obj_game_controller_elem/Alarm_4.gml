/// obj_game_controller_elem - Alarm 4
global.is_showing_starter = false;

// Если стартовая кость у компьютера — он ходит сам через свой Alarm
if (global.starter_tile.owner == "computer") {
    global.current_turn = "computer";
} else {
    // Если у игрока — просто ставим его ход и ЖДЕМ КЛИКА
    global.current_turn = "player";
}