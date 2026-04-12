/// @description obj_computer_hand - Create Event

function arrange_computer_hand() {
    var count = ds_list_size(global.computer_hand);
    if (count == 0) exit;

    // ПАРАМЕТРЫ (идентичны игроку)
    var domino_width = 64;
    var spacing = 16;
    var center_x = room_width / 2;
    
    // Отступ от верхнего края
    var top_margin = 20; 

    var total_width = (count * domino_width) + ((count - 1) * spacing);
    var start_x = center_x - (total_width / 2) + (domino_width / 2);

    for (var i = 0; i < count; i++) {
        var inst = global.computer_hand[| i];
        if (instance_exists(inst)) {
            inst.x = start_x + (i * (domino_width + spacing));
            // Центр костяшки по Y: отступ сверху плюс половина высоты (64)
            inst.y = top_margin + 64;
            
            inst.image_angle = 0;
            inst.depth = -500;
        }
    }
}