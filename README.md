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
* _cropCanvasSize_ — максимальный размер "холста" при кадрировании фотографии (см. [Memory constraints при кадрировании](#memory-constraints)).
* _routerSeed_ — routerSeed, полученный из Marshroute.
* _configuration_ — блок, позволяющий настроить [дополнительные параметры модуля](#MediaPickerModule).

#### <a name="MediaPickerModule" /> Дополнительные параметры модуля MediaPicker
Дополнительные параметры подуля описаны в протоколе `MediaPickerModule`:

* Методы `setContinueButtonTitle(_:)` и `setContinueButtonEnabled(_:)` позволяют кастомизировать названиетекст и активность кнопки "Продолжить".
* `onItemsAdd` вызывается, когда пользователь добавляет фотографии из галереи или делает новый снимок.
* `onItemUpdate` вызывается после того, как пользователь произвел кадрирование фотографии.
* `onItemRemove` вызывается после удаления фотографии пользователем.
* `onFinish` и `onCancel` вызываются при завершении и отмене модуля соответственно.

#### <a name="memory-constraints" /> Memory constraints при кадрировании
При кадрировании фотографии на устройствах с малым объемом оперативной памяти приложение может крэшиться по memory warning. Происходит это из-за того, что для кадрирования в память помещается достаточно тяжелый bitmap оригинальной фотографии. Чтобы уменьшить вероятность крэша на "старых" девайсах (вроде iPhone 4 и 4s), можно масштабировать исходную фотографию перед кадрированием, тогда ее bitmap будет занимать меньше места в оперативной памяти. Параметр модуля _cropCanvasSize_ предназначен именно для этого и обозначает размер, до которого будет производится масштабирование оригинальной фотографии перед кадрированием.

### Показ галереи
Инициализируйте ассамблею модуля, используя идущую в составе модуля фабрику `AvitoMediaPicker.AssemblyFactory`:
```swift
let factory = AvitoMediaPicker.AssemblyFactory()
let assembly = factory.photoLibraryAssembly()
```
Создайте view controller модуля, используя метод ассамблеи `module`:
```swift
let viewController = assembly.module(
    selectedItems: selectedItems,
    maxSelectedItemsCount: maxSelectedItemsCount,
    routerSeed: routerSeed,
    configuration: configuration
)
```
* _selectedItems_ — выбранные фотографии (или `nil`).
* _maxItemsCount_ — максимальное количество фотографий, которые может выбрать пользователь.
* _routerSeed_ — routerSeed, полученный из Marshroute.
* _configuration_ — блок, позволяющий настроить дополнительные параметры модуля.

### Кастомизация UI
TODO