#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#define PLUGIN_AUTHOR "Dominik Kłodziński"
#define PLUGIN_VERSION "1.00"
#define ILOSC_SUPERMOCY 18

int random;
int wampir_ile[MAXPLAYERS];
int morfina[MAXPLAYERS];
int Hud_ON[MAXPLAYERS];

#pragma semicolon 1

int player[MAXPLAYERS];

public Plugin myinfo = 
{
	name = "Super Power by My-Speak24.pl and Code Industries",
	author = PLUGIN_AUTHOR,
	description = "Plugin o niebywałej mocy dla NIKO",
	version = PLUGIN_VERSION,
	url = "http://strona.my-speak24.pl/"
};

new String:modele_serwera[10][] =
{
    "models/player/ctm_fbi.mdl", // 0
    "models/player/ctm_gign.mdl", // 1
    "models/player/ctm_gsg9.mdl", // 2
    "models/player/ctm_sas.mdl", // 3
    "models/player/ctm_st6.mdl", // 4
    "models/player/tm_anarchist.mdl", // 5
    "models/player/tm_phoenix.mdl", // 6
    "models/player/tm_pirate.mdl", // 7
    "models/player/tm_balkan_variantA.mdl", // 8
    "models/player/tm_leet_variantA.mdl" // 9
};

new String:SuperMoc[ILOSC_SUPERMOCY][2][] =
{
	{
		"Każde trafienie zabija","+1000 DMG z każdej broni" //dziala 0
	},
	{
		"Tank","Dostajesz +1000HP" //dziala 1
	},
	{
		"Wampir","Gdy zadajesz dmg przeciwnikowi, dostajesz dodatkowe hp" //dziala
	},
	{
		"Wallhack","Posiadasz wallhacka, czerwona linia wskaże przeciwników"//3
	},
	{
		"Ninja","30% widoczności"//dziala 4
	},
	{ 
		"Grawitacja","Zmniejszona grawitacja" //dziala 5
	},
	{
		"Kamienna skóra","-75% otrzymanych obrażeń"//dziala 6
	},
	{
		"Super prędkość","2.5 raza szybsze chodzenie"// dziala 7
	},
	{
		"Nieskończona amunicja","Amunicja nigdy się nie kończy"//dziala 8
	},
	{
		"Medyk","Możesz leczyć członków drużyny strzelając w nich" //dziala 9
	},
	{
		"Kameleon","Posiadasz ubranie wroga"//10
	},
	{
		"Nożownik","Natychmiastowe zabicie z noża"//dziala 11 
	},
	{
		"Szybkostrzelność","Szybciej strzelasz"//12
	},
	{
		"Bogacz","+16000$"//dziala 13
	},
	{
		"Boomer","Po śmierci wybuchasz, zabijasz przeciwników obok siebie"//14
	},
	{
		"Jumper","Posiadasz +10 dodatkowych skoków"//15
	},
	{
		"Morfina","Posiadasz 1 odrodzenie po śmierci"//dziala 16
	},
	{
		"Brak","Moc została usunięta"//17
	}
};

public void OnPluginStart()
{
	 RegConsoleCmd("sm_lista", cmd_lista, "Lista supermocy");
	 RegConsoleCmd("sm_losuj", cmd_losuj, "Testowa komenda");
	 RegConsoleCmd("sm_lecz", cmd_lecz, "Leczy medyka");
	 RegConsoleCmd("sm_help", cmd_help, "Pokazuje liste komend");
	 RegConsoleCmd("sm_hud", cmd_hud, "Uruchamia HUD lub go wylacza");
	 HookEvent("weapon_fire", EventWeaponFire,EventHookMode_Pre);
	 HookEvent("player_death", PlayerDeath,EventHookMode_Pre);
	 HookEvent("round_start", RoundStart,EventHookMode_Pre);
	 HookEvent("round_end", RoundStop,EventHookMode_Pre);
	 HookEvent("player_spawn", OnPlayerSpawn);
	 CreateTimer(5.0, SetCvars, 0, 1);
	 
}

