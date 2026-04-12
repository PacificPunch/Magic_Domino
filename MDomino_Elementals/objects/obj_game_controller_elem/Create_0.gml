randomize();
repeat(irandom_range(5, 15)) { random(1); } // Дополнительная "прокрутка" генератора

// --- 1. ПРЕЖДЕ ВСЕГО ОБЪЯВЛЯЕМ ENUM И ПРАВИЛА СТИХИЙ ---

enum ELEMENT {
    EARTH, // 0: Земля (🪨)
    WATER, // 1: Вода (💧)
    AIR,   // 2: Воздух (🌬️)
    FIRE,  // 3: Огонь (🔥)
    NONE   // 4: Пусто (для старта)
}

// Таблица конфликтов стихий
global.element_conflict[ELEMENT.EARTH] = ELEMENT.AIR;
global.element_conflict[ELEMENT.AIR]   = ELEMENT.EARTH;
global.element_conflict[ELEMENT.WATER] = ELEMENT.FIRE;
global.element_conflict[ELEMENT.FIRE]  = ELEMENT.WATER;
global.element_conflict[ELEMENT.NONE]  = -1;

// --- 2. ОБЪЯВЛЯЕМ ФУНКЦИИ ---

// Функция проверки наличия ходов (с учётом СТИХИЙ)
global.check_has_moves = function(target_hand) {
    if (ds_list_size(global.table_chain) == 0) return true;
    
    for (var i = 0; i < ds_list_size(target_hand); i++) {
        var inst = target_hand[| i];
        
        // Проверяем ЛЕВЫЙ край (Цифра совпадает И (Стихия не конфликтует ИЛИ это Дубль))
        if (inst.value1 == global.left_end || inst.value2 == global.left_end) {
            if (inst.is_double || global.element_conflict[inst.element] != global.left_element) {
                return true;
            }
        }
        
        // Проверяем ПРАВЫЙ край
        if (inst.value1 == global.right_end || inst.value2 == global.right_end) {
            if (inst.is_double || global.element_conflict[inst.element] != global.right_element) {
                return true;
            }
        }
    }
    return false;
}

