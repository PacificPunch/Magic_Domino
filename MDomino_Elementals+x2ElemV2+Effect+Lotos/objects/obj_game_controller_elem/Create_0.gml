/// obj_game_controller_elem - Create Event
randomize();
repeat(15) { random(1); } // Дополнительная прокрутка рандома для надежности

// --- 1. ПРЕЖДЕ ВСЕГО ОБЪЯВЛЯЕМ ENUM И ПРАВИЛА СТИХИЙ ---
enum ELEMENT {
    EARTH, // 0: Земля (🪨)
    WATER, // 1: Вода (💧)
    AIR,   // 2: Воздух (🌬️)
    FIRE,  // 3: Огонь (🔥)
    LOTOS, // 4: Лотос (🌕) - Золотая костяшка
    NONE   // 5: Пусто (для старта)
}

// Таблица конфликтов стихий
global.element_conflict[ELEMENT.EARTH] = ELEMENT.AIR;
global.element_conflict[ELEMENT.AIR]   = ELEMENT.EARTH;
global.element_conflict[ELEMENT.WATER] = ELEMENT.FIRE;
global.element_conflict[ELEMENT.FIRE]  = ELEMENT.WATER;
global.element_conflict[ELEMENT.LOTOS] = -1;
global.element_conflict[ELEMENT.NONE]  = -1;

// --- 2. ОБЪЯВЛЯЕМ ФУНКЦИИ ---

// Функция проверки наличия ходов (с учётом ДВУХ СТИХИЙ)
global.check_has_moves = function(target_hand) {
    if (!ds_exists(target_hand, ds_type_list)) return false;
    if (ds_list_size(global.table_chain) == 0) return true;
    
    for (var i = 0; i < ds_list_size(target_hand); i++) {
        var inst = target_hand[| i];
        
        // Проверяем ЛЕВЫЙ край: подходит ли первая или вторая половинка
        if ((inst.is_lotos) || (inst.value1 == global.left_end || global.left_end == -1) && (global.element_conflict[inst.element1] != global.left_element || global.left_element == ELEMENT.LOTOS)) return true;
        if ((inst.is_lotos) || (inst.value2 == global.left_end || global.left_end == -1) && (global.element_conflict[inst.element2] != global.left_element || global.left_element == ELEMENT.LOTOS)) return true;
        
        // Проверяем ПРАВЫЙ край: подходит ли первая или вторая половинка
        if ((inst.is_lotos) || (inst.value1 == global.right_end || global.right_end == -1) && (global.element_conflict[inst.element1] != global.right_element || global.right_element == ELEMENT.LOTOS)) return true;
        if ((inst.is_lotos) || (inst.value2 == global.right_end || global.right_end == -1) && (global.element_conflict[inst.element2] != global.right_element || global.right_element == ELEMENT.LOTOS)) return true;
    }
    return false;
}

// Функция "Рыбы"
global.resolve_fish = function() {
    global.game_over = true;
    var p_score = 0;
    for (var i = 0; i < ds_list_size(global.player_hand); i++) 
        p_score += global.player_hand[| i].value1 + global.player_hand[| i].value2;
        
    var c_score = 0;
    for (var i = 0; i < ds_list_size(global.computer_hand); i++) 
        c_score += global.computer_hand[| i].value1 + global.computer_hand[| i].value2;
    
    var msg = "🐟 РЫБА! 🐟\n\nВаши очки: " + string(p_score) + "\nОчки противника: " + string(c_score) + "\n\n";
    if (p_score < c_score) msg += "Вы победили (меньше очков)!";
    else if (c_score < p_score) msg += "Противник победил!";
    else msg += "Ничья!";
    
    global.end_message = msg;
    if (instance_exists(obj_game_controller_elem)) with (obj_game_controller_elem) alarm[3] = 60;
}

// --- 3. ИНИЦИАЛИЗАЦИЯ ПЕРЕМЕННЫХ ---
if (variable_global_exists("player_hand")) ds_list_destroy(global.player_hand);
if (variable_global_exists("computer_hand")) ds_list_destroy(global.computer_hand);
if (variable_global_exists("bazar")) ds_list_destroy(global.bazar);
if (variable_global_exists("table_chain")) ds_list_destroy(global.table_chain);

