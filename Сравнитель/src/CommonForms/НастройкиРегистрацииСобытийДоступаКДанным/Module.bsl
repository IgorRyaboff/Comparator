///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ИмяУдаляемойТаблицы, НоваяТекущаяСтрока;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьУсловноеОформление();
	
	Если Не Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		Отказ = Истина;
	КонецЕсли;
	
	НавигационнаяСсылка = "e1cib/app/ОбщаяФорма.НастройкиРегистрацииСобытийДоступаКДанным";
	
	ЗаполнитьТекущиеНастройки();
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Оповещение = Новый ОписаниеОповещения("ЗаписатьИЗакрытьНаКлиенте", ЭтотОбъект);
	ОбщегоНазначенияКлиент.ПоказатьПодтверждениеЗакрытияФормы(Оповещение, Отказ, ЗавершениеРаботы);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыНастройки

&НаКлиенте
Процедура НастройкиПриАктивизацииСтроки(Элемент)
	
	УдалениеДоступно = Элемент.ТекущиеДанные <> Неопределено
		И Элемент.ТекущиеДанные.ЭтоТаблица;
	
	Элементы.НастройкиКонтекстноеМенюУдалить.Доступность = УдалениеДоступно;
	Элементы.НастройкиУдалить.Доступность = УдалениеДоступно;
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкиПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	Отказ = Истина;
	ПодключитьОбработчикОжидания("ВыбратьОбъекты", 0.1, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкиПередУдалением(Элемент, Отказ)
	
	НоваяТекущаяСтрока = Неопределено;
	
	Если Элемент.ТекущиеДанные = Неопределено
	 Или Не Элемент.ТекущиеДанные.ЭтоТаблица Тогда
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	ИмяУдаляемойТаблицы = Элемент.ТекущиеДанные.Имя;
	
	ЭлементыТаблиц = Настройки.ПолучитьЭлементы();
	Индекс = ЭлементыТаблиц.Индекс(Настройки.НайтиПоИдентификатору(Элемент.ТекущаяСтрока));
	Если ЭлементыТаблиц.Количество() > Индекс + 1 Тогда
		НоваяТекущаяСтрока = ЭлементыТаблиц.Получить(Индекс + 1).ПолучитьИдентификатор();
	ИначеЕсли Индекс > 0 Тогда
		НоваяТекущаяСтрока = ЭлементыТаблиц.Получить(Индекс - 1).ПолучитьИдентификатор();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкиПослеУдаления(Элемент)
	
	ЭлементСписка = ВыбранныеОбъекты.НайтиПоЗначению(ИмяУдаляемойТаблицы);
	Если ЭлементСписка <> Неопределено Тогда
		ВыбранныеОбъекты.Удалить(ЭлементСписка);
	КонецЕсли;
	
	Если НоваяТекущаяСтрока <> Неопределено Тогда
		Элемент.ТекущаяСтрока = НоваяТекущаяСтрока;
		НоваяТекущаяСтрока = Неопределено;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)
	ЗаписатьИЗакрытьНаКлиенте();
КонецПроцедуры

&НаКлиенте
Процедура Выбрать(Команда)
	
	ВыбратьОбъекты();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьУсловноеОформление()

	УсловноеОформление.Элементы.Очистить();

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.НастройкиКонтролировать.Имя);
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.НастройкиРегистрировать.Имя);
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.НастройкиКомментарий.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Настройки.ЭтоПоле");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Ложь;

	Элемент.Оформление.УстановитьЗначениеПараметра("Отображать", Ложь);

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.НастройкиКомментарий.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Настройки.Контролировать");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Ложь;

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Настройки.Регистрировать");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Ложь;

	Элемент.Оформление.УстановитьЗначениеПараметра("Текст", "");
	Элемент.Оформление.УстановитьЗначениеПараметра("ТолькоПросмотр", Истина);

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.НастройкиПредставление.Имя);

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.НастройкиИмя.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Настройки.ЭтоИмяУдалено");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;

	Элемент.Оформление.УстановитьЗначениеПараметра("ЦветТекста", ЦветаСтиля.ПоясняющийОшибкуТекст);

КонецПроцедуры

