/// obj_bazar - Draw Event

var count = ds_list_size(global.bazar);

// 1. ОПРЕДЕЛЯЕМ ЦВЕТА И ТЕКСТ
var bazar_col = c_dkgray; 
var txt_col = c_white;
var txt = "";

if (count <= 0) {
    // Если пусто
    bazar_col = c_gray;    
    txt_col = c_white;     
    txt = "Пусто";
} else {
    // Если на базаре есть кости
    txt = "Базар\n" + string(count);
    
    if (global.current_turn == "player") {
        var has_any_move = false;
        
        for (var i = 0; i < ds_list_size(global.player_hand); i++) {
            var inst = global.player_hand[| i];
            if (ds_list_size(global.table_chain) == 0 || 
                inst.value1 == global.left_end || inst.value2 == global.left_end || 
                inst.value1 == global.right_end || inst.value2 == global.right_end) {
                has_any_move = true;
                break;
            }
        }
        
        // Если ходов нет - базар подсвечивается
        if (!has_any_move) {
            bazar_col = c_white; 
            txt_col = c_black; 
        }
    }
}

// 2. ОТРИСОВКА РУБАШКИ
draw_sprite_ext(spr_00, 0, x, y, 1, 1, 0, bazar_col, 1);

// 3. НАСТРОЙКА И ОТРИСОВКА ТЕКСТА
// Безопасно применяем шрифт, если он существует
var font_id = asset_get_index("fnt_bazar");
if (font_exists(font_id)) {
    draw_set_font(font_id);
}

draw_set_color(txt_col);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// САМАЯ ВАЖНАЯ СТРОЧКА (Без нее текст не появится)
draw_text(x, y, txt); 

// 4. СБРОС НАСТРОЕК
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);