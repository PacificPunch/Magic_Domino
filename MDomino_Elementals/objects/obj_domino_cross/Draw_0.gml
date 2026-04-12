/// @description obj_domino_cross - Draw Event

// 1. ЛОГИКА МИГАНИЯ СТАРТЕРА
var draw_alpha = 1.0;
var is_this_starter = (global.is_showing_starter && id == global.starter_instance);

if (is_this_starter) {
    // Плавное мигание: прозрачность от 0.3 до 1.0
    draw_alpha = 0.3 + abs(sin(current_time / 150)) * 0.7;
}

// 2. ОПРЕДЕЛЕНИЕ ВОЗМОЖНОСТИ ХОДА (для руки игрока)
var can_be_played = false;
if (owner == "player" && global.current_turn == "player" && !global.game_over && !global.is_showing_starter) {
    if (ds_list_size(global.table_chain) == 0) {
        if (value1 == value2) can_be_played = true;
    } else {
        var sides = ["up", "down", "left", "right"];
        for (var i = 0; i < 4; i++) {
            var s_data = variable_struct_get(global.ends, sides[i]);
            if (s_data.active && (value1 == s_data.val || value2 == s_data.val)) {
                can_be_played = true; break;
            }
        }
    }
}

// 3. ОТРИСОВКА КОСТЕЙ (Рубашка / Лицо)
if (owner == "computer") {
    if (is_this_starter) {
        // Если это стартовая кость компьютера, показываем её лицо, пока идет мигание
        draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, draw_alpha);
    } else {
        // Все остальные кости противника — рубашкой
        draw_sprite_ext(spr_domino_w, 0, x, y, image_xscale, image_yscale, image_angle, c_white, 1);
    }
} 
else if (owner == "player") {
    var blend = c_white;
    // Затемняем кости в руке, если сейчас нельзя ими ходить
    // (либо чужой ход, либо идет показ стартера, и это не он)
    if (!can_be_played && !is_this_starter) {
        blend = c_gray;
    }
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, blend, draw_alpha);
} 
else if (owner == "table") {
    // Кости на столе рисуются как обычно
    draw_self();

    // 4. ПОДСВЕТКА ДОСТУПНЫХ МЕСТ НА СТОЛЕ (при выборе хода)
    if (global.choice_mode && variable_global_exists("valid_sides")) {
        var is_valid_target = false;
        
        // Проверяем, является ли эта кость концом подходящей ветки
        if (id == global.ends.up.tile_id)    { for(var i=0; i<array_length(global.valid_sides); i++) if(global.valid_sides[i]=="up")    is_valid_target = true; }
        if (id == global.ends.down.tile_id)  { for(var i=0; i<array_length(global.valid_sides); i++) if(global.valid_sides[i]=="down")  is_valid_target = true; }
        if (id == global.ends.left.tile_id)  { for(var i=0; i<array_length(global.valid_sides); i++) if(global.valid_sides[i]=="left")  is_valid_target = true; }
        if (id == global.ends.right.tile_id) { for(var i=0; i<array_length(global.valid_sides); i++) if(global.valid_sides[i]=="right") is_valid_target = true; }

        if (is_valid_target) {
            gpu_set_blendmode(bm_add);
            draw_sprite_ext(sprite_index, image_index, x, y, image_xscale + 0.05, image_yscale + 0.05, image_angle, c_aqua, 0.5);
            gpu_set_blendmode(bm_normal);
        }
    }
}

// 5. ПОДСВЕТКА ВЫБРАННОЙ КОСТИ В РУКЕ
if (global.choice_mode && global.selected_domino == id) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale + 0.05, image_yscale + 0.05, image_angle, c_aqua, 0.5); //c_lime / c_aqua
    gpu_set_blendmode(bm_normal);
}