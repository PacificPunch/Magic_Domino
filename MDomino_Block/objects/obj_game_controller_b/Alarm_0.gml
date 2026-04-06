/// @description Силовая активация домино

var starter = noone;

// 1. ПРИНУДИТЕЛЬНО проявляем все кости, которые есть в комнате
with (obj_domino) {
    visible = true;
    image_alpha = 1;
    image_speed = 0; // Чтобы не мелькали кадры
}

// 2. ИЩЕМ СТАРТЕР (сначала дубли у игрока, потом у бота)
for (var val = 1; val <= 6; val++) {
    with (obj_domino) {
        if ((owner == "player" || owner == "computer") && value1 == val && value2 == val) {
            starter = id;
            break;
        }
    }
    if (starter != noone) break;
}

// 3. ЕСЛИ ДУБЛЕЙ НЕТ — берем любую первую кость
if (starter == noone) {
    starter = instance_find(obj_domino, 0);
}

// 4. ЕСЛИ СТАРТЕР НАЙДЕН — ВЫВОДИМ ЕГО
if (starter != noone) {
    global.starter_tile = starter;
    global.is_showing_starter = true;
    global.current_turn = starter.owner;

    // Центрируем первую кость (используем твои переменные центра)
    global.play_domino(starter, "first");
    
    // 5. РАССТАНОВКА РУКИ ИГРОКА (Вручную, чтобы не зависеть от других объектов)
    var p_idx = 0;
    with (obj_domino) {
        if (owner == "player" && id != global.starter_tile) {
            // Расставляем внизу экрана (подставь свои координаты, если эти не подходят)
            x = 450 + (p_idx * 110); 
            y = 850;
            p_idx++;
        }
        
        // Прячем кости бота за экран
        if (owner == "computer" && id != global.starter_tile) {
            x = -1000;
            y = -1000;
        }
    }

    // 6. ЗАПУСК ТАЙМЕРА ЗАВЕРШЕНИЯ (через 2 секунды мигание стихнет)
    alarm[4] = 120; 
} else {
    // Если костей вообще нет в комнате
    global.is_showing_starter = false;
    show_debug_message("ОШИБКА: Объекты obj_domino не найдены в комнате!");
}