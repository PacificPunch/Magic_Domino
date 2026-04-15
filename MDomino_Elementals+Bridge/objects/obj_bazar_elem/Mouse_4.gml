/// obj_bazar_elem - Mouse Event: Left Pressed

// 1. ПРОВЕРКА УСЛОВИЙ
// Если игра окончена или сейчас ход компьютера — ничего не делаем
if (global.game_over || global.current_turn != "player") exit;

// 2. ПРОВЕРКА НАЛИЧИЯ ХОДОВ (ELEMENTAL)
// Функция global.check_has_moves уже учитывает конфликты стихий и дубли.
// Если у игрока есть ХОТЯ БЫ ОДИН легальный ход (цифра совпадает и стихия подходит),
// брать из базара запрещено.
if (global.check_has_moves(global.player_hand)) {
    // Опционально: можно добавить звуковой эффект ошибки
    exit;
}

// 3. ЛОГИКА ВЗЯТИЯ КОСТИ
if (ds_list_size(global.bazar) > 0) {
    // Берем верхнюю кость из списка базара
    var dom = global.bazar[| 0];
    ds_list_delete(global.bazar, 0);
    
    // Смена владельца
    dom.owner = "player";
    dom.visible = true; // Делаем кость видимой при попадании в руку
    
    // Добавляем в список руки игрока
    ds_list_add(global.player_hand, dom);
    
    // Переупорядочиваем руку визуально (используем новый объект руки)
    if (instance_exists(obj_player_hand_elem)) {
        with (obj_player_hand_elem) {
            arrange_player_hand();
        }
    }
    
    // 4. ПРОВЕРКА ПОСЛЕ ХОДА
    // Вызываем Alarm 2 у контроллера, чтобы он проверил:
    // подошла ли новая кость для хода, или нужно продолжать брать, или передать ход.
    if (instance_exists(obj_game_controller_elem)) {
        with (obj_game_controller_elem) {
            alarm[2] = 15; 
        }
    }
}