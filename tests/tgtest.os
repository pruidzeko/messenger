#Использовать "../"


Процедура ОтпрвитьТГ(Оповещение)

	Мессенджер = Новый Мессенджер();
	BotId = "890545320:AAGKu2MfA2Ct6WZwyF0xNYKscAXxX9Q0CDs";
	Мессенджер.ИнициализироватьТранспорт("telegram", Новый Структура("Логин", BotId));
	Сообщение = Оповещение;
	Мессенджер.ОтправитьСообщение("telegram", "1487684", Сообщение);

КонецПроцедуры

ОтпрвитьТГ("ll,l,;");

