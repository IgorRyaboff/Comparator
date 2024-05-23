///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Только для внутреннего использования.
// 
// Возвращаемое значение:
//  ФиксированноеСоответствие из КлючИЗначение:
//     * Ключ     - Строка
//                - СправочникСсылка.НаборыДополнительныхРеквизитовИСведений
//     * Значение - см. Справочники.НаборыДополнительныхРеквизитовИСведений.СвойстваНабора
//
Функция ПредопределенныеНаборыСвойств() Экспорт

	Возврат Справочники.НаборыДополнительныхРеквизитовИСведений.ПредопределенныеНаборыСвойств();
	
КонецФункции

// Только для внутреннего использования.
//
Функция НаименованияНаборовСвойств() Экспорт
	
	Возврат УправлениеСвойствамиСлужебный.НаименованияНаборовСвойств();
	
КонецФункции

// Только для внутреннего использования.
//
Функция ВидыСвойствНабора(Ссылка, УчитыватьПометкуУдаления = Истина) Экспорт
	
	ВидыСвойствНабора = Новый Структура;
	ВидыСвойствНабора.Вставить("ДополнительныеРеквизиты", Ложь);
	ВидыСвойствНабора.Вставить("ДополнительныеСведения",  Ложь);
	ВидыСвойствНабора.Вставить("Метки",  Ложь);
	
	ТипСсылки = Неопределено;
	МетаданныеВладельца = УправлениеСвойствамиСлужебный.МетаданныеВладельцаЗначенийСвойствНабора(Ссылка, УчитыватьПометкуУдаления, ТипСсылки);
	
	Если МетаданныеВладельца = Неопределено Тогда
		Возврат ВидыСвойствНабора;
	КонецЕсли;
	
	// Проверка использования дополнительных реквизитов.
	ВидыСвойствНабора.Вставить(
		"ДополнительныеРеквизиты",
		МетаданныеВладельца <> Неопределено
		И МетаданныеВладельца.ТабличныеЧасти.Найти("ДополнительныеРеквизиты") <> Неопределено);
	
	// Проверка использования дополнительных сведений.
	ВидыСвойствНабора.Вставить(
		"ДополнительныеСведения",
		      Метаданные.ОбщиеКоманды.Найти("ДополнительныеСведенияКоманднаяПанель") <> Неопределено
		    И Метаданные.ОбщиеКоманды.ДополнительныеСведенияКоманднаяПанель.ТипПараметраКоманды.СодержитТип(ТипСсылки));
	
	// Проверка использования меток.
	ВладельцыМеток = Метаданные.ОпределяемыеТипы.ВладелецМеток.Тип;
	ВидыСвойствНабора.Вставить(
		"Метки",
		МетаданныеВладельца <> Неопределено
		И ВладельцыМеток.СодержитТип(ТипСсылки));
	
	Возврат Новый ФиксированнаяСтруктура(ВидыСвойствНабора);
	
КонецФункции

// Только для внутреннего использования.
//
Функция ЭтоОсновнойЯзык() Экспорт
	
	Возврат СтрСравнить(ОбщегоНазначения.КодОсновногоЯзыка(), ТекущийЯзык().КодЯзыка) = 0;
	
КонецФункции

// Только для внутреннего использования.
//
Функция ПредставленияНаборовСвойств() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	НаборыДополнительныхРеквизитовИСведений.Ссылка КАК Ссылка,
		|	ПРЕДСТАВЛЕНИЕССЫЛКИ(НаборыДополнительныхРеквизитовИСведений.Ссылка) КАК Представление
		|ИЗ
		|	Справочник.НаборыДополнительныхРеквизитовИСведений КАК НаборыДополнительныхРеквизитовИСведений
		|ГДЕ
		|	НЕ НаборыДополнительныхРеквизитовИСведений.ЭтоГруппа
		|	И НЕ НаборыДополнительныхРеквизитовИСведений.Предопределенный
		|	И НаборыДополнительныхРеквизитовИСведений.ИмяПредопределенногоНабора = """"";
	
	ПредставлениеНаборов = Новый Соответствие;
	Результат = Запрос.Выполнить().Выгрузить();
	Для Каждого Строка Из Результат Цикл
		ПредставлениеНаборов.Вставить(Строка.Ссылка, Строка.Представление);
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(ПредставлениеНаборов);
	
КонецФункции

#КонецОбласти