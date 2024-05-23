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

	УстановитьУсловноеОформление();
	
	Если Параметры.Пользователь <> Неопределено Тогда
		МассивПользователей = Новый Массив;
		МассивПользователей.Добавить(Параметры.Пользователь);
		
		ЭтоВнешниеПользователи = ?(
			ТипЗнч(Параметры.Пользователь) = Тип("СправочникСсылка.ВнешниеПользователи"), Истина, Ложь);
		Элементы.ФормаЗаписатьИЗакрыть.Заголовок = НСтр("ru = 'Записать'");
		РежимОткрытияИзКарточкиПользователя = Истина;
	Иначе
		МассивПользователей = Параметры.Пользователи;
		ЭтоВнешниеПользователи = Параметры.ВнешниеПользователи;
		РежимОткрытияИзКарточкиПользователя = Ложь;
	КонецЕсли;
	ИмяКолонкиСостава = ?(ЭтоВнешниеПользователи, "ВнешнийПользователь", "Пользователь");
	
	КоличествоПользователей = МассивПользователей.Количество();
	Если КоличествоПользователей = 0 Тогда
		ВызватьИсключение НСтр("ru = 'Не выбрано ни одного пользователя.'");
	КонецЕсли;
	
	ТипПользователей = Неопределено;
	Для Каждого ПользовательИзМассива Из МассивПользователей Цикл
		Если ТипПользователей = Неопределено Тогда
			ТипПользователей = ТипЗнч(ПользовательИзМассива);
		КонецЕсли;
		ТипПользователяИзМассива = ТипЗнч(ПользовательИзМассива);
		
		Если ТипПользователяИзМассива <> Тип("СправочникСсылка.Пользователи")
		   И ТипПользователяИзМассива <> Тип("СправочникСсылка.ВнешниеПользователи") Тогда
			
			ВызватьИсключение НСтр("ru = 'Команда не может быть выполнена для указанного объекта.'");
		КонецЕсли;
		
		Если ТипПользователей <> ТипПользователяИзМассива Тогда
			ВызватьИсключение НСтр("ru = 'Команда не может быть выполнена сразу для двух разных видов пользователей.'");
		КонецЕсли;
	КонецЦикла;
		
	Если КоличествоПользователей > 1
	   И Параметры.Пользователь = Неопределено Тогда
		
		Заголовок = НСтр("ru = 'Группы пользователей'");
		Элементы.ДеревоГруппПометка.ТриСостояния = Истина;
	КонецЕсли;
	
	СписокПользователей = Новый Структура;
	СписокПользователей.Вставить("МассивПользователей", МассивПользователей);
	СписокПользователей.Вставить("КоличествоПользователей", КоличествоПользователей);
	ЗаполнитьДеревоГрупп();
	
	Если ДеревоГрупп.ПолучитьЭлементы().Количество() = 0 Тогда
		Элементы.ГруппыИлиПредупреждение.ТекущаяСтраница = Элементы.Предупреждение;
		Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
			Элементы.КоманднаяПанель.Видимость = Ложь;
		КонецЕсли;
		Возврат;
	КонецЕсли;
	
	Если ОбщегоНазначения.ЭтоАвтономноеРабочееМесто() Тогда
		Элементы.ФормаЗаписатьИЗакрыть.Доступность = Ложь;
		Элементы.ФормаИсключитьИзВсехГрупп.Доступность = Ложь;
		Элементы.ДеревоГрупп.ТолькоПросмотр = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если РежимОткрытияИзКарточкиПользователя Тогда
		Возврат;
	КонецЕсли;
	
	Оповещение = Новый ОписаниеОповещения("ЗаписатьИЗакрытьНачало", ЭтотОбъект);
	ОбщегоНазначенияКлиент.ПоказатьПодтверждениеЗакрытияФормы(Оповещение, Отказ, ЗавершениеРаботы);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыДеревоГрупп

&НаКлиенте
Процедура ДеревоГруппВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ПоказатьЗначение(,Элемент.ТекущиеДанные.Группа);
	
