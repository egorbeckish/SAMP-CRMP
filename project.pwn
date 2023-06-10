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


new MySQL:dbHandle;



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
	PASSWORD[32],
	EMAIL[64],
	REF,
};
new player_info[MAX_PLAYERS][player];

enum dialogs
{
	DLG_NONE,
	DLG_REG,
	DLG_REGEMAIL,
	DLG_LOG,
	DLG_REGREF,
};

public OnGameModeInit()
{
	ConnectMySQL();
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
    mysql_set_charset("utf-8");
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
    static const fmt_query[] = "SELECT id FROM users WHERE name = '%s'";
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
	if(rows) ShowLogin(playerid);
	else ShowRegistration(playerid);
}

stock ShowLogin(playerid)
{
	SCM(playerid, COLOR_WHITE, "Данный аккаунт зарегистрирован");
}

stock ShowRegistration(playerid)
{
 	new dialog[300 + (-2 + MAX_PLAYER_NAME)];
	format(dialog, sizeof(dialog),
	    "{FFFFFF}Регистрация{0089ff} %s{FFFFFF}. Рады приветствовать вас на нашем сервере\n\
	    Аккаунт с данным никнеймом не зарегистррован\n\n\
		Придумайте надежны пароль для ваше аккаунта и нажмите \"Далее\"\n\n\
  		{0089ff}Примечание:{FFFFFF}\n\
		\t• Пароль должен быть от 8 до 32 символов\n\
		\t• Пароль должен содержать только цифры и латинские буквы",
		player_info[playerid][NAME]
	 );
	SPD(playerid, DLG_REG, DIALOG_STYLE_INPUT, "{ffd100}Регистрация{FFFFFF} • Ввод пароля", dialog, "Далее", "Выход");

	//SCM(playerid, COLOR_WHITE, "Данный аккаунт не зарегистрирован");
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
	    case DLG_REG:
	    {
	        if (response)
	        {
	            if (!strlen(inputtext))
	            {
	                ShowRegistration(playerid);
	                return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Введите пароль в поле ниже и нажмите \"Далее\"");
				}

				if (strlen(inputtext) < 8 || strlen(inputtext) > 32)
				{
				    ShowRegistration(playerid);
	                return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Длина пароля должна быть от 8 до 32 символов");
				}

    			new regex:rg_passwordcheck = regex_new("^[a-zA-Z0-9]{1,}$");
				if (regex_check(inputtext, rg_passwordcheck))
				{
					strmid(player_info[playerid][PASSWORD], inputtext, 0, strlen(inputtext), 32);
					SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT,
						"{ffd100}Регистрация{FFFFFF} Ввод Email",
						"При утере пароля от аккаунта, вы сможите восстановить его через Email\n\
						Введите email в поле ниже и нажмите \"Далее\"",
						"Далее",
						"");
				}

				else
				{
				    ShowRegistration(playerid);
				    return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Пароль должен содержать только латинские символы и цифры");
				}
				regex_delete(rg_passwordcheck);
			}

			else
			{
				SCM(playerid, COLOR_RED, "Введите \"/q\", чтобы выйти");
				SPD(playerid, -1, 0, " ", " ", " ", " ");
				return Kick(playerid);
			}
		}

		case DLG_REGEMAIL:
		{

			if (!strlen(inputtext))
			{
			    SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT,
					"{ffd100}Регистрация{FFFFFF} Ввод • Email",
					"При утере пароля от аккаунта, вы сможите восстановить его через Email\n\
					Введите email в поле ниже и нажмите \"Далее\"",
					"Далее",
					"");
                return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Введите email в поле ниже и нажмите \"Далее\"");
			}

			new regex:rg_emailcheck = regex_new("^[a-zA-Z0-9.-_]{1,43}@[a-zA-Z]{1,8}.[a-zA-Z]$");
			if (regex_check(inputtext, rg_emailcheck))
			{
			    strmid(player_info[playerid][EMAIL], inputtext, 0, strlen(inputtext), 64);
			    SPD(playerid, DLG_REGREF, DIALOG_STYLE_INPUT,
					"{ffd100}Регистрация{FFFFFF} Ввод • Реферальная система",
					"Используйте никнейм, который вас приграсил на сервер\n\
					Введите никнейм в поле ниже и нажмите",
					"Далее",
					"Пропустить");
			}

			else
			{
			    SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT,
					"{ffd100}Регистрация{FFFFFF} Ввод • Email",
					"При утере пароля от аккаунта, вы сможите восстановить его через Email\n\
					Введите email в поле ниже и нажмите \"Далее\"",
					"Далее",
					"");
				return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Введите email корректно");
			}
			regex_delete(rg_emailcheck);
		}

		case DLG_REGREF:
		{
			if (response)
			{
				if (!strlen(inputtext))
				{
					SPD(playerid, DLG_REGREF, DIALOG_STYLE_INPUT,
						"{ffd100}Регистрация{FFFFFF} Ввод • Реферальная система",
						"Используйте никнейм, который вас приграсил на сервер\n\
						Введите никнейм в поле ниже и нажмите",
						"Далее",
						"Пропустить");
					return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Данного никнейма не существует, либо введите его корректно");
				}

				new regex:rg_referalcheck = regex_new("^[a-zA-Z]_[a-zA-Z]$");
				if (regex_check(inputtext, rg_referalcheck))
				{
					static const fmt_query[] = "SELECT * FROM users WHERE name = '%s'";
					new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME)];
 					format(query, sizeof(query), fmt_query, inputtext);
 					mysql_tquery(dbHandle, query, "CheckReferal", "i", playerid, inputtext);
				}

				else
				{
				    SPD(playerid, DLG_REGREF, DIALOG_STYLE_INPUT,
						"{ffd100}Регистрация{FFFFFF} Ввод • Реферальная система",
						"Используйте никнейм, который вас приграсил на сервер\n\
						Введите никнейм в поле ниже и нажмите",
						"Далее",
						"Пропустить");
					return SCM(playerid, COLOR_RED, "[ОШИБКА] {FFFFFF}Данного никнейма не существует, либо введите его корректно");

				}

				regex_delete(rg_referalcheck);
			}

			else
			{

			}
		}
	}

	return 1;
}



public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
