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
// * 2013-03-17 -   0.1.2		-   Changed so map and player name print on same line.
// * 2013-03-17 -   0.1.3		-   Check for console, check for empty noms list.
// * 2013-03-17 -   0.1.4		-   Changed to use Plugin_Handled, added color.
// * 2013-03-17 -   0.1.5		-   added test for map vote completed.
// * 2013-03-17 -   0.1.6		-   fixed chat not showing up
// * 2013-03-18 -   1.0.0		-   bumped version for release, commented out debug msg
// * 2013-03-18 -   1.0.1		-   uncommented accidentally commented out debug msg, return !noms command to chat
// * 2013-03-18 -   1.1.0		-   added tests to honor "/" silent chat
// *                                
//	------------------------------------------------------------------------------------


#include <sourcemod>
#include <mapchooser>

#pragma semicolon 1

#define PLUGIN_VERSION	"1.1.0"

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
		
		new numNominations;

		if (HasEndOfMapVoteFinished())
		{
			// Is this to one client or public?
			if (text[startidx] == '/')
			{
				PrintToChat(client, "\x04[Noms]\x01 -map vote completed-");
			}
			else
			{
				PrintToChatAll("\x04[Noms]\x01 -map vote completed-");
			}
		}
		else
		{
			if ( (numNominations = GetArraySize(g_NominateList)) == GetArraySize(g_NominateOwners) )
			{
				new String:map[64];
				new clientIndex;
				new String:name[65];
				
				if (numNominations == 0)
				{
					// Is this to one client or public?
					if (text[startidx] == '/')
					{
						PrintToChat(client, "\x04[Noms]\x01 -empty-");
					}
					else
					{
						PrintToChatAll("\x04[Noms]\x01 -empty-");
					}
				}
				else
				{
					for (new i = 0; i < numNominations; i++)
					{		
						GetArrayString(g_NominateList, i, map, sizeof(map));

						clientIndex = GetArrayCell(g_NominateOwners, i);
						
						// Did an admin force a nomination?
						if (clientIndex == 0)
						{
							name = "Console";
						}
						else
						{
							GetClientName(clientIndex, name, sizeof(name));
						}
						
						// Print this to one client or public?
						if (text[startidx] == '/')
						{
							PrintToChat(client, "\x04[Noms]\x01 %s (%s)", map, name);
						}
						else
						{
							PrintToChatAll("\x04[Noms]\x01 %s (%s)", map, name);
						}
					}
				}
			}
			else
			{
				// We failed to get the same size arrays back from mapchooser!
				PrintToServer("[noms.smx]: ERROR - mapchooser array size mismatch");
				LogToGame("[noms.smx]: ERROR - mapchooser array size mismatch");
			}
		}

		// Silently return for '/'.
		if (text[startidx] == '/')
		{
			return Plugin_Handled;
		}
	
	}

	// We Continue so we don't block chat and we return the !noms command
	return Plugin_Continue;
}



