/// obj_game_controller_b - Alarm 0

var starter = noone;

// 1. Ищем любой объект домино, принадлежащий игроку
with (obj_domino) {
    if (owner == "player") {
        starter = id;
        break; 
    }
}

// 2. Если у игрока нет, ищем у бота
if (starter == noone) {
    with (obj_domino) {
        if (owner == "computer") {
            starter = id;
            break;
        }
    }
}

// 3. Запуск
if (starter != noone) {
    global.starter_tile = starter;
    global.is_showing_starter = true;
    
    // ПРИНУДИТЕЛЬНО задаем координаты центра, если переменные подвели
    starter.x = 960; 
    starter.y = 540;
    starter.visible = true;

    // Вызываем логику первой кости
    global.play_domino(starter, "first");
    
    global.current_turn = starter.owner;
    
    // ВКЛЮЧАЕМ ТАЙМЕР ЗАВЕРШЕНИЯ
    alarm[4] = 60; 
}