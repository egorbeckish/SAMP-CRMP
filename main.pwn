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
	string:NAME[MAX_PLAYER_NAME],
	string:PASSWORD[64],
	string:SALT[11],
	string:EMAIL[86],
	REF,
	SEX,
	AGE,
	SKIN,
	string:REG_DATA[13],
	string:REG_IP[16],
	string:REG_COUNTRY[30],
	string:REG_CITY[50],
	string:REG_PROVIDER[50],
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
	DLG_SEX,
	DLG_SKIN,
	DLG_CLICK,
	DLG_INFO_PLAYER,
};




new MySQL:dbHandle;
new skinmale[] = {78, 79, 134, 135, 137, 160, 212, 230};
new skinfemale[] = {13, 41, 56, 65, 190, 192, 193, 195};


new Float:base_spawn[][] = {
	{1805.2761,2507.8167,15.8725, 307.0000},
	{-2459.3999,2840.5247,38.4074, 90.0000}
};


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
	mysql_tquery(dbHandle,  query, "CheckRegistration", "i", playerid);

	return 1;
}

forward CheckRegistration(playerid);
public CheckRegistration(playerid)
{
	new rows;
	cache_get_row_count(rows);

	if (rows) ShowLogin(playerid);
	else ShowRegistration(playerid);

	SetPVarInt(playerid, "CheckPassword", 4);

	return 1;
}

stock ShowLogin(playerid)
{
	new string[300];
	format(string, sizeof(string),
		"{FFFFFF}Âõîä{0089ff} %s{FFFFFF}. Ðàäû ïðèâåòñòâîâàòü âàñ ñíîâà íà íàøåì ñåðâåðå!\n\n\
		Ââåäè ïàðîëü â ïîëå íèæå.",
		player_info[playerid][NAME]
	 );

	SPD(
		playerid,
		DLG_LOG,
		DIALOG_STYLE_INPUT,
		"Àâòîðèçàöèÿ ••• Ââîä ïàðîëÿ •••",
		string,
		"Äàëåå",
		"Âûõîä"
		);
}


stock ShowRegistration(playerid)
{
	new string[400];
	format(string, sizeof(string),
		"{FFFFFF}Ðàäû ïðèâåòñòâîâàòü âàñ, {ffd310}%s{FFFFFF}, íà íàøåì ñåðâåðå Angelskiy.\n\
		Äëÿ òîãî, ÷òîáû íà÷àòü èãðó íà ñåðâåðå, âàì íåîáõîäèìî ïðèäóìàòü ïàðîëü.\n\n\
		{033fdd}Ïðèìå÷àíèå:{FFFFFF}\n\
		\t{ff0000}• {FFFFFF}Ïàðîëü äîëæåí ñîäåðæàòü îò 8 äî 64 ñèìâîëîâ.\n\
		\t{ff0000}• {FFFFFF}Ïàðîëü ìîæåò ñîäåðæàòü öèôðû è ëàòèíñêèå ñèìâîëû.",
		player_info[playerid][NAME]);

	SPD(
		playerid,
		DLG_REG,
		DIALOG_STYLE_INPUT,
		"Ðåãèñòðàöèÿ ••• Ââîä ïàðîëÿ •••",
		string,
		"Äàëåå",
		"Âûõîä"
		);
}