КонецПроцедуры

&НаКлиенте
Процедура ДеревоГруппПометкаПриИзменении(Элемент)
	Модифицированность = Истина;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)
	ЗаписатьИЗакрытьНачало();
КонецПроцедуры

&НаКлиенте
Процедура СнятьФлажки(Команда)
	
	ЗаполнитьДеревоГрупп(Истина);
	РазвернутьДеревоЗначений();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьУсловноеОформление()

	УсловноеОформление.Элементы.Очистить();

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ДеревоГруппПометка.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ДеревоГрупп.ГруппаНеИзменяется");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;

	Элемент.Оформление.УстановитьЗначениеПараметра("ТолькоПросмотр", Истина);

КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьИЗакрытьНачало(Результат = Неопределено, ДополнительныеПараметры = Неопределено) Экспорт
	
	УведомлениеПользователя = Новый Структура;
	УведомлениеПользователя.Вставить("Сообщение");
	УведомлениеПользователя.Вставить("ЕстьОшибки");
	УведомлениеПользователя.Вставить("ПолныйТекстСообщения");
	
	ЗаписатьИзменения(УведомлениеПользователя);
	
	Если УведомлениеПользователя.ЕстьОшибки = Ложь Тогда
		Если УведомлениеПользователя.Сообщение <> Неопределено Тогда
			ПоказатьОповещениеПользователя(
				НСтр("ru = 'Перемещение пользователей'"), , УведомлениеПользователя.Сообщение, БиблиотекаКартинок.ДиалогИнформация);
		КонецЕсли;
	Иначе
		
		Если УведомлениеПользователя.ПолныйТекстСообщения <> Неопределено Тогда
			ТекстВопроса = УведомлениеПользователя.Сообщение;
			КнопкиВопроса = Новый СписокЗначений;
			КнопкиВопроса.Добавить("Ок", НСтр("ru = 'ОК'"));
			КнопкиВопроса.Добавить("ПоказатьОтчет", НСтр("ru = 'Показать отчет'"));
			Оповещение = Новый ОписаниеОповещения("ЗаписатьИЗакрытьОбработкаВопроса",
				ЭтотОбъект, УведомлениеПользователя.ПолныйТекстСообщения);
			ПоказатьВопрос(Оповещение, ТекстВопроса, КнопкиВопроса,, КнопкиВопроса[0].Значение);
		Иначе
			Оповещение = Новый ОписаниеОповещения("ЗаписатьИЗакрытьОбработкаПредупреждения", ЭтотОбъект);
			ПоказатьПредупреждение(Оповещение, УведомлениеПользователя.Сообщение);
		КонецЕсли;
		
		Возврат;
	КонецЕсли;
	
	Модифицированность = Ложь;
	ЗаписатьИЗакрытьЗавершение();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДеревоГрупп(ТолькоСнятьФлажки = Ложь)
	
	ДеревоГруппПриемник = РеквизитФормыВЗначение("ДеревоГрупп");
	Если Не ТолькоСнятьФлажки Тогда
		ДеревоГруппПриемник.Строки.Очистить();
	КонецЕсли;
	
	Если ТолькоСнятьФлажки Тогда
		
		БылиИзменения = Ложь;
		Найденные = ДеревоГруппПриемник.Строки.НайтиСтроки(Новый Структура("Пометка", 1), Истина);
		Для Каждого СтрокаДерева Из Найденные Цикл
			Если Не СтрокаДерева.ГруппаНеИзменяется Тогда
				СтрокаДерева.Пометка = 0;
				БылиИзменения = Истина;
			КонецЕсли;
		КонецЦикла;
		
		Найденные = ДеревоГруппПриемник.Строки.НайтиСтроки(Новый Структура("Пометка", 2), Истина);
		Для Каждого СтрокаДерева Из Найденные Цикл
			СтрокаДерева.Пометка = 0;
			БылиИзменения = Истина;
		КонецЦикла;
		
		Если БылиИзменения Тогда
			Модифицированность = Истина;
		КонецЕсли;
		
		ЗначениеВРеквизитФормы(ДеревоГруппПриемник, "ДеревоГрупп");
		Возврат;
	КонецЕсли;
	
	ГруппыПользователей = Неопределено;
	ПодчиненныеГруппы = Новый Массив; // Массив из СтрокаТаблицыЗначений: см. ПолучитьГруппыВнешнихПользователей.ГруппыПользователей
	МассивРодителей = Новый Массив;
	
	Если ЭтоВнешниеПользователи Тогда
		ПустаяГруппа = Справочники.ГруппыВнешнихПользователей.ПустаяСсылка();
		ПолучитьГруппыВнешнихПользователей(ГруппыПользователей);
		ОбъектыАвторизации = ОбъектыАвторизацииПользователей(СписокПользователей.МассивПользователей);
	Иначе
		ПустаяГруппа = Справочники.ГруппыПользователей.ПустаяСсылка();
		ПолучитьГруппыПользователей(ГруппыПользователей);
	КонецЕсли;
	
	Если ГруппыПользователей.Количество() <= 1 Тогда
		Элементы.ГруппыИлиПредупреждение.ТекущаяСтраница = Элементы.Предупреждение;
		Возврат;
	КонецЕсли;
	
	ПолучитьПодчиненныеГруппы(ГруппыПользователей, ПодчиненныеГруппы, ПустаяГруппа);
	СоставГрупп = СоставГрупп();
	
	Пока ПодчиненныеГруппы.Количество() > 0 Цикл
		МассивРодителей.Очистить();
		
		Для Каждого Группа Из ПодчиненныеГруппы Цикл
			
			Если Группа.Родитель = ПустаяГруппа Тогда
				НоваяСтрокаГрупп = ДеревоГруппПриемник.Строки.Добавить();
				НоваяСтрокаГрупп.Группа = Группа.Ссылка;
				НоваяСтрокаГрупп.Картинка = ?(ЭтоВнешниеПользователи, 9, 3);
				
				Если СписокПользователей.КоличествоПользователей = 1 Тогда
					ПользовательКосвенноВключенВГруппу = Ложь;
					ПользовательСсылка = СписокПользователей.МассивПользователей[0];
					
					Если ЭтоВнешниеПользователи И Группа.ВсеОбъектыАвторизации Тогда
						Тип = ТипЗнч(ОбъектыАвторизации.Получить(ПользовательСсылка));
						ОписаниеТипаСсылки = Новый ОписаниеТипов(ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Тип));
						Значение = ОписаниеТипаСсылки.ПривестиЗначение(Неопределено);
						
						Отбор = Новый Структура("ТипПользователей", Значение);
						ПользовательКосвенноВключенВГруппу = ЗначениеЗаполнено(Группа.Назначение.НайтиСтроки(Отбор));
						НоваяСтрокаГрупп.ГруппаНеИзменяется = Истина;
					КонецЕсли;
					
					НоваяСтрокаГрупп.Пометка = ?(ПользовательВГруппе(СоставГрупп,
						Группа.Ссылка, ПользовательСсылка) Или ПользовательКосвенноВключенВГруппу, 1, 0);
				Иначе
					НоваяСтрокаГрупп.Пометка = 2;
				КонецЕсли;
				
			Иначе
				ГруппаРодитель = 
					ДеревоГруппПриемник.Строки.НайтиСтроки(Новый Структура("Группа", Группа.Родитель), Истина);
				НоваяСтрокаПодчиненныхГрупп = ГруппаРодитель[0].Строки.Добавить();
				НоваяСтрокаПодчиненныхГрупп.Группа = Группа.Ссылка;
				НоваяСтрокаПодчиненныхГрупп.Картинка = ?(ЭтоВнешниеПользователи, 9, 3);
				
				Если СписокПользователей.КоличествоПользователей = 1 Тогда
					НоваяСтрокаПодчиненныхГрупп.Пометка = ?(ПользовательВГруппе(СоставГрупп,
						Группа.Ссылка, СписокПользователей.МассивПользователей[0]), 1, 0);
				Иначе
					НоваяСтрокаПодчиненныхГрупп.Пометка = 2;
				КонецЕсли;
				
			КонецЕсли;
			
			МассивРодителей.Добавить(Группа.Ссылка);
		КонецЦикла;
		ПодчиненныеГруппы.Очистить();
		
		Для Каждого Элемент Из МассивРодителей Цикл
			ПолучитьПодчиненныеГруппы(ГруппыПользователей, ПодчиненныеГруппы, Элемент);
		КонецЦикла;
		
	КонецЦикла;
	
	ДеревоГруппПриемник.Строки.Сортировать("Группа Возр", Истина);
	ЗначениеВРеквизитФормы(ДеревоГруппПриемник, "ДеревоГрупп");
	
