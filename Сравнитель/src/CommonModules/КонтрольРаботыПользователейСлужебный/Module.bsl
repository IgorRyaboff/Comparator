///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПереименованийОбъектовМетаданных.
Процедура ПриДобавленииПереименованийОбъектовМетаданных(Итог) Экспорт
	
	Библиотека = "СтандартныеПодсистемы";
	
	ОбщегоНазначения.ДобавитьПереименование(Итог,
		"2.1.0.1",
		"Подсистема.СтандартныеПодсистемы.Подсистема.КонтрольЖурналаРегистрации",
		"Подсистема.СтандартныеПодсистемы.Подсистема.АнализЖурналаРегистрации",
		Библиотека);
	
	ОбщегоНазначения.ДобавитьПереименование(Итог,
		"3.1.10.32",
		"Подсистема.СтандартныеПодсистемы.Подсистема.АнализЖурналаРегистрации",
		"Подсистема.СтандартныеПодсистемы.Подсистема.КонтрольРаботыПользователей",
		Библиотека);
	
КонецПроцедуры

// См. ВариантыОтчетовПереопределяемый.НастроитьВариантыОтчетов.
Процедура ПриНастройкеВариантовОтчетов(Настройки) Экспорт
	
	МодульВариантыОтчетов = ОбщегоНазначения.ОбщийМодуль("ВариантыОтчетов");
	МодульВариантыОтчетов.НастроитьОтчетВМодулеМенеджера(Настройки, Метаданные.Отчеты.АнализЖурналаРегистрации);
	МодульВариантыОтчетов.НастроитьОтчетВМодулеМенеджера(Настройки, Метаданные.Отчеты.ИзменениеУчетныхЗаписей);
	МодульВариантыОтчетов.НастроитьОтчетВМодулеМенеджера(Настройки, Метаданные.Отчеты.ИзменениеУчастниковГруппПользователей);
	
КонецПроцедуры

// См. ВариантыОтчетовПереопределяемый.ПередДобавлениемКомандОтчетов.
Процедура ПередДобавлениемКомандОтчетов(КомандыОтчетов, Параметры, СтандартнаяОбработка) Экспорт
	
	Отчеты.АнализЖурналаРегистрации.ПередДобавлениемКомандОтчетов(КомандыОтчетов, Параметры, СтандартнаяОбработка);
	Отчеты.ИзменениеУчетныхЗаписей.ПередДобавлениемКомандОтчетов(КомандыОтчетов, Параметры, СтандартнаяОбработка);
	Отчеты.ИзменениеУчастниковГруппПользователей.ПередДобавлениемКомандОтчетов(КомандыОтчетов, Параметры, СтандартнаяОбработка);
	
КонецПроцедуры

// См. ПользователиПереопределяемый.ПриОпределенииНастроекРегистрацииСобытийДоступаКДанным
Процедура ПриОпределенииНастроекРегистрацииСобытийДоступаКДанным(Настройки) Экспорт
	
	ХранимыеНастройки = ХранимыеНастройкиРегистрации();
	Если Не ХранимыеНастройки.Использовать Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого Настройка Из ХранимыеНастройки.Состав Цикл
		Настройки.Добавить(Настройка);
	КонецЦикла;
	
КонецПроцедуры

