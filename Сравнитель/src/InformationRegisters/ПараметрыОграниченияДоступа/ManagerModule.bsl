///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Процедура обновляет данные регистра при полном обновлении вспомогательных данных.
//
// Параметры:
//  ЕстьИзменения - Булево - (возвращаемое значение) - если производилась запись,
//                  устанавливается Истина, иначе не изменяется.
//
Процедура ОбновитьДанныеРегистра(ЕстьИзменения = Неопределено) Экспорт
	
	Если Не УправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально() Тогда
		Возврат;
	КонецЕсли;
	
	Если СтандартныеПодсистемыСервер.ЭтоРазделенныйРежимСеансаБезРазделителей()
	   И ДоступноВыполнениеФоновыхЗаданий() Тогда
		
		ОбновитьДанныеРегистраВФоне(ЕстьИзменения);
	Иначе
		ОбновитьДанныеРегистраНеВФоне(ЕстьИзменения);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ДоступноВыполнениеФоновыхЗаданий()
	
	Если ТекущийРежимЗапуска() = Неопределено
	   И ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда
		
		Сеанс = ПолучитьТекущийСеансИнформационнойБазы();
		Если Сеанс.ИмяПриложения = "COMConnection"
		 Или Сеанс.ИмяПриложения = "BackgroundJob" Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

Процедура ОбновитьДанныеРегистраНеВФоне(ЕстьИзменения)
	
	УправлениеДоступомСлужебный.ДействующиеПараметрыОграниченияДоступа(Неопределено,
		Неопределено, Истина, Ложь, Ложь, ЕстьИзменения);
	
КонецПроцедуры

Процедура ОбновитьДанныеРегистраВФоне(ЕстьИзменения)
	
	ТекущийСеанс = ПолучитьТекущийСеансИнформационнойБазы();
	НаименованиеЗадания = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Управление доступом: Обновление параметров ограничения доступа (из сеанса %1 от %2)'",
			ОбщегоНазначения.КодОсновногоЯзыка()),
		Формат(ТекущийСеанс.НомерСеанса, "ЧГ="),
		Формат(ТекущийСеанс.НачалоСеанса, "ДЛФ=DT"));
	
	ПараметрыОперации = ДлительныеОперации.ПараметрыВыполненияВФоне(Неопределено);
	ПараметрыОперации.НаименованиеФоновогоЗадания = НаименованиеЗадания;
	ПараметрыОперации.СРасширениямиБазыДанных = Истина;
	ПараметрыОперации.ОжидатьЗавершение = Неопределено;
	
	ИмяПроцедуры = "РегистрыСведений.ПараметрыОграниченияДоступа.ОбработчикДлительнойОперацииОбновленияВФоне";
	ДлительнаяОперация = ДлительныеОперации.ВыполнитьВФоне(ИмяПроцедуры, Неопределено, ПараметрыОперации);
	ЗаголовокОшибки = НСтр("ru = 'Не удалось обновить параметры ограничения доступа по причине:'") + Символы.ПС;
	
	Если ДлительнаяОперация.Статус <> "Выполнено" Тогда
		Если ДлительнаяОперация.Статус = "Ошибка" Тогда
			ТекстОшибки = ДлительнаяОперация.ПодробноеПредставлениеОшибки;
		ИначеЕсли ДлительнаяОперация.Статус = "Отменено" Тогда
			ТекстОшибки = НСтр("ru = 'Фоновое задание отменено'");
		Иначе
			ТекстОшибки = НСтр("ru = 'Ошибка выполнения фонового задания'");
		КонецЕсли;
		ВызватьИсключение ЗаголовокОшибки + ТекстОшибки;
	КонецЕсли;
	
	Результат = ПолучитьИзВременногоХранилища(ДлительнаяОперация.АдресРезультата);
	Если ТипЗнч(Результат) <> Тип("Структура") Тогда
		ТекстОшибки = НСтр("ru = 'Фоновое задание не вернуло результат'");
		ВызватьИсключение ЗаголовокОшибки + ТекстОшибки;
	КонецЕсли;
	
	Если Результат.ТребуетсяПерезапускСеанса Тогда
		УправлениеДоступомСлужебный.ПроверитьАктуальностьМетаданных();
		СтандартныеПодсистемыСервер.УстановитьТребуетсяПерезапускСеанса(Результат.ТекстОшибки);
		ВызватьИсключение ЗаголовокОшибки + Результат.ТекстОшибки;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Результат.ТекстОшибки) Тогда
		ВызватьИсключение ЗаголовокОшибки + Результат.ТекстОшибки;
	КонецЕсли;
	
	Если Результат.ЕстьИзменения Тогда
		ЕстьИзменения = Истина;
	КонецЕсли;
	
