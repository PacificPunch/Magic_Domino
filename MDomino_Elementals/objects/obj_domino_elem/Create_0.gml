/// obj_domino_elem - Create Event

// --- СВОЙСТВА КОСТЯШКИ (Классика) ---
value1 = 0;       // Значение первой половины
value2 = 0;       // Значение второй половины
owner = "none";   // Владелец: "player", "computer", "bazar", "table"
my_index = 0;     // Порядковый индекс в руке
is_horizontal = true; 
selected = false;

// Визуальные настройки
sprite_index = spr_00; // По умолчанию, изменится при создании в контроллере
image_index  = 0;
depth = -10;

// Логика перетаскивания (Mouse Dragging)
dragging = false;      
offset_x = 0;          
offset_y = 0;

// --- НОВЫЕ СВОЙСТВА (Elemental) ---

// Проверка на дубль (Мост)
// Мы используем отложенную инициализацию, так как value1/2 
// назначаются контроллером сразу после instance_create
is_double = false; 

// Элемент костяшки (EARTH, WATER, AIR, FIRE)
element = ELEMENT.NONE; 

// Мы вызываем Alarm[0], чтобы проверить свои значения и элемент 
// ПОСЛЕ того, как контроллер передаст нам нужные value и sprite_index
alarm[11] = 1;