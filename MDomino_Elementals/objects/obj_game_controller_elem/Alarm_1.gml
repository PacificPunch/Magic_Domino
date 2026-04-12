/// obj_game_controller_elem - Alarm 1 (Ход компьютера)

if (global.game_over || global.current_turn != "computer") exit;

var played = false;

// 1. Ищем подходящий ход
for (var i = 0; i < ds_list_size(global.computer_hand); i++) {
    var dom = global.computer_hand[| i];
    var my_elem = dom.element;
    
    // Если стол пуст (первый ход игры)
    if (ds_list_size(global.table_chain) == 0) {
        global.play_domino(dom, "first"); 
        played = true; 
        break;
    } 
    else {
        // --- ПРОВЕРКА ЛЕВОГО КРАЯ ---
        if (dom.value1 == global.left_end || dom.value2 == global.left_end) {
            // Условие Elemental: Дубль ИЛИ нет конфликта стихий
            if (dom.is_double || global.element_conflict[my_elem] != global.left_element) {
                global.play_domino(dom, "left"); 
                played = true; 
                break;
            }
        }
        
        // --- ПРОВЕРКА ПРАВОГО КРАЯ ---
        if (!played && (dom.value1 == global.right_end || dom.value2 == global.right_end)) {
            // Условие Elemental: Дубль ИЛИ нет конфликта стихий
            if (dom.is_double || global.element_conflict[my_elem] != global.right_element) {
                global.play_domino(dom, "right"); 
                played = true; 
                break;
            }
        }
    }
}

// 2. Если хода нет и на базаре что-то есть - берем кость
if (!played) {
    if (ds_list_size(global.bazar) > 0) {
        var draw_dom = global.bazar[| 0];
        ds_list_delete(global.bazar, 0);
        
        draw_dom.owner = "computer";
        // Важно: новая кость должна быть видимой для логики, 
        // но спрайт может быть скрыт, если вы рисуете "рубашки"
        draw_dom.visible = true; 
        
        ds_list_add(global.computer_hand, draw_dom);
        
        // Перерисовываем руку компьютера
        if (instance_exists(obj_computer_hand_elem)) {
            with (obj_computer_hand_elem) arrange_computer_hand();
        }
        
        // Компьютер берет одну кость и сразу "думает" снова через полсекунды
        alarm[1] = 30; 
    } else {
        // Если базара нет и хода нет - передаем ход игроку (Alarm 2 проверит на "Рыбу")
        global.current_turn = "player";
        alarm[2] = 10;
    }
}