public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerSkin(playerid, player_info[playerid][SKIN]);

	new place = random(sizeof(base_spawn));
	SetPlayerPos(playerid, base_spawn[place][0], base_spawn[place][1], base_spawn[place][2]);
	SetPlayerFacingAngle(playerid, base_spawn[place][3]);
	SetCameraBehindPlayer(playerid);

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
			if (response)
			{
				new string[200];
				if (!strlen(inputtext))
				{
					ShowLogin(playerid);
					SetPVarInt(playerid, "CheckPassword", GetPVarInt(playerid, "CheckPassword") - 1);
					if (GetPVarInt(playerid, "CheckPassword") > 0)
					{
						format(string, sizeof(string), "[ÎØÈÁÊÀ]{FFFFFF} Ââåäèòå ïàðîëü â âñïëûâàþùåì îêíå. Ó âàñ îñòàëîñü %i ïîïûò(êè/êà).", GetPVarInt(playerid, "CheckPassword"));
						return SCM(playerid, COLOR_RED, string);
					}

					else
					{
						SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ]{FFFFFF} Âû èñïîëüçîâàëè âñå ïîïûòêè, êîòîðûå âàì ïðåäîñòàâèëè.");
						SCM(playerid, COLOR_RED, "Ââåäèòå /q, ÷òîáû âûéòè.");
						SPD(playerid, -1, 0, "", "", "", "");
						return Kick(playerid);
					}
				}

				if (strcmp(player_info[playerid][PASSWORD], inputtext) == 0)
				{
					static const frm_query[] = "SELECT * FROM users WHERE name = '%s'";
					new query[sizeof(frm_query) + MAX_PLAYER_NAME];
					format(query, sizeof(query), frm_query, player_info[playerid][NAME]);
					mysql_tquery(dbHandle, query, "PlayerLogin", "i", playerid);
				}

				else
				{
					ShowLogin(playerid);
					SetPVarInt(playerid, "CheckPassword", GetPVarInt(playerid, "CheckPassword") - 1);
					if (GetPVarInt(playerid, "CheckPassword") > 0)
					{
						format(string, sizeof(string), "[ÎØÈÁÊÀ]{FFFFFF} Ââåäèòå ïàðîëü â âñïëûâàþùåì îêíå. Ó âàñ îñòàëîñü %i ïîïûò(êè/êà).", GetPVarInt(playerid, "CheckPassword"));
						return SCM(playerid, COLOR_RED, string);
					}

					else
					{
						SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ]{FFFFFF} Âû èñïîëüçîâàëè âñå ïîïûòêè, êîòîðûå âàì ïðåäîñòàâèëè.");
						SCM(playerid, COLOR_RED, "Ââåäèòå /q, ÷òîáû âûéòè.");
						SPD(playerid, -1, 0, "", "", "", "");
						return Kick(playerid);
					}

				}
			}

			else
			{
				SCM(playerid, COLOR_RED, "Ââåäèòå /q, ÷òîáû âûéòè.");
				SPD(playerid, -1, 0, "", "", "", "");
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
					return SendClientMessage(playerid, COLOR_RED, "[ÎØÈÁÊÀ]{FFFFFF} Ââåäèòå ïàðîëü â âûäåëåííîì âàì ïîëå.");
				}

				if (!(8 <= strlen(inputtext) <= 64))
				{
					ShowRegistration(playerid);
					return SendClientMessage(playerid, COLOR_RED, "[ÎØÈÁÊÀ]{FFFFFF} Ïàðîëü äîëæåí ñîäåðæàòü îò 8 äî 64 ñèìâîëîì.");
				}

				new regex:rg_password = regex_new("^[a-zA-Z0-9.-_,]{1,64}$");
				if (regex_check(inputtext, rg_password))
				{
					new salt[11];
					for (new i; i < 10; ++ i) salt[i] = random(79) + 47;
					salt[10] = 0;
					SHA256_PassHash(inputtext, salt, player_info[playerid][PASSWORD], 64);
					strmid(player_info[playerid][SALT], salt, 0, 11, 11);
					strmid(player_info[playerid][PASSWORD], inputtext, 0, strlen(inputtext), 64);

					ShowPlayerDialog(
						playerid,
						DLG_MAIL,
						DIALOG_STYLE_INPUT,
						"Ðåãèñòðàöèÿ ••• Ââîä email ••• ",
						"{FFFFFF}Ââåäèòå Email äëÿ òîãî, ÷òîáû âû ìîãëè âîññòàíîâèòü ñâîé ïàðîëü ïðè åãî óòåðå.\n\n\
						{033fdd}Ïðèìå÷àíèå{FFFFFF}\n\
						\t{ff0000}• {FFFFFF}Åñëè ñåé÷àñ ó âàñ íåò ïî÷òû, òî âû ìîæåòå åå ñîçäàòü è â íàñòðîéêàõ ââåñòè åå.",
						"Äàëåå",
						"Ïðîïóñòèòü"
						);
				}

				else
				{
				    ShowRegistration(playerid);
				    return SCM(playerid, COLOR_RED, "[Îøèáêà]{FFFFFF} Ïàðîëü ìîæåò ñîäåðæàòü òîëüêî öèôðû è ëàòèíñêèå ñèìâîëû.");
				}
				regex_delete(rg_password);
			}

			else
			{
				SCM(playerid, COLOR_RED, "Èñïîëüçóéòå /q, ÷òîáû âûéòè.");
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
						"Ðåãèñòðàöèÿ ••• Ââîä email ••• ",
						"{FFFFFF}Ââåäèòå Email äëÿ òîãî, ÷òîáû âû ìîãëè âîññòàíîâèòü ñâîé ïàðîëü ïðè åãî óòåðå.\n\n\
						{033fdd}Ïðèìå÷àíèå{FFFFFF}\n\
						\t{ff0000}• {FFFFFF}Åñëè ñåé÷àñ ó âàñ íåò ïî÷òû, òî âû ìîæåòå åå ñîçäàòü è â íàñòðîéêàõ ââåñòè åå.",
						"Äàëåå",
						"Ïðîïóñòèòü"
						);
					return SendClientMessage(playerid, COLOR_RED, "[Îøèáêà]{FFFFFF} Ââåäèòå email â âûäåëåííîì âàì ïîëå.");
				}

				new regex:rg_mail = regex_new("^[a-zA-Z0-9.-_]{1,}@[a-zA-Z]{1,}.[a-zA-Z]{1,5}$");
				if (regex_check(inputtext, rg_mail))
				{
					strmid(player_info[playerid][EMAIL], inputtext, 0, strlen(inputtext), 86);
					ShowPlayerDialog(
						playerid,
						DLG_REF,
						DIALOG_STYLE_INPUT,
						"Ðåãèñòðàöèÿ ••• Ðåôåðàëüíàÿ ñèñòåìà •••",
						"{FFFFFF} Ââåäèòå íèêíåéì ïðèãëàñèâøåãî âàñ èãðîêà íà ñåðâåð.\n\n\
						{033fdd}Ïðèìå÷àíèå{FFFFFF}\n\
						\t{ff0000}• {FFFFFF} Íèêíåéì äîëæåí èìåòü âèä - Egor_Egorov.",
						"Äàëåå",
						"Ïðîïóñòèòü"
						);
				}

				else
				{
					ShowPlayerDialog(
						playerid,
						DLG_MAIL,
						DIALOG_STYLE_INPUT,
						"Ðåãèñòðàöèÿ ••• Ââîä email ••• ",
						"{FFFFFF}Ââåäèòå Email äëÿ òîãî, ÷òîáû âû ìîãëè âîññòàíîâèòü ñâîé ïàðîëü ïðè åãî óòåðå.\n\n\
						{033fdd}Ïðèìå÷àíèå{FFFFFF}\n\
						\t{ff0000}• {FFFFFF}Åñëè ñåé÷àñ ó âàñ íåò ïî÷òû, òî âû ìîæåòå åå ñîçäàòü è â íàñòðîéêàõ ââåñòè åå.",
						"Äàëåå",
						"Ïðîïóñòèòü"
						);
					return SendClientMessage(playerid, COLOR_RED, "[ÎØÈÁÊÀ]{FFFFFF} Ââåäèòå êîððåêòíûé email àäðåñ.");
				}

				regex_delete(rg_mail);
			}

			else
			{
				ShowPlayerDialog(
					playerid,
					DLG_REF,
					DIALOG_STYLE_INPUT,
					"Ðåãèñòðàöèÿ ••• Ðåôåðàëüíàÿ ñèñòåìà •••",
					"{FFFFFF} Ââåäèòå íèêíåéì ïðèãëàñèâøåãî âàñ èãðîêà íà ñåðâåð.\n\n\
					{033fdd}Ïðèìå÷àíèå{FFFFFF}\n\
					\t{ff0000}• {FFFFFF} Íèêíåéì äîëæåí èìåòü âèä - Egor_Egorov.",
					"Äàëåå",
					"Ïðîïóñòèòü"
					);
			}
		}

		case DLG_REF:
		{
			if (response)
			{
				if (!strlen(inputtext))
				{
					ShowPlayerDialog(
						playerid,
						DLG_REF,
						DIALOG_STYLE_INPUT,
						"Ðåãèñòðàöèÿ ••• Ðåôåðàëüíàÿ ñèñòåìà •••",
						"{FFFFFF} Ââåäèòå íèêíåéì ïðèãëàñèâøåãî âàñ èãðîêà íà ñåðâåð.\n\n\
						{033fdd}Ïðèìå÷àíèå{FFFFFF}\n\
						\t{ff0000}• {FFFFFF} Íèêíåéì äîëæåí èìåòü âèä - Egor_Egorov.",
						"Äàëåå",
						"Ïðîïóñòèòü"
						);
				}

				new regex:rg_referal = regex_new("^[a-zA-Z]{1,}_[a-zA-Z]{1,}$");
				if (regex_check(inputtext, rg_referal))
				{
					ShowPlayerDialog(
						playerid,
						DLG_SEX,
						DIALOG_STYLE_MSGBOX,
						"Ðåãèñòðàöèÿ ••• Âûáîð ïîëà •••",
						"Âûáåðèòå ïîë ïåðñîíàæà",
						"Ìóæñêîé",
						"Æåíñêèé"
						);
				}

				else
				{
					ShowPlayerDialog(
						playerid,
						DLG_REF,
						DIALOG_STYLE_INPUT,
						"Ðåãèñòðàöèÿ ••• Ðåôåðàëüíàÿ ñèñòåìà •••",
						"{FFFFFF} Ââåäèòå íèêíåéì ïðèãëàñèâøåãî âàñ èãðîêà íà ñåðâåð.\n\n\
						{033fdd}Ïðèìå÷àíèå{FFFFFF}\n\
						\t{ff0000}• {FFFFFF} Íèêíåéì äîëæåí èìåòü âèä - Egor_Egorov.",
						"Äàëåå",
						"Ïðîïóñòèòü"
						);
					return SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ]{FFFFFF} Ââåäèòå íèêíåéì êîððåêòíî.");
				}
				regex_delete(rg_referal);
			}

			else
			{
				ShowPlayerDialog(
					playerid,
					DLG_SEX,
					DIALOG_STYLE_MSGBOX,
					"Ðåãèñòðàöèÿ ••• Âûáîð ïîëà •••",
					"Âûáåðèòå ïîë ïåðñîíàæà",
					"Ìóæñêîé",
					"Æåíñêèé"
					);
			}
		}

		case DLG_SEX:
		{
			if (response)
			{
				player_info[playerid][SEX] = 1;
				ShowPlayerDialog(
					playerid,
					DLG_SKIN,
					DIALOG_STYLE_LIST,
					"Ðåãèñòðàöèÿ ••• Âûáîð îäåæäû •••",
					"78\n79\n134\n135\n137\n160\n212\n230",
					"Âûáðàòü",
					""
					);
			}

			else
			{
				player_info[playerid][SEX] = 2;
				ShowPlayerDialog(
					playerid,
					DLG_SKIN,
					DIALOG_STYLE_LIST,
					"Ðåãèñòðàöèÿ ••• Âûáîð îäåæäû •••",
					"13\n41\n56\n65\n190\n192\n193\n195",
					"Âûáðàòü",
					""
					);
			}
		}

		case DLG_SKIN:
		{
			if (player_info[playerid][SEX] == 1) player_info[playerid][SKIN] = skinmale[listitem];
			else player_info[playerid][SKIN] = skinfemale[listitem];
			player_info[playerid][AGE] = 17;

			new Day, Month, Year;
			getdate(Year, Month, Day);
			new data[13], ip[16];
			format(data, sizeof(data), "%02d.%02d.%02d", Day, Month, Year);
			GetPlayerIp(playerid, ip, sizeof(ip));

			static const frm_query[] = "INSERT INTO \
			users (name, password, salt, email, referal, sex, age, skin, regdata, regip)\
			VALUES ('%s', '%s', '%s', '%s', '%i', '%i', '%i', '%i', '%s', '%s')";
			new query[sizeof(frm_query) + MAX_PLAYER_NAME + 64 + 11 + 86 + 8 + 1 + 3 + 3 + 12 + 16];
			format(
				query,
				sizeof(query),
				frm_query,
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

			static const frm_query2[] = "SELECT * FROM users WHERE name = '%s'";
			new query2[sizeof(frm_query2) + MAX_PLAYER_NAME];
			format(query2, sizeof(query2), frm_query2, player_info[playerid][NAME]);
			mysql_tquery(dbHandle, query2, "PlayerLogin", "i", playerid);
		}

		case DLG_CLICK:
		{
		    new string[1000];
			switch(listitem)
			{
				case 0:
				{
				    format(string, sizeof(string),
					"Íèêíåéì: %s\n\
					Óðîâåíü: %i\n\
					Îïûò: %i\n\n\
					________________________________\n\n\
				 	\t  Íàêàçàíèÿ\n\
				 	________________________________\n\n\
				 	Êîë-âî ïðîâåäåííîå â äåìîðãàíå:\n\
				 	Ïðåäóïðåæäåíèé: èç 3\n\
				 	Êîë-âî ðàç áëîêèðîâêè àêêàóíòà:\n\n\
					________________________________\n\n\
				 	\tËè÷íàÿ èíôîðìàöèÿ\n\
				 	________________________________\n\n\
				 	Äàòà ðåãèñòðàöèè: %s\n\
				 	Ðåãèñòðàöèîííûé IP-àäðåñ: %s\n\
				 	",
				 	player_info[playerid][NAME],
				 	player_info[playerid][LEVEL],
				 	player_info[playerid][EXP],
				 	player_info[playerid][REG_DATA],
				 	player_info[playerid][REG_IP]
					 );

					ShowPlayerDialog(
						playerid,
						DLG_INFO_PLAYER,
						DIALOG_STYLE_MSGBOX,
						"Èíôîðìàöèÿ èãðîêà",
						string,
						"Íàçàä",
						"Âûõîä"
						);
				}
			}
		}
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
	    cache_get_value_name(0, "email", player_info[playerid][EMAIL], 86);
	    cache_get_value_name_int(0, "referal", player_info[playerid][REF]);
	    cache_get_value_name_int(0, "sex", player_info[playerid][SEX]);
	    cache_get_value_name_int(0, "age", player_info[playerid][AGE]);
	    cache_get_value_name_int(0, "skin", player_info[playerid][SKIN]);
	    cache_get_value_name(0, "regdata", player_info[playerid][REG_DATA], 12);
	    cache_get_value_name(0, "regip", player_info[playerid][REG_IP], 16);
	    cache_get_value_name_int(0, "admin", player_info[playerid][ADMIN]);
	    cache_get_value_name_int(0, "money", player_info[playerid][MONEY]);
	    cache_get_value_name_int(0, "exp", player_info[playerid][EXP]);
	    cache_get_value_name_int(0, "level", player_info[playerid][LEVEL]);
	    cache_get_value_name_float(0, "hp", player_info[playerid][HP]);

		SpawnPlayer(playerid);
		SetPVarInt(playerid, "Login", 1);
	}

	return 1;
}


public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
    ShowPlayerDialog(
		playerid,
		DLG_CLICK,
		DIALOG_STYLE_LIST,
		"Äåéñòâèå íàä èãðîêîì",
		"1. Èíôîðìàöèÿ èãðîêà\n\
		2. Òåëåïîðòèðîâàòü\n\
		3. Ïîñàäèòü â Äåìîðãàí\n\
		4. Âûäàòü áàí ÷àòà\n\
		5. Âûäàòü ïðåäóïðåæäåíèå\n\
		6. Çàáëîêèðîâàòü àêêàóíò\n\
		7. Âûäàòü ñêèí",
		"Âûáðàòü",
		"Âûõîä"
		);
	return 1;
}

forward OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ);
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		SetVehiclePos(GetPlayerVehicleID(playerid), Float:fX, Float:fY, Float:fZ + 3);
		PutPlayerInVehicle(playerid, GetPlayerVehicleID(playerid), 0);
	}
	else SetPlayerPos(playerid, Float:fX, Float:fY, Float:fZ + 3);

	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
}