global.player_hand   = ds_list_create();
global.computer_hand = ds_list_create();
global.bazar         = ds_list_create();
global.table_chain   = ds_list_create();
global.left_lotos_sequence = ds_list_create();  // Последовательность стихий для левого края
global.right_lotos_sequence = ds_list_create(); // Последовательность стихий для правого края

global.left_tile_id = noone; global.right_tile_id = noone;
global.choice_mode = false; global.selected_domino = noone;

global.left_end  = -1; global.right_end = -1;
global.left_element = ELEMENT.NONE;  // Храним стихию на левом конце
global.right_element = ELEMENT.NONE; // Храним стихию на правом конце

global.table_center_x = 1920 / 2; global.table_center_y = 1080 / 2;
global.current_turn   = "player"; global.game_over      = false;
global.starter_tile = noone; global.is_showing_starter = false; global.end_message = "";
global.effect_animating = false; // Флаг паузы во время анимации эффекта

// Для шпаргалки по нажатию Tab
show_cheat_colors = false;
// Система змейки
global.left_count = 0; global.right_count = 0;
global.left_edge_x = global.table_center_x; global.left_edge_y = global.table_center_y;
global.right_edge_x = global.table_center_x; global.right_edge_y = global.table_center_y;
global.first_turn_dir = ""; 
global.left_dir = "left"; global.right_dir = "right";
global.left_prev_wid = 32; global.right_prev_wid = 32;

// --- 4. ДИНАМИЧЕСКАЯ КАРТА РАСПРЕДЕЛЕНИЯ СТИХИЙ (Баланс Сил 49 элементов) ---
if (variable_global_exists("domino_elemental_map")) {
    ds_map_destroy(global.domino_elemental_map);
}
global.domino_elemental_map = ds_map_create();

// История сыгранных/уничтоженных костей — чтобы трекер правильно отображал цвет стихии
if (variable_global_exists("known_dominos")) ds_map_destroy(global.known_dominos);
global.known_dominos = ds_map_create();

var element_pool = ds_list_create();
// Нам нужно 49 стихий: 21 кость * 2 + 7 дублей * 1. 
// Кладем по 12 стихий каждого типа (всего 48)
repeat(12) {
    ds_list_add(element_pool, ELEMENT.EARTH, ELEMENT.WATER, ELEMENT.AIR, ELEMENT.FIRE);
}
// Добиваем до 49-ти случайной стихией
ds_list_add(element_pool, choose(ELEMENT.EARTH, ELEMENT.WATER, ELEMENT.AIR, ELEMENT.FIRE));

// Тщательно перемешиваем мешок
randomize(); ds_list_shuffle(element_pool);
repeat(50) { 
    var _idx1 = irandom(48); var _idx2 = irandom(48);
    var _temp = element_pool[| _idx1];
    element_pool[| _idx1] = element_pool[| _idx2];
    element_pool[| _idx2] = _temp;
}

// --- 5. СОЗДАНИЕ И РАЗДАЧА КОСТЕЙ ---
var all_dominoes = ds_list_create();
for (var v1 = 0; v1 <= 6; v1++) {
    for (var v2 = v1; v2 <= 6; v2++) { 
        // Используем 100% надежное целое число (например, 3 и 5 станут числом 35)
        ds_list_add(all_dominoes, (v1 * 10) + v2); 
    }
}
ds_list_shuffle(all_dominoes);