// См. ИнтеграцияПодсистемБСП.ПриЗаполненииСпискаТекущихДел.
Процедура ПриЗаполненииСпискаТекущихДел(ТекущиеДела) Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено()
	 Или Не Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		Возврат;
	КонецЕсли;
	
	РазделАдминистрирование = Метаданные.Подсистемы.Найти("Администрирование");
	Если РазделАдминистрирование = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	ХранимыеНастройки = ХранимыеНастройкиРегистрации();
	
	НенайденныеПоля = Новый Массив;
	ПользователиСлужебный.УдалитьНесуществующиеПоляИзНастройкиСобытияДоступДоступ(
		ХранимыеНастройки.Состав, НенайденныеПоля);
	
	Если Не ЗначениеЗаполнено(НенайденныеПоля) Тогда
		Возврат;
	КонецЕсли;
	
	// Процедура вызывается только при наличии подсистемы "Текущие дела", поэтому здесь
	// не делается проверка существования подсистемы.
	МодульТекущиеДелаСервер = ОбщегоНазначения.ОбщийМодуль("ТекущиеДелаСервер");
	
	Дело = ТекущиеДела.Добавить();
	Дело.Идентификатор  = "АктуализироватьНастройкиРегистрацииСобытийДоступаКДанным";
	Дело.ЕстьДела       = Истина;
	Дело.Важное         = Истина;
	Дело.Количество     = НенайденныеПоля.Количество();
	Дело.Представление  = НСтр("ru = 'Актуализировать настройки регистрации событий доступа к данным'");
	Дело.Подсказка      = НСтр("ru = 'Не выполняется контроль доступа для неактуальных настроек.'");
	Дело.Форма          = "ОбщаяФорма.НастройкиРегистрацииСобытийДоступаКДанным";
	Дело.Владелец       = РазделАдминистрирование;
	
КонецПроцедуры

// Параметры:
//  ТекстОшибки - Строка - возвращаемое значение (текст ошибки дополняется, если нужно).
//
Процедура ПриЗаписиОшибкиОбновленияНастройкиРегистрацииСобытийДоступаКДанным(ТекстОшибки) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	ХранимыеНастройки = ХранимыеНастройкиРегистрации();
	
	Если Не ХранимыеНастройки.Использовать Тогда
		Возврат;
	КонецЕсли;
	
	НенайденныеПоля = Новый Массив;
	ПользователиСлужебный.УдалитьНесуществующиеПоляИзНастройкиСобытияДоступДоступ(
		ХранимыеНастройки.Состав, НенайденныеПоля);
	
	Если Не ЗначениеЗаполнено(НенайденныеПоля) Тогда
		Возврат;
	КонецЕсли;
	
	ТекстОшибки = ТекстОшибки + Символы.ПС + Символы.ПС + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Рекомендуется скорректировать сделанные настройки в форме по ссылке:
		           |%1'", ОбщегоНазначения.КодОсновногоЯзыка()),
		"e1cib/app/ОбщаяФорма.НастройкиРегистрацииСобытийДоступаКДанным");
	
КонецПроцедуры

// Возвращаемое значение:
//  Булево
//
Функция РегистрироватьДоступКДанным() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Возврат ХранимыеНастройкиРегистрации().Использовать;
	
КонецФункции

// Параметры:
//  РегистрироватьДоступКДанным - Булево
//
Процедура УстановитьРегистрациюДоступаКДанным(РегистрироватьДоступКДанным) Экспорт
	
	Блокировка = Новый БлокировкаДанных;
	Блокировка.Добавить("Константа.НастройкиРегистрацииСобытийДоступаКДанным");
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		ТекущиеНастройки = ХранимыеНастройкиРегистрации();
		ТекущиеНастройки.Использовать = РегистрироватьДоступКДанным;
		Хранилище = Новый ХранилищеЗначения(ТекущиеНастройки);
		Константы.НастройкиРегистрацииСобытийДоступаКДанным.Установить(Хранилище);
		Пользователи.ОбновитьНастройкиРегистрацииСобытийДоступаКДанным();
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Возвращаемое значение:
//  Булево
//
Функция РегистрироватьИзмененияПравДоступа() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	Возврат Константы.РегистрироватьИзмененияПравДоступа.Получить();
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// См. КонтрольРаботыПользователей.НастройкиРегистрацииСобытийДоступаКДанным
Функция НастройкиРегистрацииСобытийДоступаКДанным() Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("Состав", Новый Массив);
	Результат.Вставить("Комментарии", Новый Соответствие);
	Результат.Вставить("ОбщийКомментарий", "");
	
	ЗаполнитьЗначенияСвойств(Результат, ХранимыеНастройкиРегистрации());
	
	Возврат Результат;
	
