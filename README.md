AvitoMediaPicker — это модуль для выбора и редактирования фотографий. Основные возможности:
* камера
* выбор фотографий из пользовательской галереи
* кадрирование и поворот фотографий

## Установка
Для установки модуля с помощью [CocoaPods](http://cocoapods.org) добавьте следующую строку в свой Podfile:

```ruby
pod "AvitoMediaPicker"
```

## Использование
Можно использовать либо модуль целиком (камера + галерея), либо только галерею.

### Показ всего модуля
Инициализируйте ассамблею модуля, используя идущую в составе модуля фабрику `AvitoMediaPicker.AssemblyFactory`:
```swift
let factory = AvitoMediaPicker.AssemblyFactory()
let assembly = factory.mediaPickerAssembly()
```
Создайте view controller модуля, используя метод ассамблеи `module`:
```swift
let viewController = assembly.module(
    items: items,
    selectedItem: selectedItem,
    maxItemsCount: maxItemsCount,
    cropEnabled: true,
    cropCanvasSize: cropCanvasSize,
    routerSeed: routerSeed,
    configuration: configuration
)
```
Параметры метода:
* _items_ — массив фотографий, которые выбраны в пикере на момент открытия (актуально при редактировании).
* _selectedItem_ — выбранная фотография. Если не передана, или если в массиве _items_ не найдено фотографии с таким же _identifier_, то в пикере будет выделена первая фотография.
* _maxItemsCount_ — максимальное количество фотографий, которые может выбрать пользователь.
* _cropEnabled_ — флаг, указывающий на то, должен ли пользователь иметь возможность кадрировать фотографии.
* _cropCanvasSize_ — максимальный размер "холста" при кадрировании фотографии (см. [Memory constraints при кадрировании](##Memory-constraints-при-кадрировании)).
* _routerSeed_ — routerSeed, полученный из Marshroute.
* _configuration_ — блок, позволяющий настроить дополнительные параметры модуля.

## Memory constraints при кадрировании
