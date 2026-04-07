/// obj_menu_button - Draw Event

// 1. Рисуем спрайт самой кнопки
draw_self();

// 2. Настройка шрифта
if (font_exists(fnt_menu)) draw_set_font(fnt_menu);

// 3. Выравнивание: fa_left, чтобы текст шел СПРАВА от кнопки
draw_set_halign(fa_left);
draw_set_valign(fa_middle);

// 4. Смещение (на сколько пикселей текст правее центра кнопки)
var text_offset_x = 50; 

// 5. Рисуем тень
draw_set_color(c_black);
draw_text(x + text_offset_x + 2, y + 2, string(button_text));

// 6. Рисуем основной текст (желтый при наведении)
var col = hover ? c_yellow : c_white;
draw_set_color(col);
draw_text(x + text_offset_x, y, string(button_text));

// 7. Сброс настроек
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);