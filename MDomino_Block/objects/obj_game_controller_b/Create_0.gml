/// obj_game_controller_b - Create Event

randomize();
repeat(irandom_range(5, 15)) { random(1); } 

// --- БЛОК ОЧИСТКИ ---
if (variable_global_exists("player_hand")) {
    if (ds_exists(global.player_hand, ds_type_list)) ds_list_destroy(global.player_hand);
    if (ds_exists(global.computer_hand, ds_type_list)) ds_list_destroy(global.computer_hand);
    if (ds_exists(global.bazar, ds_type_list)) ds_list_destroy(global.bazar);
    if (ds_exists(global.table_chain, ds_type_list)) ds_list_destroy(global.table_chain);
}

if (instance_exists(obj_domino)) {
    with (obj_domino) instance_destroy();
}

// --- 1. ОБЪЯВЛЯЕМ ФУНКЦИИ ---

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

global.resolve_fish = function() {
    global.game_over = true;
    var p_score = 0;
    for (var i = 0; i < ds_list_size(global.player_hand); i++) p_score += global.player_hand[| i].value1 + global.player_hand[| i].value2;
    var c_score = 0;
    for (var i = 0; i < ds_list_size(global.computer_hand); i++) c_score += global.computer_hand[| i].value1 + global.computer_hand[| i].value2;
    
    var msg = "🐟 РЫБА! 🐟\n\nВаши очки: " + string(p_score) + "\nОчки противника: " + string(c_score) + "\n\n";
    if (p_score < c_score) msg += "Вы победили!";
    else if (c_score < p_score) msg += "Противник победил!";
    else msg += "Ничья!";
    
    global.end_message = msg;
    alarm[3] = 60; 
}

// --- 2. ИНИЦИАЛИЗАЦИЯ ПЕРЕМЕННЫХ ---
global.player_hand   = ds_list_create();
global.computer_hand = ds_list_create();
global.bazar         = ds_list_create();
global.table_chain   = ds_list_create();

global.left_end = -1; global.right_end = -1;
global.table_center_x = 1920 / 2;
global.table_center_y = 1080 / 2;
global.current_turn   = "player";
global.game_over      = false;
global.is_showing_starter = false;
global.end_message = "";

// Система змейки
global.left_count = 0; global.right_count = 0;
global.left_edge_x = global.table_center_x; global.left_edge_y = global.table_center_y;
global.right_edge_x = global.table_center_x; global.right_edge_y = global.table_center_y;
global.left_dir = "left"; global.right_dir = "right";
global.left_prev_wid = 32; global.right_prev_wid = 32;
global.first_turn_dir = "";

// --- 3. СОЗДАНИЕ И РАЗДАЧА (РЕЖИМ БЛОК) ---
var all_dominoes = ds_list_create();
for (var v1 = 0; v1 <= 6; v1++) {
    for (var v2 = v1; v2 <= 6; v2++) {
        ds_list_add(all_dominoes, [v1, v2]);
    }
}
ds_list_shuffle(all_dominoes);

// Раздаем только 14 костей
for (var i = 0; i < 14; i++) {
    var dom = all_dominoes[| i];
    var inst = instance_create_layer(0, 0, "Instances", obj_domino);
    inst.value1 = dom[0]; 
    inst.value2 = dom[1];

    if (i < 7) {
        inst.owner = "player";
        ds_list_add(global.player_hand, inst);
    } else {
        inst.owner = "computer";
        ds_list_add(global.computer_hand, inst);
    }
}
ds_list_destroy(all_dominoes);

// В Блоке Базар не создаем и проверку на первый ход не делаем в Create
alarm[0] = 5; // Поиск стартера

// --- 4. ФУНКЦИЯ ХОДА (PLAY_DOMINO) ---
global.play_domino = function(dom_id, side) {
    // ... (весь ваш код из файла без изменений до конца функции) ...
    // Скопируйте его сюда из вашего исходника
}