КонецПроцедуры

// Получает группы пользователей.
//
// Параметры:
//  ГруппыПользователей - ТаблицаЗначений:
//    * Ссылка - СправочникСсылка.ГруппыПользователей
//    * Родитель - СправочникСсылка.ГруппыПользователей
//
&НаСервере
Процедура ПолучитьГруппыПользователей(ГруппыПользователей)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ГруппыПользователей.Ссылка,
	|	ГруппыПользователей.Родитель
	|ИЗ
	|	Справочник.ГруппыПользователей КАК ГруппыПользователей
	|ГДЕ
	|	ГруппыПользователей.ПометкаУдаления <> ИСТИНА";
	
	ГруппыПользователей = Запрос.Выполнить().Выгрузить();
	
КонецПроцедуры

// Получает группы внешних пользователей.
//
// Параметры:
//  ГруппыПользователей - ТаблицаЗначений:
//    * Ссылка - СправочникСсылка.ГруппыВнешнихПользователей
//    * Родитель - СправочникСсылка.ГруппыВнешнихПользователей
//    * ВсеОбъектыАвторизации - Булево
//    * Назначение - ТаблицаЗначений:
//       ** ТипПользователей - ОпределяемыйТип.ВнешнийПользователь
//
&НаСервере
Процедура ПолучитьГруппыВнешнихПользователей(ГруппыПользователей)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ГруппыВнешнихПользователей.Ссылка,
	|	ГруппыВнешнихПользователей.Родитель,
	|	ГруппыВнешнихПользователей.ВсеОбъектыАвторизации,
	|	ГруппыВнешнихПользователей.Назначение.(
	|		ТипПользователей)
	|ИЗ
	|	Справочник.ГруппыВнешнихПользователей КАК ГруппыВнешнихПользователей
	|ГДЕ
	|	ГруппыВнешнихПользователей.ПометкаУдаления <> ИСТИНА";
	
	ГруппыПользователей = Запрос.Выполнить().Выгрузить();
	