КонецПроцедуры

// Параметры:
//  Параметры - Неопределено
//  АдресРезультата - Строка
//
Процедура ОбработчикДлительнойОперацииОбновленияВФоне(Параметры, АдресРезультата) Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("ЕстьИзменения", Ложь);
	Результат.Вставить("ТекстОшибки", "");
	Результат.Вставить("ТребуетсяПерезапускСеанса", Ложь);
	
	Попытка
		ОбновитьДанныеРегистраНеВФоне(Результат.ЕстьИзменения);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		Если СтандартныеПодсистемыСервер.ТребуетсяПерезапускСеанса(Результат.ТекстОшибки) Тогда
			Результат.ТребуетсяПерезапускСеанса = Истина;
		КонецЕсли;
		Если Не Результат.ТребуетсяПерезапускСеанса
		 Или Не СтандартныеПодсистемыСервер.ЭтоОшибкаТребованияПерезапускаСеанса(ИнформацияОбОшибке) Тогда
			Результат.ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
		КонецЕсли;
	КонецПопытки;
	
	ПоместитьВоВременноеХранилище(Результат, АдресРезультата);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обновление информационной базы.

// Обновляет версию текстов ограничений доступа.
//
// Параметры:
//  ЕстьИзменения - Булево - (возвращаемое значение) - если изменения найдены,
//                  устанавливается Истина, иначе не изменяется.
//
Процедура ОбновитьВерсиюТекстовОграниченияДоступа(ЕстьИзменения = Неопределено) Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено()
	   И Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		ВерсияИБ = ОбновлениеИнформационнойБазыСлужебный.ВерсияИБ("СтандартныеПодсистемы", Истина);
	Иначе
		ВерсияИБ = ОбновлениеИнформационнойБазыСлужебный.ВерсияИБ("СтандартныеПодсистемы");
	КонецЕсли;
	
	ВерсияТекстов = ВерсияТекстовОграниченияДоступа();
	
	НачатьТранзакцию();
	Попытка
		ЕстьТекущиеИзменения = Ложь;
		
		СтандартныеПодсистемыСервер.ОбновитьПараметрРаботыПрограммы(
			"СтандартныеПодсистемы.УправлениеДоступом.ВерсияТекстовОграниченияДоступа",
			ВерсияТекстов, ЕстьТекущиеИзменения);
		
		Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.0.3.168") < 0
		 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.1.1") > 0
		   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.1.109") < 0
		 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.1") > 0
		   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.249") < 0
		 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.3.1") > 0
		   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.3.4") < 0
		 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.4.1") > 0
		   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.4.376") < 0
		 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.5.1") > 0
		   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.5.475") < 0
		 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.6.1") > 0
		   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.6.275") < 0
		 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.7.1") > 0
		   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.7.100") < 0 Тогда
			
			ЕстьТекущиеИзменения = Истина;
		КонецЕсли;
		
		СтандартныеПодсистемыСервер.ДобавитьИзмененияПараметраРаботыПрограммы(
			"СтандартныеПодсистемы.УправлениеДоступом.ВерсияТекстовОграниченияДоступа",
			?(ЕстьТекущиеИзменения,
			  Новый ФиксированнаяСтруктура("ЕстьИзменения", Истина),
			  Новый ФиксированнаяСтруктура()) );
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Если ЕстьТекущиеИзменения Тогда
		ЕстьИзменения = Истина;
	КонецЕсли;
	
КонецПроцедуры

