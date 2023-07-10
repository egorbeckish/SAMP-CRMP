#include <a_samp>
#include <fix>
#include <a_mysql>
#include <streamer>
#include <Pawn.CMD>
#include <sscanf2>
#include <foreach>
#include <Pawn.Regex>
#include <crashdetect>



#define 	MYSQL_HOST 	"localhost"
#define 	MYSQL_USER 	"root"
#define 	MYSQL_PASS 	""
#define 	MYSQL_BASE 	"project"

#define 	SCM 	SendClientMessage
#define 	SCMTA 	SendClientMessageToAll
#define 	SPD 	ShowPlayerDialog

#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_RED 0xFF0000FF
#define COLOR_RED2 0xFF5E5EAA
#define COLOR_GREEN 0x00FF26AA
#define COLOR_GREY  0xA2A1AbAA
#define COLOR_YELLOW  0xFFF017AA
#define COLOR_BLUE  0x308DFFAA
#define COLOR_YELLOW2 0xC4B404AA

#if defined abs
	#undef abs
#endif
#define abs(%0)\
	(%0 < 0) ? (-(%0)) : (%0)

new MySQL:dbHandle;
new PlayerAFK[MAX_PLAYERS];


main()
{
	print("\n----------------------------------");
	print(" ALL WORKS !11!!");
	print("----------------------------------\n");
}



enum player
{
	ID,
	NAME[MAX_PLAYER_NAME],
	PASSWORD[65],
	SALT[11],
	EMAIL[64],
	REF,
	SEX,
	AGE,
	SKIN,
	REG_DATA[12],
	REG_IP[16],
	ADMIN,
	MONEY,
	LEVEL,
	EXP,
	Float:HP,
	Float:ARMOUR,
	Float:X,
	Float:Y,
	FLoat:Z,
};
new player_info[MAX_PLAYERS][player];



enum JAIL
{
	bool:J_JAIL,
	J_TIME,
	J_CONDITION[64],
	Float:J_X,
	Float:J_Y,
	Float:J_Z,
	J_SKIN,
};
new jail_info[MAX_PLAYERS][JAIL];

enum WARN
{
	W_WARN,
	W_CONDITION[64],
};
new warn_info[MAX_PLAYERS][WARN];

enum BAN
{
	B_ADMIN[64],
	DAYS,
	B_TIME[16],
	B_CONDITION[64],
	B_DATA[16],
	UNBAN[16],
};
new ban_info[MAX_PLAYERS][BAN];


enum ORGANIZATION
{
	FRACTION,
	RANK,
	NAME_RANK[32],
	bool:LEADER,
	O_SKIN,
	Float:O_X,
	Float:O_Y,
	Float:O_Z,
};
new organization_info[MAX_PLAYERS][ORGANIZATION];


enum dialogs
{
	DLG_NONE,
	DLG_REG,
	DLG_REGEMAIL,
	DLG_LOG,
	DLG_REGREF,
	DLG_SEX,
	DLG_SKIN,
	DLG_MENU,
	DLG_STAT,
	DLG_STAT2,
	DLG_BAN,
};


new Float:jail_spawn[12][3] = {
					{ -1803.2435, -2833.7939, 14.2163},
					{ -1804.8093, -2837.1912, 14.2163},
					{ -1806.9464, -2841.8916, 14.2163},
					{ -1808.5771, -2844.8264, 14.2163},
					{ -1810.6672, -2848.8464, 14.2163},
					{ -1812.4492, -2852.0698, 14.2163},
					{ -1814.4500, -2856.6196, 14.2163},
					{ -1816.1658, -2859.9084, 14.2163},
					{ -1817.9237, -2863.5110, 14.2163},
					{ -1820.2755, -2866.9219, 14.2163},
					{ -1821.9863, -2870.8372, 14.2163},
					{ -1823.6901, -2874.4792, 14.2163}
				};



new Float:player_spawn[5][3] = {
	{ 384.3503, 1676.8229, 12.0092},
	{ -2471.8445, 2838.1826, 37.7199},
	{ -2236.3992, 269.3929, 24.5337},
	{ -573.2861, -1565.2938, 40.8223},
	{ 1811.4315, 2507.4387, 15.6717}
};






public OnGameModeInit()
{
	ConnectMySQL();
	SetTimer("SecondUpdate", 1000, true);
	return 1;
}


forward SecondUpdate();
public SecondUpdate()
{
	foreach (new i:Player)
	{
		PlayerAFK[i] ++;
		if (PlayerAFK[i] >= 1)
		{
			new string[] = "{FF0000}AFK: ";
			if (PlayerAFK[i] < 60)
			{
				format(string, sizeof(string), "%s%i сек.", PlayerAFK[i]);
			}

			else
			{
			    new minute = floatround(PlayerAFK[i] / 60, floatround_floor);
			    new second = PlayerAFK[i] % 60;
			    format(string, sizeof(string), "%s%i мин. %i сек.", string, minute, second);
			}

			SetPlayerChatBubble(i, string, -1, 20, 1000);
		}
	}

	return 1;
}

stock ConnectMySQL()
{
    dbHandle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_BASE);
    switch(mysql_errno())
    {
		case 0: print("Connect to MySQL");
		default: print("Don't connect to MySQL");
    }
    mysql_log(ERROR | WARNING);
    mysql_set_charset("cp1251");
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
    GetPlayerName(playerid, player_info[playerid][NAME], MAX_PLAYER_NAME);
    TogglePlayerSpectating(playerid, 1);
    static const fmt_query[] = "SELECT password FROM users WHERE name = '%s'";
	new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME)];
 	format(query, sizeof(query), fmt_query, player_info[playerid][NAME]);
 	mysql_tquery(dbHandle, query, "CheckRegistration", "i", playerid);

	return 1;
}

forward CheckRegistration(playerid);
public CheckRegistration(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows)
	{
		cache_get_value_name(0, "password", player_info[playerid][PASSWORD], 64);
		static const fmt_query[] = "SELECT * FROM banlist WHERE name = '%s'";
		new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME)];
 		format(query, sizeof(query), fmt_query, player_info[playerid][NAME]);
 		mysql_query(dbHandle, query);
 		
		cache_get_row_count(rows);
 		if (!rows) ShowLogin(playerid);
		else
		{
			new string[200];
			cache_get_value_name(0, "administration", ban_info[playerid][B_ADMIN], MAX_PLAYER_NAME);
			cache_get_value_name_int(0, "days", ban_info[playerid][DAYS]);
			cache_get_value_name(0, "condition", ban_info[playerid][B_CONDITION], 64);
			cache_get_value_name(0, "data", ban_info[playerid][B_DATA], 16);
			cache_get_value_name(0, "time", ban_info[playerid][B_TIME], 16);
			cache_get_value_name(0, "unban", ban_info[playerid][UNBAN], 32);
			format(string, sizeof(string),
		 		"Никнейм администратора: %s\n\
		 		Кол-во дней блокировки: %i\n\
				Причина: %s\n\n\
		 		Дата блокировки: %s\n\
		 		Время: %s\n\
		 		Дата разблокировки: %s",
		 		ban_info[playerid][B_ADMIN],
		 		ban_info[playerid][DAYS],
		 		ban_info[playerid][B_CONDITION],
		 		ban_info[playerid][B_DATA],
		 		ban_info[playerid][B_TIME],
		 		ban_info[playerid][UNBAN]);

	 		SPD(playerid, DLG_BAN, DIALOG_STYLE_MSGBOX, "Блокировка аккаунта", string, "Выход", "");
	 		SCM(playerid, COLOR_RED, "Используйте \"/q\", чтобы выйти.");
		}
	}
	else ShowRegistration(playerid);

	SetPVarInt(playerid, "WrongPassword", 3);
}

stock ShowLogin(playerid)
{
    new dialog[300 + (-2 + MAX_PLAYER_NAME)];
	format(dialog, sizeof(dialog),
	    "{FFFFFF}Вход{0089ff} %s{FFFFFF}. Рады приветствовать вас снова на нашем сервере!\n\n\
		Введи пароль в поле ниже.",
		player_info[playerid][NAME]
	 );
	SPD(playerid, DLG_LOG, DIALOG_STYLE_INPUT, "{ffd100}Авторизация{FFFFFF} ••• Ввод • Пароль •••", dialog, "Далее", "Выход");
	// SCM(playerid, COLOR_WHITE, "Игрок зарегистрирован");
}


stock ShowRegistration(playerid)
{
 	new dialog[400 + (-2 + MAX_PLAYER_NAME)];
	format(dialog, sizeof(dialog),

		"{FFFFFF}Уважаемый {0089ff}%s{FFFFFF}. Рады приветствовать вас на нашем сервере\n\
		Аккаунт с данным никнеймом не зарегистрирован.\n\
		Для дальнейшей игры на нашем сервере вам нужно пройти регистрацию.\n\n\
		Придумайте пароль для вашего аккаунта и нажмите \"Далее\"\n\n\
		Примечание:\n\
		\t• Пароль должен содержать от 8 до 32 символов.\n\
		\t• Пароль должен содержать только цифры и латинские символы.",

		player_info[playerid][NAME]);

	SPD(playerid, DLG_REG, DIALOG_STYLE_INPUT, "{ffd100}Регистрация{FFFFFF} ••• Вход • Пароль •••", dialog, "Далее", "Выход");

	//SCM(playerid, COLOR_WHITE, "Игрок не зарегистрирован");
}

