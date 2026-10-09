// ========================================
// ROVER AGROTECH - LOCALIZAÇÃO
// ========================================

const API_URL = "http://127.0.0.1:8000";

const token = localStorage.getItem("access_token");


// ========================================
// VERIFICAR LOGIN
// ========================================

if (!token) {
    window.location.href = "login.html";
}


// ========================================
// ELEMENTOS DA PÁGINA
// ========================================

const roverSelect = document.getElementById("roverSelect");
const roverName = document.getElementById("roverName");
const latitudeElement = document.getElementById("latitude");
const longitudeElement = document.getElementById("longitude");
const lastUpdate = document.getElementById("lastUpdate");
const coordinates = document.getElementById("coordinates");
const locationStatus = document.getElementById("locationStatus");
const logoutButton = document.getElementById("logoutButton");
const refreshLocationButton = document.getElementById("refreshLocationButton");
const openMapButton = document.getElementById("openMapButton");


// ========================================
// MAPA
// ========================================

let map = L.map("map").fitWorld();

L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    attribution: "&copy; OpenStreetMap contributors"
}).addTo(map);


// ========================================
// MARCADOR DO ROVER
// ========================================

let roverMarker = null;


// ========================================
// CARREGAR ROVERS
// ========================================

async function carregarRovers() {

    try {

        const response = await fetch(`${API_URL}/rovers/`, {
            headers: {
                "Authorization": `Bearer ${token}`
            }
        });

        if (response.status === 401) {
            logout();
            return;
        }

        if (!response.ok) {
            throw new Error("Erro ao carregar os rovers.");
        }

        const data = await response.json();

        const rovers = Array.isArray(data)
            ? data
            : data.results || [];

        roverSelect.innerHTML = "";

        if (rovers.length === 0) {

            roverSelect.innerHTML = `
                <option value="">Nenhum rover encontrado</option>
            `;

            locationStatus.textContent = "Nenhum Rover cadastrado.";
            locationStatus.dataset.state = "unavailable";

            return;
        }


        // ========================================
        // ADICIONAR ROVERS AO SELECT
        // ========================================

        rovers.forEach(rover => {

            const option = document.createElement("option");

            option.value = rover.id_rover;

            option.textContent =
                `${rover.id_rover} - ${rover.nome}`;

            roverSelect.appendChild(option);

        });


        // ========================================
        // RECUPERAR ROVER SELECIONADO
        // ========================================

        const roverSalvo = localStorage.getItem("selected_rover");

        if (
            roverSalvo &&
            rovers.some(rover => rover.id_rover === roverSalvo)
        ) {

            roverSelect.value = roverSalvo;

        } else {

            roverSelect.value = rovers[0].id_rover;

        }


        await carregarLocalizacao(roverSelect.value);

    } catch (error) {

        console.error(error);

        locationStatus.textContent =
            "Erro ao carregar os rovers.";
        locationStatus.dataset.state = "error";

    }

}


// ========================================
// CARREGAR LOCALIZAÇÃO
// ========================================

