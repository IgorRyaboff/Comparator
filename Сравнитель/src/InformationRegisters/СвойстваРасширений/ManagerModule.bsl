///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Для внутреннего использования.
// 
Процедура СохранитьСвойстваРасширений(ИдентификаторРасширения, Свойства) Экспорт
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных();
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.СвойстваРасширений");
		ЭлементБлокировки.УстановитьЗначение("ИдентификаторРасширения", ИдентификаторРасширения);
		Блокировка.Заблокировать();
		
		МенеджерЗаписи = СоздатьМенеджерЗаписи();
		МенеджерЗаписи.ИдентификаторРасширения = ИдентификаторРасширения;
		МенеджерЗаписи.Прочитать();
		
		МенеджерЗаписи.ИдентификаторРасширения = ИдентификаторРасширения;
		ЗаполнитьЗначенияСвойств(МенеджерЗаписи, Свойства);

		МенеджерЗаписи.Записать(Истина);
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

Процедура УдалитьСвойстваРасширенияПоИдентификатору(ИдентификаторРасширения) Экспорт
	
	Набор = РегистрыСведений.СвойстваРасширений.СоздатьНаборЗаписей();
	Набор.Отбор.ИдентификаторРасширения.Установить(ИдентификаторРасширения);
	Набор.Записать();
	
КонецПроцедуры

Процедура УдалитьСвойстваУдаленныхРасширений() Экспорт

	Расширения = РасширенияКонфигурации.Получить();
	
	ИдентификаторыИспользуемыхРасширений = Новый Массив;
	
	Для Каждого Расширение Из Расширения Цикл
		ИдентификаторыИспользуемыхРасширений.Добавить(Строка(Расширение.УникальныйИдентификатор));
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СвойстваРасширений.ИдентификаторРасширения КАК ИдентификаторРасширения
		|ИЗ
		|	РегистрСведений.СвойстваРасширений КАК СвойстваРасширений
		|ГДЕ
		|	НЕ СвойстваРасширений.ИдентификаторРасширения В (&ИдентификаторыИспользуемыхРасширений)";
	
	Запрос.УстановитьПараметр("ИдентификаторыИспользуемыхРасширений", ИдентификаторыИспользуемыхРасширений);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		УдалитьСвойстваРасширенияПоИдентификатору(Выборка.ИдентификаторРасширения)
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли