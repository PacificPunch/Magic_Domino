/// @description obj_game_controller_cross - Alarm 2 (Проверка состояния игры)

if (global.game_over) exit;

// --- 1. ПРОВЕРКА ПОБЕДЫ ПО ПУСТОЙ РУКЕ ---
if (ds_list_size(global.player_hand) == 0) {
    global.game_over = true;
    global.reveal_computer_hand(); // ПОКАЗЫВАЕМ ОСТАТКИ КОМПЬЮТЕРА
    global.end_message = "ПОБЕДА!\nВы выложили все кости.";
    alarm[3] = 90; // Даем игроку 3 секунды посмотреть на кости врага
    exit;
}

if (ds_list_size(global.computer_hand) == 0) {
    global.game_over = true;
    // Кости игрока и так видны, поэтому просто задержка
    global.end_message = "ПРОИГРЫШ!\nПротивник избавился от всех костей.";
    alarm[3] = 90;
    exit;
}

// --- 2. ПРОВЕРКА НА "РЫБУ" (Блокировка игры) ---

// А. Проверка на закрытие всех 4-х сторон дублями
var active_sides_count = 0;
var side_names = ["up", "down", "left", "right"];
for (var i = 0; i < 4; i++) {
    var s_data = variable_struct_get(global.ends, side_names[i]);
    if (s_data.active) active_sides_count++;
}

// Если все стороны закрыты (active_sides_count == 0) — это Рыба (даже если есть базар!)
if (active_sides_count == 0 && ds_list_size(global.table_chain) > 0) {
    global.resolve_fish();
    exit;
}

// Б. Стандартная Рыба (нет ходов ни у кого и базар пуст)
if (ds_list_size(global.bazar) == 0) {
    var player_has_moves = global.check_has_moves(global.player_hand);
    var computer_has_moves = global.check_has_moves(global.computer_hand);
    
    if (!player_has_moves && !computer_has_moves) {
        global.resolve_fish();
        exit;
    }
}

// --- 3. ПРОВЕРКА НЕОБХОДИМОСТИ ИДТИ В БАЗАР (Для хода компьютера) ---
if (global.current_turn == "computer") {
    if (!global.check_has_moves(global.computer_hand)) {
        if (ds_list_size(global.bazar) > 0) {
            alarm[1] = 30; // Берем из базара
        } else {
            global.current_turn = "player";
            alarm[2] = 5;
        }
    } else {
        if (alarm[1] < 0) alarm[1] = 45;
    }
}

// --- 4. ПОДСКАЗКА ДЛЯ ИГРОКА ---
if (global.current_turn == "player") {
    if (!global.check_has_moves(global.player_hand)) {
        if (ds_list_size(global.bazar) == 0) {
            global.current_turn = "computer";
            alarm[2] = 10;
        }
    }
}