// Процедура обновляет вспомогательные данные регистра по результату изменения
// возможных прав по значениям доступа, сохраненных в параметрах ограничения доступа.
//
Процедура ЗапланироватьОбновлениеДоступаПоИзменениямКонфигурации() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если УправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально() Тогда
		
		ПоследниеИзменения = СтандартныеПодсистемыСервер.ИзмененияПараметраРаботыПрограммы(
			"СтандартныеПодсистемы.УправлениеДоступом.ВерсияТекстовОграниченияДоступа");
			
		Если ПоследниеИзменения = Неопределено Тогда
			ТребуетсяОбновление = Истина;
		Иначе
			ТребуетсяОбновление = Ложь;
			Для Каждого ЧастьИзменений Из ПоследниеИзменения Цикл
				
				Если ТипЗнч(ЧастьИзменений) = Тип("ФиксированнаяСтруктура")
				   И ЧастьИзменений.Свойство("ЕстьИзменения")
				   И ТипЗнч(ЧастьИзменений.ЕстьИзменения) = Тип("Булево") Тогда
					
					Если ЧастьИзменений.ЕстьИзменения Тогда
						ТребуетсяОбновление = Истина;
						Прервать;
					КонецЕсли;
				Иначе
					ТребуетсяОбновление = Истина;
					Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
		Если ТребуетсяОбновление Тогда
			УправлениеДоступомСлужебный.ЗапланироватьОбновлениеПараметровОграниченияДоступа(
				"ЗапланироватьОбновлениеДоступаПоИзменениямКонфигурации");
		КонецЕсли;
	КонецЕсли;
	
	ВерсияИБ = ОбновлениеИнформационнойБазыСлужебный.ВерсияИБ("СтандартныеПодсистемы");
	
	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.0.3.3") < 0
	 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.1.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.1.109") < 0 Тогда
		
		ЗапланироватьОбновление(Ложь, Истина, "ПереходНаВерсиюБСП_3.0.3.3");
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.0.3.76") < 0
	 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.134") < 0 Тогда
		
		ЗапланироватьОбновление(Истина, Ложь, "ПереходНаВерсиюБСП_3.0.3.76");
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.0.3.107") < 0
	 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.169") < 0 Тогда
		
		ЗапланироватьОбновление(Ложь, Истина, "ПереходНаВерсиюБСП_3.0.3.107");
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.0.3.168") < 0
	 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.249") < 0
	 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.3.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.3.4") < 0 Тогда
	
		ЗапланироватьОбновление_00_00268406("ПереходНаВерсиюБСП_3.0.3.168");
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.0.3.190") < 0
	 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.269") < 0
	 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.3.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.3.26") < 0 Тогда
		
		ЗапланироватьОбновление_00_00263154("ПереходНаВерсиюБСП_3.0.3.190");
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.4.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.4.376") < 0
	 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.5.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.5.188") < 0 Тогда
		
		РегистрыСведений.ИспользуемыеВидыДоступа.ПриИзмененииИспользованияВидовДоступа();
		ЗапланироватьОбновление(Ложь, Истина, "ПереходНаВерсиюБСП_3.1.4.376");
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.5.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.5.475") < 0
	 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.6.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.6.275") < 0
	 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.7.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.7.100") < 0 Тогда
		
		РегистрыСведений.ИспользуемыеВидыДоступа.ПриИзмененииИспользованияВидовДоступа();
		ЗапланироватьОбновление_00_00463430("ПереходНаВерсиюБСП_3.1.5.475");
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.9.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.9.319") < 0
	 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.10.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.10.103") < 0 Тогда
		
		ЗапланироватьОбновление_00_00615173("ПереходНаВерсиюБСП_3.1.9.319");
	КонецЕсли;
	
КонецПроцедуры

