/// obj_bazar_elem - Mouse Left Pressed

// 1. ПРОВЕРКА УСЛОВИЙ
// Если игра окончена, стартовая анимация еще идет, или сейчас ход компьютера — ничего не делаем
if (global.game_over || global.is_showing_starter || global.current_turn != "player") exit;

// 2. ПРОВЕРКА НАЛИЧИЯ ХОДОВ (НОВЫЕ ПРАВИЛА СТИХИЙ)
// Функция check_has_moves сама проверит ОБЕ стихии (element1 и element2) у каждой кости в вашей руке.
// Если у вас есть ХОТЯ БЫ ОДИН легальный ход, брать из базара запрещено.
if (global.check_has_moves(global.player_hand)) {
    // Выход: кость брать нельзя, так как есть доступный ход
    exit;
}

// 3. ЛОГИКА ВЗЯТИЯ КОСТИ
if (ds_list_size(global.bazar) > 0) {
    // Берем верхнюю кость из списка базара
    var dom = global.bazar[| 0];
    ds_list_delete(global.bazar, 0);
    
    // Смена владельца и раскрытие "рубашки"
    dom.owner = "player";
    dom.visible = true; 
    
    // Добавляем в список руки игрока
    ds_list_add(global.player_hand, dom);
    
    // Переупорядочиваем руку визуально (она появится с краю)
    if (instance_exists(obj_player_hand_elem)) {
        with (obj_player_hand_elem) {
            arrange_player_hand();
        }
    }
    
    // 4. ПРОВЕРКА ПОСЛЕ ДОБОРА
    // Вызываем Alarm 2 у контроллера.
    // Контроллер проверит: подошла ли новая кость, нужно ли брать еще одну, 
    // или (если базар опустел, а ходов так и нет) нужно передать ход противнику.
    if (instance_exists(obj_game_controller_elem)) {
        with (obj_game_controller_elem) {
            alarm[2] = 15; 
        }
    }
}