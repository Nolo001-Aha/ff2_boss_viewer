#include <sourcemod>
#include <webcon>
#include <ripext>

#pragma semicolon 1
#pragma newdecls required
#pragma dynamic 300000
#define BASE_PATH "configs/web/bosses/"

WebResponse indexResponse;
WebResponse cssResponse;
WebResponse jsResponse;
WebResponse dataResponse;

JSONObject jsonPackObject; //Pack object, will contain jsonFreaksObject
JSONObject jsonCurrentPackObject; //temporary object that we use while we're traversing a given pack. gets appended to jsonPackObject later

enum FF2Version {
	FF2Version_Legacy = 0,
	FF2Version_Rewrite = 1
}

FF2Version ff2Version = FF2Version_Legacy;

char  placeholder[PLATFORM_MAX_PATH];

public Plugin myinfo = 
{
	name = "Freak Fortress 2: Web List",
	author = "Nolo001",
	description = "Lists all bosses and their data from the current character set on a web page",
	version = "1.5",
	url = "https://github.com/Nolo001-Aha/ff2_boss_viewer"
};

public void OnPluginStart()
{

	if (!Web_RegisterRequestHandler("bosses", OnWebRequest, "Freak Fortress: List", "Live Freak Fortress 2 boss list"))
		SetFailState("Failed to register request handler.");

	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), BASE_PATH ... "index.html");
	indexResponse = new WebFileResponse(path);
	indexResponse.AddHeader(WebHeader_ContentType, "text/html; charset=UTF-8");

	BuildPath(Path_SM, path, sizeof(path), BASE_PATH ... "style.css");
	cssResponse = new WebFileResponse(path);
	cssResponse.AddHeader(WebHeader_ContentType, "text/css; charset=UTF-8");

	BuildPath(Path_SM, path, sizeof(path), BASE_PATH ... "loader.js");
	jsResponse = new WebFileResponse(path);
	jsResponse.AddHeader(WebHeader_ContentType, "text/javascript; charset=UTF-8");

	BuildPath(Path_SM, placeholder, sizeof(placeholder), BASE_PATH ... "images/placeholder.png");

}

void checkFF2Version()
{
	if(LibraryExists("freak_fortress_2"))
	{
		ff2Version = FF2Version_Legacy; //we're running legacy FF2
		if(LibraryExists("ff2r")) //FF2R registers both libraries for backwards compatibility, also check if ff2r is loaded
			ff2Version = FF2Version_Rewrite;			

		PrintToServer("FF2 Version is %i", ff2Version);
		return;
	}
	SetFailState("Unable to determine FF2 version (Legacy or Rewrite). Is FF2 loaded?"); //only fires if none of the libraries are available
}

void processLoaderScript()
{
	char path[PLATFORM_MAX_PATH], serverip[64];
	BuildPath(Path_SM, path, sizeof(path), BASE_PATH ... "loader.js");
	File script = OpenFile(path, "r+");
	int size = FileSize(path, false, "") + 64; //weird behavior, adding 64 more bits so it works as intended
	char[] contents = new char[size];
	script.ReadString(contents, size);
	GetServerIP(serverip, sizeof(serverip));
	ReplaceString(contents, size, "SERVERIP", serverip, false);
	script.Seek(0, SEEK_SET);
	script.WriteString(contents, false);
	script.Flush();
	script.Close();
}

stock void GetServerIP(char[] ip, int length)
{
	int hostip = FindConVar("hostip").IntValue;

	Format(ip, length, "%d.%d.%d.%d:%i",
	(hostip >> 24 & 0xFF),
	(hostip >> 16 & 0xFF),
	(hostip >> 8 & 0xFF),
	(hostip & 0xFF),
	FindConVar("hostport").IntValue
	);
}

public bool OnWebRequest(WebConnection connection, const char[] method, const char[] url)
{
	if (StrEqual(url, "/query")) 
	{
		char buffer[512000];
		jsonPackObject.ToString(buffer, sizeof(buffer));
		dataResponse = new WebStringResponse(buffer);
		dataResponse.AddHeader(WebHeader_ContentType, "application/json; charset=utf-8");
		dataResponse.AddHeader(WebHeader_CacheControl, "public, max-age=5");
		dataResponse.AddHeader(WebHeader_AccessControlAllowOrigin, "*");
		return connection.QueueResponse(WebStatus_OK, dataResponse);
	}

	if (StrEqual(url, "/loader.js"))
    	{
		return connection.QueueResponse(WebStatus_OK, jsResponse);
	}

	if (StrEqual(url, "/style.css"))
   	{
		return connection.QueueResponse(WebStatus_OK, cssResponse);
	}
	if (StrEqual(url, "/")) 
	{
		return connection.QueueResponse(WebStatus_OK, indexResponse);
	}
	if (StrContains(url, "/images/", false) != -1) 
	{
		char buffer[64][4], path[PLATFORM_MAX_PATH];
		ExplodeString(url, "/", buffer, 4, sizeof(buffer));
		BuildPath(Path_SM, path, sizeof(path), BASE_PATH ... "images/%s", buffer[2]);
		WebResponse failResponse = new WebFileResponse(path);
		failResponse.AddHeader(WebHeader_ContentType, "image/png");
		return connection.QueueResponse(WebStatus_OK, failResponse);
	}

}

