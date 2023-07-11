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


enum player
{
	ID,
	NAME[MAX_PLAYER_NAME],
	PASSWORD[64],
	SALT[11],
	EMAIL[86],
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
};
new player_info[MAX_PLAYERS][player];

enum dialog
{
	DLG_LOG,
	DLG_REG,
	DLG_MAIL,
	DLG_REF,
};




new MySQL:dbHandle;





main()
{
	print("\n----------------------------------");
	print("\tMOD WORK...");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	ConnectToMySQL();
	return 1;
}

stock ConnectToMySQL()
{
	dbHandle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_BASE);
	switch (mysql_errno())
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

	static const frm_query[] = "SELECT password FROM users WHERE name = '%s'";
	new query[sizeof(frm_query) + MAX_PLAYER_NAME];
	format(query, sizeof(query), frm_query, player_info[playerid][NAME]);
	mysql_tquery(dbHandle, frm_query, "CheckRegistration", "i", playerid);

	return 1;
}

forward CheckRegistration(playerid);
public CheckRegistration(playerid)
{
	new rows;
	cache_get_row_count(rows);

	if (rows) ShowLogin(playerid);
	else ShowRegistration(playerid);

	return 1;
}

stock ShowLogin(playerid)
{
	new string[300];
	format(string, sizeof(string),
		"{FFFFFF}Вход{0089ff} %s{FFFFFF}. Рады приветствовать вас снова на нашем сервере!\n\n\
		Введи пароль в поле ниже.",
		player_info[playerid][NAME]
	 );

	SPD(
		playerid,
		DLG_LOG,
		DIALOG_STYLE_INPUT,
		"Авторизация ••• Ввод пароля •••",
		string,
		"Далее",
		"Выход"
		);
}


stock ShowRegistration(playerid)
{
	new string[400];
	format(string, sizeof(string),
		"{FFFFFF}Рады приветствовать вас, {ffd310}%s{FFFFFF}, на нашем сервере Angelskiy.\n\
		Для того, чтобы начать игру на сервере, вам необходимо придумать пароль.\n\n\
		{033fdd}Примечание:{FFFFFF}\n\
		\t{ff0000}• {FFFFFF}Пароль должен содержать от 8 до 64 символов.\n\
		\t{ff0000}• {FFFFFF}Пароль может содержать цифры и латинские символы.",
		player_info[playerid][NAME]);

	SPD(
		playerid,
		DLG_REG,
		DIALOG_STYLE_INPUT,
		"Регистрация ••• Ввод пароля •••",
		string,
		"Далее",
		"Выход"
		);
}


public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
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
	return 1;
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

		}

		case DLG_REG:
		{
			if (response)
			{
				if (!strlen(inputtext))
				{
					ShowRegistration(playerid);
					return SendClientMessage(playerid, COLOR_RED, "[ОШИБКА]{FFFFFF} Введите пароль в выделенном вам поле.");
				}

				if (!(8 <= strlen(inputtext) <= 64))
				{
					ShowRegistration(playerid);
					return SendClientMessage(playerid, COLOR_RED, "[ОШИБКА]{FFFFFF} Пароль должен содержать от 8 до 64 символом.");
				}

				new regex:rg_password = regex_new("^[a-zA-Z0-9.-_,]{1,64}$");
				if (regex_check(inputtext, rg_password))
				{
					new salt[11];
					for (new i; i < 10; ++ i) salt[i] = random(79) + 47;
					salt[10] = 0;
					SHA256_PassHash(inputtext, salt, player_info[playerid][PASSWORD], 64);
					strmid(player_info[playerid][SALT], salt, 0, 11, 11);
					strmid(inputtext, player_info[playerid][PASSWORD], 0, strlen(inputtext), 64);

					ShowPlayerDialog(
						playerid,
						DLG_MAIL,
						DIALOG_STYLE_INPUT,
						"Регистрация ••• Ввод email ••• ",
						"{FFFFFF}Введите Email для того, чтобы вы могли восстановить свой пароль при его утере.\n\n\
						{033fdd}Примечание{FFFFFF}\n\
						\t{ff0000}• {FFFFFF}Если сейчас у вас нет почты, то вы можете ее создать и в настройках ввести ее.",
						"Далее",
						"Пропустить"
						);
				}

				else
				{
				    ShowRegistration(playerid);
				    return SCM(playerid, COLOR_RED, "[Ошибка]{FFFFFF} Пароль может содержать только цифры и латинские символы.");
				}
				regex_delete(rg_password);
			}

			else
			{
				SCM(playerid, COLOR_RED, "Используйте /q, чтобы выйти.");
				SPD(playerid, -1, 0, "", "", "", "");
				return Kick(playerid);
			}
		}

		case DLG_MAIL:
		{
			if (response)
			{
				if (!strlen(inputtext))
				{
					ShowPlayerDialog(
						playerid,
						DLG_MAIL,
						DIALOG_STYLE_INPUT,
						"Регистрация ••• Ввод email ••• ",
						"{FFFFFF}Введите Email для того, чтобы вы могли восстановить свой пароль при его утере.\n\n\
						{033fdd}Примечание{FFFFFF}\n\
						\t{ff0000}• {FFFFFF}Если сейчас у вас нет почты, то вы можете ее создать и в настройках ввести ее.",
						"Далее",
						"Пропустить"
						);
					return SendClientMessage(playerid, COLOR_RED, "[Ошибка]{FFFFFF} Введите email в выделенном вам поле.");
				}

				new regex:rg_mail = regex_new("^[a-zA-Z0-9.-_]{1,}@[a-zA-Z]{1,}.[a-zA-Z]{1,5}$");
				if (regex_check(inputtext, rg_mail))
				{
					strmid(player_info[playerid][EMAIL], inputtext, 0, strlen(inputtext), 86);
					ShowPlayerDialog(
						playerid,
						DLG_REF,
						DIALOG_STYLE_INPUT,
						"Регистрация ••• Реферальная система •••",
						"{FFFFFF} Введите никнейм пригласившего вас игрока на сервер.\n\n\
						{033fdd}Примечание{FFFFFF}\n\
						\t{ff0000}• {FFFFFF} Никнейм должен иметь вид - Egor_Egorov.",
						"Далее",
						"Пропустить"
						);
				}

				else
				{
					ShowPlayerDialog(
						playerid,
						DLG_MAIL,
						DIALOG_STYLE_INPUT,
						"Регистрация ••• Ввод email ••• ",
						"{FFFFFF}Введите Email для того, чтобы вы могли восстановить свой пароль при его утере.\n\n\
						{033fdd}Примечание{FFFFFF}\n\
						\t{ff0000}• {FFFFFF}Если сейчас у вас нет почты, то вы можете ее создать и в настройках ввести ее.",
						"Далее",
						"Пропустить"
						);
					return SendClientMessage(playerid, COLOR_RED, "[ОШИБКА]{FFFFFF} Введите корректный email адрес.");
				}

				regex_delete(rg_mail);
			}

			else
			{
				ShowPlayerDialog(
					playerid,
					DLG_REF,
					DIALOG_STYLE_INPUT,
					"Регистрация ••• Реферальная система •••",
					"{FFFFFF} Введите никнейм пригласившего вас игрока на сервер.\n\n\
					{033fdd}Примечание{FFFFFF}\n\
					\t{ff0000}• {FFFFFF} Никнейм должен иметь вид - Egor_Egorov.",
					"Далее",
					"Пропустить"
					);
			}
		}
	}


	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
