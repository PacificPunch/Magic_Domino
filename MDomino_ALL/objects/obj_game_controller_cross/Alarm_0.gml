/// @description obj_game_controller - Alarm 0 (Поиск стартера)

var starter = noone;
var found = false;

// 1. Делаем кости видимыми
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

// 3. Если дублей нет совсем — ПЕРЕСДАЧА
if (!found) {
    room_restart();
    exit;
}

// 4. Запускаем стартовую индикацию
if (starter != noone) {
    global.starter_instance = starter; // Используем для проверки в Draw
    global.is_showing_starter = true;  // Блокирует ввод и включает мигание
    
    // Устанавливаем очередь хода владельцу этой кости
    global.current_turn = starter.owner;
    
    // Включаем таймер завершения заставки (2 секунды при 60 FPS)
    alarm[4] = 120; 
}

// 5. Обновляем положение костей в руках
with (obj_player_hand_cross) arrange_player_hand();
with (obj_computer_hand_cross) arrange_computer_hand();