КонецПроцедуры

// Получает дочерние группы пользователей.
// 
// Параметры:
//  ГруппыПользователей - см. ПолучитьГруппыВнешнихПользователей.ГруппыПользователей
//  ПодчиненныеГруппы - Массив из СтрокаТаблицыЗначений: см. ПолучитьГруппыВнешнихПользователей.ГруппыПользователей
//  ГруппаРодитель - СправочникСсылка.ГруппыПользователей
//                 - СправочникСсылка.ГруппыВнешнихПользователей
//
&НаСервере
Процедура ПолучитьПодчиненныеГруппы(ГруппыПользователей, ПодчиненныеГруппы, ГруппаРодитель)
	
	ПараметрыОтбора = Новый Структура("Родитель", ГруппаРодитель);
	ОтобранныеСтроки = ГруппыПользователей.НайтиСтроки(ПараметрыОтбора);
	
	Для Каждого Элемент Из ОтобранныеСтроки Цикл
		
		Если Элемент.Ссылка = Пользователи.ГруппаВсеПользователи()
			Или Элемент.Ссылка = ВнешниеПользователи.ГруппаВсеВнешниеПользователи() Тогда
			Продолжить;
		КонецЕсли;
		
		ПодчиненныеГруппы.Добавить(Элемент);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ОбъектыАвторизацииПользователей(МассивПользователей)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("МассивПользователей", МассивПользователей);
	Запрос.Текст =
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ВнешниеПользователи.Ссылка КАК Ссылка,
	|	ВнешниеПользователи.ОбъектАвторизации КАК ОбъектАвторизации
	|ИЗ
	|	Справочник.ВнешниеПользователи КАК ВнешниеПользователи
	|ГДЕ
	|	ВнешниеПользователи.Ссылка В (&МассивПользователей)";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Результат = Новый Соответствие;
	
	Пока Выборка.Следующий() Цикл
		Результат.Вставить(Выборка.Ссылка, Выборка.ОбъектАвторизации);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция СоставГрупп()
	
	Запрос = Новый Запрос;
	
	Если ЭтоВнешниеПользователи Тогда
		Запрос.Текст =
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	СоставГрупп.Ссылка КАК Группа,
		|	СоставГрупп.ВнешнийПользователь КАК Пользователь
		|ИЗ
		|	Справочник.ГруппыВнешнихПользователей.Состав КАК СоставГрупп";
	Иначе
		Запрос.Текст =
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	СоставГрупп.Ссылка КАК Группа,
		|	СоставГрупп.Пользователь КАК Пользователь
		|ИЗ
		|	Справочник.ГруппыПользователей.Состав КАК СоставГрупп";
	КонецЕсли;
	
	Выгрузка = Запрос.Выполнить().Выгрузить();
	Выгрузка.Индексы.Добавить("Группа, Пользователь");
	
	Возврат Выгрузка;
	
