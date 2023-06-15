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
#define COLOR_GREY  0xA2A1AbAA
#define COLOR_YELLOW  0xFFF017AA

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
	HP,
	ARM,
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
				format(string, sizeof(string), "%s%i ñåêóíä.", PlayerAFK[i]);
			}

			else
			{
			    new minute = floatround(PlayerAFK[i] / 60, floatround_floor);
			    new second = PlayerAFK[i] % 60;
			    format(string, sizeof(string), "%s%i ìèíóò %i ñåêóíä", string, minute, second);
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
	if (GetPVarInt(playerid, "logged") == 0)
	{
		SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Ââåäèòå ïàðîëü, ÷òî àâòîðèçîâàòüñÿ íà ñåðâåðå.");
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
		SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}×òîáû ââåñòè ñîîáùåíèå íóæíî àâòîðèçîâàòüñÿ íà ñåðâåðå.");
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
	    SCM(playerid, COLOR_GREY, "[ÎØÈÁÊÀ] {FFFFFF}Ñîîáùåíèå ñëèøêîì äëèííîå");
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
		cache_get_value_name(0, "regdata", player_info[playerid][REG_DATA], 13);
		cache_get_value_name(0, "regip", player_info[playerid][REG_IP], 16);
		cache_get_value_name_int(0, "admin", player_info[playerid][ADMIN]);
		cache_get_value_name_int(0, "money", player_info[playerid][MONEY]);
		cache_get_value_name_int(0, "level", player_info[playerid][LEVEL]);
		cache_get_value_name_int(0, "exp", player_info[playerid][EXP]);
		cache_get_value_name_int(0, "health", player_info[playerid][HP]);
		cache_get_value_name_int(0, "armour", player_info[playerid][ARM]);

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

forward OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ);
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if (player_info[playerid][ADMIN] >= 2)
	{
		if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), fX, fY, fZ);
			PutPlayerInVehicle(playerid, GetPlayerVehicleID(playerid), 0);
		}

		else
		{
			SetPlayerPos(playerid, fX, fY, fZ);
		}

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

CMD:makeadminonline(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 5)
	{
		new id, level;
		if (sscanf(params, "ui", id, level))
		{
			SCM(playerid, COLOR_GREY, "Èñïîëüçóéòå /makeadminonline [id] [level]");
		}

		else
		{
			if (!IsPlayerConnected(id)) SCM(playerid, COLOR_GREY, "Äàííûé èãðîê íå â ñåòè.");

			else
			{
				if (player_info[playerid][ADMIN] == 5 && level > 1)
	   			{
	   				SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Ó âàñ íåäîñòàòî÷íî ïðàâ, ÷òîáû âûäàòü óðîâåíü âûøå 1-ãî.");
				}

				else if (player_info[playerid][ADMIN] == 6 && level > 4)
				{
					SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Ó âàñ íåäîñòàòî÷íî ïðàâ, ÷òîáû âûäàòü óðîâåíü âûøå 5-ãî.");
				}

				else
				{
					new string[100];
					new string2[100];
					format(string, sizeof(string), "Àäìèíèñòðàòîð %s âûäàë âàì àäìèíèñòðàòèâíûå ïðàâà %i óðîâíÿ", player_info[playerid][NAME], level);
					format(string2, sizeof(string2), "Âû âûäàëè %s àäìèíèñòðàòèâíûå ïðàâà %i óðîâíÿ", player_info[id][NAME], level);
					SCM(playerid, COLOR_YELLOW, string2);
					SCM(id, COLOR_YELLOW, string);

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



CMD:makeadminoffline(playerid, params[])
{

	if (player_info[playerid][ADMIN] >= 5)
	{
		new name[MAX_PLAYER_NAME], level;
		if (sscanf(params, "s[MAX_PLAYER_NAME]i", name, level))
		{
			SCM(playerid, COLOR_GREY, "Èñïîëüçóéòå /makeadminoffline [nickname] [level]");
		}

		else
		{
			if (!strlen(name)) SCM(playerid, COLOR_GREY, "Ââåäèòå íèêíåéì êîððåêòíî.");

			else
			{
	   			if (player_info[playerid][ADMIN] == 5 && level > 1)
	   			{
	   				SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Ó âàñ íåäîñòàòî÷íî ïðàâ, ÷òîáû âûäàòü óðîâåíü âûøå 1-ãî.");
				}

				else if (player_info[playerid][ADMIN] == 6 && level > 4)
				{
					SCM(playerid, COLOR_RED, "[ÎØÈÁÊÀ] {FFFFFF}Ó âàñ íåäîñòàòî÷íî ïðàâ, ÷òîáû âûäàòü óðîâåíü âûøå 5-ãî.");
				}

				else
				{
					new string[100];
					format(string, sizeof(string), "Âû âûäàëè îôôëàéí %s àäìèíèñòðàòèâíûå ïðàâà %i óðîâíÿ", name, level);
					SCM(playerid, COLOR_YELLOW, string);
					
					static const fmt_query[] = "UPDATE users SET admin = '%i' WHERE name = '%s'";
					new query[sizeof(fmt_query) + (-2 + 4) + (-2 + MAX_PLAYER_NAME)];
 					format(query, sizeof(query), fmt_query, level, name);
 					mysql_tquery(dbHandle, query);
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
	    new id, condition[64];
		if (sscanf(params, "us[64]", id, condition))
		{
			SCM(playerid, COLOR_GREY, "Èñïîëüçóéòå /kick [id] [condition]");
		}

		else
		{
			if (IsPlayerConnected(id))
			{
				if (!strlen(condition)) SCM(playerid, COLOR_GREY, "Ââåäèòå ïðè÷èíó.");

				else
				{
					new string[100];
					new string2[100];
					format(string, sizeof(string), "Àäìèíèñòðàòîð %s êèêíóë âàñ c ñåðâåðà. Ïðè÷èíà: %s", player_info[playerid][NAME], condition);
					format(string2, sizeof(string2), "Àäìèíèñòðàòîð %s êèêíóë èãðîêà %s. Ïðè÷èíà: %s", player_info[playerid][NAME], player_info[id][NAME], condition);
                    SCMTA(COLOR_GREEN, string2);
					SCM(id, COLOR_RED, string);
					Kick(id);
				}
			}
		}
	}
	return 1;
}



CMD:setskin(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 2)
	{
		if (sscanf(params, "ii", params[0], params[1]))
		{
			SCM(playerid, COLOR_GREY, "Èñïîëüçóéòå /setskin [id player] [id skin]");
		}

		else
		{
			if (!(0 <= params[1] <= 311)) SCM(playerid, COLOR_GREY, "Ââåäèòå êîððåêòíûé ID îäåæäû îò 0 äî 311.");
			else 
			{ 
				SetPlayerSkin(playerid, params[1]);
				static const fmt_query[] = "UPDATE users SET skin = '%i' WHERE id = '%i'";
				new query[sizeof(fmt_query) + (-2 + 3) + (-2 + 8)];
 				format(query, sizeof(query), fmt_query, params[1], player_info[playerid][ID]);
 				mysql_tquery(dbHandle, query);
			}
		}
	}
}



CDM:makeleader(playerid, params[])
{
	if (player_info[playerid][ADMIN] >= 5)
	{
		if (sscanf(params, "ii", params[0], params[1]))
		{
			SCM(playerid, COLOR_GREY, "Èñïîëüçóéòå /makeleader [id player] [id fraction]");
		}
	}
}


// OnPlayerWeaponShot
// OnPlayerTakeDamage
// OnPlayerGiveDamage