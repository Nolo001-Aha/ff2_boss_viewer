#include <sourcemod>
#include <webcon>
#include <freak_fortress_2>
#include <ripext>

#pragma semicolon 1
#pragma newdecls required
#pragma dynamic 300000
#define BASE_PATH "configs/web/bosses/"

WebResponse indexResponse;
WebResponse cssResponse;
WebResponse jsResponse;
WebResponse dataResponse;

JSONObject responseObject; //what we send to clients
JSONObject jsonDataObject; //everything inside "freaks"
JSONObject jsonBossDataObject; //contains temporary boss info JSON until appended to jsonDataObject
JSONObject themeJsonObject; //contains final JSON for themes

public Plugin myinfo = 
{
	name = "Freak Fortress 2: Web List",
	author = "Nolo001",
	description = "Lists all bosses and their data from the current character set on a web page",
	version = "0.9",
	url = "https://github.com/Nolo001-Aha/ff2_boss_viewer"
};

public void OnPluginStart()
{

	if (!Web_RegisterRequestHandler("bosses", OnWebRequest, "Freak Fortress: List", "Live Freak Fortress 2 boss list"))
		SetFailState("Failed to register request handler.");

	responseObject = new JSONObject();
	jsonDataObject = new JSONObject();
	char path[PLATFORM_MAX_PATH];
	Test(0, "test"); //ugly workaround for now until proper release
	responseObject.Set("freaks", jsonDataObject);
	BuildPath(Path_SM, path, sizeof(path), BASE_PATH ... "index.html");
	indexResponse = new WebFileResponse(path);
	indexResponse.AddHeader(WebHeader_ContentType, "text/html; charset=UTF-8");

	BuildPath(Path_SM, path, sizeof(path), BASE_PATH ... "style.css");
	cssResponse = new WebFileResponse(path);
	cssResponse.AddHeader(WebHeader_ContentType, "text/css; charset=UTF-8");

	BuildPath(Path_SM, path, sizeof(path), BASE_PATH ... "loader.js");
	jsResponse = new WebFileResponse(path);
	jsResponse.AddHeader(WebHeader_ContentType, "text/javascript; charset=UTF-8");

}

public bool OnWebRequest(WebConnection connection, const char[] method, const char[] url)
{
	if (StrEqual(url, "/query")) {
		char buffer[512000];
		responseObject.ToString(buffer, sizeof(buffer));
		dataResponse = new WebStringResponse(buffer);
		dataResponse.AddHeader(WebHeader_ContentType, "application/json");
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

}

public void Test(int set, char[] buffer) //dont look at me like that. Borrowed from FF2 source
{
	int count=0;
	char config[PLATFORM_MAX_PATH], key[4];
	bool new_file_format=true;
	BuildPath(Path_SM, config, sizeof(config), "data/freak_fortress_2/characters.cfg");

	if(!FileExists(config))
	{
		BuildPath(Path_SM, config, sizeof(config), "configs/freak_fortress_2/characters.cfg");
		new_file_format=false;
	}

	KeyValues Kv=new KeyValues("");
	FileToKeyValues(Kv, config);
	int NumOfCharSet=set;

	Kv.Rewind();
	for(int i; i<NumOfCharSet; i++)
		Kv.GotoNextKey();
	
	if(!new_file_format)
	{
		for(int i=1; i<128; i++)
		{
			IntToString(i, key, sizeof(key));
			Kv.GetString(key, config, PLATFORM_MAX_PATH);
			if(!config[0])
				break;

			LoadCharacter(config, count);
			count++;
		}
	}
	else
	{
		Kv.GotoFirstSubKey();
		do
		{
			Kv.GetSectionName(config, sizeof(config));
			if(!config[0])
				break;

			LoadCharacter(config, count);
			count++;
		}
		while(Kv.GotoNextKey());
		Kv.GoBack();
	}
}

void LoadCharacter(const char[] cfg, int count)
{	
	char config[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, config, sizeof(config), "configs/freak_fortress_2/%s.cfg", cfg);
	KeyValues kv = new KeyValues("");
	kv.ImportFromFile(config);
	kv.Rewind();
	kv.JumpToKey("character");
	char index[16], buffer[1024];

	jsonBossDataObject = new JSONObject();
	kv.GetString("name", buffer, sizeof(buffer));
	jsonBossDataObject.SetString("name", buffer);
	BuildPath(Path_SM, config, sizeof(config), "configs/web/bosses/images/%s.png", cfg);
	jsonBossDataObject.SetString("image", FileExists(config) ? cfg : "https://cdn.discordapp.com/attachments/581545730494169100/1038900114867101727/placeholder_2.png"); //placeholder
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
	themeJsonObject = new JSONObject();
	for (int i = 1; i<=10; i++)
	{
		JSONObject themeJsonDataObject = new JSONObject();
		Format(buffer, sizeof(buffer), "artist%i", i);
		kv.GetString(buffer, section_name, sizeof(section_name), "NOTFOUND");
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
    jsonDataObject.Set(index, jsonBossDataObject);
	delete themeJsonObject;
	delete jsonBossDataObject;
}

