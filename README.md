# ff2_boss_viewer
A SourceMod plugin designed to neatly list all available Freak Fortress 2 bosses and some of their config data(Descriptions, health, themes...)
in a browser.

**Requirements:**
- Webcon & Conplex by asherkin
- Freak Fortress 2 (runtime only, not required at compile time)
- Rest in Pawn

**Installation:**
- Compile and install to respective directories. 
- Load the plugin or change map.

**Providing boss images:**
Create .png images of your bosses and upload them to /configs/web/bosses/images.
Take placeholder.png dimensions as an example to avoid having different image sizes.
Image filenames must be equal to that of their respective boss, for example hhh_boss.cfg -> hhh_boss.png.

**Remote file hosting**
If you'd like to host the web front-end somewhere else (like a FastDownloads web server), please do the following:
- Move the contents of the "bosses" folder on your game server to your desired location on the web server.
    Make sure to not forget about images as well. The final result should look something like this:
    example.com/...
                .../bosses/index.html
                .../bosses/loader.js
                .../bosses/style.css
                .../bosses/images/placeholder.png
                .../bosses/images/*.png

- Change the **ff2list_enable_web** ConVar to 0. Save that ConVar in server.cfg.

**Live example:**
http://95.172.92.47:27015/bosses/

**Credits**
- Naydef for general assistance
- NecGaming for being my personal sandbox, as usual
- MadeInQuick for providing the placeholder image
- Respective authors of code pieces that I borrowed (50-DKP team of Official Freak Fortress, ...)
