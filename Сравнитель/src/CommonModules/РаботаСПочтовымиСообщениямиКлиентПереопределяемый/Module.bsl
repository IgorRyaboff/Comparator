///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Вызывается перед открытием формы нового письма.
// Открытие формы может быть отменено изменением параметра СтандартнаяОбработка.
//
// Параметры:
//  ПараметрыОтправки    - см. РаботаСПочтовымиСообщениямиКлиент.ПараметрыОтправкиПисьма
//  ОбработчикЗавершения - ОписаниеОповещения - описание процедуры, которая будет вызвана после завершения
//                                              отправки письма.
//  СтандартнаяОбработка - Булево - признак продолжения открытия формы нового письма после выхода из этой
//                                  процедуры. Если установить Ложь, форма письма открыта не будет.
//
Процедура ПередОткрытиемФормыОтправкиПисьма(ПараметрыОтправки, ОбработчикЗавершения, СтандартнаяОбработка) Экспорт

	
КонецПроцедуры

#КонецОбласти