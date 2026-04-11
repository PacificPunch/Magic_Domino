/// @description obj_player_hand - Create Event

function arrange_player_hand() {
    var count = ds_list_size(global.player_hand);
    if (count == 0) exit;

    // ПАРАМЕТРЫ (должны быть такими же, как у компьютера)
    var domino_width = 64; 
    var spacing = 16;      
    var center_x = room_width / 2;
    
    // Отступ от нижнего края (симметрично верхнему 80)
    var bottom_margin = 80; 

    var total_width = (count * domino_width) + ((count - 1) * spacing);
    var start_x = center_x - (total_width / 2) + (domino_width / 2);

    for (var i = 0; i < count; i++) {
        var inst = global.player_hand[| i];
        if (instance_exists(inst)) {
            inst.x = start_x + (i * (domino_width + spacing));
            // Центр костяшки по Y: от края комнаты минус отступ и минус половина высоты (64)
            inst.y = room_height - bottom_margin - 64; 
            
            inst.image_angle = 0;
            inst.depth = -500;
            inst.visible = true;
        }
    }
}