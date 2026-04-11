/// obj_game_controller - Alarm 0

var starter = noone;
var found = false;

// 1. Сначала принудительно делаем все кости в руках видимыми
// Это решит проблему "пустого экрана", если раздача прошла успешно
with (obj_domino_cross) {
    if (owner == "player" || owner == "computer") {
        visible = true;
    }
}

// 2. Ищем минимальный дубль (от 0:0 до 6:6)
for (var val = 0; val <= 6; val++) {
    with (obj_domino_cross) {
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
    with (obj_domino_cross) {
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
    global.is_showing_starter = true;
    
    // Устанавливаем очередь хода владельцу этой кости
    global.current_turn = starter.owner;
    
    // Включаем таймер завершения заставки (2 секунды)
    alarm[4] = 120; 
}

// 5. Обновляем положение костей в руках, чтобы они выстроились красиво
with (obj_player_hand_cross) arrange_player_hand();
with (obj_computer_hand_cross) arrange_computer_hand();