public OnPlayerDisconnect(playerid, reason)
{	
	new Float:health;
	GetPlayerHealth(playerid, health);

	static const fmt_query[] = "UPDATE users SET health = '%f' WHERE name = '%s'";
	new query[sizeof(fmt_query) + (-2 + 3) + (-2 + MAX_PLAYER_NAME)];
	format(query, sizeof(query), fmt_query, health, player_info[playerid][NAME]);
	mysql_tquery(dbHandle, query);

	return 1;
}

public OnPlayerSpawn(playerid)
{
	if (GetPVarInt(playerid, "logged") == 0)
	{
		SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Aaaaeoa ia?ieu, ?oi aaoi?eciaaouny ia na?aa?a.");
		return Kick(playerid);
	}

	SetPlayerSkin(playerid, player_info[playerid][SKIN]);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	PlayerAFK[playerid] = -2;
	
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if (GetPVarInt(playerid, "logged") == 0)
	{
		SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}?oiau aaanoe niiauaiea io?ii aaoi?eciaaouny ia na?aa?a.");
		return Kick(playerid);
	}

	new string[144];
	if (strlen(text) < 113)
	{
	    format(string, sizeof(string), "%s[%i]: %s", player_info[playerid][NAME], playerid, text);
	    ProxDetector(20.0, playerid, string, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE);
	    SetPlayerChatBubble(playerid, text, COLOR_WHITE, 20, 7500);

	    if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	    {
	    	ApplyAnimation(playerid, "PED", "IDLE_chat", 4.1, 0, 1, 1, 1, 1);
	    	SetTimerEx("StopChatAnim", 3200, false, "i", playerid);
	    }
	}

	else
	{
	    SCM(playerid, COLOR_GREY, "[ОШИБКА] {FFFFFF}Niiauaiea neeoeii aeeiiia");
	}

	return 0;
}

forward animchat(playerid);
public animchat(playerid)
{
	ApplyAnimation(playerid, "PED", "facanger", 4.1, 0, 1, 1, 1, 1);
	return 1;
}



public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	PlayerAFK[playerid] = 0;
	if (GetPlayerMoney(playerid) != player_info[playerid][MONEY])
	{
		ResetPlayerMoney(playerid);
		GivePlayerMoney(playerid, player_info[playerid][MONEY]);
	}

	return 1;
}

stock GiveMoney(playerid, money)
{
	player_info[playerid][MONEY] += money;
	static const fmt_query[] = "UPDATE users SET money = '%i' WHERE id = '%i'";
	new query[sizeof(fmt_query) + (-2 + 9) + (-2 + 8)];
 	format(query, sizeof(query), fmt_query, player_info[playerid][MONEY], player_info[playerid][ID]);
 	mysql_tquery(dbHandle, query);
 	GivePlayerMoney(playerid, money);
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DLG_LOG:
		{
			if (response)
			{
				new string[300];
				if (!strlen(inputtext))
	            {
	                ShowLogin(playerid);
	                SetPVarInt(playerid, "WrongPassword", GetPVarInt(playerid, "WrongPassword") - 1);
					if (GetPVarInt(playerid, "WrongPassword") > 0)
					{
						format(string, sizeof(string), "[ОШИБКА] {FFFFFF}Невырный ввод пароля. У вас осталось %i попыт(ок/ки), чтобы ввести пароль.", GetPVarInt(playerid, "WrongPassword"));
						SCM(playerid, COLOR_RED, string);
						return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Введите пароль в всплывающем окне и нажмите \"Далее\".");
					}

					else
					{
                        SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Вы использовали все предоставленные вам попытки.");
                        SCM(playerid, COLOR_RED, "Используйте \"/q\", чтобы выйти.");
                        SPD(playerid, -1, 0, " ", " ", " ", " ");
                        return Kick(playerid);
					}
				}

				if (strcmp(player_info[playerid][PASSWORD], inputtext) == 0)
				{
					static const fmt_query[] = "SELECT * FROM users WHERE name = '%s' AND password = '%s'";
					new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME) + (-2 + 64)];
 					format(query, sizeof(query), fmt_query, player_info[playerid][NAME], player_info[playerid][PASSWORD]);
 					mysql_tquery(dbHandle, query, "PlayerLogin", "i", playerid);
				}

				else
				{
					SetPVarInt(playerid, "WrongPassword", GetPVarInt(playerid, "WrongPassword") - 1);
					if (GetPVarInt(playerid, "WrongPassword") > 0)
					{
						format(string, sizeof(string), "[ОШИБКА] {FFFFFF}Невырный ввод пароля. У вас осталось %i попыт(ок/ки), чтобы ввести пароль.", GetPVarInt(playerid, "WrongPassword"));
						SCM(playerid, COLOR_RED, string);
					}

					else
					{
                        SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Вы использовали все предоставленные вам попытки.");
                        SCM(playerid, COLOR_RED, "Используйте \"/q\", чтобы выйти.");
                        SPD(playerid, -1, 0, " ", " ", " ", " ");
                        Kick(playerid);
					}

					ShowLogin(playerid);
				}
			}

			else
			{
				SCM(playerid, COLOR_RED, "Используйте \"/q\", чтобы выйти.");
				SPD(playerid, -1, 0, " ", " ", " ", " ");
				return Kick(playerid);
			}
		}

	    case DLG_REG:
	    {
	        if (response)
	        {
	            if (!strlen(inputtext))
	            {
	                ShowRegistration(playerid);
	                return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Введите пароль всплывающем окне и нажмите \"Далее\".");
				}

				if (!(8 <= strlen(inputtext) <= 32))
				{
				    ShowRegistration(playerid);
	                return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Пароль должен содержать от 8 до 32 символов.");
				}

    			new regex:rg_passwordcheck = regex_new("^[a-zA-Z0-9.-_,]{1,}$");
				if (regex_check(inputtext, rg_passwordcheck))
				{
				    new salt[11];
				    for (new i; i < 10; i++) salt[i] = random(79) + 47;
				    salt[10] = 0;
				    SHA256_PassHash(inputtext, salt, player_info[playerid][PASSWORD], 65);
				    strmid(player_info[playerid][SALT], salt, 0, 11, 11);

					strmid(player_info[playerid][PASSWORD], inputtext, 0, strlen(inputtext), 65);
					SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT,
						"{ffd100}Регистрация{FFFFFF} ••• Ввод • Email •••",
						"Введи существующий Email для того, чтобы при утери вами пароля вы смогли его восстановить.\n\
						Введи email в поле ниже и нажмите \"Далее\"",
						"Далее",
						"Пропустить");
				}

				else
				{
				    ShowRegistration(playerid);
				    regex_delete(rg_passwordcheck);
				    return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Пароль может состоять только из цифр и латинских символов.");
				}
				regex_delete(rg_passwordcheck);
			}

			else
			{
				SCM(playerid, COLOR_RED, "Используйте \"/q\", чтобы выйти.");
				SPD(playerid, -1, 0, " ", " ", " ", " ");
				return Kick(playerid);
			}
		}

		case DLG_REGEMAIL:
		{
			if (response)
			{
				if (!strlen(inputtext))
				{
					SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT,
						"{ffd100}Регистрация{FFFFFF} ••• Ввод • Email •••",
						"Введи существующий Email для того, чтобы при утери вами пароля вы смогли его восстановить.\n\
						Введи email в поле ниже и нажмите \"Далее\"",
						"Далее",
						"Пропустить");
	                return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Введите email всплывающем окне и нажмите \"Далее\"");
				}

				new regex:rg_emailcheck = regex_new("^[a-zA-Z0-9.-]{1,}@[a-zA-Z]{1,}.[a-zA-Z]{1,5}$");
				if (regex_check(inputtext, rg_emailcheck))
				{
				    strmid(player_info[playerid][EMAIL], inputtext, 0, strlen(inputtext), 64);
					SPD(playerid, DLG_REGREF, DIALOG_STYLE_INPUT,
						"{ffd100}Регистрация{FFFFFF} ••• Ввод • Реферальная система •••",
						"Введите никнейм игрока, который вас пригласил на сервер\
						 и нажмите \"Далее\"\n\n\
						{0089ff}Примечание:{FFFFFF}\n\
						• Пример как должен выглядить никнейм - Egor_Egorov",
						"Далее",
						"Пропустить");
				}

				else
				{
					SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT,
						"{ffd100}Регистрация{FFFFFF} ••• Ввод • Email •••",
						"Введи существующий Email для того, чтобы при утери вами пароля вы смогли его восстановить.\n\
						Введи email в поле ниже и нажмите \"Далее\"",
						"Далее",
						"Пропустить");
					return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Введите email адрес верно.");
				}
				regex_delete(rg_emailcheck);
			}

			else
			{
				SPD(playerid, DLG_REGREF, DIALOG_STYLE_INPUT,
					"{ffd100}Регистрация{FFFFFF} ••• Ввод • Реферальная система •••",
					"Введите никнейм игрока, который вас пригласил на сервер\
					и нажмите \"Далее\"\n\n\
					{0089ff}Примечание:{FFFFFF}\n\
					• Пример как должен выглядить никнейм - Egor_Egorov",
					"Далее",
					"Пропустить");
			}
		}

		case DLG_REGREF:
		{
			if (response)
			{
				if (!strlen(inputtext))
				{
					SPD(playerid, DLG_REGREF, DIALOG_STYLE_INPUT,
						"{ffd100}Регистрация{FFFFFF} ••• Ввод • Реферальная система •••",
						"Введите никнейм игрока, который вас пригласил на сервер\
						 и нажмите \"Далее\"\n\n\
						{0089ff}Примечание:{FFFFFF}\n\
						• Пример как должен выглядить никнейм - Egor_Egorov",
						"Далее",
						"Пропустить");
					return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Введи в всплывающем окне никнейм и нажмите \"Далее\"");
				}

				new regex:rg_referalcheck = regex_new("^[a-zA-Z_]{2,24}$");
				if (regex_check(inputtext, rg_referalcheck))
				{
					static const fmt_query[] = "SELECT * FROM users WHERE name = '%s'";
					new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME)];
 					format(query, sizeof(query), fmt_query, inputtext);
 					mysql_tquery(dbHandle, query, "CheckReferal", "is", playerid, inputtext);
				}

				else
				{
					SPD(playerid, DLG_REGREF, DIALOG_STYLE_INPUT,
						"{ffd100}Регистрация{FFFFFF} ••• Ввод • Реферальная система •••",
						"Введите никнейм игрока, который вас пригласил на сервер\
						 и нажмите \"Далее\"\n\n\
						{0089ff}Примечание:{FFFFFF}\n\
						• Пример как должен выглядить никнейм - Egor_Egorov",
						"Далее",
						"Пропустить");
					return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Введите никнейм корректно.");
				}
				regex_delete(rg_referalcheck);
			}

			else
			{
				SPD(playerid, DLG_SEX, DIALOG_STYLE_MSGBOX,
				"{ffd100}Регистрация{FFFFFF} ••• Выбор пола •••",
				"Выберите пол персонажа",
				"Мужчина",
				"Женщина"
				);
			}
		}

		case DLG_SEX:
		{
			if (response) player_info[playerid][SEX] = 1;
			else player_info[playerid][SEX] = 2;
			player_info[playerid][AGE] = 17;

			if (player_info[playerid][SEX] == 1)
			{
			    SPD(playerid, DLG_SKIN, DIALOG_STYLE_LIST,
			        "{ffd100}Регистрация{FFFFFF} ••• Ввод • Выбор одежды •••",
			        "78\n79\n134\n135\n137\n160\n212\n230",
					"Далее",
					""
				);
			}
			else
			{
				SPD(playerid, DLG_SKIN, DIALOG_STYLE_LIST,
					"{ffd100}Регистрация{FFFFFF} ••• Ввод • Выбор одежды •••",
			        "13\n41\n56\n65\n190\n192\n193\n195",
					"Далее",
					""
				);
			}
		}

		case DLG_SKIN:
		{
		    new skinmale[] = {78, 79, 134, 135, 137, 160, 212, 230};
		    new skinfemale[] = {13, 41, 56, 65, 190, 192, 193, 195};
   			if (player_info[playerid][SEX] == 1) player_info[playerid][SKIN] = skinmale[listitem];
			else player_info[playerid][SKIN] = skinfemale[listitem];

			new Year, Month, Day;
			getdate(Year, Month, Day);
			new data[13];
			format(data, sizeof(data), "%02d.%02d.%d", Day, Month, Year);

			new ip[16];
			GetPlayerIp(playerid, ip, sizeof(ip));

			static const fmt_query[] = "INSERT INTO \
			users (name, password, salt, email, referal, sex, age, skin, regdata, regip)\
			VALUES ('%s', '%s', '%s', '%s', '%d', '%d', '%d', '%d', '%s', '%s')";

			new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME) + (-2 + 64) + (-2 + 10) + (-2 + 64) + (-2 + 8) + (-2 + 1) + (-2 + 3) + (-2 + 3) + (-2 + 12) + (-2 + 16)];
		 	format(query, sizeof(query), fmt_query,
			  player_info[playerid][NAME],
			  player_info[playerid][PASSWORD],
			  player_info[playerid][SALT],
			  player_info[playerid][EMAIL],
			  player_info[playerid][REF],
			  player_info[playerid][SEX],
			  player_info[playerid][AGE],
			  player_info[playerid][SKIN],
			  data,
			  ip
			  );
		 	mysql_tquery(dbHandle, query);

		 	static const fmt_query2[] = "SELECT * FROM users WHERE name = '%s' AND password = '%s'";
			// new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME) + (-2 + 64)];
 			format(query, sizeof(query), fmt_query2, player_info[playerid][NAME], player_info[playerid][PASSWORD]);
 			mysql_tquery(dbHandle, query, "PlayerLogin", "i", playerid);
		}
		
		case DLG_MENU:
		{
			if (response)
			{
				if (listitem == 0)
				{
					new string[1000];
					format(string, sizeof(string),
						"Никнейм: %s\n\
						Возраст: %i\n\
						Опыт: %i\n\
						Пол: %s\n\
						Деньги: %i\n\n\
						--------------Наказание--------------\n\
						Предупреждение: %i из 3",
						player_info[playerid][NAME],
						player_info[playerid][AGE],
						player_info[playerid][EXP],
						(player_info[playerid][SEX] == 1) ? ("Мужской") : ("Женский"),
						player_info[playerid][MONEY],
						warn_info[playerid][W_WARN]);
						
                    SPD(playerid, DLG_STAT, DIALOG_STYLE_MSGBOX, "Статистика", string, "Назад", "Выход");
				}
			}

			else
			{

			}
		}

		case DLG_STAT:
		{
			if (response)
			{
				SPD(playerid, DLG_MENU, DIALOG_STYLE_LIST,
					"Меню",
					"1. Статистика",
					"Выбрать",
					"Выход");
			}

			else
			{

			}
		}

		case DLG_STAT2: {if (response) SPD(playerid, -1, 0, " ", " ", " ", " ");}
		// case DLG_BAN: {SCM(playerid, COLOR_RED, "Используйте \"/q\", чтобы выйти.");}
	}

	return 1;
}