// Для процедуры ОбновитьДанныеРегистраПоИзменениямКонфигурации.
Процедура ЗапланироватьОбновление(КлючиДоступаКДанным, РазрешенныеКлючиДоступа, Описание)
	
	Если Не УправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально() Тогда
		Возврат;
	КонецЕсли;
	
	ОписаниеОграниченийДанных = УправлениеДоступомСлужебный.ОписаниеОграниченийДанных();
	ВнешниеПользователиВключены = Константы.ИспользоватьВнешнихПользователей.Получить();
	
	Списки = Новый Массив;
	СпискиДляВнешнихПользователей = Новый Массив;
	Для Каждого КлючИЗначение Из ОписаниеОграниченийДанных Цикл
		Списки.Добавить(КлючИЗначение.Ключ);
		Если ВнешниеПользователиВключены Тогда
			СпискиДляВнешнихПользователей.Добавить(КлючИЗначение.Ключ);
		КонецЕсли;
	КонецЦикла;
	
	ПараметрыПланирования = УправлениеДоступомСлужебный.ПараметрыПланированияОбновленияДоступа();
	
	ПараметрыПланирования.КлючиДоступаКДанным = КлючиДоступаКДанным;
	ПараметрыПланирования.РазрешенныеКлючиДоступа = РазрешенныеКлючиДоступа;
	ПараметрыПланирования.ДляВнешнихПользователей = Ложь;
	ПараметрыПланирования.ЭтоПродолжениеОбновления = Истина;
	ПараметрыПланирования.Описание = Описание;
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступа(Списки, ПараметрыПланирования);
	
	ПараметрыПланирования.ДляПользователей = Ложь;
	ПараметрыПланирования.ДляВнешнихПользователей = Истина;
	ПараметрыПланирования.Описание = Описание;
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступа(СпискиДляВнешнихПользователей, ПараметрыПланирования);
	
КонецПроцедуры

// Для процедуры ОбновитьДанныеРегистраПоИзменениямКонфигурации.
Процедура ЗапланироватьОбновление_00_00268406(Описание)
	
	Если Не УправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально() Тогда
		Возврат;
	КонецЕсли;
	
	ИдентификаторТранзакции = Новый УникальныйИдентификатор;
	ДействующиеПараметры = УправлениеДоступомСлужебный.ДействующиеПараметрыОграниченияДоступа(
		ИдентификаторТранзакции, Неопределено, Ложь);
	
	Списки = Новый Массив;
	СпискиДляВнешнихПользователей = Новый Массив;
	ВнешниеПользователиВключены = Константы.ИспользоватьВнешнихПользователей.Получить();
	
	Для Каждого ВедущийСписок Из ДействующиеПараметры.ВедущиеСписки Цикл
		ПоЗначениямСГруппами = ВедущийСписок.Значение.ПоЗначениямСГруппами;
		Если ПоЗначениямСГруппами = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		ДобавитьСписки_00_00268406(Списки, ПоЗначениямСГруппами.ДляПользователей);
		Если ВнешниеПользователиВключены Тогда
			ДобавитьСписки_00_00268406(СпискиДляВнешнихПользователей, ПоЗначениямСГруппами.ДляВнешнихПользователей);
		КонецЕсли;
	КонецЦикла;
	
	ПараметрыПланирования = УправлениеДоступомСлужебный.ПараметрыПланированияОбновленияДоступа();
	
	ПараметрыПланирования.КлючиДоступаКДанным = Истина;
	ПараметрыПланирования.РазрешенныеКлючиДоступа = Ложь;
	ПараметрыПланирования.ДляВнешнихПользователей = Ложь;
	ПараметрыПланирования.ЭтоПродолжениеОбновления = Истина;
	ПараметрыПланирования.Описание = Описание;
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступа(Списки, ПараметрыПланирования);
	
	ПараметрыПланирования.ДляПользователей = Ложь;
	ПараметрыПланирования.ДляВнешнихПользователей = Истина;
	ПараметрыПланирования.Описание = Описание;
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступа(СпискиДляВнешнихПользователей, ПараметрыПланирования);
	
КонецПроцедуры

// Для процедуры ЗапланироватьОбновление_00_00268406.
Процедура ДобавитьСписки_00_00268406(Списки, ЗависимыеСписки)
	
	Если ЗависимыеСписки = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого ЗависимыйСписок Из ЗависимыеСписки Цикл
		ОбъектМетаданных = ОбщегоНазначения.ОбъектМетаданныхПоПолномуИмени(ЗависимыйСписок);
		Если ОбъектМетаданных = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		Списки.Добавить(ЗависимыйСписок);
	КонецЦикла;
	
КонецПроцедуры

// Для процедуры ОбновитьДанныеРегистраПоИзменениямКонфигурации.
Процедура ЗапланироватьОбновление_00_00263154(Описание)
	
	Если Не УправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально() Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыПланирования = УправлениеДоступомСлужебный.ПараметрыПланированияОбновленияДоступа(Ложь);
	
	ПараметрыПланирования.РазрешенныеКлючиДоступа = Ложь;
	ПараметрыПланирования.ЭтоПродолжениеОбновления = Истина;
	ПараметрыПланирования.Описание = Описание;
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступа("Справочник.НаборыГруппДоступа",
		ПараметрыПланирования);
	
