/// @description obj_table - Draw GUI Event

// 1. ПРИНУДИТЕЛЬНЫЙ СБРОС (Защита от багов при переходах)
draw_set_alpha(1.0);
draw_set_font(fnt_buttons); // Твой созданный шрифт
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var spr = spr_button; // Твой спрайт

if (!sprite_exists(spr)) exit;

// --- ЛОГИКА И ОТРИСОВКА КНОПКИ "РЕСТАРТ" ---
var hover2 = (mx > btn_x - btn_w/2 && mx < btn_x + btn_w/2 && my > btn_2_y - btn_h/2 && my < btn_2_y + btn_h/2);

if (hover2) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(spr, 0, btn_x, btn_2_y, 1.05, 1.05, 90, c_lime, 0.4);
    gpu_set_blendmode(bm_normal);
}
draw_sprite_ext(spr, 0, btn_x, btn_2_y, 1, 1, 90, c_white, 1);

draw_set_color(c_black); // Цвет текста
draw_text(btn_x, btn_2_y, "РЕСТАРТ");

// 2. СБРОС ЦВЕТА (Чтобы не покрасить остальную игру)
draw_set_color(c_white);