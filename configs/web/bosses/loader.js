
const path = "SERVERIP"
var info;
var selectedPack = 0;
var sourceBossItem;
info = JSON.parse(httpGet("http://" + path + "/bosses/query"));
document.addEventListener("DOMContentLoaded", ready);

function ready() {
    var sourcePackItem = document.getElementById("bossPackOptionSource");
    var bossPackSelect = document.getElementById("bossPackSelector");
    sourceBossItem = document.getElementById("source");

    for (var key in info) {
        var newnode = sourcePackItem.cloneNode(true);
        newnode.innerHTML = info[key].packName;
        newnode.value = key;
        bossPackSelect.append(newnode);
    }   
    sourcePackItem.remove();

    displayFreaks(selectedPack);

}

function updateBossList()
{
    var bossPackSelected = document.getElementById("bossPackSelector").value;
    if(selectedPack == bossPackSelected)
        return;
    var flex = document.getElementById("flexbox");
    removeAllChildNodes(flex)
    selectedPack = bossPackSelected
    displayFreaks(bossPackSelected)
}

function removeAllChildNodes(parent) {
    while (parent.firstChild) {
        console.log(parent.firstChild.id)
        parent.removeChild(parent.firstChild);
    }
}

function displayFreaks(packId)
{
    var flex = document.getElementById("flexbox");
    for (var key in info[packId]) {
        var newnode = sourceBossItem.cloneNode(true);
        newnode.childNodes[1].innerHTML = info[packId][key].name;
        newnode.childNodes[3].childNodes[1].src = "http://" + path + "/bosses/images/" + info[packId][key].image + ".png";
        newnode.childNodes[5].childNodes[1].id = key;
        newnode.hidden = false;
        flex.append(newnode);
    }
    sourceBossItem.hidden = true;
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
    for (key in info[selectedPack][boxid].themes) {
        if (info[selectedPack][boxid].themes[key].artist == "NOTFOUND")
            continue;
        var themedata = document.createElement('p');
        themedata.innerHTML = "Theme " + key + "<br/>Artist: " + info[selectedPack][boxid].themes[key].artist + "<br/>Name: " + info[selectedPack][boxid].themes[key].name;
        themes.appendChild(themedata);

    }
    health.innerHTML = "Health: " + info[selectedPack][boxid].health_formula;
    ragedamage.innerHTML = "Damage to Rage: " + info[selectedPack][boxid].ragedamage;
    lives.innerHTML = info[selectedPack][boxid].lives != "" ? "Lives: " + info[selectedPack][boxid].lives : "Lives: 1";
    description.innerHTML = info[selectedPack][boxid].description.replaceAll("\\n", "<br/>");
    wrapper.appendChild(ragedamage);
    wrapper.appendChild(health);
    wrapper.appendChild(lives);
    wrapper.appendChild(description);
    wrapper.appendChild(themes);
    swal({
        title: info[selectedPack][boxid].name,
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