КонецПроцедуры

// Для процедуры ОбновитьДанныеРегистраПоИзменениямКонфигурации.
Процедура ЗапланироватьОбновление_00_00463430(Описание)
	
	Если Не УправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально() Тогда
		Возврат;
	КонецЕсли;
	
	ИдентификаторТранзакции = Новый УникальныйИдентификатор;
	ДействующиеПараметры = УправлениеДоступомСлужебный.ДействующиеПараметрыОграниченияДоступа(
		ИдентификаторТранзакции, Неопределено, Ложь);
	
	ДополнительныйКонтекст = ДействующиеПараметры.ДополнительныйКонтекст;
	
	Списки = Новый Массив;
	СпискиДляВнешнихПользователей = Новый Массив;
	ВнешниеПользователиВключены = Константы.ИспользоватьВнешнихПользователей.Получить();
	
	ДобавитьСписки_00_00463430(Списки, ДополнительныйКонтекст.ДляПользователей);
	Если ВнешниеПользователиВключены Тогда
		ДобавитьСписки_00_00463430(СпискиДляВнешнихПользователей,
			ДополнительныйКонтекст.ДляВнешнихПользователей);
	КонецЕсли;
	
	ПараметрыПланирования = УправлениеДоступомСлужебный.ПараметрыПланированияОбновленияДоступа();
	
	ПараметрыПланирования.КлючиДоступаКДанным = Ложь;
	ПараметрыПланирования.РазрешенныеКлючиДоступа = Истина;
	ПараметрыПланирования.ДляВнешнихПользователей = Ложь;
	ПараметрыПланирования.ЭтоПродолжениеОбновления = Истина;
	ПараметрыПланирования.Описание = Описание;
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступа(Списки, ПараметрыПланирования);
	
	ПараметрыПланирования.ДляПользователей = Ложь;
	ПараметрыПланирования.ДляВнешнихПользователей = Истина;
	ПараметрыПланирования.Описание = Описание;
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступа(СпискиДляВнешнихПользователей, ПараметрыПланирования);
	
КонецПроцедуры

// Для процедуры ЗапланироватьОбновление_00_00463430.
Процедура ДобавитьСписки_00_00463430(Списки, ДополнительныйКонтекст)
	
	СпискиСЗаписьюКлючейДляЗависимыхСписковБезКлючей =
		ДополнительныйКонтекст.СпискиСЗаписьюКлючейДляЗависимыхСписковБезКлючей;
	
	Для Каждого КлючИЗначение Из ДополнительныйКонтекст.СпискиСОтключеннымОграничением Цикл
		Если СпискиСЗаписьюКлючейДляЗависимыхСписковБезКлючей.Получить(КлючИЗначение.Ключ) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		ОбъектМетаданных = ОбщегоНазначения.ОбъектМетаданныхПоПолномуИмени(КлючИЗначение.Ключ);
		Если ОбъектМетаданных = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		Списки.Добавить(ОбъектМетаданных.ПолноеИмя());
	КонецЦикла;
	
КонецПроцедуры

// Для процедуры ОбновитьДанныеРегистраПоИзменениямКонфигурации.
Процедура ЗапланироватьОбновление_00_00615173(Описание)
	
	Если Не УправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально() Тогда
		Возврат;
	КонецЕсли;
	
	Списки = Новый Массив;
	СпискиДляВнешнихПользователей = Новый Массив;
	ВнешниеПользователиВключены = Константы.ИспользоватьВнешнихПользователей.Получить();
	
	ДобавитьСписки_00_00615173(Списки, Ложь);
	Если ВнешниеПользователиВключены Тогда
		ДобавитьСписки_00_00615173(СпискиДляВнешнихПользователей, Истина);
	КонецЕсли;
	
	ПараметрыПланирования = УправлениеДоступомСлужебный.ПараметрыПланированияОбновленияДоступа();
	
	ПараметрыПланирования.КлючиДоступаКДанным = Истина;
	ПараметрыПланирования.РазрешенныеКлючиДоступа = Ложь;
	ПараметрыПланирования.ДляВнешнихПользователей = Ложь;
	ПараметрыПланирования.ЭтоПродолжениеОбновления = Истина;
	ПараметрыПланирования.Описание = Описание;
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступа(Списки, ПараметрыПланирования);
	
	ПараметрыПланирования.ДляПользователей = Ложь;
	ПараметрыПланирования.ДляВнешнихПользователей = Истина;
	ПараметрыПланирования.Описание = Описание;
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступа(СпискиДляВнешнихПользователей, ПараметрыПланирования);
	