КонецФункции

&НаСервере
Функция ПользовательВГруппе(СоставГрупп, Группа, Пользователь)
	
	Отбор = Новый Структура;
	Отбор.Вставить("Группа", Группа);
	Отбор.Вставить("Пользователь", Пользователь);
	
	Возврат ЗначениеЗаполнено(СоставГрупп.НайтиСтроки(Отбор));
	
КонецФункции

// Параметры:
//  УведомлениеПользователя - Структура:
//   * Сообщение - Строка
//   * ЕстьОшибки - Булево
//   * ПолныйТекстСообщения - Строка
//
&НаСервере
Процедура ЗаписатьИзменения(УведомлениеПользователя)
	
	МассивПользователей = Неопределено;
	НеПеремещенныеПользователи = Новый Соответствие;
	ДеревоГруппИсточник = ДеревоГрупп.ПолучитьЭлементы();
	ПерезаполнитьСоставГрупп(ДеревоГруппИсточник, СоставГрупп(), МассивПользователей, НеПеремещенныеПользователи);
	СформироватьТекстСообщения(МассивПользователей, УведомлениеПользователя, НеПеремещенныеПользователи)
	
КонецПроцедуры

// Описание
// 
// Параметры:
//  ДеревоГруппИсточник - ДанныеФормыКоллекцияЭлементовДерева
//  МассивПеремещенныхПользователей - Массив из СправочникСсылка.Пользователи
//                                  - Массив из СправочникСсылка.ВнешниеПользователи
//  НеПеремещенныеПользователи - Соответствие из КлючИЗначение:
//    * Ключ - СправочникСсылка.Пользователи
//    * Значение - Массив из СправочникСсылка.ГруппыПользователей
//               - СправочникСсылка.ГруппыВнешнихПользователей
//
&НаСервере
Процедура ПерезаполнитьСоставГрупп(ДеревоГруппИсточник, СоставГрупп, МассивПеремещенныхПользователей, НеПеремещенныеПользователи)
	
	МассивПользователей = СписокПользователей.МассивПользователей; // Массив из СправочникСсылка.Пользователи
	Если МассивПеремещенныхПользователей = Неопределено Тогда
		МассивПеремещенныхПользователей = Новый Массив;
	КонецЕсли;
	
	Для Каждого СтрокаДерева Из ДеревоГруппИсточник Цикл
		
		Если СтрокаДерева.Пометка = 1
			И Не СтрокаДерева.ГруппаНеИзменяется Тогда
			
			Для Каждого ПользовательСсылка Из МассивПользователей Цикл
				
				Если ЭтоВнешниеПользователи Тогда
					ПеремещениеВозможно = ПользователиСлужебный.ВозможноПеремещениеПользователя(СтрокаДерева.Группа, ПользовательСсылка);
					
					Если Не ПеремещениеВозможно Тогда
						
						Если НеПеремещенныеПользователи.Получить(ПользовательСсылка) = Неопределено Тогда
							НеПеремещенныеПользователи.Вставить(ПользовательСсылка, Новый Массив);
							НеПеремещенныеПользователи[ПользовательСсылка].Добавить(СтрокаДерева.Группа);
						Иначе
							НеПеремещенныеПользователи[ПользовательСсылка].Добавить(СтрокаДерева.Группа);
						КонецЕсли;
						
						Продолжить;
					КонецЕсли;
				КонецЕсли;
				
				Если Не ПользовательВГруппе(СоставГрупп, СтрокаДерева.Группа, ПользовательСсылка) Тогда
					Добавлен = Ложь;
					ПользователиСлужебный.ДобавитьПользователяВГруппу(СтрокаДерева.Группа,
						ПользовательСсылка, ИмяКолонкиСостава, Добавлен);
					
					Если Добавлен И МассивПеремещенныхПользователей.Найти(ПользовательСсылка) = Неопределено Тогда
						МассивПеремещенныхПользователей.Добавить(ПользовательСсылка);
					КонецЕсли;
				КонецЕсли;
				
			КонецЦикла;
			
		ИначеЕсли СтрокаДерева.Пометка = 0
			И Не СтрокаДерева.ГруппаНеИзменяется Тогда
			
			Для Каждого ПользовательСсылка Из МассивПользователей Цикл
				
				Если ПользовательВГруппе(СоставГрупп, СтрокаДерева.Группа, ПользовательСсылка) Тогда
					Удален = Ложь;
					ПользователиСлужебный.УдалитьПользователяИзГруппы(СтрокаДерева.Группа,
						ПользовательСсылка, ИмяКолонкиСостава, Удален);
					
					Если Удален И МассивПеремещенныхПользователей.Найти(ПользовательСсылка) = Неопределено Тогда
						МассивПеремещенныхПользователей.Добавить(ПользовательСсылка);
					КонецЕсли;
				КонецЕсли;
				
			КонецЦикла;
			
		КонецЕсли;
		
		ЭлементыСтрокиДерева = СтрокаДерева.ПолучитьЭлементы();
		// Рекурсия
		ПерезаполнитьСоставГрупп(ЭлементыСтрокиДерева, СоставГрупп, МассивПеремещенныхПользователей, НеПеремещенныеПользователи);
		
	КонецЦикла;
	
