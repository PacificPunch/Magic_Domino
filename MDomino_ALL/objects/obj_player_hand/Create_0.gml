/// obj_player_hand - Create Event

function arrange_player_hand() {
    var count = ds_list_size(global.player_hand);
    if (count <= 0) return;
    
    var spacing = 72;
    var total_width = (count - 1) * spacing;
    var start_x = 1920 / 2 - total_width / 2;
    var y_pos   = 1080 - 160;
    
    for (var i = 0; i < count; i++) {
        var inst = global.player_hand[| i];
        if (instance_exists(inst)) {
            inst.x = start_x + i * spacing;
            inst.y = y_pos;
            inst.depth = -200 - i;
            inst.image_angle = 0;
            inst.visible = true;
        }
    }
}