public OnMapStart()
{
    for(new i = 0; i < sizeof(modele_serwera); i++)
        PrecacheModel(modele_serwera[i]);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	player[client] = 17;
	Hud_ON[client] = 1;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action cmd_lecz(int client,int args)
{
	if(player[client] == 9)
	{
		int health = GetClientHealth(client);
		int difference = 100 - health;
		
		if(difference == 0)
		{
			PrintHintText(client, "Nie jestes ranny. Nie możesz się uleczyć");
		}
		else
		{
			PrintHintText(client, "Leczysz się do 100 HP");
			SetEntityHealth(client,health+difference);
		}
	}
	else
	{
		PrintHintText(client, "Nie wylosowałeś medyka. Nie możesz się uleczyć");
	}
}


public Action cmd_hud(int client,int args)
{
	Menu menu = new Menu(Menu_Handler);
	menu.SetTitle("Włącz lub wyłącz Hud");
	menu.AddItem("1","Włącz");
	menu.AddItem("2","Wyłącz");
	
	menu.Display(client, 120);
}

public int Menu_Handler(Menu menu, MenuAction action, int client, int position)
{
	if(action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Select)
	{
		char buffer[32];
		GetMenuItem(menu, position, buffer, sizeof(buffer));
		
		if(position == 0)
		{
			if(Hud_ON[client] == 1)
			{
				PrintCenterText(client, "Masz uruchomiony Hud");
			}
			else
			{
				Hud_ON[client] = 1;
				CreateTimer(1.0, ShowHud, client, TIMER_FLAG_NO_MAPCHANGE);
			}
				
		}
		else if(position == 1)
		{
			Hud_ON[client] = 0;
		}
	}
}

public Action cmd_help(int client,int args)
{
	PrintCenterText(client, "Napisz: \n !lecz ->>> Komenda tylko dla medyków leczy medyka do 100hp \n !hud ->>> otwiera się menu sterowania hudem \n !lista ->>> wyświetla listę klass i opisy obenych oraz przyszłych");
}

public Action cmd_lista(int client, int args)
{		
	PrintToChat(client,"Nazwa i opisy mocy");	
	
	for (int i = 0; i <= ILOSC_SUPERMOCY - 1; i++)
	{
		PrintToChat(client,"%s | %s",SuperMoc[i][0],SuperMoc[i][1]);	
	}
}

public Action cmd_losuj(int client,int args)
{
	char buf[12];
	GetCmdArg(1, buf, sizeof(buf));
	args = StringToInt(buf); 
	
	random = args;
	if(IsValidClient(client))
	{
		PrintCenterText(client, "<font color='#03ecfc'>Wylosowałeś: %s Opis: %s</font>", SuperMoc[random][0], SuperMoc[random][1]);
			
		switch(random)
		{
			case 0:
			{
				player[client] = 0;
			}
			case 1:
			{	
				player[client] = 1;
				SetEntityHealth(client, 1000);
			}
			case 2:
			{
				player[client] = 2;
			}
			case 4:
			{
				player[client] = 4;
				SetEntityRenderMode(client, RENDER_TRANSALPHA);
				SetEntityRenderColor(client, 255, 255, 255, 30);
			}
			case 5:
			{
				player[client] = 5;
				SetEntityGravity(client, 0.3);
			}
			case 6:
			{
				player[client] = 6;
			}
			case 7:
			{
				player[client] = 7;
				SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 2.5);
			}
			case 8:
			{
				player[client] = 8;
			}
			case 9:
			{
				player[client] = 9;
			}
			case 10:
			{
				int tmp;
				
				player[client] = 10;
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					tmp = GetRandomInt(5,9);
				}				
				else
				{
					tmp = GetRandomInt(0,4);
				}
				
				SetEntityModel(client,modele_serwera[tmp]);
			}
			case 11:
			{
				player[client] = 11;
			}
			case 13:
			{
				player[client] = 13;
				SetEntData(client, FindSendPropInfo("CCSPlayer", "m_iAccount"), 16000);
			}
			case 16:
			{
				player[client] = 16;
			}
		}
		PrintToChatAll("Gracz %N wylosował: %s",client , SuperMoc[random][0]);
	}
}
public Action PlayerDeath(Handle:event_death, String:name[], bool:dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event_death ,"userId"));
	int attacker = GetClientOfUserId(GetEventInt(event_death, "attacker"));
	
	if(IsValidClient(client) && IsValidClient(attacker))
	{
		switch(player[client])
		{
			case 0:
			{
				PrintToChatAll("%N mógł zabić %N jednym strzałem ale sam umiera",client,attacker);
			}
			case 1:
			{
				PrintToChatAll("%N był prawie nieśmiertelny",client);
			}
			case 2:
			{
				PrintToChatAll("%N zabija gracza %N i wysysa z niego %i HP ",attacker,client,wampir_ile[attacker]*10);
			}
			case 5:
			{
				PrintToChatAll("%N odlatuje w kosmos --->>>>>",client);
			}
			case 9:
			{
				PrintToChatAll("%N Zmarł kliniczną śmiercią",client);
			}
			case 11:
			{
				PrintToChatAll("%N Miało byc bez sprzętów :C",client);
			}
			case 16:
			{
				if(morfina[client] == 0)
				{
					morfina[client] = 1;
					CreateTimer(0.1, respanw, client, TIMER_FLAG_NO_MAPCHANGE);
				}
				else
				{
					PrintToChatAll("Nie udało się wyciągnąć z zaświatów %N",client);
				}
			}
		}
	}

}