forward PlayerLogin(playerid);
public PlayerLogin(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if (rows)
	{
		cache_get_value_name_int(0, "id", player_info[playerid][ID]);
		cache_get_value_name(0, "email", player_info[playerid][EMAIL], 64);
		cache_get_value_name_int(0, "referal", player_info[playerid][REF]);
		cache_get_value_name_int(0, "sex", player_info[playerid][SEX]);
		cache_get_value_name_int(0, "age", player_info[playerid][AGE]);
		cache_get_value_name_int(0, "skin", player_info[playerid][SKIN]);
		cache_get_value_name(0, "regdata", player_info[playerid][REG_DATA], 13);
		cache_get_value_name(0, "regip", player_info[playerid][REG_IP], 16);
		cache_get_value_name_int(0, "admin", player_info[playerid][ADMIN]);
		cache_get_value_name_int(0, "money", player_info[playerid][MONEY]);
		cache_get_value_name_int(0, "level", player_info[playerid][LEVEL]);
		cache_get_value_name_int(0, "exp", player_info[playerid][EXP]);
		cache_get_value_name_float(0, "health", player_info[playerid][HP]);
		cache_get_value_name_float(0, "armour", player_info[playerid][ARMOUR]);
		cache_get_value_name_int(0, "fraction", organization_info[playerid][FRACTION]);
		cache_get_value_name_int(0, "rank", organization_info[playerid][RANK]);
		cache_get_value_name(0, "name_rank", organization_info[playerid][NAME_RANK], 30);
		cache_get_value_name_int(0, "jail_skin", jail_info[playerid][J_SKIN]);
		cache_get_value_name_int(0, "warn", warn_info[playerid][W_WARN]);

		TogglePlayerSpectating(playerid, 0);
		SetPVarInt(playerid, "logged", 1);
		SetSpawnInfo(playerid, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		SpawnPlayer(playerid);
	}


	return 1;
}

forward CheckReferal(playerid, referal[]);
public CheckReferal(playerid, referal[])
{
	new rows;
	cache_get_row_count(rows);
	if (rows)
	{
		new referalid;
		cache_get_value_name_int(0, "id", referalid);
		player_info[playerid][REF] = referalid;
		SPD(playerid, DLG_SEX, DIALOG_STYLE_MSGBOX,
			"{ffd100}Регистрация{FFFFFF} ••• Выбор пола •••",
			"Выберите пол персонажа",
			"Мужчина",
			"Женщина"
			);
	}
	else
	{
		SPD(playerid, DLG_REGREF, DIALOG_STYLE_INPUT,
			"{ffd100}Регистрация{FFFFFF} ••• Ввод • Реферальная система •••",
			"Введите никнейм игрока, который вас пригласил на сервер\
			 и нажмите \"Далее\"\n\n\
			{0089ff}Примечание:{FFFFFF}\n\
			• Пример как должен выглядить никнейм - Egor_Egorov",
			"Далее",
			"Пропустить");
		return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Введите никнейм корректно.");
	}

	return 1;
}


public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

forward OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ);
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if (player_info[playerid][ADMIN] >= 2)
	{
		if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), fX, fY, fZ + 2);
			PutPlayerInVehicle(playerid, GetPlayerVehicleID(playerid), 0);
		}

		else SetPlayerPos(playerid, fX, fY, fZ + 2);

		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 0);
	}

	return 1;
}



stock ProxDetector(Float:radi, playerid, string[], col1, col2, col3, col4, col5)
{
	if (IsPlayerConnected(playerid))
	{
		new Float:posx; new Float:posy; new Float:posz; new Float:oldposx; new Float:oldposy; new Float:oldposz;
		new Float:tempposx; new Float:tempposy; new Float:tempposz;
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);

		foreach (new i:Player)
		{
			if (IsPlayerConnected(i))
			{
				if (GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
				{
					GetPlayerPos(i, posx, posy, posz);
					tempposx = oldposx - posx;
					tempposy = oldposy - posy;
					tempposz = oldposz - posz;

					if (((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16))) SCM(i, col1, string);
					else if (((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8))) SCM(i, col2, string);
					else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4))) SCM(i, col3, string);
					else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2))) SCM(i, col4, string);
					else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi))) SCM(i, col5, string);
				}
			}
		}
	}

	return 1;
}

CMD:makeadmin(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 5)
	{
		new id, level;
		if (sscanf(params, "ui", id, level)) SCM(playerid, COLOR_GREY, "Используйте /makeadmin [id] [level]");
		else
		{
			if (!IsPlayerConnected(id)) SCM(playerid, COLOR_GREY, "Игрок отсутствует на сервере.");

			else
			{
				if (player_info[playerid][ADMIN] == 5 && level > 1) SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}У вас недостаточной прав, чтобы выдать выше 1-го уровня.");
				else if (player_info[playerid][ADMIN] == 6 && level > 4) SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}У вас недостаточной прав, чтобы выдать выше 4-го уровня.");
				else
				{
					new string[100];
					format(string, sizeof(string), "Администратор %s выдал вам административные права %i уровня.", player_info[playerid][NAME], level);
					SCM(id, COLOR_YELLOW, string);
					format(string, sizeof(string), "Вы выдали игроку %s административные права %i уровня.", player_info[id][NAME], level);
					SCM(playerid, COLOR_YELLOW, string);

					static const fmt_query[] = "UPDATE users SET admin = '%i' WHERE name = '%s'";
					new query[sizeof(fmt_query) + (-2 + 4) + (-2 + MAX_PLAYER_NAME)];
 					format(query, sizeof(query), fmt_query, level, player_info[id][NAME]);
 					mysql_tquery(dbHandle, query);
				}
			}
		}
	}

	return 1;
}



CMD:makeadminoff(playerid, params[])
{

	if (player_info[playerid][ADMIN] >= 5)
	{
		extract params -> new string:name[64], string:level[2];
		if (!strlen(name) && !strlen(level)) SCM(playerid, COLOR_GREY, "Используйте /makeadminoff [nickname] [level]");
		else
		{
			static const fmt_query[] = "SELECT * FROM users WHERE name = '%s'";
			new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME)];
			format(query, sizeof(query), fmt_query, name);
			mysql_query(dbHandle, query);

			new rows;
			cache_get_row_count(rows);
			if (!rows) SCM(playerid, COLOR_GREY, "Данного аккаунта не существует.");
			else
			{
				if (!strlen(level)) SCM(playerid, COLOR_GREY, "Введите выдаваемый уровень.");
				else
				{
					if (strval(level) < 1) SCM(playerid, COLOR_GREY, "Уровень должен быть выше 0.");
					else
					{
			   			if (player_info[playerid][ADMIN] == 5 && strval(level) > 1)
			   			{
			   				SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}У вас недостаточной прав, чтобы выдать выше 1-го уровня.");
						}

						else if (player_info[playerid][ADMIN] == 6 && strval(level) > 4)
						{
							SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}У вас недостаточной прав, чтобы выдать выше 4-го уровня.");
						}

						else
						{
							new string[100];
							format(string, sizeof(string), "Вы выдали игроку %s административные права %i уровня.", name, strval(level));
							SCM(playerid, COLOR_YELLOW, string);

							static const fmt_query2[] = "UPDATE users SET admin = '%i' WHERE name = '%s'";
							new query2[sizeof(fmt_query2) + (-2 + 4) + (-2 + MAX_PLAYER_NAME)];
		 					format(query2, sizeof(query2), fmt_query2, strval(level), name);
		 					mysql_tquery(dbHandle, query2);
						}
					}
				}
			}
		}
	}

	return 1;
}



CMD:kick(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 1)
	{
		extract params -> new string:id[3], string:condition[64];
		if (!strlen(id) && !strlen(condition)) SCM(playerid, COLOR_GREY, "Используйте /kick [id] [condition]");
		else
		{
			if (IsPlayerConnected(strval(id)))
			{
				if (!strlen(condition)) SCM(playerid, COLOR_GREY, "Введите причину.");

				else
				{
					new string[100];
					format(string, sizeof(string), "Администратор %s кикнул игрока %s. Причина: %s", player_info[playerid][NAME], player_info[strval(id)][NAME], condition);
                    SCMTA(COLOR_RED2, string);
                    format(string, sizeof(string), "Администратор %s кикнул вас с сервера. Причина: %s", player_info[playerid][NAME], condition);
					SCM(strval(id), COLOR_RED, string);
					Kick(strval(id));
				}
			}
		}
	}
	return 1;
}



CMD:skin(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 2)
	{
		extract params -> new string:id[4], string:skin[4];
		if (!strlen(id) && !strlen(skin)) SCM(playerid, COLOR_GREY, "Используйте /skin [id player] [id skin]");
		else
		{
			if (!strlen(skin))
			{
				if (!(0 <= strval(id) <= 311)) SCM(playerid, COLOR_GREY, "Введите корректный ID скина от 0 до 311.");
				SetPlayerSkin(playerid, strval(id));
				static const fmt_query[] = "UPDATE users SET skin = '%i' WHERE name = '%s'";
				new query[sizeof(fmt_query) + (-2 + 3) + (-2 + MAX_PLAYER_NAME)];
	 			format(query, sizeof(query), fmt_query, strval(id), player_info[playerid][NAME]);
	 			mysql_tquery(dbHandle, query);
			}

			else
			{
				if (!(0 <= strval(skin) <= 311)) SCM(playerid, COLOR_GREY, "Введите корректный ID скина от 0 до 311.");
				else
				{
					new name[MAX_PLAYER_NAME];
					GetPlayerName(strval(id), name, MAX_PLAYER_NAME);
					SetPlayerSkin(strval(id), strval(skin));
					static const fmt_query[] = "UPDATE users SET skin = '%i' WHERE name = '%s'";
					new query[sizeof(fmt_query) + (-2 + 3) + (-2 + MAX_PLAYER_NAME)];
	 				format(query, sizeof(query), fmt_query, strval(skin), name);
	 				mysql_tquery(dbHandle, query);
				}
			}
		}
	}
}



// CDM:makeleader(playerid, params[])
// {
// 	if (player_info[playerid][ADMIN] >= 5)
// 	{
// 		if (sscanf(params, "ii", params[0], params[1]))
// 		{
// 			SCM(playerid, COLOR_GREY, "Используйте /makeleader [id player] [id fraction]");
// 		}

// 		else
// 		{
// 			if ()
// 			{

// 			}

// 			else
// 			{

// 			}
// 		}
// 	}

// 	return 1;
// }


// OnPlayerWeaponShot
// OnPlayerTakeDamage
// OnPlayerGiveDamage



stock Distance(Float: x, Float: y, Float: z, Float: fx, Float:fy, Float: fz)
{
	return floatround(floatsqroot(floatpower(fx - x, 2) + floatpower(fy - y, 2) + floatpower(fz - z, 2)));
}

CMD:pay(playerid, params[])
{
	extract params -> new string:id[4], money;
	if (!strlen(id) && money <= 0) SCM(playerid, COLOR_GREY, "Используйте /pay [id] [money]");
	else
	{
		if (!IsPlayerConnected(strval(id))) SCM(playerid, COLOR_GREY, "Данного игрока нет на сервере.");
		else
		{
			new Float:x, Float:y, Float:z, Float:fx, Float:fy, Float:fz;
			GetPlayerPos(playerid, x, y, z);
			GetPlayerPos(strval(id), fx, fy, fz);

			if (!(1 <= money <= 5000)) SCM(playerid, COLOR_GREY, "Значение не может быть меньше 1 и больше 5000 рублей.");
			else if (playerid == strval(id)) SCM(playerid, COLOR_GREY, "Вы не можете передавать деньги самому себе.");
			else if (Distance(x, y, z, fx, fy, fz) > 4) SCM(playerid, COLOR_GREY, "Вы находитесь слишком далеко от игрока.");
			else
			{
				new string[100];
				format(string, sizeof(string), "Вы передали утроку %s %i рублей", player_info[strval(id)][NAME], money);
				SCM(playerid, COLOR_BLUE, string);
				format(string, sizeof(string), "Игрок %s дал вам %i рублей", player_info[playerid][NAME], money);
				SCM(strval(id), COLOR_BLUE, string);

				GivePlayerMoney(strval(id), money);
				player_info[strval(id)][MONEY] += money;
				static const fmt_query[] = "UPDATE users SET money = '%i' WHERE name = '%s'";
				new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME)];
		 		format(query, sizeof(query), fmt_query, player_info[strval(id)][MONEY], player_info[strval(id)][NAME]);
		 		mysql_tquery(dbHandle, query);
			}
		}
	}

	return 1;
}

CMD:givemoney(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 4)
	{
		extract params -> new string:id[4], money;
		if (!strlen(id) && money <= 0) SCM(playerid, COLOR_GREY, "Используйте /givemoney [id] [money]");
		else
		{
			if (!IsPlayerConnected(strval(id))) SCM(playerid, COLOR_GREY, "Данный игрок не на сервере.");
			else
			{
				if (money == 0) SCM(playerid, COLOR_GREY, "Введите значение.");
				else
				{	
					new string[200];
					if (money < 0)
					{
						format(string, sizeof(string), "Вы забрали у игрока %s %i рублей", player_info[strval(id)][NAME], abs(money));
						SCM(playerid, COLOR_BLUE, string);
						format(string, sizeof(string), "Администратор %s забрал у вас %i рублей", player_info[playerid][NAME], abs(money));
						SCM(strval(id), COLOR_BLUE, string);

						GivePlayerMoney(strval(id), money);
						player_info[strval(id)][MONEY] += money;
						static const fmt_query[] = "UPDATE users SET money = '%i' WHERE name = '%s'";
						new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME) + (-2 + 12)];
		 				format(query, sizeof(query), fmt_query, player_info[strval(id)][MONEY], player_info[strval(id)][NAME]);
		 				mysql_tquery(dbHandle, query);
					}
					
					else
					{
						format(string, sizeof(string), "Вы выдали игроку %s %i рублей", player_info[strval(id)][NAME], money);
						SCM(playerid, COLOR_BLUE, string);
						format(string, sizeof(string), "Администратор %s выдал вам %i рублей", player_info[playerid][NAME], money);
						SCM(strval(id), COLOR_BLUE, string);

						GivePlayerMoney(strval(id), money);
						player_info[strval(id)][MONEY] += money;
						static const fmt_query[] = "UPDATE users SET money = '%i' WHERE name = '%s'";
						new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME) + (-2 + 11)];
		 				format(query, sizeof(query), fmt_query, player_info[strval(id)][MONEY], player_info[strval(id)][NAME]);
		 				mysql_tquery(dbHandle, query);	
					}
				}
			}
		}
	}


	return 1;
}


CMD:setveh(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 2)
	{
		new id;
		if (sscanf(params, "i", id)) SCM(playerid, COLOR_GREY, "Используйте /setveh [id car]");
		else
		{
			if (!(400 <= id <= 611)) SCM(playerid, COLOR_GREY, "Введите корректный ID скина от 400 до 611.");
			else
			{
				new x, y, z;
				GetPlayerPos(playerid, Float:x, Float:y, Float:z);
				CreateVehicle(id, Float:x + 2, Float:y + 2, Float:z, 0, 0, 0, -1);
				// PutPlayerInVehicle(playerid, params[0], 0);
				// CreateVehicle(vehicletype, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay, addsiren=0)
			}
		}
	}

	return 1;
}


CMD:jail(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 2)
	{
		extract params -> new string:id[4], time, string:condition[64];
		if (!strlen(id) && time < 1 && !strlen(condition)) SCM(playerid, COLOR_GREY, "Используйте /jail [id] [time] [condition]");
		else
		{
			if (!IsPlayerConnected(strval(id))) SCM(playerid, COLOR_GREY, "Данного игрока нет на сервере.");
			else if (time < 0) SCM(playerid, COLOR_GREY, "Введите время от 1 минуты.");
			else
			{
			    new string[100];
				format(string, sizeof(string), "Администратор %s посадил игрока %s в деморган на %i минут. Причина: %s", player_info[playerid][NAME], player_info[strval(id)][NAME], time, condition);
				SCMTA(COLOR_RED2, string);
				format(string, sizeof(string), "Администратор %s посадил вас в деморган на %i минут. Причина: %s", player_info[playerid][NAME], time, condition);
				SCM(strval(id), COLOR_RED, string);

				new index = random(12);
				SetPlayerPos(playerid, jail_spawn[index][0], jail_spawn[index][1], jail_spawn[index][2]);
				SetPlayerSkin(playerid, jail_info[playerid][J_SKIN]);

				static const fmt_query[] = "INSERT INTO \
				jaillist (name, administration, `time`, `condition`)\
				VALUES ('%s', '%s', '%i', '%s')";
				new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME) + (-2 + MAX_PLAYER_NAME) + (-2 + 11) + (-2 + 64)];
				format(query, sizeof(query), fmt_query, 
					player_info[playerid][NAME], 
					player_info[strval(id)][NAME], 
					time, 
					condition);
				mysql_tquery(dbHandle, query);
			}
		}
	}

	return 1;
}

CMD:jailoff(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 3)
	{
		extract params -> new string:name[64], time, string:condition[64];
		if (!strlen(name) && time <= 0 && !strlen(condition)) SCM(playerid, COLOR_GREY, "Используйте /jailoff [name] [time] [condition]");
		else
		{
			if (time <= 0) SCM(playerid, COLOR_GREY, "Время должно быть от 1 минуты.");
			else
			{
				if (!strlen(condition)) SCM(playerid, COLOR_GREY, "Введите причину.");
				else
				{
					new string[200];
					format(string, sizeof(string), "Администратор %s посадил оффлайн игрока %s в деморган на %i минут. Причина: %s",
						player_info[playerid][NAME], name, time, condition);
					SCMTA(COLOR_RED2, string);

					static const fmt_query[] = "INSERT INTO \
					jaillist (name, administration, `time`, `condition`)\
					VALUES ('%s', '%s', '%i', '%s')";
					new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME) + (-2 + MAX_PLAYER_NAME) + (-2 + 11) + (-2 + 64)];
					format(query, sizeof(query), fmt_query, 
						name, 
						player_info[playerid][NAME], 
						time, 
						condition);
					mysql_tquery(dbHandle, query);
				}
			}
		}
	}

	return 1;
}

CMD:unjail(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 3)
	{
		extract params -> new string:id[4];
		if (!strlen(id)) SCM(playerid, COLOR_GREY, "Используйте /jailoff [id]");
		else
		{
			if (!IsPlayerConnected(strval(id))) SCM(playerid, COLOR_GREY, "");
			else
			{
				static const fmt_query2[] = "SELECT * FROM jaillist WHERE name = '%s'";
				new query2[sizeof(fmt_query2) + (-2 + MAX_PLAYER_NAME)], rows;
				format(query2, sizeof(query2), fmt_query2, player_info[strval(id)][NAME]);
				mysql_query(dbHandle, query2);

				cache_get_row_count(rows);
				if (!rows) SCM(playerid, COLOR_GREY, "Данный игрок не сидит в деморгане.");
				else
				{
					new string[100];
					format(string, sizeof(string), "Администратор %s выпустил из деморгана %s.",
					player_info[playerid][NAME], player_info[strval(id)][NAME]);
					SCMTA(COLOR_RED2, string);

					new index = random(5);
					SetPlayerSkin(playerid, player_info[playerid][SKIN]);
					SetPlayerPos(playerid, player_spawn[index][0], player_spawn[index][1], player_spawn[index][2]);

					static const fmt_query[] = "DELETE FROM jaillist WHERE name = '%s'";
					new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME)];
					format(query, sizeof(query), fmt_query, player_info[strval(id)][NAME]);
					mysql_tquery(dbHandle, query);
				}
			}
		}
	}

	return 1;
}

CMD:unjailoff(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 3)
	{
		extract params -> new string:name[64];
		if (!strlen(name)) SCM(playerid, COLOR_GREY, "/unjailoff [name]");
		else
		{
			static const fmt_query2[] = "SELECT * FROM jaillist WHERE name = '%s'";
			new query2[sizeof(fmt_query2) + (-2 + MAX_PLAYER_NAME)], rows;
			format(query2, sizeof(query2), fmt_query2, name);
			mysql_query(dbHandle, query2);

			cache_get_row_count(rows);
			if (!rows) SCM(playerid, COLOR_GREY, "Данный игрок не сидит в деморгане.");
			else
			{
				new string[200];
				format(string, sizeof(string), "Администратор %s оффлайн выпустил из деморгана %s.",
				player_info[playerid][NAME], name);
				SCMTA(COLOR_RED2, string);

				static const fmt_query[] = "DELETE FROM jaillist WHERE name = '%s'";
				new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME)];
				format(query, sizeof(query), fmt_query, name);
				mysql_tquery(dbHandle, query);
   			}
		}
	}

	return 1;
}

CMD:goto(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 2)
	{
		if (sscanf(params, "u", params[0])) SCM(playerid, COLOR_GREY, "Используйте /goto [id]");
		else
		{
			if (!IsPlayerConnected(params[0])) SCM(playerid, COLOR_GREY, "Aaiiiai ea?iea iao ia na?aa?a.");
			else
			{
				new x, y, z;
				GetPlayerPos(params[0], Float:x, Float:y, Float:z);
				SetPlayerPos(playerid, Float:x + 1, Float:y + 1, Float:z);

				new string[100], string2[100];
				format(string, sizeof(string), "Вы телепортировались к игроку %s.", player_info[params[0]][NAME]);
				format(string2, sizeof(string2), "К вам телепортировался администратор %s.", player_info[playerid][NAME]);
				SCM(playerid, COLOR_WHITE, string);
				SCM(playerid, COLOR_WHITE, string2);
			}
		}
	}

	return 1;
}



CMD:gethere(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 2)
	{
		if (sscanf(params, "u", params[0])) SCM(playerid, COLOR_GREY, "Используйте /gethere [id]");
		else
		{
			if (!IsPlayerConnected(params[0])) SCM(playerid, COLOR_GREY, "Данного игрока нет на сервере.");
			else
			{
				new x, y, z;
				GetPlayerPos(playerid, Float:x, Float:y, Float:z);
				SetPlayerPos(params[0], Float:x + 1, Float:y + 1, Float:z);

				new string[100], string2[100];
				format(string, sizeof(string), "Вы телепортировали к себе игрока %s.", player_info[params[0]][NAME]);
				format(string2, sizeof(string2), "Вы были телепортированы администратором %s.", player_info[playerid][NAME]);
				SCM(playerid, COLOR_WHITE, string);
				SCM(params[0], COLOR_WHITE, string2);
			}
		}
	}

	return 1;
}



CMD:warn(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 3)
	{
		extract params -> new string:id[4], string:condition[64];
		if (!strlen(id) && !strlen(condition)) SCM(playerid, COLOR_GREY, "Используйте /warn [id] [condition]");
		else
		{
			if (!IsPlayerConnected(strval(id))) SCM(playerid, COLOR_GREY, "Данного игрока нет на сервере.");
			else if (!strlen(condition)) SCM(playerid, COLOR_GREY, "Введите причину.");
			else
			{
				new string[200];
			    warn_info[strval(id)][W_WARN] += 1;
			    if (warn_info[strval(id)][W_WARN] == 3)
			    {
			    	new name[MAX_PLAYER_NAME];
			    	GetPlayerName(strval(id), name, MAX_PLAYER_NAME);
			    	format(string, sizeof(string), "Администратор %s выдал оффлайн предупреждение игроку %s [%i/3]. Причина: %s",
								player_info[playerid][NAME], name, warn_info[strval(id)][W_WARN], condition);
					SCMTA(COLOR_RED2, string);
							
					format(string, sizeof(string), "Аккаунт игрока %s автоматически заблокирован из-за 3-х предупреждений на %i дней. Причина: %s",
						name, 30, condition);
					SCMTA(COLOR_RED2, string);
							
					new data[16], time[16], unban[16], Day, Month, Year, Second, Minute, Hour;
					getdate(Year, Month, Day); gettime(Hour, Minute, Second);
					format(data, sizeof(data), "%02d.%02d.%02d", Day, Month, Year);
					format(time, sizeof(time), "%02d:%02d:%02d", Hour, Minute, Second);
					unban = Data(30, Day, Month, Year);

					static const fmt_query3[] = "INSERT INTO \
					banlist (name, data, administration, `time`, days, `condition`, unban) \
					VALUES ('%s', '%s', '%s', '%s', '%i', '%s', '%s')";

					new query3[sizeof(fmt_query3) + (-2 + 64) + (-2 + 32) + (-2 + 64) + (-2 + 32) + (-2 + 11) + (-2 + 64) + (-2 + 32)];
			 		format(query3, sizeof(query3), fmt_query3,
					  name,
					  data,
					  player_info[playerid][NAME],
					  time,
					  30,
					  condition,
					  unban
					  );
			 		mysql_tquery(dbHandle, query3);
			 				
			 		static const fmt_query2[] = "UPDATE users SET warn = '%i' WHERE name = '%s'";
					new query2[sizeof(fmt_query2) + (-2 + 1) + (-2 + MAX_PLAYER_NAME)];
 					format(query2, sizeof(query2), fmt_query2, 0, name);
 					mysql_tquery(dbHandle, query2);

 					format(string, sizeof(string),
 						"Никнейм администратора: %s\n\
	 					Кол-во дней блокировки: %i\n\
						Причина: %s\n\n\
		 				Дата блокировки: %s\n\
		 				Время: %s\n\
		 				Дата разблокировки: %s",
		 				player_info[playerid][NAME],
		 				30,
		 				condition,
		 				data,
		 				time,
		 				unban);
	 				SPD(strval(id), DLG_BAN, DIALOG_STYLE_MSGBOX, "Блокировка аккаунта", string, "Выход", "");
	 				SCM(strval(id), COLOR_RED, "Используйте \"/q\", чтобы выйти.");

 					Kick(strval(id));
			    }

			    else
			    {

					format(string, sizeof(string), "Администратор %s выдал предупреждение игроку %s [%i/3]. Причина: %s", 
						player_info[playerid][NAME], player_info[strval(id)][NAME], warn_info[strval(id)][W_WARN], condition);
					SCMTA(COLOR_RED2, string);

					format(string, sizeof(string), "Администратор %s выдал вам предупреждение [%i/3]. Причина: %s", 
						player_info[playerid][NAME], warn_info[strval(id)][W_WARN], condition);
					SCM(strval(id), COLOR_RED, string);

					static const fmt_query[] = "UPDATE users SET warn = '%i' WHERE name = '%s'";
					new query[sizeof(fmt_query) + (-2 + 1) + (-2 + MAX_PLAYER_NAME)];
 					format(query, sizeof(query), fmt_query, warn_info[strval(id)][W_WARN], player_info[strval(id)][NAME]);
 					mysql_tquery(dbHandle, query);
	
 					Kick(strval(id));
			    }
			}
		}
	}

	return 1;
}


CMD:warnoff(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 3)
	{
     	extract params -> new string:name[64], string:condition[64];
		if (!strlen(name) && !strlen(condition)) SCM(playerid, COLOR_GREY, "Используйте /warnoff [nick] [condition]");
		else
		{
			if (!strlen(condition)) SCM(playerid, COLOR_GREY, "Введите причину.");
			else
			{
				static const fmt_query[] = "SELECT * FROM users WHERE name = '%s'";
				new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME)];
 				format(query, sizeof(query), fmt_query, name);
 				mysql_query(dbHandle, query);

 				new rows, counter, string[200];
 				cache_get_row_count(rows);
 				if (rows)
 				{
					cache_get_value_int(0, "warn", counter);
					static const fmt_query5[] = "SELECT * FROM banlist WHERE name = '%s'";
					new query5[sizeof(fmt_query5) + (-2 + MAX_PLAYER_NAME)];
 					format(query5, sizeof(query5), fmt_query5, name);
 					mysql_query(dbHandle, query5);

 					cache_get_row_count(rows);
 					if (rows) SCM(playerid, COLOR_GREY, "Данный аккаунт заблокирован.");
 					else
 					{
						if (counter < 3)
						{
							counter += 1;
							if (counter == 3)
							{
								format(string, sizeof(string), "Администратор %s выдал оффлайн предупреждение игроку %s [%i/3]. Причина: %s",
																player_info[playerid][NAME], name, counter, condition);
								SCMTA(COLOR_RED2, string);
								
								format(string, sizeof(string), "Аккаунт игрока %s автоматически заблокирован из-за 3-х предупреждений на %i дней. Причина: %s",
								name, 30, condition);
								SCMTA(COLOR_RED2, string);
								
								new data[16], time[16], unban[16], Day, Month, Year, Second, Minute, Hour;
								getdate(Year, Month, Day); gettime(Hour, Minute, Second);
								format(data, sizeof(data), "%02d.%02d.%02d", Day, Month, Year);
								format(time, sizeof(time), "%02d:%02d:%02d", Hour, Minute, Second);
								unban = Data(30, Day, Month, Year);

								static const fmt_query2[] = "INSERT INTO \
								banlist (name, data, administration, `time`, days, `condition`, unban) \
								VALUES ('%s', '%s', '%s', '%s', '%i', '%s', '%s')";

								new query2[sizeof(fmt_query2) + (-2 + 64) + (-2 + 32) + (-2 + 64) + (-2 + 32) + (-2 + 11) + (-2 + 64) + (-2 + 32)];
				 				format(query2, sizeof(query2), fmt_query2,
								  name,
								  data,
								  player_info[playerid][NAME],
								  time,
								  30,
								  condition,
								  unban
								  );
				 				mysql_tquery(dbHandle, query2);
				 				
				 				static const fmt_query3[] = "UPDATE users SET warn = '%i' WHERE name = '%s'";
								new query3[sizeof(fmt_query3) + (-2 + 1) + (-2 + MAX_PLAYER_NAME)];
	 							format(query3, sizeof(query3), fmt_query3, 0, name);
	 							mysql_tquery(dbHandle, query3);
							}
							
							else
							{
								format(string, sizeof(string), "Администратор %s выдал оффлайн предупреждение игроку %s [%i/3]. Причина: %s",
																player_info[playerid][NAME], name, counter, condition);
								SCMTA(COLOR_RED2, string);
								static const fmt_query4[] = "UPDATE users SET warn = '%i' WHERE name = '%s'";
								new query4[sizeof(fmt_query4) + (-2 + 1) + (-2 + MAX_PLAYER_NAME)];
	 							format(query4, sizeof(query4), fmt_query4, counter, name);
	 							mysql_tquery(dbHandle, query4);
							}
						}
					}
 				}

 				else SCM(playerid, COLOR_RED, "Данного игрока не существует.");
			}
		}
	}

	return 1;
}


CMD:unwarn(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 3)
	{
		extract params -> new string:id[4];
		if (!strlen(id)) SCM(playerid, COLOR_GREY, "Используйте /unwarn [id]");
		else
		{
			static const fmt_query[] = "SELECT * FROM users WHERE name = '%s'";
			new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME)];
 			format(query, sizeof(query), fmt_query, player_info[strval(id)][NAME]);
 			mysql_query(dbHandle, query);

 			new rows, counter;
 			cache_get_row_count(rows);
 			if (rows)
 			{
				cache_get_value_int(0, "warn", counter);
				if (counter == 0) SCM(playerid, COLOR_GREY, "У данного аккаунта больше нет предупреждений.");
				else
				{
					counter -= 1;
					new string[200];
					format(string, sizeof(string), "Администратор %s снял предупреждение игроку %s [%i/3].",
												player_info[playerid][NAME], player_info[strval(id)][NAME], counter);
					SCMTA(COLOR_RED2, string);

					static const fmt_query2[] = "UPDATE users SET warn = '%i' WHERE name = '%s'";
					new query2[sizeof(fmt_query2) + (-2 + 1) + (-2 + MAX_PLAYER_NAME)];
	 				format(query2, sizeof(query2), fmt_query2, counter, player_info[strval(id)][NAME]);
	 				mysql_tquery(dbHandle, query2);
	 			}
 			}

 			else SCM(playerid, COLOR_RED, "Данного игрока не существует.");
		}
	}

	return 1;
}


CMD:unwarnoff(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 3)
	{
		extract params -> new string:name[64];
		if (!strlen(name)) SCM(playerid, COLOR_GREY, "Используйте /unwarnoff [name]");
		else
		{
			static const fmt_query[] = "SELECT * FROM users WHERE name = '%s'";
			new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME)];
 			format(query, sizeof(query), fmt_query, name);
 			mysql_query(dbHandle, query);

 			new rows, counter;
 			cache_get_row_count(rows);
 			if (rows)
 			{
				cache_get_value_int(0, "warn", counter);
				if (counter == 0) SCM(playerid, COLOR_GREY, "У данного аккаунта больше нет предупреждений.");
				else
				{
					counter -= 1;
					new string[200];
					format(string, sizeof(string), "Администратор %s оффлайн снял предупреждение игроку %s [%i/3].",
												player_info[playerid][NAME], name, counter);
					SCMTA(COLOR_RED2, string);

					static const fmt_query2[] = "UPDATE users SET warn = '%i' WHERE name = '%s'";
					new query2[sizeof(fmt_query2) + (-2 + 1) + (-2 + MAX_PLAYER_NAME)];
	 				format(query2, sizeof(query2), fmt_query2, counter, name);
	 				mysql_tquery(dbHandle, query2);
	 			}
 			}

 			else SCM(playerid, COLOR_RED, "Данного игрока не существует.");
		}
	}

	return 1;
}




CMD:hp(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 2)
	{
		extract params -> new string:id[4];

		if (!strlen(id))
		{
			SetPlayerHealth(playerid, 100.0);
			SCM(playerid, COLOR_WHITE, "Вы выдали себе здоровье.");
		}

		else
		{
			new name[MAX_PLAYER_NAME], string[100];
			GetPlayerName(strval(id), name, MAX_PLAYER_NAME);

			static const fmt_query[] = "UPDATE users SET health = '%.2f' WHERE name = '%s'";
			new query[sizeof(fmt_query) + (-2 + 3) + (-2 + MAX_PLAYER_NAME)];
		 	format(query, sizeof(query), fmt_query, 100.0, name);
		 	mysql_tquery(dbHandle, query);

			format(string, sizeof(string), "Вы выдали здоровье игроку %s.", name);
			SCM(strval(id), COLOR_WHITE, "Администратор пополнил вам здоровье.");
			SCM(playerid, COLOR_WHITE, string);
			SetPlayerHealth(strval(id), 100.0);
		}
	}

	return 1;
}



CMD:armour(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 2)
	{
		extract params -> new string:id[4];

		if (!strlen(id))
		{
			SetPlayerArmour(playerid, 100.0);
			SCM(playerid, COLOR_WHITE, "Вы выдали себе броню.");
		}

		else
		{
			new name[MAX_PLAYER_NAME], string[100];
			GetPlayerName(strval(id), name, MAX_PLAYER_NAME);
			format(string, sizeof(string), "Вы выдали броню %s.", name);
			SCM(strval(id), COLOR_WHITE, "Администратор выдал вам бронежелет.");
			SCM(playerid, COLOR_WHITE, string);
			SetPlayerArmour(strval(id), 100.0);
		}
	}
	
	return 1;
}



CMD:slap(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 1)
	{
		if (sscanf(params, "u", params[0])) SCM(playerid, COLOR_GREY, "Используйте /slap [id]");
		else
		{
			if (!IsPlayerConnected(playerid)) SCM(playerid, COLOR_GREY, "Данного игрока нет на сервере.");
			else
			{
				new x, y, z;
				GetPlayerPos(params[0], Float:x, Float:y, Float:z);
				SetPlayerPos(params[0], Float:x, Float:y, Float:z + 3);
				SCM(params[0], COLOR_WHITE, "Администратор подкинул вас.");
			}
		}
	}
	
	return 1;
}



CMD:clear(playerid, params[])
{
	for (new i = 0; i < 40; ++ i) SCM(playerid, COLOR_WHITE, "");
	SCM(playerid, COLOR_YELLOW, "Вы очистили себе чат.");
	return 1;
}


CMD:eject(playerid, params[])
{
	if (!IsPlayerInAnyVehicle(playerid)) SCM(playerid, COLOR_GREY, "Вы не находитесь в транспортном средстве.");
	else
	{
		if (GetPlayerVehicleSeat(playerid) != 0) SCM(playerid, COLOR_GREY, "Вы седите не на месте водителя.");
		else
		{
			extract params -> new string:id[4];
			if (!strlen(id)) SCM(playerid, COLOR_GREY, "Используйте /eject [id]");
			else
			{
				if (!IsPlayerConnected(strval(id))) SCM(playerid, COLOR_GREY, "Данного игрока нет на сервере.");
				else
				{
					if (!IsPlayerInAnyVehicle(strval(id))) SCM(playerid, COLOR_GREY, "Данный игрок не в вашем транспорте.");
					else
					{
						new name[MAX_PLAYER_NAME], _name[MAX_PLAYER_NAME], string[100];
						GetPlayerName(playerid, name, MAX_PLAYER_NAME);
						GetPlayerName(strval(id), _name, MAX_PLAYER_NAME);
						format(string, sizeof(string), "Вы выкинули из транспортного средства %s.", _name);
						SCM(playerid, COLOR_BLUE, string);
						format(string, sizeof(string), "%s выкинул вас из транспортного средства.", name);
						SCM(strval(id), COLOR_BLUE, string);
						RemovePlayerFromVehicle(strval(id));
					}
				}
			}
		}
	}

	return 1;
}



CMD:menu(playerid)
{
	SPD(playerid, DLG_MENU, DIALOG_STYLE_LIST,
		"Меню",
		"1. Статистика",
		"Выбрать",
		"Выход");


	return 1;
}
alias:menu("mn");


CMD:stat(playerid, response)
{
	new name[MAX_PLAYER_NAME], rows;
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	static const fmt_query[] = "SELECT * FROM users WHERE name = '%s'";
	new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME)];
	format(query, sizeof(query), fmt_query, name);
	mysql_query(dbHandle, query);
	
	cache_get_row_count(rows);
	if (rows)
	{
		cache_get_value_name_int(0, "age", player_info[playerid][AGE]);
		cache_get_value_name_int(0, "exp", player_info[playerid][EXP]);
		cache_get_value_name_int(0, "sex", player_info[playerid][SEX]);
		cache_get_value_name_int(0, "money", player_info[playerid][MONEY]);
		cache_get_value_name_int(0, "warn", warn_info[playerid][W_WARN]);
	}
	
	new string[1000];
	format(string, sizeof(string),
		"Никнейм: %s\n\
		Возраст: %i\n\
		Опыт: %i\n\
		Пол: %s\n\
		Деньги: %i\n\n\
		--------------Наказание--------------\n\
		Предупреждение: %i из 3",
		player_info[playerid][NAME],
		player_info[playerid][AGE],
		player_info[playerid][EXP],
		(player_info[playerid][SEX] == 1) ? ("Мужской") : ("Женский"),
		player_info[playerid][MONEY],
		warn_info[playerid][W_WARN]);
		
	SPD(playerid, DLG_STAT2, DIALOG_STYLE_MSGBOX, "Статистика", string, "Выход", "");
}



stock Data(days, Day, Month, Year)
{
	new _data[16];
	if (31 <= (Day + days) < 60)
	{
		if ((Month + 1) > 12) format(_data, sizeof(_data), "%02d.%02d.%02d", (Day + days) - 30, 1, Year + 1);
		else format(_data, sizeof(_data), "%02d.%02d.%02d", (Day + days) - 30, Month + 1, Year);
	}
	
	else if (60 <= (Day + days) < 90)
	{
		if ((Month + 2) > 12) format(_data, sizeof(_data), "%02d.%02d.%02d", (Day + days) - 30*2, 1, Year + 1);
		else format(_data, sizeof(_data), "%02d.%02d.%02d", (Day + days) - 30*2, Month + 2, Year);
	}

	else if (90 <= (Day + days) < 120)
	{
		if ((Month + 3) > 12) format(_data, sizeof(_data), "%02d.%02d.%02d", (Day + days) - 30*3, 1, Year + 1);
		else format(_data, sizeof(_data), "%02d.%02d.%02d", (Day + days) - 30*3, Month + 3, Year);
	}

	else if (120 <= (Day + days) < 150)
	{
		if ((Month + 4) > 12) format(_data, sizeof(_data), "%02d.%02d.%02d", (Day + days) - 30*4, 1, Year + 1);
		else format(_data, sizeof(_data), "%02d.%02d.%02d", (Day + days) - 30*4, Month + 4, Year);
	}

	else if (150 <= (Day + days) < 180)
	{
		if ((Month + 5) > 12) format(_data, sizeof(_data), "%02d.%02d.%02d", (Day + days) - 30*5, 1, Year + 1);
		else format(_data, sizeof(_data), "%02d.%02d.%02d", (Day + days) - 30*5, Month + 5, Year);
	}

	else if (180 <= (Day + days) < 210)
	{
		if ((Month + 6) > 12) format(_data, sizeof(_data), "%02d.%02d.%02d", (Day + days) - 30*6, 1, Year + 1);
		else format(_data, sizeof(_data), "%02d.%02d.%02d", (Day + days) - 30*6, Month + 6, Year);
	}
	else format(_data, sizeof(_data), "%02d.%02d.%02d", Day + days, Month, Year);

	return _data;
}


CMD:ban(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 3)
	{
		extract params -> new string:id[4], days, string:condition[100];
		if (!strlen(id) && days < 1 && !strlen(condition)) SCM(playerid, COLOR_GREY, "Используйте /ban [id] [days] [condition]");
		else
		{
			if (!IsPlayerConnected(strval(id))) SCM(playerid, COLOR_GREY, "Данного игрока нет на сервере.");
			else
			{
				if (days < 1) SCM(playerid, COLOR_GREY, "Блокировка должна быть от 1 дня.");
				else
				{
					if (!strlen(condition)) SCM(playerid, COLOR_GREY, "Введите причину.");
					else
					{
						new string[200], name[MAX_PLAYER_NAME];
						GetPlayerName(strval(id), name, MAX_PLAYER_NAME);
						format(string, sizeof(string), "Администратор %s заблокировал игрока %s на %i дней. Причина: %s",
						player_info[playerid][NAME], name, days, condition);
						SCMTA(COLOR_RED2, string);
						
						format(string, sizeof(string), "Администратор %s заблокировал вас на %i дней. Причина: %s",
						player_info[playerid][NAME], days, condition);
						SCM(strval(id), COLOR_RED, string);

						new data[64], Day, Month, Year, Second, Minute, Hour, time[64], unban[16];
						getdate(Year, Month, Day); gettime(Hour, Minute, Second);
						format(data, sizeof(data), "%02d.%02d.%02d", Day, Month, Year);
						format(time, sizeof(time), "%02d:%02d:%02d", Hour, Minute, Second);
						unban  = Data(days, Day, Month, Year);

						static const fmt_query[] = "INSERT INTO \
						banlist (name, data, administration, `time`, days, `condition`, unban)\
						VALUES ('%s', '%s', '%s', '%s', '%d', '%s', '%s')";

						new query[sizeof(fmt_query) + (-2 + 64) + (-2 + 32) + (-2 + 64) + (-2 + 32) + (-2 + 11) + (-2 + 64) + (-2 + 32)];
		 				format(query, sizeof(query), fmt_query,
						  name,
						  data,
						  player_info[playerid][NAME],
						  time,
						  days,
						  condition,
						  unban
						  );
		 				mysql_tquery(dbHandle, query);
		 				
	 					format(string, sizeof(string),
		 					"Никнейм администратора: %s\n\
		 					Кол-во дней блокировки: %i\n\
						 	Причина: %s\n\n\
		 					Дата блокировки: %s\n\
		 					Время: %s\n\
		 					Дата разблокировки: %s",
		 					player_info[playerid][NAME],
		 					days,
		 					condition,
		 					data,
		 					time,
		 					unban);
	 					SPD(strval(id), DLG_BAN, DIALOG_STYLE_MSGBOX, "Блокировка аккаунта", string, "Выход", "");
	 					SCM(strval(id), COLOR_RED, "Используйте \"/q\", чтобы выйти.");
	 					Kick(strval(id));
					}
				}
			}
		}
	}

	return 1;
}



CMD:offban(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 4)
	{
		extract params -> new string:name[64], days, string:condition[100];
		if (!strlen(name) && days < 1 && !strlen(condition)) SCM(playerid, COLOR_GREY, "Используйте /offban [nickname] [days] [condition]");
		else
		{
		    static const fmt_query[] = "SELECT * FROM users WHERE name = '%s'";
			new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME)];
 			format(query, sizeof(query), fmt_query, name);
 			mysql_query(dbHandle, query);

 			new rows;
 			cache_get_row_count(rows);
 			if (!rows) SCM(playerid, COLOR_RED, "Данного игрока не существует.");
 			else
 			{
 				static const fmt_query2[] = "SELECT * FROM banlist WHERE name = '%s'";
				new query2[sizeof(fmt_query2) + (-2 + MAX_PLAYER_NAME)];
 				format(query2, sizeof(query2), fmt_query2, name);
 				mysql_query(dbHandle, query2);

 				cache_get_row_count(rows);
 				if (rows) SCM(playerid, COLOR_GREY, "Данный аккаунт заблокирован.");
 				else
 				{
	 				if (days < 1) SCM(playerid, COLOR_GREY, "Блокировка должна быть от 1 дня.");
	 				else
	 				{
	 					if (!strlen(condition)) SCM(playerid, COLOR_GREY, "Введите причину.");
	 					else
	 					{
	 						new string[200];
							format(string, sizeof(string), "Администратор %s оффлайн заблокировал игрока %s на %i дней. Причина: %s",
							player_info[playerid][NAME], name, days, condition);
							SCMTA(COLOR_RED2, string);
							

							new data[64], Day, Month, Year, Second, Minute, Hour, time[64], unban[16];
							getdate(Year, Month, Day); gettime(Hour, Minute, Second);
							format(data, sizeof(data), "%02d.%02d.%02d", Day, Month, Year);
							format(time, sizeof(time), "%02d:%02d:%02d", Hour, Minute, Second);
							unban  = Data(days, Day, Month, Year);

							static const fmt_query3[] = "INSERT INTO \
							banlist (name, data, administration, `time`, days, `condition`, unban)\
							VALUES ('%s', '%s', '%s', '%s', '%i', '%s', '%s')";

							new query3[sizeof(fmt_query3) + (-2 + 64) + (-2 + 32) + (-2 + 64) + (-2 + 32) + (-2 + 11) + (-2 + 64) + (-2 + 32)];
			 				format(query3, sizeof(query3), fmt_query3,
							  name,
							  data,
							  player_info[playerid][NAME],
							  time,
							  days,
							  condition,
							  unban
							  );
			 				mysql_tquery(dbHandle, query3);
	 					}
	 				}
	 			}
 			}
		}
	}

	return 1;
}


CMD:unban(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 5)
	{
		extract params -> new string:name[64];
		if (!strlen(name)) SCM(playerid, COLOR_GREY, "Используйте /unban [nick]");
		else
		{
			static const fmt_query[] = "SELECT * FROM banlist WHERE name = '%s'";
			new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME)];
 			format(query, sizeof(query), fmt_query, name);
 			mysql_query(dbHandle, query);
	
	 		new rows;
	 		cache_get_row_count(rows);
 			if (!rows) SCM(playerid, COLOR_RED, "Данный игровой аккаунт не заблокирован.");
 			else
 			{
 				static const fmt_query2[] = "DELETE FROM banlist WHERE name = '%s'";
				new query2[sizeof(fmt_query2) + (-2 + MAX_PLAYER_NAME)];
 				format(query2, sizeof(query2), fmt_query2, name);
 				mysql_tquery(dbHandle, query2);

 				new string[100];
 				format(string, sizeof(string), "Администратор %s разблокировал аккаунт игрока %s.", player_info[playerid][NAME], name);
 				SCMTA(COLOR_RED2, string);	
 			}
 		}		
	}

	return 1;
}


CMD:ahelp(playerid)
{
	if (player_info[playerid][ADMIN] >= 1)
	{
		SCM(playerid, COLOR_YELLOW2,
			"1 уровень: /kick, /sp, /a, /slap");
		SCM(playerid, COLOR_YELLOW2,
			"2 уровень: /skin, /jail, /setveh, /hp, /armour, /goto, /gethere");
		SCM(playerid, COLOR_YELLOW2, 
			"3 уровень: /ban, /warn");
		SCM(playerid, COLOR_YELLOW2, 
			"4 уровень: /offban, /warnoff, /unban, /unwarn, /givemoney");
		SCM(playerid, COLOR_YELLOW2, 
			"5 уровень: /makeadmin, /makeadminoff, /makeleader");
	}
	
	return 1;
}


// CMD:spectation(playerid, params[])
// {
// 	if (player_info[playerid][ADMIN] >= 1)
// 	{
		
// 	}

// 	return 1;
// }
// alias:spectation("sp");



CMD:a(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 1)
	{
		extract params -> new string:text[200];
		if (!strlen(text)) SCM(playerid, COLOR_GREY, "Используйте  /a [text]");
		else
		{
			format(text, sizeof(text), "[%c] %s[%i]: %s",
				player_info[playerid][ADMIN] == 1 ? 'S' : 'A',
				player_info[playerid][NAME],
				player_info[playerid][ID],
				text);

			for (new id = GetPlayerPoolSize(); id != -1; id --)
			{
				if (!IsPlayerConnected(id)) continue;
				else
				{
					if (player_info[id][ADMIN] >= 1) SCM(id, COLOR_YELLOW2, text);
				}
			}
		}
	}

	return 1;
}
