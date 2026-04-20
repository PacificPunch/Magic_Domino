/// obj_game_controller_elem - Alarm 0 (Поиск стартовой кости)

var starter = noone;
var found = false;

// 1. Делаем кости в руках видимыми
// Используем новый объект obj_domino_elem
with (obj_domino_elem) {
    if (owner == "player" || owner == "computer") {
        visible = true;
    }
}

// 2. Ищем минимальный дубль (от 0:0 до 6:6) для начала игры
for (var val = 0; val <= 6; val++) {
    with (obj_domino_elem) {
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
    with (obj_domino_elem) {
        if (owner == "player" || owner == "computer") {
            var current_sum = value1 + value2;
            if (current_sum < min_sum) {
                min_sum = current_sum;
                starter = id;
            }
        }
    }
}

// 4. Запускаем стартовую индикацию и определяем первый ход
if (starter != noone) {
    global.starter_tile = starter;
    global.is_showing_starter = true;
    
    // ВАЖНО ДЛЯ НОВЫХ ПРАВИЛ: Первая кость сразу задает ДВЕ стихии краев стола.
    // Если это дубль, element1 и element2 будут одинаковыми.
    global.left_element = starter.element1;
    global.right_element = starter.element2;
    
    // Устанавливаем очередь хода владельцу этой кости
    global.current_turn = starter.owner;
    
    // Включаем таймер завершения заставки (2 секунды при 60 FPS)
    alarm[4] = 120; 
}

// 5. Обновляем положение костей в руках (через новые объекты рук)
if (instance_exists(obj_player_hand_elem)) {
    with (obj_player_hand_elem) arrange_player_hand();
}
if (instance_exists(obj_computer_hand_elem)) {
    with (obj_computer_hand_elem) arrange_computer_hand();
}