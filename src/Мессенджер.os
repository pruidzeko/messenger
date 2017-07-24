﻿
///////////////////////////////////////////////////////////////////////////////////////////////
//
// Модуль отправки сообщений 
// Доступные варианты
//	- Канал SLACK
//	- SMS
//	- Gitter
//
// (с) BIA Technologies, LLC	
//
///////////////////////////////////////////////////////////////////////////////////////////////
#Использовать json

Перем АвторизацияSLACK;
Перем АвторизацияRocketChat;
Перем АвторизацияSMS;
Перем АвторизацияGitter Экспорт;
Перем АвторизацияTelegram;

Перем ПараметрыДоступныеОператорыSMS;
Перем ПараметрыДоступныеПротоколы;

///////////////////////////////////////////////////////////////////////////////////////////////

Функция ДоступныеПротоколы() Экспорт

	Если ПараметрыДоступныеПротоколы = Неопределено Тогда

		ПараметрыДоступныеПротоколы = Новый Структура("slack, sms, gitter, rocketchat, telegram", "slack", "sms", "gitter", "rocketchat", "telegram");

	КонецЕсли;

	Возврат ПараметрыДоступныеПротоколы;

КонецФункции

///////////////////////////////////////////////////////////////////////////////////////////////

Процедура ОтправитьСообщениеSMS(Адресат, Сообщение) Экспорт

	ОтправитьСообщение("sms", Адресат, Сообщение);

КонецПроцедуры

Процедура ОтправитьСообщениеSLACK(Адресат, Сообщение, ТипСообщения) Экспорт

	ОтправитьСообщение("slack", Адресат, Сообщение,, ТипСообщения);
	
КонецПроцедуры

Процедура ОтправитьСообщениеGitter(Комната, Сообщение) Экспорт

	IdКомнаты = АвторизацияGitter.Комнаты[Комната];
	Если IdКомнаты = Неопределено Тогда

		ВызватьИсключение "Комната не найдена в списке комнат пользователя";	

	Иначе	 
		ОтправитьСообщениеВКомнатуGitter(IdКомнаты, Сообщение);
	КонецЕсли;	

КонецПроцедуры

Процедура ОтправитьСообщениеRocketChat(Адресат, Сообщение, ТипСообщения) Экспорт

	ОтправитьСообщение("rocketchat", Адресат, Сообщение,, ТипСообщения);
	
КонецПроцедуры

Процедура ОтправитьСообщениеTelegram(Чат, Сообщение) Экспорт

	ОтправитьСообщение("telegram", Чат, Сообщение);
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////////

Процедура ОтправитьСообщение(Протокол, Адресат, Сообщение, ТемаСообщения = "", ТипСообщения = "") Экспорт

	Если Протокол = ДоступныеПротоколы().slack Тогда

		ОтправитьСообщениеВКаналSLACK(Адресат, Сообщение, ТипСообщения)

	ИначеЕсли Протокол = ДоступныеПротоколы().sms Тогда

		ОтправитьСообщениеОператоруSMS(Адресат, Сообщение);
	
	ИначеЕсли Протокол = ДоступныеПротоколы().gitter Тогда

		ОтправитьСообщениеGitter(Адресат, Сообщение);

	ИначеЕсли Протокол = ДоступныеПротоколы().rocketchat Тогда

		ОтправитьСообщениеВКаналRocketChat(Адресат, Сообщение, ТипСообщения);
	
	ИначеЕсли Протокол = ДоступныеПротоколы().telegram Тогда

		ОтправитьСообщениеВЧатTelegram(Адресат, Сообщение);	
	
	Иначе

		ВызватьИсключение "Неизвестный протокол отправки: " + Протокол;

	КонецЕсли;

КонецПроцедуры