// Функция "Рыбы"
global.resolve_fish = function() {
    global.game_over = true;
    var p_score = 0;
    for (var i = 0; i < ds_list_size(global.player_hand); i++) p_score += global.player_hand[| i].value1 + global.player_hand[| i].value2;
    var c_score = 0;
    for (var i = 0; i < ds_list_size(global.computer_hand); i++) c_score += global.computer_hand[| i].value1 + global.computer_hand[| i].value2;
    
    var msg = "🐟 РЫБА! 🐟\n\nВаши очки: " + string(p_score) + "\nОчки противника: " + string(c_score) + "\n\n";
    if (p_score < c_score) msg += "Вы победили (меньше очков)!";
    else if (c_score < p_score) msg += "Противник победил!";
    else msg += "Ничья!";
    
    global.end_message = msg;
    with (obj_game_controller_elem) alarm[3] = 10;
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

global.left_tile_id = noone;
global.right_tile_id = noone;
global.choice_mode = false;
global.selected_domino = noone;

global.left_end  = -1;
global.right_end = -1;
global.left_element = ELEMENT.NONE;  // Храним стихию на концах
global.right_element = ELEMENT.NONE;

global.table_center_x = 1920 / 2;
global.table_center_y = 1080 / 2;
global.current_turn   = "player";
global.game_over      = false;
global.starter_tile = noone;
global.is_showing_starter = false;
global.end_message = "";

// Система змейки
global.left_count = 0; global.right_count = 0;
global.left_edge_x = global.table_center_x; global.left_edge_y = global.table_center_y;
global.right_edge_x = global.table_center_x; global.right_edge_y = global.table_center_y;
global.first_turn_dir = ""; 
global.left_dir = "left"; global.right_dir = "right";
global.left_prev_wid = 32; global.right_prev_wid = 32;

// --- 4. КАРТА РАСПРЕДЕЛЕНИЯ СТИХИЙ (Баланс Сил) ---
global.domino_elemental_map = ds_map_create();
var _m = global.domino_elemental_map;

// Земля (🪨)
_m[? "spr_00"] = ELEMENT.EARTH; _m[? "spr_01"] = ELEMENT.EARTH; _m[? "spr_02"] = ELEMENT.EARTH;
_m[? "spr_03"] = ELEMENT.EARTH; _m[? "spr_11"] = ELEMENT.EARTH; _m[? "spr_12"] = ELEMENT.EARTH;
_m[? "spr_22"] = ELEMENT.EARTH;
// Вода (💧)
_m[? "spr_04"] = ELEMENT.WATER; _m[? "spr_13"] = ELEMENT.WATER; _m[? "spr_05"] = ELEMENT.WATER;
_m[? "spr_14"] = ELEMENT.WATER; _m[? "spr_23"] = ELEMENT.WATER; _m[? "spr_33"] = ELEMENT.WATER;
_m[? "spr_06"] = ELEMENT.WATER;
// Воздух (🌬️)
_m[? "spr_16"] = ELEMENT.AIR; _m[? "spr_25"] = ELEMENT.AIR; _m[? "spr_34"] = ELEMENT.AIR;
_m[? "spr_44"] = ELEMENT.AIR; _m[? "spr_15"] = ELEMENT.AIR; _m[? "spr_26"] = ELEMENT.AIR;
_m[? "spr_35"] = ELEMENT.AIR;
// Огонь (🔥)
_m[? "spr_46"] = ELEMENT.FIRE; _m[? "spr_55"] = ELEMENT.FIRE; _m[? "spr_45"] = ELEMENT.FIRE;
_m[? "spr_36"] = ELEMENT.FIRE; _m[? "spr_56"] = ELEMENT.FIRE; _m[? "spr_66"] = ELEMENT.FIRE;
_m[? "spr_24"] = ELEMENT.FIRE;

// --- 5. СОЗДАНИЕ И РАЗДАЧА КОСТЕЙ ---

var all_dominoes = ds_list_create();
for (var v1 = 0; v1 <= 6; v1++) {
    for (var v2 = v1; v2 <= 6; v2++) { ds_list_add(all_dominoes, [v1, v2]); }
}

// Усиленное перемешивание
ds_list_shuffle(all_dominoes);
var _size = ds_list_size(all_dominoes);
repeat(100) {
    var _idx1 = irandom(_size - 1);
    var _idx2 = irandom(_size - 1);
    var _temp = all_dominoes[| _idx1];
    all_dominoes[| _idx1] = all_dominoes[| _idx2];
    all_dominoes[| _idx2] = _temp;
}
ds_list_shuffle(all_dominoes);

for (var i = 0; i < 28; i++) {
    var dom = all_dominoes[| i];
    var inst = instance_create_layer(0, 0, "Instances", obj_domino_elem);
    inst.value1 = dom[0]; 
    inst.value2 = dom[1]; 
    inst.is_double = (inst.value1 == inst.value2);
    
    var spr_name = "spr_" + string(inst.value1) + string(inst.value2);
    inst.sprite_index = asset_get_index(spr_name);
    
    // Назначаем стихию из карты
    if (ds_map_exists(global.domino_elemental_map, spr_name)) {
        inst.element = global.domino_elemental_map[? spr_name];
    } else {
        inst.element = ELEMENT.NONE;
    }
    
    inst.visible = false;
    
    if (i < 7) { inst.owner = "player"; ds_list_add(global.player_hand, inst); }
    else if (i < 14) { inst.owner = "computer"; ds_list_add(global.computer_hand, inst); }
    else { inst.owner = "bazar"; ds_list_add(global.bazar, inst); }
}
ds_list_destroy(all_dominoes);

instance_create_layer(200, global.table_center_y, "Instances", obj_bazar_elem);
alarm[0] = 2; // Поиск стартовой кости

// --- 6. ОСНОВНАЯ ФУНКЦИЯ ХОДА ---

global.play_domino = function(dom_id, side) {
    global.choice_mode = false;
    global.selected_domino = noone;

    var is_double = dom_id.is_double;
    var len_half = is_double ? 32 : 64; 
    var wid_half = is_double ? 64 : 32;
    
    if (side == "first") {
        dom_id.x = global.table_center_x;
        dom_id.y = global.table_center_y;
        dom_id.image_angle = is_double ? 0 : 90;
        global.left_end = dom_id.value1;
        global.right_end = dom_id.value2;
        global.left_element = dom_id.element;
        global.right_element = dom_id.element;
        global.left_edge_x = dom_id.x - len_half;
        global.left_edge_y = dom_id.y;
        global.right_edge_x = dom_id.x + len_half;
        global.right_edge_y = dom_id.y;
        global.left_prev_wid = wid_half;
        global.right_prev_wid = wid_half;
        global.left_tile_id = dom_id;
        global.right_tile_id = dom_id;
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
            match_v1 = (dom_id.value1 == global.right_end);
            global.right_end = match_v1 ? dom_id.value2 : dom_id.value1;
            global.right_element = dom_id.element; // Обновляем стихию края
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
            match_v1 = (dom_id.value1 == global.left_end);
            global.left_end = match_v1 ? dom_id.value2 : dom_id.value1;
            global.left_element = dom_id.element; // Обновляем стихию края
            global.left_tile_id = dom_id;
        }

        var px, py, nx, ny;
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

    var p_idx = ds_list_find_index(global.player_hand, dom_id);
    if (p_idx >= 0) ds_list_delete(global.player_hand, p_idx);
    var c_idx = ds_list_find_index(global.computer_hand, dom_id);
    if (c_idx >= 0) ds_list_delete(global.computer_hand, c_idx);

    with (obj_player_hand_elem) arrange_player_hand();
    with (obj_computer_hand_elem) arrange_computer_hand();
    
    global.current_turn = (global.current_turn == "player") ? "computer" : "player";
    with (obj_game_controller_elem) alarm[2] = 10;
}