async function carregarLocalizacao(idRover) {

    if (!idRover) {
        limparLocalizacao();
        roverName.textContent = "--";
        locationStatus.textContent =
            "Selecione um rover para consultar a localização.";
        locationStatus.dataset.state = "unavailable";
        return;
    }

    try {

        roverName.textContent =
            obterNomeRover(idRover) || idRover;
        limparLocalizacao();
        locationStatus.textContent =
            "Buscando última localização...";
        locationStatus.dataset.state = "loading";


        const response = await fetch(
            `${API_URL}/telemetrias/?rover=${encodeURIComponent(idRover)}`,
            {
                headers: {
                    "Authorization": `Bearer ${token}`
                }
            }
        );


        if (response.status === 401) {
            logout();
            return;
        }


        if (!response.ok) {
            throw new Error(
                "Erro ao carregar as telemetrias."
            );
        }


        const data = await response.json();

        const telemetrias = Array.isArray(data)
            ? data
            : data.results || [];


        // ========================================
        // VERIFICAR TELEMETRIA
        // ========================================

        if (telemetrias.length === 0) {

            limparLocalizacao();

            locationStatus.textContent =
                "Nenhuma telemetria encontrada para este Rover.";
            locationStatus.dataset.state = "unavailable";

            return;
        }


        // ========================================
        // ORDENAR DA MAIS RECENTE PARA A MAIS ANTIGA
        // ========================================

        telemetrias.sort((a, b) => {

            return new Date(b.data_hora) -
                   new Date(a.data_hora);

        });


        const ultimaTelemetria = telemetrias[0];


        // ========================================
        // VERIFICAR COORDENADAS
        // ========================================

        const latitude = ultimaTelemetria.latitude;
        const longitude = ultimaTelemetria.longitude;
        const lat = Number(latitude);
        const lng = Number(longitude);


        if (
            latitude == null ||
            String(latitude).trim() === "" ||
            longitude == null ||
            String(longitude).trim() === "" ||
            !Number.isFinite(lat) ||
            !Number.isFinite(lng) ||
            lat < -90 ||
            lat > 90 ||
            lng < -180 ||
            lng > 180
        ) {

            limparLocalizacao();

            locationStatus.textContent =
                "O Rover ainda não possui localização.";
            locationStatus.dataset.state = "unavailable";

            return;
        }


        // ========================================
        // ATUALIZAR INFORMAÇÕES
        // ========================================

        const nomeRover =
            obterNomeRover(idRover);

        roverName.textContent =
            nomeRover || idRover;

        latitudeElement.textContent =
            lat.toFixed(8);

        longitudeElement.textContent =
            lng.toFixed(8);


        coordinates.innerHTML = `
            Latitude: ${lat.toFixed(8)}<br>
            Longitude: ${lng.toFixed(8)}
        `;


        lastUpdate.textContent =
            formatarData(ultimaTelemetria.data_hora);


        locationStatus.textContent =
            "Localização atualizada com sucesso.";
        locationStatus.dataset.state = "success";


        // ========================================
        // ATUALIZAR MARCADOR
        // ========================================

        atualizarMarcador(
            lat,
            lng,
            nomeRover || idRover
        );

    } catch (error) {

        console.error(error);

        locationStatus.textContent =
            "Erro ao carregar a localização.";
        locationStatus.dataset.state = "error";

    }

}


// ========================================
// ATUALIZAR MARCADOR
// ========================================

function atualizarMarcador(lat, lng, nome) {

    const novaPosicao = [lat, lng];


    if (roverMarker) {

        roverMarker.setLatLng(novaPosicao);

    } else {

        roverMarker = L.marker(novaPosicao)
            .addTo(map);

    }


    roverMarker.bindPopup(`
        <strong>${nome}</strong><br>
        Latitude: ${lat.toFixed(8)}<br>
        Longitude: ${lng.toFixed(8)}
    `);

    openMapButton.href =
        `https://www.openstreetmap.org/?mlat=${lat}&mlon=${lng}#map=17/${lat}/${lng}`;
    openMapButton.setAttribute("aria-disabled", "false");

    roverMarker.openPopup();


    // Centralizar mapa no Rover

    map.setView(
        novaPosicao,
        17
    );

}


// ========================================
// LIMPAR LOCALIZAÇÃO
// ========================================

function limparLocalizacao() {

    latitudeElement.textContent = "--";
    longitudeElement.textContent = "--";
    lastUpdate.textContent = "--";
    openMapButton.removeAttribute("href");
    openMapButton.setAttribute("aria-disabled", "true");

    coordinates.innerHTML = `
        Latitude: --<br>
        Longitude: --
    `;


    if (roverMarker) {

        map.removeLayer(roverMarker);

        roverMarker = null;

    }

    map.fitWorld();

}


// ========================================
// OBTER NOME DO ROVER
// ========================================

function obterNomeRover(idRover) {

    const option =
        Array.from(roverSelect.options)
            .find(option =>
                option.value === idRover
            );

    if (!option) {
        return idRover;
    }

    const texto = option.textContent;

    const partes = texto.split(" - ");

    return partes.length > 1
        ? partes.slice(1).join(" - ")
        : idRover;

}


// ========================================
// FORMATAR DATA
// ========================================

function formatarData(data) {

    if (!data) {
        return "--";
    }

    const dataObj = new Date(data);

    if (Number.isNaN(dataObj.getTime())) {
        return "--";
    }

    return dataObj.toLocaleString(
        "pt-BR",
        {
            day: "2-digit",
            month: "2-digit",
            year: "numeric",
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit"
        }
    );

}


// ========================================
// TROCAR ROVER
// ========================================

roverSelect.addEventListener(
    "change",
    async function () {

        const idRover = this.value;

        localStorage.setItem(
            "selected_rover",
            idRover
        );

        await carregarLocalizacao(idRover);

    }
);

refreshLocationButton.addEventListener(
    "click",
    async function () {
        await carregarLocalizacao(roverSelect.value);
    }
);


// ========================================
// LOGOUT
// ========================================

function logout() {

    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    localStorage.removeItem("selected_rover");

    window.location.href = "login.html";

}


if (logoutButton) {

    logoutButton.addEventListener(
        "click",
        logout
    );

}


// ========================================
// INICIALIZAÇÃO
// ========================================

carregarRovers();