Процедура ОтправитьСообщениеОператоруSMS(Адресат, Знач Сообщение) Экспорт

	Если АвторизацияSMS = Неопределено Тогда

		ВызватьИсключение "Необходимо выполнить инициализацию транспорта SMS";

	КонецЕсли;

	URL = АвторизацияSMS.URL;
	ИмяСервера = АвторизацияSMS.ИмяСервера;
	
	ТелоЗапроса = СтрШаблон(АвторизацияSMS.ШаблонТелаЗапроса, 
		АвторизацияSMS.Логин,
		АвторизацияSMS.Пароль,
		Адресат,
		Сообщение,
		АвторизацияSMS.Подпись); 
		
	HTTPЗапрос = Новый HTTPЗапрос(АвторизацияSMS.URL, АвторизацияSMS.Заголовки);
	HTTPЗапрос.УстановитьТелоИзСтроки(ТелоЗапроса);

	HTTP = Новый HTTPСоединение(ИмяСервера);
	Ответ = HTTP.ОтправитьДляОбработки(HTTPЗапрос);

КонецПроцедуры

Процедура ОтправитьСообщениеВКаналSLACK(Канал, ТекстСообщения, ТипСообщения) Экспорт

	Если АвторизацияSLACK = Неопределено Тогда

		ВызватьИсключение "Необходимо выполнить инициализацию транспорта Slack";

	КонецЕсли;
	
	ИмяСервера = "slack.com";
	
	Прокси = Новый ИнтернетПрокси(ИСТИНА);
	
	URL = "api/chat.postMessage?channel=" 
		+ Канал 
		+ "&text=" + СформироватьТекстСообщенияSLACK(ТипСообщения, ТекстСообщения) 
		+ "&as_user=" + АвторизацияSLACK.Логин + "&token=" + АвторизацияSLACK.Ключ;
	

	HTTPЗапрос = Новый HTTPЗапрос;
	HTTPЗапрос.АдресРесурса = URL;
	
	HTTP = Новый HTTPСоединение(ИмяСервера,,,, Прокси);
	Ответ = HTTP.Получить(HTTPЗапрос);

КонецПроцедуры

