/// obj_bazar_elem - Draw Event

var count = ds_list_size(global.bazar);

// --- 1. ОПРЕДЕЛЯЕМ ЦВЕТА И ТЕКСТ ---
var bazar_col = c_dkgray; 
var txt_col = c_white;
var txt = "";
var show_glow = false; // Флаг для включения рамки

if (count <= 0) {
    txt = "Пусто";
    bazar_col = c_gray;
} else {
    txt = "Базар\n" + string(count);
    
    // Проверка необходимости добора
    if (global.current_turn == "player" && !global.game_over) {
        // Проверяем наличие ходов с учетом СТИХИЙ
        var has_any_valid_move = global.check_has_moves(global.player_hand);
        
        // Если ходов нет — активируем свечение и меняем цвет подложки
        if (!has_any_valid_move) {
            bazar_col = c_white; 
            txt_col = c_black; 
            show_glow = true; // Разрешаем рисовать рамку
        }
    }
}

// --- 2. ОТРИСОВКА ВИЗУАЛА БАЗАРА ---
draw_sprite_ext(spr_00, 0, x, y, 1, 1, 0, bazar_col, 1);

// --- 3. ПУЛЬСИРУЮЩАЯ РАМКА ПОДСВЕТКИ ---
if (show_glow) {
    // Тот же эффект пульсации, что и у костяшек
    var pulse = 0.4 + sin(current_time * 0.01) * 0.2;
    draw_set_alpha(pulse);
    draw_set_color(c_lime);
    
    // Размеры рамки (чуть больше стандартной кости 64x128)
    var thickness = 4;
    var w = 35;
    var h = 67;
    
    // Рисуем рамку (базар обычно всегда стоит вертикально, поэтому без поворотов)
    draw_line_width(x - w, y - h, x + w, y - h, thickness); // Верх
    draw_line_width(x - w, y + h, x + w, y + h, thickness); // Низ
    draw_line_width(x - w, y - h, x - w, y + h, thickness); // Лево
    draw_line_width(x + w, y - h, x + w, y + h, thickness); // Право
    
    draw_set_alpha(1.0);
    draw_set_color(c_white);
}

// --- 4. НАСТРОЙКА И ОТРИСОВКА ТЕКСТА ---
var font_id = asset_get_index("fnt_bazar");
if (font_exists(font_id)) draw_set_font(font_id);

draw_set_color(txt_col);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_text(x, y, txt); 

// --- 5. СБРОС НАСТРОЕК ---
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);