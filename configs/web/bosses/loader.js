
const path = "SERVERIP"
var info;
document.addEventListener("DOMContentLoaded", ready);

function ready() {
    info = JSON.parse(httpGet("http://" + path + "/bosses/query"));
    var sourceitem = document.getElementById("source");
    var flex = document.getElementById("flexbox");

    for (var key in info.freaks) {
        var newnode = sourceitem.cloneNode(true);
        newnode.childNodes[1].innerHTML = info.freaks[key].name;
        newnode.childNodes[3].childNodes[1].src = "http://" + path + "/bosses/images/" + info.freaks[key].image + ".png";
        newnode.childNodes[5].childNodes[1].id = key;
        flex.append(newnode);
    }
    sourceitem.remove();
}

function httpGet(theUrl) {
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open("GET", theUrl, false);
    xmlHttp.send(null);
    return xmlHttp.responseText;
}

function showModalDialog(boxid) {
    var wrapper = document.createElement('div');
    var health = document.createElement('p');
    var ragedamage = document.createElement('p');
    var lives = document.createElement('p');
    var description = document.createElement('p');
    var themes = document.createElement('div');
    for (key in info.freaks[boxid].themes) {
        if (info.freaks[boxid].themes[key].artist == "NOTFOUND")
            continue;
        var themedata = document.createElement('p');
        themedata.innerHTML = "Theme " + key + "<br/>Artist: " + info.freaks[boxid].themes[key].artist + "<br/>Name: " + info.freaks[boxid].themes[key].name;
        themes.appendChild(themedata);

    }
    health.innerHTML = "Health: " + info.freaks[boxid].health_formula;
    ragedamage.innerHTML = "Damage to Rage: " + info.freaks[boxid].ragedamage;
    lives.innerHTML = info.freaks[boxid].lives != "" ? "Lives: " + info.freaks[boxid].lives : "Lives: 1";
    description.innerHTML = info.freaks[boxid].description.replaceAll("\\n", "<br/>");
    wrapper.appendChild(ragedamage);
    wrapper.appendChild(health);
    wrapper.appendChild(lives);
    wrapper.appendChild(description);
    wrapper.appendChild(themes);
    swal({
        title: info.freaks[boxid].name,
        content: wrapper,
        buttons: false
    });
}

function showCredits() {
    var creditsdiv = document.createElement('div');
    var bywho = document.createElement('a');
    bywho.innerHTML = "Made with ♟💓♟ by Nolo001 (GitHub)";
    bywho.href = "https://github.com/Nolo001-Aha/ff2_boss_viewer";
    bywho.style = "color: white;"
    var help = document.createElement('p');
    help.innerHTML = "Inspired by Naydef.<br/>Template boss image by MadeInQuick.<br/><br/>Powered by SourcePawn, Webcon and SweetAlert 2.";
    creditsdiv.appendChild(bywho);
    creditsdiv.appendChild(help);
    swal({
        title: "Credits",
        content: creditsdiv

    });
}