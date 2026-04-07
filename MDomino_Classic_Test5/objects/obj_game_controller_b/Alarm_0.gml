/// obj_game_controller_b - Alarm 0

var starter = noone;
var found = false;

// 1. Делаем кости видимыми (если при раздаче они были скрыты)
with (obj_domino_b) {
    if (owner == "player" || owner == "computer") {
        visible = true;
    }
}

// 2. Ищем минимальный дубль (от 0:0 до 6:6)
for (var val = 0; val <= 6; val++) {
    with (obj_domino_b) {
        if (owner == "player" || owner == "computer") {
            if (value1 == val && value2 == val) {
                starter = id;
                found = true;
                break;
            }
        }
    }
    if (found) break;
}

// 3. Если дублей нет совсем, ищем кость с минимальной суммой очков
if (!found) {
    var min_sum = 100;
    with (obj_domino_b) {
        if (owner == "player" || owner == "computer") {
            var current_sum = value1 + value2;
            if (current_sum < min_sum) {
                min_sum = current_sum;
                starter = id;
            }
        }
    }
}

// 4. Запускаем стартовую индикацию
if (starter != noone) {
    global.starter_tile = starter;
    global.is_showing_starter = true; // Эта переменная запретит игроку кликать
    
    // Передаем ход владельцу стартовой кости
    global.current_turn = starter.owner;
    
    // Включаем таймер завершения заставки (120 кадров = 2 секунды)
    alarm[4] = 120;
}

// 5. Красиво расставляем кости (Укажи тут свои объекты рук для Блока)
if (instance_exists(obj_player_hand_b)) {
    with (obj_player_hand_b) arrange_player_hand(); // или твой скрипт для расстановки
}
if (instance_exists(obj_computer_hand_b)) {
    with (obj_computer_hand_b) arrange_computer_hand();
}