КонецПроцедуры

// Параметры:
//  МассивПеремещенныхПользователей - см. ПерезаполнитьСоставГрупп.МассивПеремещенныхПользователей
//  УведомлениеПользователя         - см. ЗаписатьИзменения.УведомлениеПользователя
//  НеПеремещенныеПользователи      - см. ПерезаполнитьСоставГрупп.НеПеремещенныеПользователи
//
&НаСервере
Процедура СформироватьТекстСообщения(МассивПеремещенныхПользователей, УведомлениеПользователя, НеПеремещенныеПользователи)
	
	КоличествоПользователей = МассивПеремещенныхПользователей.Количество();
	КоличествоНеПеремещенныхПользователей = НеПеремещенныеПользователи.Количество();
	СтрокаПользователей = "";
	
	Если КоличествоНеПеремещенныхПользователей > 0 Тогда
		
		Если КоличествоНеПеремещенныхПользователей = 1 Тогда
			Для Каждого НеПеремещенныйПользователь Из НеПеремещенныеПользователи Цикл
				Предмет = Строка(НеПеремещенныйПользователь.Ключ);
			КонецЦикла;
			СообщениеПользователю = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Пользователя ""%1"" не удалось включить в выбранные группы,
				           |т.к. у них различается тип или у групп установлен признак ""Все пользователи заданного типа"".'"),
				Предмет);
		Иначе
			Предмет = Формат(КоличествоНеПеремещенныхПользователей, "ЧДЦ=0") + " "
				+ ПользователиСлужебныйКлиентСервер.ПредметЦелогоЧисла(КоличествоНеПеремещенныхПользователей,
					"", НСтр("ru = 'пользователю,пользователям,пользователям,,,,,,0'"));
			СообщениеПользователю =
				НСтр("ru = 'Не всех пользователей удалось включить в выбранные группы,
				           |т.к. у них различается тип или у групп установлен признак ""Все пользователи заданного типа"".'");
			Для Каждого НеПеремещенныйПользователь Из НеПеремещенныеПользователи Цикл
				СтрокаПользователей = СтрокаПользователей + Строка(НеПеремещенныйПользователь.Ключ)
					+ " : " + СтрСоединить(НеПеремещенныйПользователь.Значение, ",") + Символы.ПС;
			КонецЦикла;
			УведомлениеПользователя.ПолныйТекстСообщения =
				НСтр("ru = 'Следующие пользователи не были включены в группы:'")
				+ Символы.ПС + Символы.ПС + СтрокаПользователей;
		КонецЕсли;
		
		УведомлениеПользователя.Сообщение = СообщениеПользователю;
		УведомлениеПользователя.ЕстьОшибки = Истина;
		Возврат;
		
	ИначеЕсли КоличествоПользователей = 1 Тогда
		НаименованиеПользователя = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(
			МассивПеремещенныхПользователей[0], "Наименование");
		
		УведомлениеПользователя.Сообщение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Изменен состав групп у пользователя ""%1""'"),
			НаименованиеПользователя);
			
	ИначеЕсли КоличествоПользователей > 1 Тогда
		СтрокаОбъект = Формат(КоличествоПользователей, "ЧДЦ=0") + " "
			+ ПользователиСлужебныйКлиентСервер.ПредметЦелогоЧисла(КоличествоПользователей,
				"", НСтр("ru = 'пользователя,пользователей,пользователей,,,,,,0'"));
		
		УведомлениеПользователя.Сообщение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Изменен состав групп у %1'"), СтрокаОбъект);
	КонецЕсли;
	
	УведомлениеПользователя.ЕстьОшибки = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура РазвернутьДеревоЗначений()
	
	Строки = ДеревоГрупп.ПолучитьЭлементы();
	Для Каждого Строка Из Строки Цикл
		Элементы.ДеревоГрупп.Развернуть(Строка.ПолучитьИдентификатор(), Истина);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьИЗакрытьОбработкаВопроса(Ответ, ПолныйТекстСообщения) Экспорт
	
	Если Ответ = "Ок" Тогда
		Модифицированность = Ложь;
		ЗаписатьИЗакрытьЗавершение();
	Иначе
		ЗаголовокСообщения = НСтр("ru = 'Пользователи, не включенные в группы'");
		Отчет = Новый ТекстовыйДокумент;
		Отчет.ДобавитьСтроку(ПолныйТекстСообщения);
		Отчет.Показать(ЗаголовокСообщения);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьИЗакрытьОбработкаПредупреждения(ДополнительныеПараметры) Экспорт
	
	Модифицированность = Ложь;
	ЗаписатьИЗакрытьЗавершение();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьИЗакрытьЗавершение()
	
	Оповестить("РазмещениеПользователейВГруппах");
	Если ЭтоВнешниеПользователи Тогда
		Оповестить("Запись_ГруппыВнешнихПользователей");
	Иначе
		Оповестить("Запись_ГруппыПользователей");
	КонецЕсли;
	
	Если Не РежимОткрытияИзКарточкиПользователя Тогда
		Закрыть();
	Иначе
		ЗаполнитьДеревоГрупп();
		РазвернутьДеревоЗначений();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
