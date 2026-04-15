/// obj_computer_hand_elem - Create Event

/**
 * Функция визуального упорядочивания костей в руке компьютера.
 * Вызывается при раздаче, когда компьютер берет из базара 
 * или когда делает ход.
 */
function arrange_computer_hand() {
    // Получаем количество костей в руке компьютера
    var count = ds_list_size(global.computer_hand);
    
    // Если костей нет, выходим
    if (count <= 0) return;
    
    // Настройки сетки (чуть плотнее, чем у игрока - 68 вместо 72)
    var spacing = 68; 
    var total_width = (count - 1) * spacing;
    
    // Центрируем руку по горизонтали
    var start_x = 1920 / 2 - total_width / 2;
    
    // Позиция Y (верхняя часть экрана)
    var y_pos   = 140; 
    
    // Проходим по списку всех костей компьютера
    for (var i = 0; i < count; i++) {
        var inst = global.computer_hand[| i];
        
        if (instance_exists(inst)) {
            // Устанавливаем целевые координаты
            inst.x = start_x + i * spacing;
            inst.y = y_pos;
            
            // Настраиваем глубину (чтобы кости могли слегка перекрывать друг друга)
            inst.depth = -100 - i;
            
            // В руке кости всегда стоят вертикально (0 градусов)
            inst.image_angle = 0;
            
            // Кости должны быть активны в логике, даже если Draw рисует рубашку
            inst.visible = true;
            
            // Обновляем индекс для порядка
            inst.my_index = i;
            
            // Сбрасываем флаги взаимодействия, так как компьютер не может "тащить" кость мышкой
            inst.dragging = false;
            inst.selected = false;
        }
    }
}