var pool_idx = 0;
for (var i = 0; i < 28; i++) {
    var val = all_dominoes[| i];
    var _v1 = val div 10; 
    var _v2 = val mod 10;
    
    var inst = instance_create_layer(0, 0, "Instances", obj_domino_elem);
    inst.value1 = _v1; 
    inst.value2 = _v2; 
    inst.is_double = (_v1 == _v2);
    
    var spr_name = "spr_" + string(_v1) + string(_v2);
    inst.sprite_index = asset_get_index(spr_name);
    
    // --- НАЗНАЧАЕМ ДВЕ СТИХИИ ---
    var e1 = element_pool[| pool_idx++];
    var e2;
    
    if (inst.is_double) {
        e2 = e1; // Для дубля берем ту же, пул не расходуем
    } else {
        // Для обычной костяшки стихии должны быть разными
        var _found_idx = pool_idx;
        while (_found_idx < ds_list_size(element_pool) && element_pool[| _found_idx] == e1) {
            _found_idx++;
        }
        
        if (_found_idx < ds_list_size(element_pool)) {
            // Нашли другую стихию, меняем местами с текущей (pool_idx)
            var _temp = element_pool[| pool_idx];
            element_pool[| pool_idx] = element_pool[| _found_idx];
            element_pool[| _found_idx] = _temp;
        } else {
            // Запасной вариант, если остались только одинаковые стихии
            var _new_e = choose(ELEMENT.EARTH, ELEMENT.WATER, ELEMENT.AIR, ELEMENT.FIRE);
            while (_new_e == e1) _new_e = choose(ELEMENT.EARTH, ELEMENT.WATER, ELEMENT.AIR, ELEMENT.FIRE);
            element_pool[| pool_idx] = _new_e;
        }
        
        e2 = element_pool[| pool_idx++];
    }
    
    inst.element1 = e1;
    inst.element2 = e2;
    
    // Динамически записываем МАССИВ в глобальную карту
    global.domino_elemental_map[? spr_name] = [e1, e2];
    
    inst.visible = false;
    
    if (i < 7) { inst.owner = "player"; ds_list_add(global.player_hand, inst); }
    else if (i < 14) { inst.owner = "computer"; ds_list_add(global.computer_hand, inst); }
    else { inst.owner = "bazar"; ds_list_add(global.bazar, inst); }
}

// Очищаем память от списков
ds_list_destroy(all_dominoes);
ds_list_destroy(element_pool);

// Создаем объекты управления руками и базар
if (!instance_exists(obj_player_hand_elem)) instance_create_layer(0, 0, "Instances", obj_player_hand_elem);
if (!instance_exists(obj_computer_hand_elem)) instance_create_layer(0, 0, "Instances", obj_computer_hand_elem);
instance_create_layer(200, global.table_center_y, "Instances", obj_bazar_elem);

alarm[0] = 2; // Поиск стартовой кости

