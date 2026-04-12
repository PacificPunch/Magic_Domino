/// obj_table - Step Event

if (mouse_check_button_pressed(mb_left)) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    
    // Клик по МЕНЮ
    if (mx > btn_x - btn_w/2 && mx < btn_x + btn_w/2 && my > btn_1_y - btn_h/2 && my < btn_1_y + btn_h/2) {
        if (room_exists(rm_menu)) room_goto(rm_menu);
    }
    
    // Клик по РЕСТАРТ
    if (mx > btn_x - btn_w/2 && mx < btn_x + btn_w/2 && my > btn_2_y - btn_h/2 && my < btn_2_y + btn_h/2) {
        room_restart();
    }
}