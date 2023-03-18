
const path = "95.172.92.47:27015"
var info;
var selectedPack = 0;
var sourceBossItem;
var xhr;
var imagesOnScrds = true;

document.addEventListener("DOMContentLoaded", httpGetAsync("http://" + path + "/bosses/query", ready));

function ready() {
    if (xhr.readyState != 4) return;
    info = JSON.parse(xhr.responseText);
    var sourcePackItem = document.getElementById("bossPackOptionSource");
    var bossPackSelect = document.getElementById("bossPackSelector");
    bossPackSelect.addEventListener('change', function () {
        updateBossList();
    });
    sourceBossItem = document.getElementById("source");

    imagesOnScrds = info['serveImagesFromScrds'];

    for (var key in info) {
        if(key === "serveImagesFromScrds")
            continue; //ugly.

        var newnode = sourcePackItem.cloneNode(true);
        newnode.innerHTML = info[key].packName;
        newnode.value = key;
        bossPackSelect.append(newnode);
    }
    sourcePackItem.remove();

    displayFreaks(selectedPack);
}

function httpGetAsync(theUrl, callback) {
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open("GET", theUrl, true);
    xmlHttp.onload = callback;
    xmlHttp.send(null);
    xhr = xmlHttp;
}

function updateBossList() {
    var bossPackSelected = document.getElementById("bossPackSelector").value;
    if (selectedPack == bossPackSelected)
        return;
    var flex = document.getElementById("flexbox");
    removeAllChildNodes(flex)
    selectedPack = bossPackSelected
    displayFreaks(bossPackSelected)
}

function removeAllChildNodes(parent) {
    while (parent.firstChild) {
        parent.removeChild(parent.firstChild);
    }
}

function displayFreaks(packId) {
    var flex = document.getElementById("flexbox");
    for (var key in info[packId]) {
        if (key === "packName") //this is ugly.
            continue;
        var newnode = sourceBossItem.cloneNode(true);
        newnode.childNodes[1].innerHTML = info[packId][key].name;
        var imageName = info[packId][key].image;
        if(imageName.includes("/"))
        {
            var imagePathArray = imageName.split("/");
            imageName = imagePathArray[imagePathArray.length-1];
        }
        newnode.childNodes[3].childNodes[1].src = 
                                                   imagesOnScrds === true ? 
                                                                        "http://" + 
                                                                        path + 
                                                                        "/bosses/images/" + 
                                                                        imageName + 
                                                                        ".png"
                                                                        :
                                                                        "images/" +
                                                                        imageName + 
                                                                        ".png";
        newnode.childNodes[5].childNodes[1].id = key;
        newnode.hidden = false;
        flex.append(newnode);
    }
    sourceBossItem.hidden = true;
}


function showModalDialog(boxid) {
    var wrapper = document.createElement('div');
    var health = document.createElement('p');
    var ragedamage = document.createElement('p');
    var lives = document.createElement('p');
    var description = document.createElement('p');
    var themes = document.createElement('div');

    var table = document.createElement('table');
    table.id = "health-table";
    table.setAttribute('title', 'N.B.: The data shown are per life');
    table.style = 'width:100%; height:100%;display:none';


    for (key in info[selectedPack][boxid].themes) {
        if (info[selectedPack][boxid].themes[key].artist == "NOTFOUND")
            continue;
        var themedata = document.createElement('p');
        themedata.innerHTML = "Theme " + key + "<br/>Artist: " + info[selectedPack][boxid].themes[key].artist + "<br/>Name: " + info[selectedPack][boxid].themes[key].name;
        themes.appendChild(themedata);

    }

    table.innerHTML += `
    <tr>
    <th>Player count</th>
    <th>Health</th>
    <th>Δ</th>
    </tr>`;
    var old = 0;
    for (var i = 1; i <= 27; i++) {
        var scope = { n: i, x: i };
        var answer = Math.round(math.eval(info[selectedPack][boxid].health_formula, scope));
        var delta = (answer - old);

        table.innerHTML += `
        <tr>
        <td>` + i + `</td>
        <td>` + answer.toLocaleString() + `</td>
        <td>` + delta.toLocaleString() + `</td>
        </tr>`;
        old = answer;
    }

    health.innerHTML = "Health: `" + info[selectedPack][boxid].health_formula + "`";
    //MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
    ragedamage.innerHTML = "Damage to Rage: " + info[selectedPack][boxid].ragedamage;
    lives.innerHTML = info[selectedPack][boxid].lives != "" ? "Lives: " + info[selectedPack][boxid].lives : "Lives: 1";
    description.innerHTML = info[selectedPack][boxid].description.replaceAll("\\n", "<br/>");
    wrapper.appendChild(ragedamage);
    wrapper.appendChild(health);
    wrapper.appendChild(lives);
    wrapper.appendChild(description);
    wrapper.appendChild(themes);
    wrapper.appendChild(table);
    swal({
        title: info[selectedPack][boxid].name,
        content: wrapper,
        buttons: false
    });

    MathJax.typesetPromise()
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