// --- 6. ОСНОВНАЯ ФУНКЦИЯ ХОДА ---
global.play_domino = function(dom_id, side) {
    global.choice_mode = false; 
    global.selected_domino = noone;

    var is_double = dom_id.is_double;
    var len_half = is_double ? 32 : 64; 
    var wid_half = is_double ? 64 : 32;
    
    // --- СОХРАНЕНИЕ ПРЕДЫДУЩЕГО СОСТОЯНИЯ (Для эффекта Огня) ---
    dom_id.prev_left_end = global.left_end;
    dom_id.prev_left_element = global.left_element;
    dom_id.prev_left_edge_x = global.left_edge_x;
    dom_id.prev_left_edge_y = global.left_edge_y;
    if (variable_global_exists("left_dir")) dom_id.prev_left_dir = global.left_dir; else dom_id.prev_left_dir = "left";
    if (variable_global_exists("left_prev_wid")) dom_id.prev_left_prev_wid = global.left_prev_wid; else dom_id.prev_left_prev_wid = 32;
    dom_id.prev_left_tile_id = global.left_tile_id;
    dom_id.prev_left_count = global.left_count;
    
    dom_id.prev_right_end = global.right_end;
    dom_id.prev_right_element = global.right_element;
    dom_id.prev_right_edge_x = global.right_edge_x;
    dom_id.prev_right_edge_y = global.right_edge_y;
    if (variable_global_exists("right_dir")) dom_id.prev_right_dir = global.right_dir; else dom_id.prev_right_dir = "right";
    if (variable_global_exists("right_prev_wid")) dom_id.prev_right_prev_wid = global.right_prev_wid; else dom_id.prev_right_prev_wid = 32;
    dom_id.prev_right_tile_id = global.right_tile_id;
    dom_id.prev_right_count = global.right_count;
    
    dom_id.target_id = noone;
    if (side == "left") dom_id.target_id = global.left_tile_id;
    if (side == "right") dom_id.target_id = global.right_tile_id;
    // -------------------------------------------------------------
    
    if (side == "first") {
        dom_id.x = global.table_center_x; dom_id.y = global.table_center_y;
        dom_id.image_angle = is_double ? 0 : 90;
        
        // Стартовая кость задает числа и стихии для обоих краев
        if (dom_id.is_lotos) {
            global.left_end = -1; global.right_end = -1;
            global.left_element = ELEMENT.LOTOS; global.right_element = ELEMENT.LOTOS;
        } else {
            global.left_end = dom_id.value1; global.right_end = dom_id.value2;
            global.left_element = dom_id.element1; global.right_element = dom_id.element2;
        }
        
        global.left_edge_x = dom_id.x - len_half; global.left_edge_y = dom_id.y;
        global.right_edge_x = dom_id.x + len_half; global.right_edge_y = dom_id.y;
        global.left_prev_wid = wid_half; global.right_prev_wid = wid_half;
        global.left_tile_id = dom_id; global.right_tile_id = dom_id;
        
        // Сброс счетчиков змейки для новой цепи
        global.left_count = 0; global.right_count = 0;
        global.left_dir = "left"; global.right_dir = "right";
        global.first_turn_dir = ""; 
    } 
    else {
        var current_dir, target_dir, edge_x, edge_y, match_v1;
        var p_wid = (side == "right") ? global.right_prev_wid : global.left_prev_wid;

        if (side == "right") {
            global.right_count++; current_dir = global.right_dir;
            if (global.right_count <= 4) target_dir = "right";
            else if (global.right_count <= 6) { 
                if (global.first_turn_dir == "") global.first_turn_dir = choose("up", "down");
                target_dir = global.first_turn_dir; 
            } else target_dir = "left";
            
            edge_x = global.right_edge_x; edge_y = global.right_edge_y;
            
            if (dom_id.is_lotos) {
                match_v1 = true;
                global.right_end = -1;
                global.right_element = ELEMENT.LOTOS;
            } else {
                match_v1 = (dom_id.value1 == global.right_end || global.right_end == -1);
                // Если приставили value1, торчать будет value2 и стихия 2
                global.right_end = match_v1 ? dom_id.value2 : dom_id.value1;
                global.right_element = match_v1 ? dom_id.element2 : dom_id.element1; 
            }
            global.right_tile_id = dom_id;
        } 
        else {
            global.left_count++; current_dir = global.left_dir;
            if (global.left_count <= 4) target_dir = "left";
            else if (global.left_count <= 6) { 
                if (global.first_turn_dir == "") global.first_turn_dir = choose("up", "down");
                target_dir = (global.first_turn_dir == "up") ? "down" : "up"; 
            } else target_dir = "right";
            
            edge_x = global.left_edge_x; edge_y = global.left_edge_y;
            
            if (dom_id.is_lotos) {
                match_v1 = true;
                global.left_end = -1;
                global.left_element = ELEMENT.LOTOS;
            } else {
                match_v1 = (dom_id.value1 == global.left_end || global.left_end == -1);
                // Если приставили value1, торчать будет value2 и стихия 2
                global.left_end = match_v1 ? dom_id.value2 : dom_id.value1;
                global.left_element = match_v1 ? dom_id.element2 : dom_id.element1;
            }
            global.left_tile_id = dom_id;
        }

        // Начальные значения на случай если ни одно условие не сработало
        var px = edge_x, py = edge_y, nx = edge_x, ny = edge_y;
        if (current_dir == target_dir) {
            if (target_dir == "right") { px = edge_x + len_half; py = edge_y; nx = px + len_half; ny = py; }
            else if (target_dir == "left") { px = edge_x - len_half; py = edge_y; nx = px - len_half; ny = py; }
            else if (target_dir == "down") { px = edge_x; py = edge_y + len_half; nx = px; ny = py + len_half; }
            else if (target_dir == "up") { px = edge_x; py = edge_y - len_half; nx = px; ny = py - len_half; }
        } else {
            if (current_dir == "right" && target_dir == "down") { px = edge_x - 32; py = edge_y + p_wid + len_half; nx = px; ny = py + len_half; }
            else if (current_dir == "right" && target_dir == "up") { px = edge_x - 32; py = edge_y - p_wid - len_half; nx = px; ny = py - len_half; }
            else if (current_dir == "left" && target_dir == "down") { px = edge_x + 32; py = edge_y + p_wid + len_half; nx = px; ny = py + len_half; }
            else if (current_dir == "left" && target_dir == "up") { px = edge_x + 32; py = edge_y - p_wid - len_half; nx = px; ny = py - len_half; }
            else if (current_dir == "down" && target_dir == "right") { px = edge_x + p_wid + len_half; py = edge_y - 32; nx = px + len_half; ny = py; }
            else if (current_dir == "down" && target_dir == "left") { px = edge_x - p_wid - len_half; py = edge_y - 32; nx = px - len_half; ny = py; }
            else if (current_dir == "up" && target_dir == "right") { px = edge_x + p_wid + len_half; py = edge_y + 32; nx = px + len_half; ny = py; }
            else if (current_dir == "up" && target_dir == "left") { px = edge_x - p_wid - len_half; py = edge_y + 32; nx = px - len_half; ny = py; }
        }
        dom_id.x = px; dom_id.y = py;

        if (is_double) dom_id.image_angle = (target_dir == "right" || target_dir == "left") ? 0 : 90;
        else {
            if (target_dir == "right") dom_id.image_angle = match_v1 ? 90 : 270;
            else if (target_dir == "left") dom_id.image_angle = match_v1 ? 270 : 90;
            else if (target_dir == "down") dom_id.image_angle = match_v1 ? 0 : 180;
            else if (target_dir == "up") dom_id.image_angle = match_v1 ? 180 : 0;
        }
        
        if (side == "right") { global.right_edge_x = nx; global.right_edge_y = ny; global.right_dir = target_dir; global.right_prev_wid = wid_half; } 
        else { global.left_edge_x = nx; global.left_edge_y = ny; global.left_dir = target_dir; global.left_prev_wid = wid_half; }
    }

    dom_id.owner = "table"; 
    dom_id.depth = -150 - ds_list_size(global.table_chain); 
    dom_id.visible = true;
    ds_list_add(global.table_chain, dom_id);
    // Запоминаем что эта кость была сыграна
    global.known_dominos[? sprite_get_name(dom_id.sprite_index)] = true;

    var p_idx = ds_list_find_index(global.player_hand, dom_id); if (p_idx >= 0) ds_list_delete(global.player_hand, p_idx);
    var c_idx = ds_list_find_index(global.computer_hand, dom_id); if (c_idx >= 0) ds_list_delete(global.computer_hand, c_idx);

    if (instance_exists(obj_player_hand_elem)) with (obj_player_hand_elem) arrange_player_hand();
    if (instance_exists(obj_computer_hand_elem)) with (obj_computer_hand_elem) arrange_computer_hand();
    
    // --- ОБНОВЛЕНИЕ ПОСЛЕДОВАТЕЛЬНОСТИ ЛОТОСА ---
    if (side == "first") {
        ds_list_clear(global.left_lotos_sequence);
        ds_list_clear(global.right_lotos_sequence);
    } else {
        var _seq = (side == "left") ? global.left_lotos_sequence : global.right_lotos_sequence;
        var _other_seq = (side == "left") ? global.right_lotos_sequence : global.left_lotos_sequence;
        
        // Очищаем противоположный край, так как "ряд" прервался
        ds_list_clear(_other_seq);
        
        // Добавляем стихии новой кости (вместе с её ID)
        ds_list_add(_seq, {elem: dom_id.element1, tile: dom_id});
        ds_list_add(_seq, {elem: dom_id.element2, tile: dom_id});
        
        // Убираем дубликаты стихий, оставляя только последние уникальные
        var _i = 0;
        while (_i < ds_list_size(_seq)) {
            var _data = _seq[| _i];
            var _found = false;
            for (var _j = _i + 1; _j < ds_list_size(_seq); _j++) {
                var _next_data = _seq[| _j];
                if (_next_data.elem == _data.elem) {
                    _found = true; break;
                }
            }
            if (_found) {
                // Если стихия встречается дальше, удаляем все ДО текущей позиции включительно
                repeat(_i + 1) ds_list_delete(_seq, 0);
                _i = 0;
            } else {
                _i++;
            }
        }
        
        // Если набрали 4 стихии - выдаем Лотос
        if (ds_list_size(_seq) >= 4) {
            var _owner = (global.current_turn == "player") ? "player" : "computer";
            var _hand = (_owner == "player") ? global.player_hand : global.computer_hand;
            
            // ЗАСТАВЛЯЕМ КОСТЯШКИ МИГАТЬ
            var _blink_col = make_color_rgb(255, 215, 0);
            for (var _k = 0; _k < ds_list_size(_seq); _k++) {
                var _item = _seq[| _k];
                if (instance_exists(_item.tile)) {
                    _item.tile.effect_blink_color = _blink_col;
                    _item.tile.effect_blink_timer = 130; // ~2 секунды
                }
            }

            var _lotos = instance_create_layer(0, 0, "Instances", obj_domino_elem);
            _lotos.value1 = -1; _lotos.value2 = -1;
            _lotos.element1 = ELEMENT.LOTOS; _lotos.element2 = ELEMENT.LOTOS;
            _lotos.is_lotos = true;
            _lotos.is_double = false;
            _lotos.owner = _owner;
            _lotos.sprite_index = spr_00; // Пустышка
            _lotos.visible = true;
            _lotos.effect_blink_color = make_color_rgb(255, 215, 0); // Золотой цвет
            _lotos.effect_blink_timer = 120;
            
            ds_list_add(_hand, _lotos);
            ds_list_clear(_seq);
            
            if (instance_exists(obj_player_hand_elem)) with (obj_player_hand_elem) arrange_player_hand();
            if (instance_exists(obj_computer_hand_elem)) with (obj_computer_hand_elem) arrange_computer_hand();
        }
        
        // После всех проверок, если это был дубль или Лотос — сбрасываем прогресс для следующей серии
        if (is_double || dom_id.is_lotos) {
            ds_list_clear(global.left_lotos_sequence);
            ds_list_clear(global.right_lotos_sequence);
        }
    }
    
    // === НОВЫЕ ПРАВИЛА: ЭФФЕКТЫ ОТ ДУБЛЕЙ ===
    var _pass_turn = true;

    if (is_double) {
        var _played_by = (global.current_turn == "player") ? "player" : "computer";
        var _eff_elem = dom_id.element1;
        
        // ЗЕМЛЯ: Противник берет кость из базара (было Огонь)
        if (_eff_elem == ELEMENT.EARTH) {
            var _opp_hand = (_played_by == "player") ? global.computer_hand : global.player_hand;
            if (ds_list_size(global.bazar) > 0) {
                var _draw_dom = global.bazar[| 0];
                ds_list_delete(global.bazar, 0);
                _draw_dom.owner = (_played_by == "player") ? "computer" : "player";
                _draw_dom.visible = true; 
                ds_list_add(_opp_hand, _draw_dom);
                
                // АНИМАЦИЯ ЗЕМЛИ
                _draw_dom.effect_blink_color = c_green;
                _draw_dom.effect_blink_timer = 120;
                _draw_dom.effect_destroy = false;
                
                if (instance_exists(obj_player_hand_elem)) with (obj_player_hand_elem) arrange_player_hand();
                if (instance_exists(obj_computer_hand_elem)) with (obj_computer_hand_elem) arrange_computer_hand();
            }
        }
        
        // ОГОНЬ: Уничтожает себя и цель (target_id), откатывая край
        if (_eff_elem == ELEMENT.FIRE) {
            var _t_id = dom_id.target_id;
            
            // Удаляем сыгранный Огонь из цепи стола
            var idx = ds_list_find_index(global.table_chain, dom_id);
            if (idx >= 0) ds_list_delete(global.table_chain, idx);
            // АНИМАЦИЯ ОГНЯ
            dom_id.effect_blink_color = c_red;
            dom_id.effect_blink_timer = 120;
            dom_id.effect_destroy = true;
            
            if (_t_id != noone && instance_exists(_t_id)) {
                // Удаляем цель (которую Огонь уничтожил)
                var t_idx = ds_list_find_index(global.table_chain, _t_id);
                if (t_idx >= 0) ds_list_delete(global.table_chain, t_idx);
                
                // АНИМАЦИЯ ОГНЯ (Цель)
                _t_id.effect_blink_color = c_red;
                _t_id.effect_blink_timer = 120;
                _t_id.effect_destroy = true;
                
                // Восстанавливаем состояние края из target_id
                if (side == "left") {
                    global.left_end = _t_id.prev_left_end;
                    global.left_element = _t_id.prev_left_element;
                    global.left_edge_x = _t_id.prev_left_edge_x;
                    global.left_edge_y = _t_id.prev_left_edge_y;
                    global.left_dir = _t_id.prev_left_dir;
                    global.left_prev_wid = _t_id.prev_left_prev_wid;
                    global.left_tile_id = _t_id.prev_left_tile_id;
                    global.left_count = _t_id.prev_left_count;
                } else if (side == "right") {
                    global.right_end = _t_id.prev_right_end;
                    global.right_element = _t_id.prev_right_element;
                    global.right_edge_x = _t_id.prev_right_edge_x;
                    global.right_edge_y = _t_id.prev_right_edge_y;
                    global.right_dir = _t_id.prev_right_dir;
                    global.right_prev_wid = _t_id.prev_right_prev_wid;
                    global.right_tile_id = _t_id.prev_right_tile_id;
                    global.right_count = _t_id.prev_right_count;
                }
                
                // Если target_id был первой (стартовой) костью, откатываем весь стол
                if (_t_id == global.starter_tile) {
                    global.left_end = -1; global.right_end = -1;
                    global.left_tile_id = noone; global.right_tile_id = noone;
                    global.left_count = 0; global.right_count = 0;
                    global.left_dir = "left"; global.right_dir = "right";
                    global.first_turn_dir = "";
                    ds_list_clear(global.table_chain);
                }
            } else {
                // Если Огонь играется самым первым на пустой стол
                global.left_end = -1; global.right_end = -1;
                global.left_tile_id = noone; global.right_tile_id = noone;
                global.left_count = 0; global.right_count = 0;
                global.left_dir = "left"; global.right_dir = "right";
                global.first_turn_dir = "";
                ds_list_clear(global.table_chain);
            }
        }
        
        // ВОЗДУХ: Из руки сыгравшего сбрасывается случайная кость
        if (_eff_elem == ELEMENT.AIR) {
            var _curr_hand = (_played_by == "player") ? global.player_hand : global.computer_hand;
            var _hand_size = ds_list_size(_curr_hand);
            if (_hand_size > 0) {
                var _rand_idx = irandom(_hand_size - 1);
                var _discard_dom = _curr_hand[| _rand_idx];
                ds_list_delete(_curr_hand, _rand_idx);
                
                // АНИМАЦИЯ ВОЗДУХА
                _discard_dom.effect_blink_color = c_aqua;
                _discard_dom.effect_blink_timer = 120;
                _discard_dom.effect_destroy = true;
                _discard_dom.owner = (_played_by == "player") ? "discarded_player" : "discarded_computer";
                _discard_dom.depth = -500;
                _discard_dom.x = 1920 / 2; // Центр руки
                // Запоминаем что эта кость была сброшена
                global.known_dominos[? sprite_get_name(_discard_dom.sprite_index)] = true;
                if (_played_by == "player") {
                    _discard_dom.y -= 130; // Выше на уровень одной костяшки
                } else {
                    _discard_dom.y += 130; // У противника опускается ниже
                }
                
                if (instance_exists(obj_player_hand_elem)) with (obj_player_hand_elem) arrange_player_hand();
                if (instance_exists(obj_computer_hand_elem)) with (obj_computer_hand_elem) arrange_computer_hand();
            }
        }
        
        // ВОДА: Ход не передается
        if (_eff_elem == ELEMENT.WATER) {
            _pass_turn = false;
            
            // АНИМАЦИЯ ВОДЫ (Все кости в руке мигают)
            var _curr_hand = (_played_by == "player") ? global.player_hand : global.computer_hand;
            for(var _i = 0; _i < ds_list_size(_curr_hand); _i++) {
                var _d = _curr_hand[| _i];
                if (instance_exists(_d)) {
                    _d.effect_blink_color = c_blue;
                    _d.effect_blink_timer = 120;
                    _d.effect_destroy = false;
                }
            }
        }
    }
    // ======================================

    if (_pass_turn) {
        global.current_turn = (global.current_turn == "player") ? "computer" : "player";
    }
    
    if (is_double) {
        // Если был сыгран дубль стихии — запускаем паузу на 2 секунды
        global.effect_animating = true;
        if (instance_exists(obj_game_controller_elem)) with (obj_game_controller_elem) alarm[5] = 130;
    } else {
        if (instance_exists(obj_game_controller_elem)) with (obj_game_controller_elem) alarm[2] = 20;
    }
}

