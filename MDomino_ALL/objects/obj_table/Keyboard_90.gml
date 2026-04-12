/// Событие: Key Press - Z

var count = ds_list_size(global.bazar);

if (count > 0) {
    // 1. Проходим по всему списку базара и уничтожаем физические объекты костяшек
    for (var i = 0; i < count; i++) {
        var inst = global.bazar[| i];
        if (instance_exists(inst)) {
            instance_destroy(inst);
        }
    }
    
    // 2. Полностью очищаем список
    ds_list_clear(global.bazar);
    
    // 3. Выводим сообщение, чтобы вы точно знали, что кнопка сработала
    show_message("Чит-код активирован: Базар уничтожен!\nТеперь можно быстро проверить комбинацию 'Рыба'.");
}