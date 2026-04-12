/// @description Завершение показа стартера
global.is_showing_starter = false;

// Если ход компьютера — запускаем его логику через небольшую паузу
if (global.current_turn == "computer") {
    alarm[1] = 30;
}