# Подготовка TestFlight — версия2, сборка5

12 октября 2026. Владелец запросил подготовку проекта для архивации и отправки
на тестирование; номер5 утверждён отдельно. Скриншот App Store Connect:
версия2, предыдущая сборка4 истекла. Загрузка/назначение тестировщиков ещё
не разрешены. Сохраняем Bundle ID CorlasnbIe.Sudoky и Team73P89VLQ3W.

## Задача разработчику TF-05

- CURRENT_PROJECT_VERSION приложения установить5 в Debug/Release;
  MARKETING_VERSION оставить2. Тестовые targets не перенумеровывать.
- Добавить общую схему Sudoky (xcshareddata/xcschemes), ArchiveAction=Release,
  BuildAction приложения разрешает archiving; не запускать тесты при архивации.
  Debug Run и существующая архитектура приложения неизменны.
- PrivacyInfo.xcprivacy в bundle приложения: tracking=false, пустые tracking
  domains/collected data, UserDefaults required-reason CA92.1 — только локальные
  данные приложения. Фактические вызовы AppStorage/UserDefaults обнаружены;
  сторонних SDK/сетевого обмена/собственной криптографии не обнаружено.
- ITSAppUsesNonExemptEncryption=false в основном Info.plist; остальные ключи
  (светлый вид, локализация, шрифты, ориентации) сохранить.
- Проверить Release: тестовый режим, одна пустая клетка, ускорение/сброс сада
  и debug-панель полностью исключены #if DEBUG. Не удалять функции из Debug.
- Допустимы только project.pbxproj, общая схема, Info.plist и новый privacy
  manifest. При другом реальном блокере сначала сообщить руководителю.
  Не менять игровые исходники/PNG/сохранения. Не чистить dirty worktree.
- После проверки первого архива дополнительно исключить внутреннюю папку
  «Проектная документация» из bundle, не удаляя исходные документы. У владельца
  получено разрешение на UIRequiresFullScreen=true: iPad остаётся в портретном
  полноэкранном режиме, без Split View. Игра на iPhone не меняется.
- Plist/XML lint, static Release checks, diff. Компиляцию/архивирование
  выполняет руководитель; разработчик не повторяет их. Никаких симуляторов,
  UI-обходов, commit/push, загрузок, новых сертификатов/профилей.

## Основание деклараций

Apple: [CA92.1 — собственные данные приложения](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitypereasons?language=objc),
[декларация required reason API](https://developer.apple.com/documentation/technotes/tn3183-adding-required-reason-api-entries-to-your-privacy-manifest),
[ITSAppUsesNonExemptEncryption](https://developer.apple.com/documentation/bundleresources/information-property-list/itsappusesnonexemptencryption).

## Контрольная точка

Статус: подготовка выдана. План: Release для generic iOS/arm64, затем
проверка реального bundle (версия/номер, manifest, иконка, аудио/шрифты,
светлая тема, отсутствие тестовых методов). Если локальная подпись доступна,
архивировать без сетевого обновления профилей. Неподписанный архив не
считать готовым к загрузке. В связке ключей доступны2 Apple Development
идентификатора; Apple Distribution пока не найден. Сертификаты не менять.
Визуальную и игровую проверку выполняет владелец; архив/компиляция её не заменяют.

### Итог TF-05 — 12 октября 2026

Проект подготовлен; итоговая чистая ArchiveAction Release для generic iOS
завершилась exit0 без предупреждений. Архив arm64 версии2/сборки5:
соседняя папка `../Сборки/Sudoky-2-5-20261012.xcarchive`
относительно Git-корня Sudoky/. Архив сохранён вне Git-корня и app sources.
Полный путь: `/Users/zotchik/Documents/2. Репозиторий/Sudoky/Сборки/Sudoky-2-5-20261012.xcarchive`.

Архив имеет проверенную Apple Development подпись Team73P89VLQ3W,
не App Store distribution подпись. Экспорт/валидация App Store Connect,
переподпись для распространения, загрузка и назначение тестировщиков НЕ
выполнялись; они являются следующим шагом владельца в Xcode Organizer.
Новых сертификатов/профилей агенты не создавали, сетевое обновление подписи
не разрешали. Это не подтверждение принятия сборки Apple/TestFlight.

Проверены CFBundleVersion=5, CFBundleShortVersionString=2, Bundle ID прежний,
UIUserInterfaceStyle=Light, UIRequiresFullScreen=true,
ITSAppUsesNonExemptEncryption=false, встроенный PrivacyInfo.xcprivacy,
dSYM, Assets.car, музыка, десять шрифтов и RU/EN. Иконка1024×1024 без alpha.
DEBUG-пути исключены статически; поиск экспортированных тестовых символов
в Release-бинарнике не нашёл совпадений (это не запуск функциональных тестов).
Все10 внутренних .md исключены из итогового bundle; публичная privacy_policy.md
сохранена. Четыре исключения записаны NFD из-за поведения Xcode с буквой й.
При добавлении новых внутренних документов проверять target membership.

Из исходников изменены только project.pbxproj и основной Info.plist,
добавлены shared Sudoky.xcscheme и PrivacyInfo.xcprivacy. Схема сохраняет
Product→Test для владельца, но тестовые targets не участвуют в Archive.
Игровой код, PNG, локализация и сохранения не менялись по контрольным суммам.
Симуляторы, приложение и XCTest не запускались. Commit/push не выполнялись.
Первоначальный архив выявил недостающий fullscreen и внутренние ресурсы;
попытки исключения потребовали исправления формата пути/Unicode и повторных
архивов. Окончательная контрольная точка относится только к архиву выше.

### Что проверить в тестовой сборке

- Обновление с прежней версии без потери партии, статистики и сада.
- Запуск новой партии каждой сложности, сохранение и продолжение.
- Победа/поражение, награда за победу без штрафа за поражение.
- Посадка/рост дуба и бука, свайпы дерева на главной, тень горшка.
- RU/EN, музыка, настройки шрифта; светлый вид при тёмной теме устройства.
- iPhone mini/15 Pro/Pro Max и полноэкранный портретный iPad: все кнопки видны.
- В TestFlight отсутствуют тестовый переключатель, одна пустая клетка,
  ускорение и DEBUG-панель. Обычный сброс статистики не сбрасывает сад/XP.
