RJDU - Jamsys.ru DynamicUI

Общая получаемая иерархия виджетов:

1 BottomNavigationBar (+FloatingActionButton)
   1.1 Scaffold (+AppBar)
      1.1.1 ListView
      1.1.2 Sliver (+AppBar)

У каждого BottomTab своя история навигации
Элемент навигации - DynamicPage

DynamicPage состоит из:

1) State - состояния (ввод данных с клавиатуры, что-то присвоеное в runtime) Авто создание Notify при установки флага в шаблон onStateDataUpdate: true
2) Properties - программные контролеры (ScrollBarController, TextEditingController, ShadowUuid) - при reload контролеры зануляются, что приводит к сбросу состояний
3) Container - словарь uuid всех подгруженных данных через DataSource/State. Для удобства работы в шаблонах, когда разные блоки имеют разный контекст данных, но очень надо получить данные из другова контекста
4) Arguments - параметры запуска DynamicPage, это как аргументы для создания экземпляра

StatefulWidget DynamicPage динамически строит Widget/ы из аргументов запуска.

Особые аргументы первичного уровня:

1) constructor, что приведёт к выполнению DynamicInvoke перед отрисовкой UI. В constructor DynamicInvoke можно динамически установить данные, которые в конечном итоге отрисуются в UI.
2) socket: true, что приведёт к открытию коннекта на сервер
3) subscribeOnChangeUuid: {list: [], onChange: DynamicInvoke}

Перезагрузка DynamicPage:

1) reload - полная перерисовка DynamicPage с вытекающим запуском конструктора перед отрисовкой
2) safeReload - выполнение только constructor, дальше всё на откуп Notify блокам