public void OnAllPluginsLoaded()
{
	checkFF2Version();
	processLoaderScript();

	jsonPackObject = new JSONObject();

	processConfigs();
}

void processConfigs()
{
	int packCount = 0;
	char config[PLATFORM_MAX_PATH], packName[PLATFORM_MAX_PATH];


	BuildPath(Path_SM, config, sizeof(config), "data/freak_fortress_2/characters.cfg");

	KeyValues Kv=new KeyValues("Keys");
	Kv.ImportFromFile(config);

	Kv.Rewind();
	do
	{
		int configCount = 0;
		Kv.GetSectionName(packName, sizeof(packName));
		if(!packName[0])
			break;

		jsonCurrentPackObject = new JSONObject();

		jsonCurrentPackObject.SetString("packName", packName);

		Kv.GotoFirstSubKey(ff2Version == FF2Version_Legacy ? true : false);
		do
		{
			Kv.GetSectionName(config, sizeof(config));
			if(!config[0])
				break;	

			LoadCharacter(config, configCount);
			configCount++;


		}
		while(Kv.GotoNextKey(ff2Version == FF2Version_Legacy ? true : false));

		Kv.GoBack();
		char key[4];
		IntToString(packCount, key, sizeof(key));
		jsonPackObject.Set(key, jsonCurrentPackObject);
		packCount++;	
		
	}
	while(Kv.GotoNextKey());
}

void LoadCharacter(const char[] cfg, int count)
{	
	char config[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, config, sizeof(config), "configs/freak_fortress_2/%s.cfg", cfg);
	KeyValues kv = new KeyValues("");
	kv.ImportFromFile(config);
	kv.Rewind();
	kv.JumpToKey("character");
	char index[16], buffer[1024], path[PLATFORM_MAX_PATH];

	JSONObject jsonBossDataObject = new JSONObject();
	kv.GetString("name", buffer, sizeof(buffer));
	jsonBossDataObject.SetString("name", buffer);
	BuildPath(Path_SM, path, sizeof(path), BASE_PATH ... "images/%s.png", cfg);
	jsonBossDataObject.SetString("image", FileExists(path) ? cfg : "placeholder"); //placeholder
	kv.GetString("ragedamage", buffer, sizeof(buffer));
	jsonBossDataObject.SetString("ragedamage", buffer);
	kv.GetString("health_formula", buffer, sizeof(buffer));
	jsonBossDataObject.SetString("health_formula", buffer);
	kv.GetString("description_en", buffer, sizeof(buffer));
	jsonBossDataObject.SetString("description", buffer);
	kv.GetString("lives", buffer, sizeof(buffer));
	jsonBossDataObject.SetString("lives", buffer);
	char section_name[128];
	kv.GetSectionName(section_name, sizeof(section_name));
	kv.JumpToKey("sound_bgm");
	JSONObject themeJsonObject = new JSONObject();
	for (int i = 1; ; i++)
	{
		JSONObject themeJsonDataObject = new JSONObject();
		Format(buffer, sizeof(buffer), "artist%i", i);
		kv.GetString(buffer, section_name, sizeof(section_name), "NOTFOUND");
		if(strcmp(section_name, "NOTFOUND") == 0)
		{
			delete themeJsonDataObject;
			break;
		}
		themeJsonDataObject.SetString("artist", section_name);
		Format(buffer, sizeof(buffer), "name%i", i);
		kv.GetString(buffer, section_name, sizeof(section_name), "NOTFOUND");
		themeJsonDataObject.SetString("name", section_name);
		IntToString(i, index, sizeof(index));
		themeJsonObject.Set(index, themeJsonDataObject);
		delete themeJsonDataObject;
	}
	jsonBossDataObject.Set("themes", themeJsonObject);
	IntToString(count, index, sizeof(index));
    jsonCurrentPackObject.Set(index, jsonBossDataObject);
	delete themeJsonObject;
	delete jsonBossDataObject;
}

