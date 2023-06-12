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
#define COLOR_GREEN 0x00FF26AA


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
	PASSWORD[65],
	SALT[11],
	EMAIL[64],
	REF,
	SEX,
	AGE,
	SKIN,
	REG_DATA[12],
	REG_IP[16],
};
new player_info[MAX_PLAYERS][player];

enum dialogs
{
	DLG_NONE,
	DLG_REG,
	DLG_REGEMAIL,
	DLG_LOG,
	DLG_REGREF,
	DLG_SEX,
	DLG_SKIN,
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
		ShowLogin(playerid);
	}
	else ShowRegistration(playerid);

	SetPVarInt(playerid, "WrongPassword", 3);
}

stock ShowLogin(playerid)
{
    new dialog[300 + (-2 + MAX_PLAYER_NAME)];
	format(dialog, sizeof(dialog),
	    "{FFFFFF}Óâàæàåìûé{0089ff} %s{FFFFFF}. Ðàäû âèäåòü âàñ ñíîâà íà íàøåì ñåðâåðå\n\n\
		Äëÿ ïðîäîëæåíèÿ èãðû ââåäèòå ñâîé ïàðîëü íèæå",
		player_info[playerid][NAME]
	 );
	SPD(playerid, DLG_LOG, DIALOG_STYLE_INPUT, "{ffd100}Àâòîðèçàöèÿ{FFFFFF} ••• Ââîä • Ïàðîëü •••", dialog, "Âîéòè", "Âûõîä");
	// SCM(playerid, COLOR_WHITE, "Äàííûé àêêàóíò çàðåãèñòðèðîâàí");
}

