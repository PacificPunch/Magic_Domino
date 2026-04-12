/// obj_game_controller - Create Event

randomize();
repeat(irandom_range(5, 15)) { random(1); } // Дополнительная "прокрутка" генератора

// --- 1. ПРЕЖДЕ ВСЕГО ОБЪЯВЛЯЕМ ФУНКЦИИ (Чтобы Alarm-ы их видели) ---

// Функция проверки наличия ходов
global.check_has_moves = function(target_hand) {
    if (ds_list_size(global.table_chain) == 0) return true;
    for (var i = 0; i < ds_list_size(target_hand); i++) {
        var inst = target_hand[| i];
        if (inst.value1 == global.left_end || inst.value2 == global.left_end || 
            inst.value1 == global.right_end || inst.value2 == global.right_end) {
            return true;
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
    with (obj_game_controller) alarm[3] = 10;
}

// --- 2. ИНИЦИАЛИЗАЦИЯ СПИСКОВ И ПЕРЕМЕННЫХ ---

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

global.left_end       = -1;
global.right_end      = -1;
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

// --- 3. СОЗДАНИЕ И РАЗДАЧА КОСТЕЙ ---

var all_dominoes = ds_list_create();
for (var v1 = 0; v1 <= 6; v1++) {
    for (var v2 = v1; v2 <= 6; v2++) {
        ds_list_add(all_dominoes, [v1, v2]);
    }
}

// 3. УСИЛЕННОЕ ПЕРЕМЕШИВАНИЕ
// Сначала стандартный шаффл
ds_list_shuffle(all_dominoes);

// Затем ручной цикл случайных перестановок (метод Фишера-Йетса или просто хаотичный обмен)
var _size = ds_list_size(all_dominoes);
repeat(100) { // 100 раз меняем случайные элементы местами
    var _idx1 = irandom(_size - 1);
    var _idx2 = irandom(_size - 1);
    var _temp = all_dominoes[| _idx1];
    all_dominoes[| _idx1] = all_dominoes[| _idx2];
    all_dominoes[| _idx2] = _temp;
}
// Еще один финальный шаффл для верности
ds_list_shuffle(all_dominoes);

for (var i = 0; i < 28; i++) {
    var dom = all_dominoes[| i];
    var inst = instance_create_layer(0, 0, "Instances", obj_domino);
    inst.value1 = dom[0]; 
    inst.value2 = dom[1]; 
    inst.sprite_index = asset_get_index("spr_" + string(inst.value1) + string(inst.value2));
    inst.visible = false;
    
    if (i < 7) { inst.owner = "player"; ds_list_add(global.player_hand, inst); }
    else if (i < 14) { inst.owner = "computer"; ds_list_add(global.computer_hand, inst); }
    else { inst.owner = "bazar"; ds_list_add(global.bazar, inst); }
}
ds_list_destroy(all_dominoes);

instance_create_layer(200, global.table_center_y, "Instances", obj_bazar);
alarm[0] = 2; // Поиск стартовой кости

// --- 4. ОСНОВНАЯ ФУНКЦИЯ ХОДА ---

global.play_domino = function(dom_id, side) {
    global.choice_mode = false;
    global.selected_domino = noone;

    var is_double = (dom_id.value1 == dom_id.value2);
    var len_half = is_double ? 32 : 64; 
    var wid_half = is_double ? 64 : 32;
    
    if (side == "first") {
        dom_id.x = global.table_center_x;
        dom_id.y = global.table_center_y;
        dom_id.image_angle = is_double ? 0 : 90;
        global.left_end = dom_id.value1;
        global.right_end = dom_id.value2;
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

    with (obj_player_hand) arrange_player_hand();
    with (obj_computer_hand) arrange_computer_hand();
    
    global.current_turn = (global.current_turn == "player") ? "computer" : "player";
    with (obj_game_controller) alarm[2] = 10;
}