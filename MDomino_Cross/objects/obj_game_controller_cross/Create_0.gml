/// obj_game_controller_cross - Create Event

randomize();
repeat(irandom_range(5, 15)) { random(1); }

// --- 1. ОЧИСТКА ---
if (variable_global_exists("player_hand")) {
    if (ds_exists(global.player_hand, ds_type_list)) ds_list_destroy(global.player_hand);
    if (ds_exists(global.computer_hand, ds_type_list)) ds_list_destroy(global.computer_hand);
    if (ds_exists(global.bazar, ds_type_list)) ds_list_destroy(global.bazar);
    if (ds_exists(global.table_chain, ds_type_list)) ds_list_destroy(global.table_chain);
}

if (instance_exists(obj_domino_cross)) {
    with (obj_domino_cross) instance_destroy();
}

// --- 2. ФУНКЦИИ ---

// Проверка наличия ходов для режима Крест
global.check_has_moves = function(target_hand) {
    if (ds_list_size(global.table_chain) == 0) {
        // Первый ход: можно ходить только если есть дубль
        for (var i = 0; i < ds_list_size(target_hand); i++) {
            var inst = target_hand[| i];
            if (inst.value1 == inst.value2) return true;
        }
        return false;
    }
    
    // Проверка по всем 4 активным веткам
    var sides = ["up", "down", "left", "right"];
    for (var i = 0; i < ds_list_size(target_hand); i++) {
        var inst = target_hand[| i];
        for (var j = 0; j < 4; j++) {
            var side_data = variable_struct_get(global.ends, sides[j]);
            if (side_data.active) {
                if (inst.value1 == side_data.val || inst.value2 == side_data.val) return true;
            }
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
    
    var msg = "🐟 РЫБА (КРЕСТ)! 🐟\n\nВаши очки: " + string(p_score) + "\nОчки противника: " + string(c_score) + "\n\n";
    if (p_score < c_score) msg += "Вы победили!";
    else if (c_score < p_score) msg += "Противник победил!";
    else msg += "Ничья!";
    
    global.end_message = msg;
    alarm[3] = 10;
}

// --- 3. ИНИЦИАЛИЗАЦИЯ ПЕРЕМЕННЫХ ---

global.player_hand   = ds_list_create();
global.computer_hand = ds_list_create();
global.bazar         = ds_list_create();
global.table_chain   = ds_list_create();

global.choice_mode = false;
global.selected_domino = noone;
global.current_turn = "player";
global.game_over = false;
global.end_message = "";
global.is_showing_starter = false;

// Система 4-х сторон (Крест)
// Храним значение конца, координаты для следующей кости, активность ветки и ID крайней кости
global.ends = {
    up:    { val: -1, x: 0, y: 0, active: true, tile_id: noone },
    down:  { val: -1, x: 0, y: 0, active: true, tile_id: noone },
    left:  { val: -1, x: 0, y: 0, active: true, tile_id: noone },
    right: { val: -1, x: 0, y: 0, active: true, tile_id: noone }
};

global.table_center_x = 1920 / 2;
global.table_center_y = 1080 / 2;

// --- 4. СОЗДАНИЕ И РАЗДАЧА КОСТЕЙ ---

var all_dominoes = ds_list_create();
for (var v1 = 0; v1 <= 6; v1++) {
    for (var v2 = v1; v2 <= 6; v2++) {
        ds_list_add(all_dominoes, [v1, v2]);
    }
}

ds_list_shuffle(all_dominoes);
// Усиленное перемешивание
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
    var inst = instance_create_layer(0, 0, "Instances", obj_domino_cross);
    inst.value1 = dom[0]; 
    inst.value2 = dom[1];
    inst.sprite_index = asset_get_index("spr_" + string(inst.value1) + string(inst.value2));
    inst.visible = false;
    
    if (i < 7) { inst.owner = "player"; ds_list_add(global.player_hand, inst); }
    else if (i < 14) { inst.owner = "computer"; ds_list_add(global.computer_hand, inst); }
    else { inst.owner = "bazar"; ds_list_add(global.bazar, inst); }
}
ds_list_destroy(all_dominoes);

// Создание объекта базара (используем кросс-версию)
instance_create_layer(200, global.table_center_y, "Instances", obj_bazar_cross);
alarm[0] = 2; // Запуск проверки стартового хода (нужен ли дубль в руке)

// --- 5. ФУНКЦИЯ РАЗМЕЩЕНИЯ (play_domino_cross) ---
global.play_domino_cross = function(dom_id, side) {
    global.choice_mode = false;
    global.selected_domino = noone;
    
    var is_double = (dom_id.value1 == dom_id.value2);
    
    if (side == "first") {
        dom_id.x = global.table_center_x;
        dom_id.y = global.table_center_y;
        dom_id.image_angle = 0; // Первый дубль всегда горизонтально
        
        // Инициализируем 4 направления от центрального дубля
        global.ends.up    = { val: dom_id.value1, x: dom_id.x, y: dom_id.y - 128, active: true, tile_id: dom_id };
        global.ends.down  = { val: dom_id.value1, x: dom_id.x, y: dom_id.y + 128, active: true, tile_id: dom_id };
        global.ends.left  = { val: dom_id.value1, x: dom_id.x - 128, y: dom_id.y, active: true, tile_id: dom_id };
        global.ends.right = { val: dom_id.value1, x: dom_id.x + 128, y: dom_id.y, active: true, tile_id: dom_id };
    } 
    else {
        var target = variable_struct_get(global.ends, side);
        var match_v1 = (dom_id.value1 == target.val);
        var new_val = match_v1 ? dom_id.value2 : dom_id.value1;
        
        dom_id.x = target.x;
        dom_id.y = target.y;
        
        // Поворот и установка координат для следующего шага в этой ветке
        switch(side) {
            case "up":
                dom_id.image_angle = match_v1 ? 180 : 0;
                target.y -= 128;
                break;
            case "down":
                dom_id.image_angle = match_v1 ? 0 : 180;
                target.y += 128;
                break;
            case "left":
                dom_id.image_angle = match_v1 ? 270 : 90;
                target.x -= 128;
                break;
            case "right":
                dom_id.image_angle = match_v1 ? 90 : 270;
                target.x += 128;
                break;
        }
        
        target.val = new_val;
        target.tile_id = dom_id;
        
        // Если поставлен дубль — ветка блокируется
        if (is_double) {
            target.active = false;
            dom_id.image_blend = c_gray; // Затемнение
        }
    }

    // Завершение хода
    dom_id.owner = "table";
    dom_id.visible = true;
    ds_list_add(global.table_chain, dom_id);
    
    var p_idx = ds_list_find_index(global.player_hand, dom_id);
    if (p_idx >= 0) ds_list_delete(global.player_hand, p_idx);
    var c_idx = ds_list_find_index(global.computer_hand, dom_id);
    if (c_idx >= 0) ds_list_delete(global.computer_hand, c_idx);

    with (obj_player_hand_cross) arrange_player_hand();
    with (obj_computer_hand_cross) arrange_computer_hand();
    
    global.current_turn = (global.current_turn == "player") ? "computer" : "player";
    alarm[2] = 10; // Проверка на конец игры / автоход
}