&НаКлиенте
Процедура ВыбратьОбъекты()
	
	ОтборМетаданных = Новый СписокЗначений;
	ОтборМетаданных.Добавить("ПланыОбмена");
	ОтборМетаданных.Добавить("Константы");
	ОтборМетаданных.Добавить("Последовательности");
	ОтборМетаданных.Добавить("Справочники");
	ОтборМетаданных.Добавить("Документы");
	ОтборМетаданных.Добавить("ЖурналыДокументов");
	ОтборМетаданных.Добавить("ПланыВидовХарактеристик");
	ОтборМетаданных.Добавить("ПланыСчетов");
	ОтборМетаданных.Добавить("ПланыВидовРасчета");
	ОтборМетаданных.Добавить("РегистрыСведений");
	ОтборМетаданных.Добавить("РегистрыНакопления");
	ОтборМетаданных.Добавить("РегистрыБухгалтерии");
	ОтборМетаданных.Добавить("РегистрыРасчета");
	ОтборМетаданных.Добавить("БизнесПроцессы");
	ОтборМетаданных.Добавить("Задачи");
	ОтборМетаданных.Добавить("ВнешниеИсточникиДанных");
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("КоллекцииВыбираемыхОбъектовМетаданных", ОтборМетаданных);
	ПараметрыФормы.Вставить("ВыбранныеОбъектыМетаданных", ВыбранныеОбъекты);
	ПараметрыФормы.Вставить("УникальныйИдентификаторИсточник", УникальныйИдентификатор);
	ПараметрыФормы.Вставить("ВыборЕдинственного", Ложь);
	ПараметрыФормы.Вставить("ВыбиратьТаблицыВнешнихИсточниковДанных", Истина);
	ПараметрыФормы.Вставить("СпособГруппировкиОбъектов", "ПоВидам");
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ВыбратьОбъектыЗавершение", ЭтотОбъект);
	
	ОткрытьФорму("ОбщаяФорма.ВыборОбъектовМетаданных", ПараметрыФормы,,,,, ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьОбъектыЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> Неопределено Тогда
		ОбработатьВыбранные(Результат.ВыгрузитьЗначения());
		СтандартныеПодсистемыКлиент.РазвернутьУзлыДерева(ЭтотОбъект,
			Элементы.Настройки.Имя,, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьВыбранные(ВыбранныеТаблицы)
	
	УдаляемыеЭлементы = Новый Массив;
	ЭлементыТаблиц = Настройки.ПолучитьЭлементы();
	ИменаТаблиц = Новый Соответствие;
	
	Индекс = 0;
	Для Каждого ЭлементТаблицы Из ЭлементыТаблиц Цикл
		Если ВыбранныеТаблицы.Найти(ЭлементТаблицы.Имя) <> Неопределено Тогда
			ИменаТаблиц.Вставить(ЭлементТаблицы.Имя, ЭлементТаблицы);
		ИначеЕсли ЭлементТаблицы.ЭтоИмяУдалено Тогда
			ИменаТаблиц.Вставить(ЭлементТаблицы.Имя, ЭлементТаблицы);
			ВыбранныеТаблицы.Вставить(Индекс, ЭлементТаблицы.Имя);
			Индекс = Индекс + 1;
		Иначе
			УдаляемыеЭлементы.Добавить(ЭлементТаблицы);
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого ЭлементТаблицы Из УдаляемыеЭлементы Цикл
		ЭлементыТаблиц.Удалить(ЭлементТаблицы);
	КонецЦикла;
	
	Индекс = -1;
	Для Каждого ВыбраннаяТаблица Из ВыбранныеТаблицы Цикл
		ЭлементТаблицы = ИменаТаблиц.Получить(ВыбраннаяТаблица);
		Если ЭлементТаблицы <> Неопределено Тогда
			Индекс = Индекс + 1;
			ИндексЭлемента = ЭлементыТаблиц.Индекс(ЭлементТаблицы);
			ЭлементыТаблиц.Сдвинуть(ИндексЭлемента, Индекс - ИндексЭлемента);
			Продолжить;
		КонецЕсли;
		ОбъектМетаданных = ОбщегоНазначения.ОбъектМетаданныхПоПолномуИмени(ВыбраннаяТаблица);
		Если ОбъектМетаданных = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		ПолноеИмяТаблицы = ОбъектМетаданных.ПолноеИмя();
		ПоляТаблицы = ПользователиСлужебныйПовтИсп.ПоляТаблицы(ПолноеИмяТаблицы);
		Если ПоляТаблицы = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		Индекс = Индекс + 1;
		ЭлементТаблицы = ЭлементыТаблиц.Вставить(Индекс);
		ЭлементТаблицы.Имя = ПолноеИмяТаблицы;
		ЭлементТаблицы.ЭтоТаблица = Истина;
		ЭлементТаблицы.Представление = ОбъектМетаданных.Представление();
		ЭлементТаблицы.Картинка = КартинкаВКонфигураторе(ОбъектМетаданных, ЭлементТаблицы.Представление);
		ЭлементТаблицы.Контролировать = Истина;
		ЭлементТаблицы.Регистрировать = Истина;
		ОписаниеЭлемента = Новый Структура("Элемент, Поля, ТабличныеЧасти",
			ЭлементТаблицы, Новый Соответствие, Новый Соответствие);
		ДобавитьТаблицу(ОписаниеЭлемента, ПоляТаблицы);
	КонецЦикла;
	
	ВыбранныеОбъекты.Очистить();
	Для Каждого ЭлементТаблицы Из ЭлементыТаблиц Цикл
		ВыбранныеОбъекты.Добавить(ЭлементТаблицы.Имя);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТекущиеНастройки()
	
	ТекущиеНастройки = КонтрольРаботыПользователей.НастройкиРегистрацииСобытийДоступаКДанным();
	НастройкиСобытия = ТекущиеНастройки.Состав;
	ОбщийКомментарий = ТекущиеНастройки.ОбщийКомментарий;
	
	Комментарии = Новый Соответствие;
	Для Каждого КлючИЗначение Из ТекущиеНастройки.Комментарии Цикл
		Комментарии.Вставить(НРег(КлючИЗначение.Ключ), КлючИЗначение.Значение);
	КонецЦикла;
	
	ЭлементыТаблиц = Настройки.ПолучитьЭлементы();
	Добавленные = Новый Соответствие;
	ВыбранныеОбъекты.Очистить();
	
	Для Каждого НастройкаСобытия Из НастройкиСобытия Цикл
		ОбъектМетаданных = ОбщегоНазначения.ОбъектМетаданныхПоПолномуИмени(НастройкаСобытия.Объект);
		Если ОбъектМетаданных = Неопределено Тогда
			ИмяТаблицыУдалено = Истина;
			ПолноеИмяТаблицы = НастройкаСобытия.Объект;
			ПредставлениеТаблицы = НастройкаСобытия.Объект;
		Иначе
			ИмяТаблицыУдалено = Ложь;
			ПолноеИмяТаблицы = ОбъектМетаданных.ПолноеИмя();
			ПредставлениеТаблицы = ОбъектМетаданных.Представление();
		КонецЕсли;
		ПоляТаблицы = ПользователиСлужебный.ПоляТаблицыСУчетомНастройкиСобытияДоступ(НастройкаСобытия);
		Если ПоляТаблицы = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		ВыбранныеОбъекты.Добавить(ПолноеИмяТаблицы);
		ОписаниеЭлемента = Добавленные.Получить(ПолноеИмяТаблицы);
		Если ОписаниеЭлемента = Неопределено Тогда
			ЭлементТаблицы = ЭлементыТаблиц.Добавить();
			ЭлементТаблицы.Имя = ПолноеИмяТаблицы;
			ЭлементТаблицы.ЭтоИмяУдалено = ИмяТаблицыУдалено;
			ЭлементТаблицы.ЭтоТаблица = Истина;
			ЭлементТаблицы.Представление = ПредставлениеТаблицы;
			ЭлементТаблицы.Картинка = КартинкаВКонфигураторе(ОбъектМетаданных, ЭлементТаблицы.Представление);
			ЭлементТаблицы.Контролировать = Истина;
			ЭлементТаблицы.Регистрировать = Истина;
			ОписаниеЭлемента = Новый Структура("Элемент, Поля, ТабличныеЧасти",
				ЭлементТаблицы, Новый Соответствие, Новый Соответствие);
			Добавленные.Вставить(ПолноеИмяТаблицы, ОписаниеЭлемента);
		КонецЕсли;
		НастроенныеПоля = Новый Структура;
		НастроенныеПоля.Вставить("ПоляДоступа",      ПоляВНижнемРегистре(НастройкаСобытия.ПоляДоступа));
		НастроенныеПоля.Вставить("ПоляРегистрации",  ПоляВНижнемРегистре(НастройкаСобытия.ПоляРегистрации));
		НастроенныеПоля.Вставить("ВсеПоля",          ПоляТаблицы.ВсеПоля);
		НастроенныеПоля.Вставить("ПолноеИмяТаблицы", ПолноеИмяТаблицы);
		НастроенныеПоля.Вставить("Комментарии",      Комментарии);
		
		ДобавитьТаблицу(ОписаниеЭлемента,
			ПоляТаблицы, НастроенныеПоля, ИмяТаблицыУдалено);
	КонецЦикла;
	
	Индекс = 0;
	Для Каждого ЭлементТаблицы Из ЭлементыТаблиц Цикл
		Если ЭлементТаблицы.ЭтоИмяУдалено Тогда
			ИндексЭлемента = ЭлементыТаблиц.Индекс(ЭлементТаблицы);
			ЭлементыТаблиц.Сдвинуть(ИндексЭлемента, Индекс - ИндексЭлемента);
			Индекс = Индекс + 1;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ПоляВНижнемРегистре(Поля)
	
	Результат = Новый Соответствие;
	Для Каждого Поле Из Поля Цикл
		Если ТипЗнч(Поле) = Тип("Массив") Тогда
			Для Каждого ВложенноеПоле Из Поле Цикл
				Если Результат.Получить(НРег(ВложенноеПоле)) = Неопределено Тогда
					Результат.Вставить(НРег(ВложенноеПоле), ВложенноеПоле);
				КонецЕсли;
			КонецЦикла;
		ИначеЕсли Результат.Получить(НРег(Поле)) = Неопределено Тогда
			Результат.Вставить(НРег(Поле), Поле);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Процедура ДобавитьТаблицу(ОписаниеЭлементаТаблицы, ПоляТаблицы, НастроенныеПоля = Неопределено, ИмяТаблицыУдалено = Ложь)
	
	ЭлементТаблицы = ОписаниеЭлементаТаблицы.Элемент;
	ТабличныеЧасти = ОписаниеЭлементаТаблицы.ТабличныеЧасти;
	Поля           = ОписаниеЭлементаТаблицы.Поля;
	
	ЭлементыПолейИТаблиц = ЭлементТаблицы.ПолучитьЭлементы();
	
	Для Каждого ОписаниеКоллекции Из ПоляТаблицы.Коллекции Цикл
		Если ОписаниеКоллекции.Поля <> Неопределено Тогда
			ДобавитьПоля(ЭлементыПолейИТаблиц,
				ОписаниеКоллекции.Поля, Поля, НастроенныеПоля, ИмяТаблицыУдалено,
				КартинкаВКонфигураторе(Неопределено, "", ОписаниеКоллекции.Имя));
		Иначе
			Для Каждого ОписаниеТаблицы Из ОписаниеКоллекции.Таблицы Цикл
				ТабличнаяЧасть = ТабличныеЧасти.Получить(ОписаниеТаблицы.Имя);
				Если ТабличнаяЧасть = Неопределено Тогда
					ЭлементТабличнойЧасти = ЭлементыПолейИТаблиц.Добавить();
					ЭлементТабличнойЧасти.ЭтоТабличнаяЧасть = Истина;
					ЭлементТабличнойЧасти.Имя = ОписаниеТаблицы.Имя;
					ЭлементТабличнойЧасти.ЭтоИмяУдалено = ИмяТаблицыУдалено
						Или Не ЗначениеЗаполнено(ОписаниеКоллекции.Имя);
					ЭлементТабличнойЧасти.Представление = ОписаниеТаблицы.Представление;
					ЭлементТабличнойЧасти.Картинка = КартинкаВКонфигураторе(Неопределено, "", ОписаниеКоллекции.Имя);
					ЭлементТабличнойЧасти.Контролировать = Истина;
					ЭлементТабличнойЧасти.Регистрировать = Истина;
					ТабличнаяЧасть = Новый Структура;
					ТабличнаяЧасть.Вставить("Элемент", ЭлементТабличнойЧасти);
					ТабличнаяЧасть.Вставить("Поля", Новый Соответствие);
					ТабличныеЧасти.Вставить(ОписаниеТаблицы.Имя, ТабличнаяЧасть);
				КонецЕсли;
				ДобавитьПоля(ТабличнаяЧасть.Элемент.ПолучитьЭлементы(),
					ОписаниеТаблицы.Поля, ТабличнаяЧасть.Поля, НастроенныеПоля, ИмяТаблицыУдалено,
					КартинкаВКонфигураторе(Неопределено, "", ОписаниеКоллекции.Имя, Истина),
					ОписаниеТаблицы.Имя + ".");
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьПоля(ЭлементыПолей, ОписаниеПолей, ДобавленныеПоля, НастроенныеПоля,
			ИмяТаблицыУдалено, Картинка, ИмяТабличнойЧасти = "")
	
	Для Каждого ОписаниеПоля Из ОписаниеПолей Цикл
		ЭлементПоля = ДобавленныеПоля.Получить(ОписаниеПоля.Имя);
		Если ЭлементПоля = Неопределено Тогда
			ЭлементПоля = ЭлементыПолей.Добавить();
			ЭлементПоля.ЭтоПоле = Истина;
			ЭлементПоля.Имя = ОписаниеПоля.Имя;
			ЭлементПоля.ЭтоИмяУдалено = ИмяТаблицыУдалено;
			ЭлементПоля.Представление = ОписаниеПоля.Представление;
			ЭлементПоля.Картинка = Картинка;
			ДобавленныеПоля.Вставить(ОписаниеПоля.Имя, ЭлементПоля);
		КонецЕсли;
		Если НастроенныеПоля = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		ИмяПоляДляПоиска = НРег(ИмяТабличнойЧасти + ОписаниеПоля.Имя);
		Если НастроенныеПоля.ВсеПоля.Получить(ИмяПоляДляПоиска) = Неопределено Тогда
			ЭлементПоля.ЭтоИмяУдалено = Истина;
		КонецЕсли;
		Если НастроенныеПоля.ПоляДоступа.Получить(ИмяПоляДляПоиска) <> Неопределено Тогда
			ЭлементПоля.Контролировать = Истина;
		КонецЕсли;
		Если НастроенныеПоля.ПоляРегистрации.Получить(ИмяПоляДляПоиска) <> Неопределено Тогда
			ЭлементПоля.Регистрировать = Истина;
		КонецЕсли;
		ПолноеИмяПоляДляПоиска = НРег(НастроенныеПоля.ПолноеИмяТаблицы + "." + ИмяПоляДляПоиска);
		ЭлементПоля.Комментарий = НастроенныеПоля.Комментарии.Получить(ПолноеИмяПоляДляПоиска);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция КартинкаВКонфигураторе(ОбъектМетаданных, Представление, ИмяКоллекции = Неопределено, ПоляКоллекции = Ложь)
	
	Если ОбъектМетаданных <> Неопределено Тогда
		ЧастиСтроки = СтрРазделить(ОбъектМетаданных.ПолноеИмя(), ".");
		ИмяКартинки = ЧастиСтроки[0];
		Если ИмяКартинки = "ВнешнийИсточникДанных" Тогда
			ИмяКартинки = "ВнешнийИсточникДанныхТаблица";
			Представление = Метаданные.ВнешниеИсточникиДанных[ЧастиСтроки[1]].Представление()
				+ ". " + Представление;
		КонецЕсли;
	ИначеЕсли ИмяКоллекции = Неопределено Тогда
		Возврат Неопределено;
	Иначе
		УточненноеИмяКоллекции = ИмяКоллекции;
		Если ПоляКоллекции Тогда
			Если ИмяКоллекции = "ТабличныеЧасти" Тогда
				УточненноеИмяКоллекции = "Реквизиты";
			ИначеЕсли ИмяКоллекции = "СтандартныеТабличныеЧасти" Тогда
				УточненноеИмяКоллекции = "СтандартныеРеквизиты";
			КонецЕсли;
		КонецЕсли;
		ИмяКартинки = "Метаданные" + УточненноеИмяКоллекции;
	КонецЕсли;
	
	Картинки = Новый Структура(ИмяКартинки);
	ЗаполнитьЗначенияСвойств(Картинки, БиблиотекаКартинок);
	
	Возврат Картинки[ИмяКартинки];
	
КонецФункции

&НаКлиенте
Процедура ЗаписатьИЗакрытьНаКлиенте(Результат = Неопределено, ДополнительныеПараметры = Неопределено) Экспорт
	
	ОчиститьСообщения();
	
	Если ЗаписаноНаСервере() Тогда
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ЗаписаноНаСервере()
	
	НастройкиСобытия = Новый Массив;
	Комментарии = Новый Соответствие;
	ЕстьОшибки = Ложь;
	
	ЭлементыТаблиц = Настройки.ПолучитьЭлементы();
	Для Каждого ЭлементТаблицы Из ЭлементыТаблиц Цикл
		Если ЭлементТаблицы.ЭтоИмяУдалено Тогда
			ОбщегоНазначения.СообщитьПользователю(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Таблица ""%1"" не найдена.'"), ЭлементТаблицы.Имя), , "Настройки");
			ЕстьОшибки = Истина;
			Продолжить;
		КонецЕсли;
		ЭлементыПолейИТабличныхЧастей = ЭлементТаблицы.ПолучитьЭлементы();
		ПоляДоступа = Новый Массив;
		ПоляРегистрации = Новый Массив;
		Для Каждого ЭлементПоляИлиТабличнойЧасти Из ЭлементыПолейИТабличныхЧастей Цикл
			Если ЭлементПоляИлиТабличнойЧасти.ЭтоПоле Тогда
				ЭлементыПолей = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(ЭлементПоляИлиТабличнойЧасти);
			Иначе
				ЭлементыПолей = ЭлементПоляИлиТабличнойЧасти.ПолучитьЭлементы();
			КонецЕсли;
			Для Каждого ЭлементПоля Из ЭлементыПолей Цикл
				ИмяПоля = ЭлементПоля.Имя;
				Если ЭлементПоляИлиТабличнойЧасти.ЭтоТабличнаяЧасть Тогда
					ИмяПоля = ЭлементПоляИлиТабличнойЧасти.Имя + "." + ИмяПоля;
				КонецЕсли;
				Если ЭлементПоля.ЭтоИмяУдалено
				   И (ЭлементПоля.Контролировать Или ЭлементПоля.Регистрировать) Тогда
					ОбщегоНазначения.СообщитьПользователю(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
							НСтр("ru = 'Поле ""%1"" не найдено.'"),
						ЭлементТаблицы.Имя + "." + ИмяПоля), , "Настройки");
					ЕстьОшибки = Истина;
					Продолжить;
				КонецЕсли;
				Если ЭлементПоля.Контролировать Тогда
					ПоляДоступа.Добавить(ИмяПоля);
				КонецЕсли;
				Если ЭлементПоля.Регистрировать Тогда
					ПоляРегистрации.Добавить(ИмяПоля);
				КонецЕсли;
				Если ЗначениеЗаполнено(ЭлементПоля.Комментарий)
				   И (ЭлементПоля.Контролировать Или ЭлементПоля.Регистрировать) Тогда
					Комментарии.Вставить(ЭлементТаблицы.Имя + "." + ИмяПоля, ЭлементПоля.Комментарий);
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
		Если Не ЗначениеЗаполнено(ПоляДоступа) Тогда
			Если ЗначениеЗаполнено(ПоляРегистрации) Тогда
				ОбщегоНазначения.СообщитьПользователю(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Для таблицы ""%1"" указаны поля, которые нужно включать в событие, но не указаны поля, при доступе к которым событие будет записываться.'"),
					ЭлементТаблицы.Представление), , "Настройки");
				ЕстьОшибки = Истина;
			КонецЕсли;
			Продолжить;
		КонецЕсли;
		НоваяНастройка = Новый ОписаниеИспользованияСобытияДоступЖурналаРегистрации;
		НоваяНастройка.Объект = ЭлементТаблицы.Имя;
		НоваяНастройка.ПоляДоступа = ПоляДоступа;
		НоваяНастройка.ПоляРегистрации = ПоляРегистрации;
		НастройкиСобытия.Добавить(НоваяНастройка);
	КонецЦикла;
	
	Если ЕстьОшибки Тогда
		Возврат Ложь;
	КонецЕсли;
	
	НовыеНастройки = Новый Структура;
	НовыеНастройки.Вставить("Состав", НастройкиСобытия);
	НовыеНастройки.Вставить("Комментарии", Комментарии);
	НовыеНастройки.Вставить("ОбщийКомментарий", ОбщийКомментарий);
	
	КонтрольРаботыПользователей.УстановитьНастройкиРегистрацииСобытийДоступаКДанным(НовыеНастройки);
	
	Модифицированность = Ложь;
	
	Возврат Истина;
	
КонецФункции

#КонецОбласти
