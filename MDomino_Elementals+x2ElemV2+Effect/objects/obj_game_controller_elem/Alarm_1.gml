/// obj_game_controller_elem - Alarm 1 (Ход компьютера)

// Блокировка AI во время анимации эффекта
if (variable_global_exists("effect_animating") && global.effect_animating) {
    alarm[1] = 20; // Ожидаем окончания анимации
    exit;
}

if (global.game_over || global.current_turn != "computer") exit;

var played = false;

for (var i = 0; i < ds_list_size(global.computer_hand); i++) {
    var dom = global.computer_hand[| i];
    
    // Если стол пуст, ходим первой попавшейся костью
    if (ds_list_size(global.table_chain) == 0) {
        global.play_domino(dom, "first");
        played = true; 
        break;
    } 
    else {
        // --- ПРОВЕРКА ЛЕВОГО КРАЯ ---
        // Проверяем первую половинку (value1 + element1)
        if (dom.value1 == global.left_end && global.element_conflict[dom.element1] != global.left_element) {
            global.play_domino(dom, "left");
            played = true; 
            break;
        }
        // Проверяем вторую половинку (value2 + element2)
        else if (dom.value2 == global.left_end && global.element_conflict[dom.element2] != global.left_element) {
            global.play_domino(dom, "left");
            played = true; 
            break;
        }
        
        // --- ПРОВЕРКА ПРАВОГО КРАЯ ---
        if (!played) {
            // Проверяем первую половинку (value1 + element1)
            if (dom.value1 == global.right_end && global.element_conflict[dom.element1] != global.right_element) {
                global.play_domino(dom, "right"); 
                played = true; 
                break;
            }
            // Проверяем вторую половинку (value2 + element2)
            else if (dom.value2 == global.right_end && global.element_conflict[dom.element2] != global.right_element) {
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
        // но спрайт рубашки останется, так как это рука компьютера
        draw_dom.visible = true; 
        
        ds_list_add(global.computer_hand, draw_dom);
        
        // Перерисовываем руку компьютера
        if (instance_exists(obj_computer_hand_elem)) {
            with (obj_computer_hand_elem) arrange_computer_hand();
        }
        
        // Компьютер берет одну кость и сразу "думает" снова через полсекунды
        alarm[1] = 30; 
    } else {
        // Если базара нет и хода нет - передаем ход игроку (Step Event сам проверит на "Рыбу")
        global.current_turn = "player";
        if (instance_exists(obj_game_controller_elem)) alarm[2] = 10;
    }
}