КонецПроцедуры

// Для процедуры ЗапланироватьОбновление_00_00615173.
Процедура ДобавитьСписки_00_00615173(Списки, ДляВнешнихПользователей)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДляВнешнихПользователей", ДляВнешнихПользователей);
	Запрос.Текст =
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	КлючиДоступа.Список КАК Список
	|ИЗ
	|	Справочник.КлючиДоступа КАК КлючиДоступа
	|ГДЕ
	|	КлючиДоступа.СоставПолей >= 16
	|	И КлючиДоступа.ДляВнешнихПользователей = &ДляВнешнихПользователей";
	
	Списки = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Список");
	
КонецПроцедуры

// Для процедуры ОбновитьВерсиюТекстовОграниченияДоступа.
Функция ВерсияТекстовОграниченияДоступа()
	
	ОписаниеОграничений = УправлениеДоступомСлужебный.ОписаниеОграниченийДанных();
	
	ВсеТексты = Новый СписокЗначений;
	Разделители = " 	" + Символы.ПС + Символы.ВК + Символы.НПП + Символы.ПФ;
	Для Каждого ОписаниеОграничения Из ОписаниеОграничений Цикл
		Ограничение = ОписаниеОграничения.Значение;
		Тексты = Новый Массив;
		Тексты.Добавить(ОписаниеОграничения.Ключ);
		ДобавитьСвойство(Тексты, Ограничение, Разделители, "Текст");
		ДобавитьСвойство(Тексты, Ограничение, Разделители, "ТекстДляВнешнихПользователей");
		ДобавитьСвойство(Тексты, Ограничение, Разделители, "ПоВладельцуБезЗаписиКлючейДоступа");
		ДобавитьСвойство(Тексты, Ограничение, Разделители, "ПоВладельцуБезЗаписиКлючейДоступаДляВнешнихПользователей");
		ДобавитьСвойство(Тексты, Ограничение, Разделители, "ТекстВМодулеМенеджера");
		ВсеТексты.Добавить(СтрСоединить(Тексты, Символы.ПС), ОписаниеОграничения.Ключ);
	КонецЦикла;
	ВсеТексты.СортироватьПоПредставлению();
	
	ПолныйТекст = СтрСоединить(ВсеТексты.ВыгрузитьЗначения(), Символы.ПС);
	
	Хеширование = Новый ХешированиеДанных(ХешФункция.SHA256);
	Хеширование.Добавить(ПолныйТекст);
	
	Возврат Base64Строка(Хеширование.ХешСумма);
	
КонецФункции

// Для функции ВерсияТекстовОграниченияДоступа.
Процедура ДобавитьСвойство(Тексты, Ограничение, Разделители, ИмяСвойства)
	
	Значение = Ограничение[ИмяСвойства];
	Если ТипЗнч(Значение) = Тип("Строка") Тогда
		Текст = СтрСоединить(СтрРазделить(НРег(Значение), Разделители, Ложь), " ");
	Иначе
		Текст = Строка(Значение);
	КонецЕсли;
	
	Тексты.Добавить("	" + ИмяСвойства + ": " + Текст);
	
КонецПроцедуры

Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	// Регистрация данных не требуется.
	Возврат;
	
КонецПроцедуры

Процедура ОбработатьДанныеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	ВключитьОграничениеДоступаНаУровнеЗаписейУниверсально();
	
	Параметры.ОбработкаЗавершена = Истина;
	
КонецПроцедуры

Процедура ВключитьОграничениеДоступаНаУровнеЗаписейУниверсально() Экспорт
	
	Если ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ() Тогда
		Возврат;
	КонецЕсли;
	
	Константы.ОграничиватьДоступНаУровнеЗаписейУниверсально.Установить(Истина);
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