КонецФункции

// См. КонтрольРаботыПользователей.УстановитьНастройкиРегистрацииСобытийДоступаКДанным
Процедура УстановитьНастройкиРегистрацииСобытийДоступаКДанным(Настройки) Экспорт
	
	Блокировка = Новый БлокировкаДанных;
	Блокировка.Добавить("Константа.НастройкиРегистрацииСобытийДоступаКДанным");
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		ТекущиеНастройки = ХранимыеНастройкиРегистрации();
		ТекущиеНастройки.Состав           = Настройки.Состав;
		ТекущиеНастройки.Комментарии      = Настройки.Комментарии;
		ТекущиеНастройки.ОбщийКомментарий = Настройки.ОбщийКомментарий;
		Хранилище = Новый ХранилищеЗначения(ТекущиеНастройки);
		Константы.НастройкиРегистрацииСобытийДоступаКДанным.Установить(Хранилище);
		Пользователи.ОбновитьНастройкиРегистрацииСобытийДоступаКДанным();
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

Функция ИмяСобытияАудитДоступаКДаннымИзменениеНастроекРегистрацииСобытий() Экспорт
	
	Возврат НСтр("ru = 'Аудит доступа к данным.Изменение настроек регистрации событий'",
		ОбщегоНазначения.КодОсновногоЯзыка());
	
КонецФункции

// Параметры:
//  Хранилище - Неопределено - прочитать из константы.
//            - ХранилищеЗначения - использовать указанное.
//
// Возвращаемое значение:
//  Структура:
//    * Использовать - Булево
//    * Состав - Массив из ОписаниеИспользованияСобытияДоступЖурналаРегистрации
//    * Комментарии - Соответствие из КлючИЗначение:
//        * Ключ     - Строка - полное имя таблицы + имя поля, например "Справочник.ФизическиеЛица.НомерДокумента".
//        * Значение - Строка - произвольный текст
//    * ОбщийКомментарий - Строка - произвольный текст
//
Функция ХранимыеНастройкиРегистрации(Хранилище = Неопределено) Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("Использовать", Ложь);
	Результат.Вставить("Состав", Новый Массив);
	Результат.Вставить("Комментарии", Новый Соответствие);
	Результат.Вставить("ОбщийКомментарий", "");
	
	Если Хранилище = Неопределено Тогда
		Хранилище = Константы.НастройкиРегистрацииСобытийДоступаКДанным.Получить();
	КонецЕсли;
	Если ТипЗнч(Хранилище) <> Тип("ХранилищеЗначения") Тогда
		Возврат Результат;
	КонецЕсли;
	
	Значение = Хранилище.Получить();
	Если ТипЗнч(Значение) <> Тип("Структура") Тогда
		Возврат Результат;
	КонецЕсли;
	
	Для Каждого КлючИЗначение Из Результат Цикл
		Если Не Значение.Свойство(КлючИЗначение.Ключ)
		 Или ТипЗнч(Значение[КлючИЗначение.Ключ]) <> ТипЗнч(КлючИЗначение.Значение) Тогда
			Продолжить;
		КонецЕсли;
		Если КлючИЗначение.Ключ = "Состав" Тогда
			Для Каждого Настройка Из Значение.Состав Цикл
				Если ТипЗнч(Настройка) = Тип("ОписаниеИспользованияСобытияДоступЖурналаРегистрации") Тогда
					Результат.Состав.Добавить(Настройка);
				КонецЕсли;
			КонецЦикла;
		Иначе
			Результат[КлючИЗначение.Ключ] = Значение[КлючИЗначение.Ключ];
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Для корректного перевода имени колонки журнала регистрации
//
Функция ИмяКолонкиСоединение() Экспорт
	Возврат "Соединение";
КонецФункции

#КонецОбласти