Процедура ОтправитьСообщениеВКаналRocketChat(Канал, ТекстСообщения, ТипСообщения) Экспорт

	Если АвторизацияRocketChat = Неопределено Тогда

		ВызватьИсключение "Необходимо выполнить инициализацию транспорта RocketChat";

	КонецЕсли;
	
	Прокси = Новый ИнтернетПрокси(ИСТИНА);
	
	// сначала авторизация
	URL = "api/v1/login";
	HTTPЗапрос = Новый HTTPЗапрос;
	HTTPЗапрос.АдресРесурса = URL;
	HTTPЗапрос.УстановитьТелоИзСтроки("{""user"":""" + АвторизацияRocketChat.Логин + """, ""password"":""" + АвторизацияRocketChat.Пароль + """}");
	HTTP = Новый HTTPСоединение(АвторизацияRocketChat.АдресСервера,,,, Прокси);
	ОтветHTTP = HTTP.ОтправитьДляОбработки(HTTPЗапрос);

	Если ОтветHTTP.КодСостояния = 200 Тогда

		json = Новый ПарсерJSON();
		ОтветJson = json.ПрочитатьJSON(ОтветHTTP.ПолучитьТелоКакСтроку());
		Если ОтветJson.Получить("status") = "success" Тогда

			Токен = ОтветJson.Получить("data").Получить("authToken");
			ИД = ОтветJson.Получить("data").Получить("userId");

			// отправка сообщения
			URL = "api/v1/chat.postMessage";

			Заголовки = Новый Соответствие;
			Заголовки.Вставить("Content-Type", "application/json");
			Заголовки.Вставить("Accept", "application/json");
			Заголовки.Вставить("X-Auth-Token", Токен);
			Заголовки.Вставить("X-User-Id", ИД);

			ОписаниеСообщения = Новый Структура;
			ОписаниеСообщения.Вставить("channel", Канал);
			ОписаниеСообщения.Вставить("text", ТекстСообщения);
			ОписаниеСообщения.Вставить("emoji", ПолучитьИконкуТипаСообщения(ТипСообщения));
			HTTPЗапрос = Новый HTTPЗапрос(URL, Заголовки);
			HTTPЗапрос.УстановитьТелоИзСтроки(json.ЗаписатьJSON(ОписаниеСообщения));
			HTTP = Новый HTTPСоединение(АвторизацияRocketChat.АдресСервера,,,, Прокси);
			ОтветHTTP = HTTP.ОтправитьДляОбработки(HTTPЗапрос);
			Сообщить(ОтветHTTP.ПолучитьТелоКакСтроку());

		Иначе
			
			ВызватьИсключение "Ошибка авторизации";	

		КонецЕсли; 

	 Иначе

		ВызватьИсключение "Ошибка выполнения команды";

	КонецЕсли;

КонецПроцедуры

Процедура ОтправитьСообщениеВКомнатуGitter(IdКомнаты, ТекстСообщения) Экспорт

	Если АвторизацияGitter = Неопределено Тогда

		ВызватьИсключение "Необходимо выполнить инициализацию комнат Gitter";

	КонецЕсли;
	
	ИмяСервера = "https://api.gitter.im";
	
	Прокси = Новый ИнтернетПрокси(Истина);

	URL = "/v1/rooms/" 
		+ IdКомнаты 
		+ "/chatMessages";

	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "application/json");
	Заголовки.Вставить("Accept", "application/json");
	Заголовки.Вставить("Authorization", " Bearer " + АвторизацияGitter.Токен);

	HTTPЗапрос = Новый HTTPЗапрос(URL, Заголовки);

	Сообщение = СтрЗаменить(ТекстСообщения, Символы.ПС, "\n");
	Сообщение = СтрЗаменить(Сообщение, Символы.ВК, "\r");
	
	ТекстТела   = "{""text"":""%1""}";
	ТелоЗапроса = СтрШаблон(ТекстТела, Сообщение);

	HTTPЗапрос.УстановитьТелоИзСтроки(ТелоЗапроса);

	HTTP = Новый HTTPСоединение(ИмяСервера);
	ОтветHTTP = HTTP.ОтправитьДляОбработки(HTTPЗапрос);
	
КонецПроцедуры

Процедура ОтправитьСообщениеВЧатTelegram(IdЧата, ТекстСообщения) Экспорт

	Сообщение = СтрЗаменить(ТекстСообщения, Символы.ПС, "%0A");
	ОтветHTTP = ВызватьМетодTelegramAPI("sendMessage", Новый Структура("chat_id, text", IdЧата, Сообщение));
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////////
// Инициализация
///////////////////////////////////////////////////////////////////////////////////////////////

Процедура ИнициализацияGitter(Токен) Экспорт

	Комнаты = ПолучитьСписокКомнатGitter(Токен);
	АвторизацияGitter = Новый Структура("Токен, Комнаты", Токен, Комнаты);

КонецПроцедуры

Процедура ИнициализацияSLACK(Логин, Ключ)Экспорт

	АвторизацияSLACK = Новый Структура("Логин, Ключ", Логин, Ключ);

КонецПроцедуры

Процедура ИнициализацияSMS(КодОператора, Логин, Пароль, Подпись) Экспорт

	Если КодОператора = ДоступныеОператорыSMS().smsbliss Тогда

		Заголовки = Новый Соответствие;
		Заголовки.Вставить("Content-Type", "application/json");

		АвторизацияSMS = Новый Структура("ШаблонТелаЗапроса, Логин, Пароль, Подпись", ПолучитьШаблонТелаЗапросаSMSBliss(), Логин, Пароль, Подпись);
		АвторизацияSMS.Вставить("ИмяСервера", "json.gate.smsbliss.ru");
		АвторизацияSMS.Вставить("URL", "send");
		АвторизацияSMS.Вставить("Заголовки", Заголовки);

	ИначеЕсли КодОператора = ДоступныеОператорыSMS().infobip Тогда

		Заголовки = Новый Соответствие;
		Заголовки.Вставить("Content-Type", "application/json");
			
		АвторизацияSMS = Новый Структура("ШаблонТелаЗапроса, Логин, Пароль, Подпись", ПолучитьШаблонТелаЗапросаInfobip(), Логин, Пароль, Подпись);
		АвторизацияSMS.Вставить("ИмяСервера", "api.infobip.com");
		АвторизацияSMS.Вставить("URL", "api/v3/sendsms/json");
		АвторизацияSMS.Вставить("Заголовки", Заголовки);

	ИначеЕсли КодОператора = ДоступныеОператорыSMS().sms4b Тогда

		Заголовки = Новый Соответствие;
		Заголовки.Вставить("Accept-Encoding", "gzip,deflate");
		Заголовки.Вставить("Content-Type", "text/xml;charset=UTF-8");
		Заголовки.Вставить("SOAPAction", "SMS4B/SendSMS");
				
		АвторизацияSMS = Новый Структура("ШаблонТелаЗапроса, Логин, Пароль, Подпись", ПолучитьШаблонТелаЗапросаSms4b(), Логин, Пароль, Подпись);
		АвторизацияSMS.Вставить("ИмяСервера", "https://sms4b.ru");
		АвторизацияSMS.Вставить("URL", "ws/sms.asmx");
		АвторизацияSMS.Вставить("Заголовки", Заголовки);

	Иначе

		ВызватьИсключение "Неизвестный код оператора: " + КодОператора;
		
	КонецЕсли;

КонецПроцедуры

Процедура ИнициализацияRocketChat(АдресСервера, Логин, Пароль)Экспорт

	АвторизацияRocketChat = Новый Структура("АдресСервера, Логин, Пароль", АдресСервера, Логин, Пароль);

КонецПроцедуры

Процедура ИнициализацияTelegram(Токен) Экспорт
	
	АвторизацияTelegram = Новый Структура("Токен", Токен);

КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////////

Функция СформироватьТекстСообщенияSLACK(ТипСообщения, ТекстСообщения)

	Сообщение = ПолучитьИконкуТипаСообщения(ТипСообщения) + " " + КодироватьСтроку(ТекстСообщения, СпособКодированияСтроки.КодировкаURL);
	Возврат Сообщение;

КонецФункции 

///////////////////////////////////////////////////////////////////////////////////////////////

Функция ПолучитьИконкуТипаСообщения(ТипСообщения)

	Иконка = ТипСообщения;
	Если ТипСообщения = "Ошибка" Тогда
		
		Иконка = ":no_entry:";
		
	ИначеЕсли ТипСообщения = "Информация" Тогда
		
		Иконка = ":speech_balloon:";                                            
		
	ИначеЕсли ТипСообщения = "Предупреждение" Тогда
	
		Иконка = ":warning:";  
		
	КонецЕсли;
	
	Возврат Иконка;

КонецФункции

///////////////////////////////////////////////////////////////////////////////////////////////

Функция ПолучитьШаблонТелаЗапросаSMSBliss()

	Возврат
		"{ 
		|""login"": ""%1"",
		|""password"": ""%2"", 
		|""messages"" :[
		|	{
		|	""clientId"": 0,
		|	""phone"": ""%3"",
		|	""text"": ""%4"",
		|	""sender"": ""%5""
		|	}]
		|}";

КонецФункции

Функция ПолучитьШаблонТелаЗапросаInfobip()

	Возврат
	"{ 
	|""authentication"": 
	|	{
	|	""username"": ""%1"", 
	|	""password"": ""%2""
	|	}, 
	|""messages"" :[
	|	{
	|	""sender"": ""%5"",
	|	""text"": ""%4"",
	|	""type"": ""longSMS"",
	|	""datacoding"": ""8"",
	|	""recipients"": [{
	|		""gsm"": ""%3""}]
	|	}
	|]
	|}";		

КонецФункции

Функция ПолучитьШаблонТелаЗапросаSms4b()

	 Возврат 
		"<soapenv:Envelope xmlns:soapenv=" + Символ(34) + "http://schemas.xmlsoap.org/soap/envelope/" + Символ(34) + " xmlns:sms="+Символ(34)+"SMS4B"+Символ(34)+">
		|<soapenv:Header/>
		|<soapenv:Body>
		|<sms:SendSMS>
		|<sms:Login>%1</sms:Login>
		|<sms:Password>%2</sms:Password>
		|<sms:Source>%5</sms:Source>
		|<sms:Phone>%3</sms:Phone>
		|<sms:Text>%4</sms:Text>
		|</sms:SendSMS>
		|</soapenv:Body>
		|</soapenv:Envelope>";		

КонецФункции

///////////////////////////////////////////////////////////////////////////////////////////////

Функция ДоступныеОператорыSMS()Экспорт

	Если ПараметрыДоступныеОператорыSMS = Неопределено Тогда

		ПараметрыДоступныеОператорыSMS = Новый Структура("smsbliss, infobip, sms4b", "smsbliss", "infobip", "sms4b");

	КонецЕсли;

	Возврат ПараметрыДоступныеОператорыSMS;
	
КонецФункции

///////////////////////////////////////////////////////////////////////////////////////////////

Функция ПолучитьСписокКомнатGitter(Токен)

	СписокКомнат = Новый Соответствие();

	ИмяСервера = "https://api.gitter.im";
	
	Прокси = Новый ИнтернетПрокси(ИСТИНА);
	
	URL = "v1/rooms?access_token=" 
		+ Токен ;
	
	HTTPЗапрос = Новый HTTPЗапрос;
	HTTPЗапрос.АдресРесурса = URL;
	
	HTTP = Новый HTTPСоединение(ИмяСервера);
	Ответ = HTTP.Получить(HTTPЗапрос);
		
	json = Новый ПарсерJSON();
	UnJason = json.ПрочитатьJSON(Ответ.ПолучитьТелоКакСтроку());
	
	Если Ответ.КодСостояния = 200 И ТипЗнч(UnJason) = Тип("Массив") Тогда
		
	 	Для Каждого Комната Из UnJason Цикл
		
			СписокКомнат.Вставить(Комната.Получить("name"),Комната.Получить("id"));
	
	 	КонецЦикла;

	 ИначеЕсли ТипЗнч(UnJason) = Тип("Соответствие") И UnJason["error"] = "Unauthorized" Тогда
	
		 ВызватьИсключение "Ошибка авторизации";	

	 Иначе

		ВызватьИсключение "Ошибка получения списка комнат";	

	 КонецЕсли;

	 Возврат СписокКомнат;

КонецФункции	

///////////////////////////////////////////////////////////////////////////////////////////////

Процедура telegramGetUpdates() Экспорт
	
	ОтветHTTP = ВызватьМетодTelegramAPI("getUpdates", Новый Структура());
	
	Сообщить(ОтветHTTP.ПолучитьТелоКакСтроку());

КонецПроцедуры	

Функция ВызватьМетодTelegramAPI(ИмяМетода, Параметры)
	
	Если Авторизацияtelegram = Неопределено Тогда

		ВызватьИсключение "Необходимо выполнить инициализацию Telegram";

	КонецЕсли;
	
	СтрокаПараметров = "";
	Для Каждого Параметр Из Параметры Цикл
	
		Шаблон = "%1=%2&";
		СтрокаПараметров = СтрокаПараметров + СтрШаблон(Шаблон, Параметр.Ключ, Параметр.Значение);

	КонецЦикла;	

	ИмяСервера = "https://api.telegram.org";
		
	URL = "/bot"
		+ АвторизацияTelegram.Токен
		+ "/" + ИмяМетода
		+ "?" + СтрокаПараметров;

	HTTPЗапрос = Новый HTTPЗапрос(URL);

	HTTP = Новый HTTPСоединение(ИмяСервера);
	ОтветHTTP = HTTP.ОтправитьДляОбработки(HTTPЗапрос);

	Возврат ОтветHTTP;

КонецФункции

///////////////////////////////////////////////////////////////////////////////////////////////

АвторизацияSLACK = Неопределено;
АвторизацияSMS = Неопределено;
АвторизацияGitter = Неопределено;
АвторизацияRocketChat = Неопределено;
АвторизацияTelegram = Неопределено;
ПараметрыДоступныеОператорыSMS = Неопределено;
ПараметрыДоступныеПротоколы = Неопределено;