public Action respanw(Handle timer, any client)
{
	if(IsValidClient(client))
	{
		PrintToChatAll("%N Dostaje drugą szansę od boga !",client);
		CS_RespawnPlayer(client);
	
	}
}

public Action OnTakeDamage(int client,int & attacker,int & inflictor, float & damage,int & damagetype)
{
	if(IsValidClient(client) && IsValidClient(attacker) && IsClientInGame(client) && IsClientInGame(attacker))
	{
		switch(player[attacker])
		{
			case 0:
			{
				if(attacker != client)
				{
					if (GetClientTeam(client) != GetClientTeam(attacker))
					{
						damage = 1000.00;
					}
				}
				
			}
			case 2:
			{
				if(attacker != client)
				{
					if (GetClientTeam(client) != GetClientTeam(attacker))
					{
						int health = GetClientHealth(attacker);
						SetEntityHealth(attacker, health+10);
						wampir_ile[attacker]++;
					}
				}
			}
			case 9:
			{
				if (GetClientTeam(client) == GetClientTeam(attacker))
				{
					if(attacker != client)
					{
						if (GetClientHealth(client) <= 99)
						{
							damage = 0.00;
							int health = GetClientHealth(client);
							SetEntityHealth(client,health+10);
							
							if(GetClientHealth(client) >= 101)
							{
								SetEntityHealth(client, 100);
							}
							
							PrintHintText(attacker, "Leczysz gracza: %N Jego zdrowie to: %i", client, GetClientHealth(client));
						}
						else
						{
							damage = 0.00;
						}
					}
				}
			}
			case 11:
			{
	            char sWeaponName[64];
	            if(IsValidClient(client))
	            {
	           		GetClientWeapon(attacker, sWeaponName, sizeof(sWeaponName));
	           		
	           		if(StrContains(sWeaponName, "knife", false) != -1 || StrContains(sWeaponName, "bayonet", false) != -1)
				    {
				        damage = 2000.00;
				    }
	          	}
			}
			default:
			{
				if(player[client] == 6)
				{
					damage *= 0.75;
				}
			}
		}
	}
	return Plugin_Changed;
}

