/// obj_bazar_elem - Draw Event

var count = ds_list_size(global.bazar);

// --- 1. ОПРЕДЕЛЯЕМ ЦВЕТА И ТЕКСТ ---
var bazar_col = c_dkgray; 
var txt_col = c_white;
var txt = "";

if (count <= 0) {
    // Если базар пуст
    bazar_col = c_gray;    
    txt_col = c_white;     
    txt = "Пусто";
} else {
    // Если на базаре есть кости
    txt = "Базар\n" + string(count);
    
    // Подсветка базара, если сейчас ход игрока
    if (global.current_turn == "player") {
        
        // Используем нашу глобальную функцию проверки ходов, 
        // которая уже учитывает и цифры, и СТИХИИ, и ДУБЛИ.
        var has_any_valid_move = global.check_has_moves(global.player_hand);
        
        // Если легальных ходов нет — подсвечиваем базар белым, привлекая внимание
        if (!has_any_valid_move) {
            bazar_col = c_white; 
            txt_col = c_black; 
        }
    }
}

// --- 2. ОТРИСОВКА ВИЗУАЛА БАЗАРА ---
// Рисуем рубашку кости (используем spr_00 как шаблон)
draw_sprite_ext(spr_00, 0, x, y, 1, 1, 0, bazar_col, 1);

// --- 3. НАСТРОЙКА И ОТРИСОВКА ТЕКСТА ---
var font_id = asset_get_index("fnt_bazar");
if (font_exists(font_id)) {
    draw_set_font(font_id);
}

draw_set_color(txt_col);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Отрисовка надписи и количества костей
draw_text(x, y, txt); 

// --- 4. СБРОС НАСТРОЕК ОТРИСОВКИ ---
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);