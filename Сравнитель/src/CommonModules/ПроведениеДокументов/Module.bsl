
#Область ПрограммныйИнтерфейс

// Заполняет и записывает движения объекта документа
//  
//  Для формирования движений в модуле менеджера объекта должна быть определена функция по шаблону:
//
//	// Формирует наборы движений по регистрам для переданного документа
//	//
//	// Параметры:
//	//  Ссылка - ДокументСсылка.<ИмяДокумента> -
//	//
//	// Возвращаемое значение:
//	//  Структура - Ключ структуры соответствует имени регистра.
//	//              Значение каждого свойства - ТаблицаЗначений с движениями по регистру
//	Функция ДанныеДляПроведенияДокумента(Ссылка) Экспорт
//		// Вставить код формирования движений
//		// Вернуть структуру согласно описанию функции
//	КонецФункции
//
// Параметры:
//  ДокументОбъект - ДокументОбъект -
//  БлокируемыеРегистры	- Строка - Перечисленные через запятую имена регистров,
//                        для которых будет установлен признак БлокироватьДляИзменения
//
Процедура СоздатьИЗаписатьДвиженияПриПроведении(ДокументОбъект, БлокируемыеРегистры = "") Экспорт
	ОбщегоНазначенияКлиентСервер.Проверить(ДокументОбъект.Проведен, НСтр("ru='Попытка записать движения в непроведенный документ'"));
	
	МенеджерОбъекта = ОбщегоНазначения.МенеджерОбъектаПоСсылке(ДокументОбъект.Ссылка);
	
	СформированныеДвижения = МенеджерОбъекта.ДанныеДляПроведенияДокумента(ДокументОбъект.Ссылка);
	ОбщегоНазначенияКлиентСервер.Проверить(СформированныеДвижения <> Неопределено
		, СтрШаблон(НСтр("ru='Функция ДанныеДляПроведенияДокумента документа %1 не вернула структуру с движениями'"), ДокументОбъект.Ссылка.Метаданные().Имя));
	//
	
	ИменаБлокируемыхРегистров = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(БлокируемыеРегистры, ",", Истина, Истина);
	
	Для Каждого КлючЗначение Из СформированныеДвижения Цикл
		ИмяРегистра = КлючЗначение.Ключ;
		ТаблицаЗначений = КлючЗначение.Значение;
		
		ДокументОбъект.Движения[ИмяРегистра].Загрузить(ТаблицаЗначений);
		ДокументОбъект.Движения[ИмяРегистра].Записывать = Истина;
		
		Если ИменаБлокируемыхРегистров.Найти(ИмяРегистра) <> Неопределено Тогда
			ДокументОбъект.Движения[ИмяРегистра].БлокироватьДляИзменения = Истина;
		КонецЕсли;
	КонецЦикла;
	
	ДокументОбъект.Движения.Записать();
КонецПроцедуры

// Формирует и записывает движения переданного документа по регистрам
// Документ при этом не перезаписывается
//
// Параметры:
//  Ссылка					 - 	 - 
//  ПерезаписываемыеРегистры - Строка, Неопределено - Имена регистров, которые будут перезаписаны,
//                             перечисленные через запятую. Для перезаписи движений всех регистров
//                             следует передать Неопределено
//  БлокируемыеРегистры	- Строка - Перечисленные через запятую имена регистров,
//                        для которых будет установлен признак БлокироватьДляИзменения
Процедура ПерезаписатьДвиженияБезПерепроведения(Ссылка, ПерезаписываемыеРегистры = Неопределено, БлокируемыеРегистры = "") Экспорт
	Проведен = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, "Проведен");
	ОбщегоНазначенияКлиентСервер.Проверить(Проведен, НСтр("ru='Попытка записать движения в непроведенный документ'"));
	
	МенеджерОбъекта = ОбщегоНазначения.МенеджерОбъектаПоСсылке(Ссылка);
	
	СформированныеДвижения = МенеджерОбъекта.ДанныеДляПроведенияДокумента(Ссылка);
	ОбщегоНазначенияКлиентСервер.Проверить(СформированныеДвижения <> Неопределено
		, СтрШаблон(НСтр("ru='Функция ДанныеДляПроведенияДокумента документа %1 не вернула структуру с движениями'"), Ссылка.Метаданные().Имя));
	//
	
	ИменаБлокируемыхРегистров = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(БлокируемыеРегистры, ",", Истина, Истина);
	
	Если ПерезаписываемыеРегистры = Неопределено Тогда
		ИменаПерезаписываемыхРегистров = Неопределено;
	Иначе
		ИменаПерезаписываемыхРегистров = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(ПерезаписываемыеРегистры, ",", Истина, Истина);
	КонецЕсли;
	
	НачатьТранзакцию();
	Попытка
		Для Каждого КлючЗначение Из СформированныеДвижения Цикл
			ИмяРегистра = КлючЗначение.Ключ;
			ТаблицаЗначений = КлючЗначение.Значение;
			
			Если ИменаПерезаписываемыхРегистров <> Неопределено И ИменаПерезаписываемыхРегистров.Найти(ИмяРегистра) = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			
			Если Метаданные.РегистрыСведений.Найти(ИмяРегистра) <> Неопределено Тогда
				НаборЗаписей = РегистрыСведений[ИмяРегистра].СоздатьНаборЗаписей();
			ИначеЕсли Метаданные.РегистрыНакопления.Найти(ИмяРегистра) <> Неопределено Тогда
				НаборЗаписей = РегистрыНакопления[ИмяРегистра].СоздатьНаборЗаписей();
			Иначе
				ВызватьИсключение СтрШаблон(НСтр("ru='Регистр %1 не существует среди регистров сведений и регистров накопления'"), ИмяРегистра);
			КонецЕсли;
			
			НаборЗаписей.Отбор.Найти("Регистратор").Установить(Ссылка);
			НаборЗаписей.Загрузить(ТаблицаЗначений);
			
			Если ИменаБлокируемыхРегистров.Найти(ИмяРегистра) <> Неопределено Тогда
				НаборЗаписей.БлокироватьДляИзменения = Истина;
			КонецЕсли;
			
			НаборЗаписей.Записать();
		КонецЦикла;
		
		ЗафиксироватьТранзакцию();
	Исключение
		Если ТранзакцияАктивна() Тогда
			ОтменитьТранзакцию();
		КонецЕсли;
		ВызватьИсключение;
	КонецПопытки;
КонецПроцедуры

Процедура УдалитьВсеДвиженияОбъекта(ДокументОбъект) Экспорт
	Для Каждого НаборДвижений Из ДокументОбъект.Движения Цикл
		НаборДвижений.Записывать = Истина;
	КонецЦикла;
	
	ДокументОбъект.Движения.Записать();
КонецПроцедуры

#КонецОбласти
