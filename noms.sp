//	------------------------------------------------------------------------------------
//	Filename:		noms.sp
//	Author:			Malachi
//	Version:		(see PLUGIN_VERSION)
//	Description:
//					Plugin displays the current status of alltalk and teamtalk in 
//					response to chat commands ("!alltalk") and at the beginning of a round.
//
// * Changelog (date/version/description):
// * 2013-01-23	-	0.1.1		-	initial dev version
// * 2013-03-17 -   0.1.1.1     -   Added new array handling
//	------------------------------------------------------------------------------------


#include <sourcemod>
#include <mapchooser>

#pragma semicolon 1

#define PLUGIN_VERSION	"0.1.1.1"

new Handle:g_NominateList = INVALID_HANDLE;
new Handle:g_NominateOwners = INVALID_HANDLE;


public Plugin:myinfo = 
{
	name = "Noms",
	author = "Malachi",
	description = "prints nominated maps to clients",
	version = PLUGIN_VERSION,
	url = "www.necrophix.com"
}


public OnPluginStart()
{
	g_NominateList = CreateArray( ByteCountToCells(33) );
	g_NominateOwners = CreateArray(1);

	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_Say, "say_team");			
}


public Action:Command_Say(client, const String:command[], args)
{	
	new String:text[192];
	GetCmdArgString(text, sizeof(text));
	
	new startidx = 0;
	if (text[0] == '"')
	{
		startidx = 1;
		
		new len = strlen(text);
		if (text[len-1] == '"')
		{
			text[len-1] = '\0';
		}
	}
	
	if(StrEqual(text[startidx], "!noms") || StrEqual(text[startidx], "/noms"))
	{
		ClearArray(g_NominateList);
		ClearArray(g_NominateOwners);

		GetNominatedMapList(g_NominateList, g_NominateOwners);
		
		if ( (g_NominateList == INVALID_HANDLE) && (g_NominateOwners == INVALID_HANDLE) )
		{
			PrintToServer("[noms.smx]: Invalid arrays");
			LogToGame("[noms.smx]: Invalid arrays");
		}
		else
		{
			if (g_NominateList != INVALID_HANDLE)
			{
				new NominateListSize;		
				NominateListSize = GetArraySize(g_NominateList);
				PrintToServer("[noms.smx]: MapArray Size=%d", NominateListSize);
				LogToGame("[noms.smx]: MapArray Size=%d", NominateListSize);

				new String:map[33];
				
				for (new i = 0; i < NominateListSize; i++)
				{		
					GetArrayString(g_NominateList, i, map, sizeof(map));
					PrintToChatAll("Noms: %s", map);
				}
			}
					
			if (g_NominateOwners != INVALID_HANDLE)
			{
				new NominateOwnersSize;
				NominateOwnersSize = GetArraySize(g_NominateOwners);
				PrintToServer("[noms.smx]: OwnerArray Size=%d", NominateOwnersSize);
				LogToGame("[noms.smx]: OwnerArray Size=%d", NominateOwnersSize);

				new clientIndex;
				new String:name[32];

				for (new i = 0; i < NominateOwnersSize; i++)
				{		
					clientIndex = GetArrayCell(g_NominateOwners, i);

					GetClientName(clientIndex, name, sizeof(name));
					
					PrintToChatAll("Noms: %s", name);
				}
			}
		}
		
	}
		
	return Plugin_Continue;
}



