///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.ОписаниеОбъекта = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	СсылкаНаОбъект = Параметры.ОписаниеОбъекта.Ссылка;
	Если Не ЗначениеЗаполнено(СсылкаНаОбъект) Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ПравоДоступа("Изменение", Метаданные.Справочники.НаборыДополнительныхРеквизитовИСведений) Тогда
		Элементы.МеткиКонтекстноеМенюСоздать.Видимость = Ложь;
		Элементы.МеткиКонтекстноеМенюИзменить.Видимость = Ложь;
	КонецЕсли;
	
	Если Не ПравоДоступа("Изменение", Метаданные.НайтиПоТипу(ТипЗнч(СсылкаНаОбъект))) Тогда
		Элементы.МеткиЗначение.Доступность = Ложь;
		Элементы.МеткиКонтекстноеМенюУстановитьВсе.Видимость = Ложь;
		Элементы.МеткиКонтекстноеМенюСнятьВсе.Видимость = Ложь;
	КонецЕсли;
	
	// Получение списка доступных наборов свойств.
	НаборыСвойств = УправлениеСвойствамиСлужебный.ПолучитьНаборыСвойствОбъекта(СсылкаНаОбъект);
	Для каждого Строка Из НаборыСвойств Цикл
		ДоступныеНаборыСвойств.Добавить(Строка.Набор);
	КонецЦикла;
	
	МеткиОбъекта.ЗагрузитьЗначения(УправлениеСвойствами.СвойстваПоВидуДополнительныхРеквизитов(
		Параметры.ОписаниеОбъекта.ДополнительныеРеквизиты.Выгрузить(),
		Перечисления.ВидыСвойств.Метки));
	
	// Заполнение таблицы меток.
	ЗаполнитьМетки();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	// Перезаполнение таблицы меток.
	Если ИмяСобытия = "Запись_ДополнительныеРеквизитыИСведения" Тогда
		ЗаполнитьМетки();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыТаблицаЗначенийСвойств

&НаКлиенте
Процедура МеткиПриИзменении(Элемент)
	
	Модифицированность = Истина;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура МеткиПередУдалением(Элемент, Отказ)
	
	Отказ = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура МеткиПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, ЭтоГруппа, Параметр)
	
	Отказ = Истина;
	ОткрытьФормуСозданияМетки();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗавершитьРедактирование(Команда)
	
	ПараметрыОповещения = Новый Структура;
	ПараметрыОповещения.Вставить("Владелец", ВладелецФормы);
	ПараметрыОповещения.Вставить("УстановленныеМетки", УстановленныеМетки(Метки));
	Оповестить("Запись_ИзменениеМеток", ПараметрыОповещения);
	
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ОтметитьРедактирование(Команда)
	
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура Создать(Команда)
	
	ОткрытьФормуСозданияМетки()
	
КонецПроцедуры

&НаКлиенте
Процедура Изменить(Команда)
	
	ТекущиеДанные = Элементы.Метки.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Ключ", ТекущиеДанные.Свойство);
	ПараметрыФормы.Вставить("ТекущийНаборСвойств", ТекущиеДанные.Набор);
	
	ОткрытьФорму("ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения.ФормаОбъекта",
		ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВсе(Команда)
	
	УстановитьСнятьВсе(Метки, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура СнятьВсе(Команда)
	
	УстановитьСнятьВсе(Метки, Ложь);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ОткрытьФормуСозданияМетки()
	
	ТекущиеДанные = Элементы.Метки.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Если ДоступныеНаборыСвойств.Количество() = 0 Тогда
			Возврат;
		КонецЕсли;
		НаборСвойств = ДоступныеНаборыСвойств[0].Значение;
	Иначе
		НаборСвойств = ТекущиеДанные.Набор;
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("НаборСвойств", НаборСвойств);
	ПараметрыФормы.Вставить("ВидСвойств", ПредопределенноеЗначение("Перечисление.ВидыСвойств.Метки"));
	ПараметрыФормы.Вставить("ТекущийНаборСвойств", НаборСвойств);
	
	ОткрытьФорму("ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения.ФормаОбъекта",
		ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьМетки()
	
	ДополнительныеРеквизиты = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
		СсылкаНаОбъект, "ДополнительныеРеквизиты", Истина);
	
	Метки.Очистить();
	ЗначенияМеток = УправлениеСвойствамиСлужебный.ЗначенияСвойств(
		ДополнительныеРеквизиты.Выгрузить(),
		ДоступныеНаборыСвойств,
		Перечисления.ВидыСвойств.Метки);
		
	Для Каждого Метка Из ЗначенияМеток Цикл
		Если Метка.Удалено Тогда
			Продолжить;
		КонецЕсли;
		НоваяСтрока = Метки.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Метка);
		МеткаОбъекта = МеткиОбъекта.НайтиПоЗначению(Метка.Свойство);
		Если МеткаОбъекта = Неопределено Тогда
			НоваяСтрока.Значение = Ложь;
		Иначе
			НоваяСтрока.Значение = Истина;
		КонецЕсли;
		НоваяСтрока.Наименование = Метка.Наименование;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция УстановленныеМетки(Метки)
	
	УстановленныеМетки = Новый Массив;
	Для Каждого Метка Из Метки Цикл
		Если Метка.Значение Тогда
			УстановленныеМетки.Добавить(Метка.Свойство);
		КонецЕсли;
	КонецЦикла;
	
	Возврат УстановленныеМетки;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьСнятьВсе(Метки, Установить)
	
	Для Каждого Метка Из Метки Цикл
		Метка.Значение = Установить;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти