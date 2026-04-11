/// @description obj_game_controller_cross - Create Event

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

// Функция раскрытия костей противника в конце раунда
global.reveal_computer_hand = function() {
    for (var i = 0; i < ds_list_size(global.computer_hand); i++) {
        var inst = global.computer_hand[| i];
        if (instance_exists(inst)) {
            inst.owner = "player"; // Переключаем на player, чтобы Draw Event отрисовал лицо
            inst.visible = true;
        }
    }
}

global.check_has_moves = function(target_hand) {
    // ПРОВЕРКА НА ЗАКРЫТИЕ ВСЕХ ВЕТОК (Рыба по дублям)
    var active_count = 0;
    var side_names = ["up", "down", "left", "right"];
    for (var j = 0; j < 4; j++) {
        if (variable_struct_get(global.ends, side_names[j]).active) active_count++;
    }
    
    if (active_count == 0 && ds_list_size(global.table_chain) > 0) return false;

    if (ds_list_size(global.table_chain) == 0) {
        for (var i = 0; i < ds_list_size(target_hand); i++) {
            var inst = target_hand[| i];
            if (inst.value1 == inst.value2) return true;
        }
        return false;
    }
    
    for (var i = 0; i < ds_list_size(target_hand); i++) {
        var inst = target_hand[| i];
        for (var j = 0; j < 4; j++) {
            var side_data = variable_struct_get(global.ends, side_names[j]);
            if (side_data.active) {
                if (inst.value1 == side_data.val || inst.value2 == side_data.val) return true;
            }
        }
    }
    return false;
}

global.resolve_fish = function() {
    global.game_over = true;
    
    // Показываем кости противника игроку
    global.reveal_computer_hand();
    
    var p_score = 0;
    for (var i = 0; i < ds_list_size(global.player_hand); i++) p_score += global.player_hand[| i].value1 + global.player_hand[| i].value2;
    var c_score = 0;
    for (var i = 0; i < ds_list_size(global.computer_hand); i++) c_score += global.computer_hand[| i].value1 + global.computer_hand[| i].value2;
    
    var msg = "🐟 РЫБА (КРЕСТ)! 🐟\n\nВаши очки: " + string(p_score) + "\nОчки противника: " + string(c_score) + "\n\n";
    if (p_score < c_score) msg += "Вы победили!";
    else if (c_score < p_score) msg += "Противник победил!";
    else msg += "Ничья!";
    
    global.end_message = msg;
    alarm[3] = 90; // Увеличиваем задержку, чтобы рассмотреть карты
}

// --- 3. ИНИЦИАЛИЗАЦИЯ ПЕРЕМЕННЫХ ---

global.player_hand   = ds_list_create();
global.computer_hand = ds_list_create();
global.bazar         = ds_list_create();
global.table_chain   = ds_list_create();

global.choice_mode = false;
global.selected_domino = noone;
global.valid_sides = []; 
global.current_turn = "player";
global.game_over = false;
global.end_message = "";
global.is_showing_starter = false;

global.table_center_x = 1920 / 2;
global.table_center_y = 1080 / 2;

global.starter_instance = noone; // Костяшка, которая начинает
global.is_showing_starter = false; // Состояние мигания

global.turn_direction = 0; 

global.ends = {
    up:    { val: 0, x: 0, y: 0, active: true, tile_id: noone, count: 0, dir_x: 0,  dir_y: -1, can_turn: true },
    down:  { val: 0, x: 0, y: 0, active: true, tile_id: noone, count: 0, dir_x: 0,  dir_y: 1,  can_turn: true  },
    left:  { val: 0, x: 0, y: 0, active: true, tile_id: noone, count: 0, dir_x: -1, dir_y: 0,  can_turn: true  },
    right: { val: 0, x: 0, y: 0, active: true, tile_id: noone, count: 0, dir_x: 1,  dir_y: 0,  can_turn: true  }
};

// --- 4. СОЗДАНИЕ И РАЗДАЧА КОСТЕЙ ---

var all_dominoes = ds_list_create();
for (var v1 = 0; v1 <= 6; v1++) {
    for (var v2 = v1; v2 <= 6; v2++) {
        ds_list_add(all_dominoes, [v1, v2]);
    }
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

instance_create_layer(200, global.table_center_y, "Instances", obj_bazar_cross);
alarm[0] = 2;

// --- 5. ФУНКЦИЯ РАЗМЕЩЕНИЯ (play_domino_cross) ---
global.play_domino_cross = function(dom_id, side) {
    global.choice_mode = false;
    global.selected_domino = noone;
    global.valid_sides = []; 
    
    var is_double = (dom_id.value1 == dom_id.value2);
    
    if (side == "first") {
        dom_id.x = global.table_center_x;
        dom_id.y = global.table_center_y;
        dom_id.image_angle = 0; 
        
        global.ends.up    = { val: dom_id.value1, x: dom_id.x, y: dom_id.y - 128, active: true, tile_id: dom_id, count: 0, dir_x: 0,  dir_y: -1, can_turn: true };
        global.ends.down  = { val: dom_id.value1, x: dom_id.x, y: dom_id.y + 128, active: true, tile_id: dom_id, count: 0, dir_x: 0,  dir_y: 1,  can_turn: true };
        global.ends.left  = { val: dom_id.value1, x: dom_id.x - 96,  y: dom_id.y, active: true, tile_id: dom_id, count: 0, dir_x: -1, dir_y: 0,  can_turn: true };
        global.ends.right = { val: dom_id.value1, x: dom_id.x + 96,  y: dom_id.y, active: true, tile_id: dom_id, count: 0, dir_x: 1,  dir_y: 0,  can_turn: true };
    } 
    else {
        var struct = variable_struct_get(global.ends, side);
        var match_v1 = (dom_id.value1 == struct.val);
        var new_val = match_v1 ? dom_id.value2 : dom_id.value1;
        
        dom_id.x = struct.x;
        dom_id.y = struct.y;
        struct.count += 1;

        if (struct.dir_x != 0) {
            dom_id.image_angle = (struct.dir_x > 0) ? (match_v1 ? 90 : 270) : (match_v1 ? 270 : 90);
        } else {
            dom_id.image_angle = (struct.dir_y > 0) ? (match_v1 ? 0 : 180) : (match_v1 ? 180 : 0);
        }

        var need_turn = false;
        if (struct.can_turn) {
            if ((side == "left" || side == "right") && struct.count == 5) need_turn = true;
            if ((side == "up" || side == "down") && struct.count == 2) need_turn = true;
        }

        if (need_turn) {
            if (global.turn_direction == 0) global.turn_direction = choose(1, -1);
            
            var old_dx = struct.dir_x;
            var old_dy = struct.dir_y;
            
            if (global.turn_direction == 1) { 
                struct.dir_x = -old_dy; struct.dir_y = old_dx;
            } else { 
                struct.dir_x = old_dy; struct.dir_y = -old_dx;
            }

            if (old_dx != 0) { 
                struct.x += (old_dx * 32); 
                struct.y += (struct.dir_y * 96);
            } else { 
                struct.y += (old_dy * 32);
                struct.x += (struct.dir_x * 96);
            }
            
            struct.can_turn = false; 
        } else {
            struct.x += struct.dir_x * 128;
            struct.y += struct.dir_y * 128;
        }

        struct.val = new_val;
        struct.tile_id = dom_id;
        
        if (is_double) {
            struct.active = false;
            dom_id.image_blend = c_gray;
        }
    }

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
    alarm[2] = 10;
}