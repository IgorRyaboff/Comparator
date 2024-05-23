
#Область ОбработчикиСобытий

Процедура ОбработкаПолученияПолейПредставления(Поля, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	Поля.Добавить("БазовыйТип");
КонецПроцедуры

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	Представление = Строка(Данные.БазовыйТип);
КонецПроцедуры

#КонецОбласти


#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОписаниеПеременных

#КонецОбласти

#Область ПрограммныйИнтерфейс
// Код процедур и функций
#КонецОбласти

#Область ОбработчикиСобытий
// Код процедур и функций
#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс
// Код процедур и функций
#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ВыгрузитьВОбъектXDTO(Ссылка) Экспорт
	ОписаниеТипаXDTO = ОбщегоНазначенияСравнитель.СоздатьОбъектXDTO(1, "ОписаниеТипа");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ОписанияТипов.БазовыйТип КАК БазовыйТип,
		|	ОписанияТипов.ДлинаЧисла КАК ДлинаЧисла,
		|	ОписанияТипов.ТочностьЧисла КАК ТочностьЧисла,
		|	ОписанияТипов.НеотрицательноеЧисло КАК НеотрицательноеЧисло,
		|	ОписанияТипов.ДлинаСтроки КАК ДлинаСтроки,
		|	ОписанияТипов.СтрокаНеограниченнойДлины КАК СтрокаНеограниченнойДлины,
		|	ОписанияТипов.ДатаСВременем КАК ДатаСВременем
		|ИЗ
		|	Справочник.ОписанияТипов КАК ОписанияТипов
		|ГДЕ
		|	ОписанияТипов.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(ОписаниеТипаXDTO, Выборка, "ДлинаЧисла, ТочностьЧисла, НеотрицательноеЧисло
		    |, ДлинаСтроки, СтрокаНеограниченнойДлины
			|, ДатаСВременем");
		ОписаниеТипаXDTO.БазовыйТип = ОбщегоНазначения.ИмяЗначенияПеречисления(Выборка.БазовыйТип);
	КонецЦикла;
	
	ОписаниеТипаXDTO.Проверить();
	Возврат ОписаниеТипаXDTO;
КонецФункции

#КонецОбласти

#Область Инициализация

#КонецОбласти

#КонецЕсли