stock ShowRegistration(playerid)
{
 	new dialog[300 + (-2 + MAX_PLAYER_NAME)];
	format(dialog, sizeof(dialog),
	    "{FFFFFF}Ðåãèñòðàöèÿ{0089ff} %s{FFFFFF}. Ðàäû ïðèâåòñòâîâàòü âàñ íà íàøåì ñåðâåðå\n\
	    Àêêàóíò ñ äàííûì íèêíåéìîì íå çàðåãèñòððîâàí\n\n\
		Ïðèäóìàéòå íàäåæíû ïàðîëü äëÿ âàøå àêêàóíòà è íàæìèòå \"Äàëåå\"\n\n\
  		{0089ff}Ïðèìå÷àíèå:{FFFFFF}\n\
		\t• Ïàðîëü äîëæåí áûòü îò 8 äî 32 ñèìâîëîâ\n\
		\t• Ïàðîëü äîëæåí ñîäåðæàòü òîëüêî öèôðû è ëàòèíñêèå áóêâû",
		player_info[playerid][NAME]
	 );
	SPD(playerid, DLG_REG, DIALOG_STYLE_INPUT, "{ffd100}Ðåãèñòðàöèÿ{FFFFFF} ••• Ââîä • Ïàðîëü •••", dialog, "Äàëåå", "Âûõîä");

	//SCM(playerid, COLOR_WHITE, "Äàííûé àêêàóíò íå çàðåãèñòðèðîâàí");
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
			if (response)
			{
				if (!strlen(inputtext))
	            {
	                ShowLogin(playerid);
	                return SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Ââåäèòå ïàðîëü â ïîëå íèæå è íàæìèòå \"Âîéòè\".");
				}

				if (strcmp(player_info[playerid][PASSWORD], inputtext) == 0)
				{
					static const fmt_query[] = "SELECT * FROM users WHERE name = '%s' AND password = '%s'";
					new query[sizeof(fmt_query) + (-2 + MAX_PLAYER_NAME) + (-2 + 64)];
 					format(query, sizeof(query), fmt_query, player_info[playerid][NAME], player_info[playerid][PASSWORD]);
 					mysql_tquery(dbHandle, query, "PlayerLogin", "i", playerid);

                    // SCM(playerid, COLOR_GREEN, "[ÂÅÐÍÎ] {FFFFFF}Ïàðîëü óñïåøíî ââåäåí.");
				}

				else
				{
					new string[300];
					SetPVarInt(playerid, "WrongPassword", GetPVarInt(playerid, "WrongPassword") - 1);
					if (GetPVarInt(playerid, "WrongPassword") > 0)
					{
						format(string, sizeof(string), "[ÎØÈÁÊÀ] {FFFFFF}Ïàðîëü íå âåðåí. Ó âàñ îñòàëîñü %i ïîïûòê(è/à), ÷òîáû âîéòè íà ñåðâåð.", GetPVarInt(playerid, "WrongPassword"));
						SCM(playerid, COLOR_RED, string);
					}

					else
					{
                        SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Ó âàñ çàêîí÷èëèñü ïîïûòêè äëÿ âõîäà íà ñåðâåð è áûëè îò íåãî îòêëëþ÷åíû.");
                        Kick(playerid);
					}

					ShowLogin(playerid);
				}
			}

			else
			{
				SCM(playerid, COLOR_RED, "Ââåäèòå \"/q\", ÷òîáû âûéòè");
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
	                return SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Ââåäèòå ïàðîëü â ïîëå íèæå è íàæìèòå \"Äàëåå\"");
				}

				if (!(8 <= strlen(inputtext) <= 32))
				{
				    ShowRegistration(playerid);
	                return SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Äëèíà ïàðîëÿ äîëæíà áûòü îò 8 äî 32 ñèìâîëîâ");
				}

    			new regex:rg_passwordcheck = regex_new("^[a-zA-Z0-9.-_,]{1,}$");
				if (regex_check(inputtext, rg_passwordcheck))
				{
				    /*new salt[11];
				    for (new i; i < 10; i++) salt[i] = random(79) + 47;
				    salt[10] = 0;
				    SHA256_PassHash(inputtext, salt, player_info[playerid][PASSWORD], 65);
				    strmid(player_info[playerid][SALT], salt, 0, 9, 9);*/

					strmid(player_info[playerid][PASSWORD], inputtext, 0, strlen(inputtext), 65);
					SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT,
						"{ffd100}Ðåãèñòðàöèÿ{FFFFFF} ••• Ââîä Email •••",
						"Ïðè óòåðå ïàðîëÿ îò àêêàóíòà, âû ñìîæèòå âîññòàíîâèòü åãî ÷åðåç Email\n\
						Ââåäèòå email â ïîëå íèæå è íàæìèòå \"Äàëåå\"",
						"Äàëåå",
						"");
				}

				else
				{
				    ShowRegistration(playerid);
				    regex_delete(rg_passwordcheck);
				    return SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Ïàðîëü äîëæåí ñîäåðæàòü òîëüêî ëàòèíñêèå ñèìâîëû è öèôðû");
				}
				regex_delete(rg_passwordcheck);
			}

			else
			{
				SCM(playerid, COLOR_RED, "Ââåäèòå \"/q\", ÷òîáû âûéòè");
				SPD(playerid, -1, 0, " ", " ", " ", " ");
				return Kick(playerid);
			}
		}

		case DLG_REGEMAIL:
		{

			if (!strlen(inputtext))
			{
			    SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT,
					"{ffd100}Ðåãèñòðàöèÿ{FFFFFF} ••• Ââîä • Email •••",
					"Ïðè óòåðå ïàðîëÿ îò àêêàóíòà, âû ñìîæèòå âîññòàíîâèòü åãî ÷åðåç Email\n\
					Ââåäèòå email â ïîëå íèæå è íàæìèòå \"Äàëåå\"",
					"Äàëåå",
					"");
                return SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Ââåäèòå email â ïîëå íèæå è íàæìèòå \"Äàëåå\"");
			}

			new regex:rg_emailcheck = regex_new("^[a-zA-Z0-9.-]{1,}@[a-zA-Z]{1,}.[a-zA-Z]{1,5}$");
			if (regex_check(inputtext, rg_emailcheck))
			{
			    strmid(player_info[playerid][EMAIL], inputtext, 0, strlen(inputtext), 64);
			    SPD(playerid, DLG_REGREF, DIALOG_STYLE_INPUT,
					"{ffd100}Ðåãèñòðàöèÿ{FFFFFF} ••• Ââîä • Ðåôåðàëüíàÿ ñèñòåìà •••",
					"Èñïîëüçóéòå íèêíåéì, êîòîðûé âàñ ïðèãðàñèë íà ñåðâåð\n\
					Ââåäèòå íèêíåéì â ïîëå íèæå è íàæìèòå \"Äàëåå\"\n\n\
					{0089ff}Ïðèìå÷àíèå:{FFFFFF}\n\
					• Íèêíåéì èìååò ñëåäóþùèé âèä - Egor_Egorov",
					"Äàëåå",
					"Ïðîïóñòèòü");
			}

			else
			{
			    SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT,
					"{ffd100}Ðåãèñòðàöèÿ{FFFFFF} ••• Ââîä • Email •••",
					"Ïðè óòåðå ïàðîëÿ îò àêêàóíòà, âû ñìîæèòå âîññòàíîâèòü åãî ÷åðåç Email\n\
					Ââåäèòå email â ïîëå íèæå è íàæìèòå \"Äàëåå\"",
					"Äàëåå",
					"");
                regex_delete(rg_emailcheck);
				return SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Ââåäèòå email êîððåêòíî");
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
						"{ffd100}Ðåãèñòðàöèÿ{FFFFFF} ••• Ââîä • Ðåôåðàëüíàÿ ñèñòåìà •••",
						"Èñïîëüçóéòå íèêíåéì, êîòîðûé âàñ ïðèãðàñèë íà ñåðâåð\n\
						Ââåäèòå íèêíåéì â ïîëå íèæå è íàæìèòå \"Äàëåå\"\n\n\
						{0089ff}Ïðèìå÷àíèå:{FFFFFF}\n\
						   • Íèêíåéì èìååò ñëåäóþùèé âèä - Egor_Egorov",
						"Äàëåå",
						"Ïðîïóñòèòü");
					return SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Ââåäèòå íèêíåéì, ïðãèãëàñèâøåãî âàñ èãðîêà â ïîëå íèæå è íàæìèòå \"Äàëåå\"");
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
						"{ffd100}Ðåãèñòðàöèÿ{FFFFFF} ••• Ââîä • Ðåôåðàëüíàÿ ñèñòåìà •••",
						"Èñïîëüçóéòå íèêíåéì, êîòîðûé âàñ ïðèãðàñèë íà ñåðâåð\n\
						Ââåäèòå íèêíåéì â ïîëå íèæå è íàæìèòå \"Äàëåå\"\n\n\
						{0089ff}Ïðèìå÷àíèå:{FFFFFF}\n\
						   • Íèêíåéì èìååò ñëåäóþùèé âèä - Egor_Egorov",
						"Äàëåå",
						"Ïðîïóñòèòü");
					regex_delete(rg_referalcheck);
					return SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Äàííîãî íèêíåéìà íå ñóùåñòâóåò, ëèáî ââåäèòå åãî êîððåêòíî");
				}
				regex_delete(rg_referalcheck);
			}

			else
			{
				SPD(playerid, DLG_SEX, DIALOG_STYLE_MSGBOX,
				"{ffd100}Ðåãèñòðàöèÿ{FFFFFF} ••• Âûáîð ïîëà ïåðñîíàæà •••",
				"Âûáåðèòå ïîë äëÿ âàøåãî ïåðñîíàæà",
				"Ìóæùèíà",
				"Æåíùèíà"
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
			        "{ffd100}Ðåãèñòðàöèÿ{FFFFFF} ••• Ââîä • Âûáîð îäåæäû •••",
			        "78\n79\n134\n135\n137\n160\n212\n230",
					"Äàëåå",
					""
				);
			}
			else
			{
				SPD(playerid, DLG_SKIN, DIALOG_STYLE_LIST,
					"{ffd100}Ðåãèñòðàöèÿ{FFFFFF} ••• Ââîä • Âûáîð îäåæäû •••",
			        "13\n41\n56\n65\n190\n192\n193\n195",
					"Äàëåå",
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
		cache_get_value_name_int(0, "AGE", player_info[playerid][AGE]);
		cache_get_value_name_int(0, "skin", player_info[playerid][SKIN]);
		cache_get_value_name(0, "regdata", player_info[playerid][REG_DATA], 12);
		cache_get_value_name(0, "regip", player_info[playerid][REG_IP], 15);

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
			"{ffd100}Ðåãèñòðàöèÿ{FFFFFF} ••• Âûáîð ïîëà ïåðñîíàæà •••",
			"Âûáåðèòå ïîë äëÿ âàøåãî ïåðñîíàæà",
			"Ìóæùèíà",
			"Æåíùèíà"
			);
	}
	else
	{
        SPD(playerid, DLG_REGREF, DIALOG_STYLE_INPUT,
			"{ffd100}Ðåãèñòðàöèÿ{FFFFFF} ••• Ââîä • Ðåôåðàëüíàÿ ñèñòåìà •••",
			"Èñïîëüçóéòå íèêíåéì, êîòîðûé âàñ ïðèãðàñèë íà ñåðâåð\n\
			Ââåäèòå íèêíåéì â ïîëå íèæå è íàæìèòå \"Äàëåå\"\n\n\
			{0089ff}Ïðèìå÷àíèå:{FFFFFF}\n\
 			• Íèêíåéì èìååò ñëåäóþùèé âèä - Egor_Egorov",
			"Äàëåå",
			"Ïðîïóñòèòü");
		return SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Äàííîãî àêêàóíòà ñ òàêèì íèêíåéìîì íå ñóùåñòâóåò");
	}

	return 1;
}


public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}