public Action RoundStart(Handle event,char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i)) 
		{
			int tab[13] =  {0,1,2,4,5,7,6,8,9,10,11,13,16};
			random = tab[GetRandomInt(0, 12)];
			
			player[i] = random;

			PrintCenterText(i, "Wylosowałeś: %s Opis: %s", SuperMoc[random][0], SuperMoc[random][1]);
			
			switch(player[i])
			{
				case 1:
				{		
					SetEntityHealth(i, 1000);
				}
				case 4:
				{
					SetEntityRenderMode(i, RENDER_TRANSALPHA);
					SetEntityRenderColor(i, 255, 255, 255, 30);
				}
				case 5:
				{
					SetEntityGravity(i, 0.3);
				}
				case 7:
				{
					SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", 2.5);
				}
				case 10:
				{
					int tmp;
					if (GetClientTeam(i) == CS_TEAM_CT)
					{
						tmp = GetRandomInt(5,9);
					}				
					else
					{
						tmp = GetRandomInt(0,4);
					}
					
					SetEntityModel(i,modele_serwera[tmp]);
				}
				case 13:
				{
					SetEntData(i, FindSendPropInfo("CCSPlayer", "m_iAccount"), 16000);
				}
				case 16:
				{
					morfina[i] = 0;
				}
			}
		}
	}
}

public Action EventWeaponFire(Event gEventHook,char[] gEventName, bool iDontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(gEventHook, "userid")); 

    if(player[client] == 8)
    {
        int iWeapon = Client_GetActiveWeapon(client);

        if(IsValidEdict(iWeapon))
        {
            Weapon_SetPrimaryClip(iWeapon, Weapon_GetPrimaryClip(iWeapon) + 1);
        }
    }
}

public Client_GetActiveWeapon(client)
{
    int weapon =  GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
    
    if (!Entity_IsValid(weapon)) 
    {
        return INVALID_ENT_REFERENCE;
    }
    
    return weapon;
}

public Entity_IsValid(entity)
{
    return IsValidEntity(entity);
}

public Weapon_SetPrimaryClip(weapon, value)
{
    SetEntProp(weapon, Prop_Data, "m_iClip1", value);
}

public Weapon_GetPrimaryClip(weapon)
{
    return GetEntProp(weapon, Prop_Data, "m_iClip1");
}

public Action RoundStop(Handle event, char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		player[i] = 17;
		SetEntityRenderMode(player[i], RENDER_TRANSALPHA);
		SetEntityRenderColor(player[i], 255, 255, 255, 255);
		SetEntPropFloat(player[i], Prop_Send, "m_flLaggedMovementValue", 1.0);
		SetEntityGravity(player[i], 1.0);
		SetEntityHealth(player[i], 100);
		PrintCenterText(player[i], "%s super mocy. %s", SuperMoc[player[i]][0], SuperMoc[player[i]][1]);
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(wampir_ile[i] >= 1)
		{
			wampir_ile[i] = 0;
		}
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(morfina[i] >= 1)
		{
			morfina[i] = 0;
		}
	}
	
	PrintToChatAll("[My-Speak24.pl Informator] Wpisz !help aby wyświetlić listę poleceń.");
}

public Action ShowHud(Handle timer,int client)
{
	if (Hud_ON[client] == 1)
	{
		SetHudTextParams(-1.0, 0.9, 1.5, 0, 255, 0, 255);
		ShowHudText(client, -1, "Obecna moc: %s \n Opis: %s \n My-Speak24.pl Pozdrawia", SuperMoc[player[client]][0], SuperMoc[player[client]][1]);
		
		CreateTimer(1.0, ShowHud, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	return Plugin_Continue;
}

public OnPlayerSpawn(Handle event, char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    
    if(Hud_ON[client] == 1)
    {
  		 CreateTimer(1.0, ShowHud, client, TIMER_FLAG_NO_MAPCHANGE);
   	}

}

public bool IsValidClient(client)
{
    if(client >= 1 && client <= MaxClients && IsClientInGame(client))
        return true;

    return false;
}

public Action SetCvars(Handle timer)
{
    ServerCommand("sv_disable_immunity_alpha 1");
    ServerCommand("mp_warmup_end");
}