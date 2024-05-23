
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОписаниеПеременных

#КонецОбласти

#Область ПрограммныйИнтерфейс

Функция НовыйРезультатЗагрузки() Экспорт
	Результат = Новый Структура;
	
	Результат.Вставить("СравнениеДанныхСсылка", Документы.СравнениеДанных.ПустаяСсылка());
	Результат.Вставить("ТребуетсяВыборПравилаСравнения", Ложь);
	
	Возврат Результат;
КонецФункции

Функция ЗагрузитьВыгрузкуДанных(ВыгрузкаСтрокой, ПравилоСравненияДанных) Экспорт
	РезультатЗагрузки = НовыйРезультатЗагрузки();
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.УстановитьСтроку(ВыгрузкаСтрокой);
	ВыгрузкаXDTO = ФабрикаXDTO.ПрочитатьXML(ЧтениеXML, ФабрикаXDTO.Тип("http://comparator.iryaboff.ru/v1/", "ВыгрузкаДанных"));
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СравненияДанных.Регистратор КАК Регистратор,
		|	СравненияДанных.Статус КАК Статус
		|ИЗ
		|	РегистрСведений.СравненияДанных КАК СравненияДанных
		|ГДЕ
		|	СравненияДанных.ИдентификаторВыгрузки = &ИдентификаторВыгрузки";
	
	Запрос.УстановитьПараметр("ИдентификаторВыгрузки", ВыгрузкаXDTO.ИдентификаторВыгрузки);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДокументы = РезультатЗапроса.Выбрать();
	
	НачатьТранзакцию();
	Попытка
		Если ВыборкаДокументы.Следующий() Тогда
			Документ = ВыборкаДокументы.Регистратор.ПолучитьОбъект();
			Документ.Заблокировать();
		ИначеЕсли Не ЗначениеЗаполнено(ПравилоСравненияДанных) Тогда
			РезультатЗагрузки.ТребуетсяВыборПравилаСравнения = Истина;
			Возврат РезультатЗагрузки;
		Иначе
			Документ = Документы.СравнениеДанных.СоздатьДокумент();
			Документ.Дата = ТекущаяДата();
			Документ.ПравилоСравненияДанных = ПравилоСравненияДанных;
			Документ.ИдентификаторВыгрузки = ВыгрузкаXDTO.ИдентификаторВыгрузки;
			
			Документ.Записать();
			Документ.Заблокировать();
		КонецЕсли;
		
		ЗаписьРегистраВыгрузок = РегистрыСведений.ВыгрузкиДанных.СоздатьМенеджерЗаписи();
		ЗаписьРегистраВыгрузок.Документ = Документ.Ссылка;
		ЗаписьРегистраВыгрузок.База = ?(ВыгрузкаXDTO.НомерБазы = 1, Перечисления.НомераБаз.Первая, Перечисления.НомераБаз.Вторая);
		ЗаписьРегистраВыгрузок.Выгрузка = Новый ХранилищеЗначения(ВыгрузкаСтрокой, Новый СжатиеДанных(9));
		
		ЗаписьРегистраВыгрузок.Записать();
		
		Документ.ОбновитьСтатус();
		Документ.Записать(РежимЗаписиДокумента.Проведение);
		
		РезультатЗагрузки.СравнениеДанныхСсылка = Документ.Ссылка;
		
		ЗафиксироватьТранзакцию();
		Возврат РезультатЗагрузки;
	Исключение
	
	КонецПопытки;
КонецФункции

#КонецОбласти

#Область ОбработчикиСобытий
// Код процедур и функций
#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс
// Код процедур и функций
#КонецОбласти

#Область СлужебныеПроцедурыИФункции
// Код процедур и функций
#КонецОбласти

#Область Инициализация

#КонецОбласти

#КонецЕсли
