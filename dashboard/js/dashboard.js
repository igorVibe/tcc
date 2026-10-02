console.log("Dashboard Rover AgroTech carregado!");

const API_URL = "http://127.0.0.1:8000";

// Pega o token salvo no login
const token = localStorage.getItem("access_token");

// Verifica se o usuário está autenticado
if (!token) {
    window.location.href = "login.html";
}


// Elementos do HTML
const roverSelect = document.getElementById("roverSelect");
const selectedRover = document.getElementById("selectedRover");


// ========================================
// BUSCAR ROVERS
// ========================================

async function carregarRovers() {

    try {

        const response = await fetch(`${API_URL}/rovers/`, {

            method: "GET",

            headers: {
                "Authorization": `Bearer ${token}`,
                "Content-Type": "application/json"
            }

        });


        if (response.status === 401) {

            localStorage.removeItem("access_token");
            localStorage.removeItem("refresh_token");

            window.location.href = "login.html";

            return;
        }


        if (!response.ok) {
            throw new Error("Erro ao buscar os rovers.");
        }


        const rovers = await response.json();

        console.log("Rovers recebidos:", rovers);


        // Limpa o select
        roverSelect.innerHTML = "";


        // Adiciona os rovers encontrados
        rovers.forEach(rover => {

            const option = document.createElement("option");

            option.value = rover.id_rover;

            option.textContent =
                `${rover.id_rover} - ${rover.nome}`;

            roverSelect.appendChild(option);

        });


        // Se encontrou algum rover,
        // carrega a telemetria do primeiro
        if (rovers.length > 0) {

    // Verifica se existe um Rover selecionado
    // vindo da página Rovers
         const roverSalvo =
            localStorage.getItem("selected_rover");

    // Procura o Rover salvo
         let roverSelecionado =
            rovers.find(
                rover => rover.id_rover === roverSalvo
        );

    // Se não encontrou o Rover salvo,
    // utiliza o primeiro Rover da lista
        if (!roverSelecionado) {

            roverSelecionado = rovers[0];

    }

    // Atualiza o select
    roverSelect.value =
        roverSelecionado.id_rover;

    // Atualiza o nome/ID exibido
    selectedRover.textContent =
        roverSelecionado.id_rover;

    // Atualiza bateria
    atualizarBateria(
        roverSelecionado.bateria
    );

    // Carrega telemetria
    carregarTelemetria(
        roverSelecionado.id_rover
    );

    // Carrega gráficos
    carregarGraficos(
        roverSelecionado.id_rover
    );

}


    } catch (error) {

        console.error("Erro:", error);

    }

}


// ========================================
// BUSCAR TELEMETRIA
// ========================================

async function carregarTelemetria(idRover) {

    try {

        const response = await fetch(
            `${API_URL}/telemetrias/?rover=${encodeURIComponent(idRover)}`,
            {
                method: "GET",

                headers: {
                    "Authorization": `Bearer ${token}`,
                    "Content-Type": "application/json"
                }
            }
        );


        // ========================================
        // VERIFICAR RESPOSTA DA API
        // ========================================

        if (!response.ok) {

            throw new Error(
                "Erro ao buscar telemetrias."
            );

        }


        // ========================================
        // CONVERTER RESPOSTA PARA JSON
        // ========================================

        const resultado =
            await response.json();


        console.log(
            "Telemetrias recebidas:",
            resultado
        );


        // Django REST Framework pode retornar:
        // { count, next, previous, results }

        const telemetrias =
            resultado.results || resultado;


        // ========================================
        // VERIFICAR SE EXISTEM TELEMETRIAS
        // ========================================

        if (
            !telemetrias ||
            telemetrias.length === 0
        ) {

            console.log(
                "Nenhuma telemetria encontrada."
            );

            return;

        }


        // ========================================
        // PEGAR A ÚLTIMA TELEMETRIA
        // ========================================

        // O backend está ordenado por -data_hora,
        // então a primeira telemetria é a mais recente.

        const ultima =
            telemetrias[0];


        console.log(
            "Última telemetria:",
            ultima
        );


        // ========================================
        // ATUALIZAR MAPA
        // ========================================

        if (
            ultima.latitude != null &&
            ultima.longitude != null
        ) {

            atualizarMapa(
                ultima.latitude,
                ultima.longitude,
                idRover
            );

        }


        // ========================================
        // ATUALIZAR UMIDADE DO SOLO
        // ========================================

        const soilHumidity =
            document.getElementById(
                "soilHumidity"
            );

        if (soilHumidity) {

            soilHumidity.textContent =
                ultima.umidade_solo ?? "--";

        }


        // ========================================
        // ATUALIZAR UMIDADE DO AR
        // ========================================

        const airHumidity =
            document.getElementById(
                "airHumidity"
            );

        if (airHumidity) {

            airHumidity.textContent =
                ultima.umidade_ar ?? "--";

        }


        // ========================================
        // ATUALIZAR TEMPERATURA
        // ========================================

        const temperature =
            document.getElementById(
                "temperature"
            );

        if (temperature) {

            temperature.textContent =
                ultima.temperatura_ar ?? "--";

        }


        // ========================================
        // ATUALIZAR QUALIDADE DO AR
        // ========================================

        const airQuality =
            document.getElementById(
                "airQuality"
            );

        if (airQuality) {

            airQuality.textContent =
                ultima.qualidade_ar ?? "--";

        }


        // ========================================
        // ATUALIZAR SINAL LORA
        // ========================================

        const rssiValue =
            document.getElementById(
                "rssiValue"
            );

        if (rssiValue) {

            rssiValue.textContent =
                ultima.sinal_lora_rssi != null
                    ? `${ultima.sinal_lora_rssi} dBm`
                    : "-- dBm";

        }


        // ========================================
        // ATUALIZAR LATITUDE
        // ========================================

        const latitude =
            document.getElementById(
                "latitude"
            );

        if (latitude) {

            latitude.textContent =
                ultima.latitude ?? "--";

        }


        // ========================================
        // ATUALIZAR LONGITUDE
        // ========================================

        const longitude =
            document.getElementById(
                "longitude"
            );

        if (longitude) {

            longitude.textContent =
                ultima.longitude ?? "--";

        }


        // ========================================
        // ATUALIZAR DATA/HORA
        // ========================================

        const lastUpdate =
            document.getElementById(
                "lastUpdate"
            );


        if (
            lastUpdate &&
            ultima.data_hora
        ) {

            const data =
                new Date(
                    ultima.data_hora
                );


            lastUpdate.textContent =
                data.toLocaleString(
                    "pt-BR"
                );

        }


        // ========================================
        // FINALIZAÇÃO
        // ========================================

        console.log(
            "✅ Telemetria atualizada com sucesso!"
        );


    } catch (error) {

        console.error(
            "❌ Erro ao carregar telemetria:",
            error
        );

    }

}


// ========================================
// ATUALIZAR BATERIA
// ========================================

function atualizarBateria(bateria) {

    const elemento =
        document.getElementById(
            "batteryValue"
        );


    if (!elemento) {

        console.warn(
            "Elemento da bateria não encontrado."
        );

        return;

    }


    if (
        bateria !== null &&
        bateria !== undefined
    ) {

        elemento.textContent =
            `${bateria}%`;

    } else {

        elemento.textContent =
            "-- %";

    }

}

// ========================================
// ATUALIZAR DADOS DO ROVER AUTOMATICAMENTE
// ========================================

async function atualizarRoverSelecionado() {

    const idRover = roverSelect.value;

    if (!idRover) {
        return;
    }

    try {

        const response = await fetch(
            `${API_URL}/rovers/${encodeURIComponent(idRover)}/`,
            {
                method: "GET",
                headers: {
                    "Authorization": `Bearer ${token}`,
                    "Content-Type": "application/json"
                }
            }
        );

        if (!response.ok) {
            throw new Error("Erro ao buscar dados do Rover.");
        }

        const rover = await response.json();

        console.log("🔋 Dados do Rover atualizados:", rover);

        atualizarBateria(rover.bateria);

    } catch (error) {

        console.error(
            "❌ Erro ao atualizar dados do Rover:",
            error
        );

    }
}


// ========================================
// TROCA DE ROVER
// ========================================

roverSelect.addEventListener(
    "change",
    async function () {

        const idRover =
            this.value;

        localStorage.setItem(
            "selected_rover",
            idRover
        );


        selectedRover.textContent =
            idRover;


        try {

            const response = await fetch(

                `${API_URL}/rovers/${encodeURIComponent(idRover)}/`,

                {

                    method: "GET",

                    headers: {

                        "Authorization":
                            `Bearer ${token}`,

                        "Content-Type":
                            "application/json"

                    }

                }

            );


            if (!response.ok) {

                throw new Error(
                    "Erro ao buscar dados do Rover."
                );

            }


            const rover = await response.json();

            console.log("Rover selecionado:", rover);

            atualizarBateria(
                rover.bateria
            );


            carregarTelemetria(
                idRover
            );


            carregarGraficos(
                idRover
            );


        } catch (error) {

            console.error(
                "Erro ao carregar Rover:",
                error
            );

        }

    }
);


// ========================================
// LOGOUT
// ========================================

document
    .getElementById("logoutButton")
    .addEventListener(
        "click",
        function () {

            localStorage.removeItem(
                "access_token"
            );

            localStorage.removeItem(
                "refresh_token"
            );

            window.location.href =
                "login.html";

        }
    );


// ========================================
// INICIAR DASHBOARD
// ========================================

carregarRovers();

// ==========================================
// ATUALIZAÇÃO AUTOMÁTICA DA TELEMETRIA
// ==========================================

setInterval(() => {

    console.log("⏱️ Intervalo de 5 segundos funcionando!");

    const idRover = roverSelect.value;

    console.log("🤖 Rover selecionado:", idRover);

    if (idRover) {

        console.log("🔄 Atualizando dados do Rover...");

        carregarTelemetria(idRover);

        atualizarRoverSelecionado();

        atualizarGraficosAutomaticamente();

    } else {

        console.warn("⚠️ Nenhum Rover selecionado!");

    }

}, 5000);


// ========================================
// GRÁFICO DE TEMPERATURA
// ========================================

// ========================================
// GRÁFICOS HISTÓRICOS
// ========================================

let temperatureChart = null;
let soilHumidityChart = null;
let airHumidityChart = null;
let rssiChart = null;
let airQualityChart = null;
let ultimoTotalTelemetrias = 0;


async function carregarGraficos(idRover) {

    try {

        const response = await fetch(
            `${API_URL}/telemetrias/?rover=${encodeURIComponent(idRover)}`,
            {
                method: "GET",

                headers: {
                    "Authorization": `Bearer ${token}`,
                    "Content-Type": "application/json"
                }
            }
        );


        if (!response.ok) {
            throw new Error(
                "Erro ao buscar dados para os gráficos."
            );
        }


        const resultado = await response.json();

        const telemetrias =
            resultado.results || resultado;


        if (!telemetrias || telemetrias.length === 0) {

            console.log(
                "Nenhuma telemetria encontrada para os gráficos."
            );

            return;
        }


        // A API retorna da mais recente
        // para a mais antiga.
        // Invertemos para ficar em ordem cronológica.

        const dados =
            [...telemetrias].reverse();


        // ========================================
        // HORÁRIOS
        // ========================================

        const labels = dados.map(item => {

            const data =
                new Date(item.data_hora);

            return data.toLocaleTimeString("pt-BR");

        });


        // ========================================
        // DADOS DOS SENSORES
        // ========================================

        const temperaturas =
            dados.map(item =>
                item.temperatura_ar
            );


        const umidadeSolo =
            dados.map(item =>
                item.umidade_solo
            );


        const umidadeAr =
            dados.map(item =>
                item.umidade_ar
            );


        const rssi =
            dados.map(item =>
                item.sinal_lora_rssi
            );

            const qualidadeAr =
    dados.map(item =>
        item.qualidade_ar
    );


        // ========================================
        // DESTRUIR GRÁFICOS ANTERIORES
        // ========================================

        if (temperatureChart) {
            temperatureChart.destroy();
        }

        if (soilHumidityChart) {
            soilHumidityChart.destroy();
        }

        if (airHumidityChart) {
            airHumidityChart.destroy();
        }

        if (rssiChart) {
            rssiChart.destroy();
        }

       if (airQualityChart) {
    airQualityChart.destroy();
}

        // ========================================
        // TEMPERATURA
        // ========================================

        const temperatureCanvas =
            document.getElementById("temperatureChart");


        if (temperatureCanvas) {

            temperatureChart = new Chart(
                temperatureCanvas,
                {

                    type: "line",

                    data: {

                        labels: labels,

                        datasets: [

                            {
                                label: "Temperatura (°C)",

                                data: temperaturas,

                                tension: 0.3,

                                borderWidth: 2,

                                pointRadius: 3
                            }

                        ]

                    },

                    options: {

                        responsive: true,

                        maintainAspectRatio: false,

                        scales: {

                            y: {

                                title: {

                                    display: true,

                                    text: "°C"

                                }

                            },

                            x: {

                                title: {

                                    display: true,

                                    text: "Horário"

                                }

                            }

                        }

                    }

                }
            );

        }


        // ========================================
        // UMIDADE DO SOLO
        // ========================================

        const soilCanvas =
            document.getElementById(
                "soilHumidityChart"
            );


        if (soilCanvas) {

            soilHumidityChart = new Chart(
                soilCanvas,
                {

                    type: "line",

                    data: {

                        labels: labels,

                        datasets: [

                            {
                                label:
                                    "Umidade do solo (%)",

                                data:
                                    umidadeSolo,

                                tension: 0.3,

                                borderWidth: 2,

                                pointRadius: 3
                            }

                        ]

                    },

                    options: {

                        responsive: true,

                        maintainAspectRatio: false,

                        scales: {

                            y: {

                                title: {

                                    display: true,

                                    text: "%"

                                }

                            },

                            x: {

                                title: {

                                    display: true,

                                    text: "Horário"

                                }

                            }

                        }

                    }

                }
            );

        }


        // ========================================
        // UMIDADE DO AR
        // ========================================

        const airCanvas =
            document.getElementById(
                "airHumidityChart"
            );


        if (airCanvas) {

            airHumidityChart = new Chart(
                airCanvas,
                {

                    type: "line",

                    data: {

                        labels: labels,

                        datasets: [

                            {
                                label:
                                    "Umidade do ar (%)",

                                data:
                                    umidadeAr,

                                tension: 0.3,

                                borderWidth: 2,

                                pointRadius: 3
                            }

                        ]

                    },

                    options: {

                        responsive: true,

                        maintainAspectRatio: false,

                        scales: {

                            y: {

                                title: {

                                    display: true,

                                    text: "%"

                                }

                            },

                            x: {

                                title: {

                                    display: true,

                                    text: "Horário"

                                }

                            }

                        }

                    }

                }
            );

        }



// ========================================
// QUALIDADE DO AR
// ========================================

const airQualityCanvas =
    document.getElementById(
        "airQualityChart"
    );

if (airQualityCanvas) {

    airQualityChart = new Chart(
        airQualityCanvas,
        {
            type: "line",

            data: {
                labels: labels,

                datasets: [
                    {
                        label:
                            "Qualidade do ar",

                        data:
                            qualidadeAr,

                        tension: 0.3,

                        borderWidth: 2,

                        pointRadius: 3
                    }
                ]
            },

            options: {
                responsive: true,

                maintainAspectRatio: false,

                scales: {

                    y: {
                        beginAtZero: true,

                        title: {
                            display: true,

                            text: "Qualidade"
                        }
                    },

                    x: {
                        title: {
                            display: true,

                            text: "Horário"
                        }
                    }

                }
            }
        }
    );
}


        // ========================================
        // SINAL LORA
        // ========================================

        const rssiCanvas =
            document.getElementById(
                "rssiChart"
            );


        if (rssiCanvas) {

            rssiChart = new Chart(
                rssiCanvas,
                {

                    type: "line",

                    data: {

                        labels: labels,

                        datasets: [

                            {
                                label:
                                    "Sinal LoRa (dBm)",

                                data:
                                    rssi,

                                tension: 0.3,

                                borderWidth: 2,

                                pointRadius: 3
                            }

                        ]

                    },

                    options: {

                        responsive: true,

                        maintainAspectRatio: false,

                        scales: {

                            y: {

                                title: {

                                    display: true,

                                    text: "dBm"

                                }

                            },

                            x: {

                                title: {

                                    display: true,

                                    text: "Horário"

                                }

                            }

                        }

                    }

                }
            );

        }

        

        console.log(
            "📊 Gráficos históricos carregados!"
        );


    } catch (error) {

        console.error(
            "Erro ao carregar gráficos:",
            error
        );

    }

}

// ========================================
// ATUALIZAÇÃO AUTOMÁTICA DOS GRÁFICOS
// ========================================

async function atualizarGraficosAutomaticamente() {

    const idRover = roverSelect.value;

    if (!idRover) {
        return;
    }

    try {

        const response = await fetch(
            `${API_URL}/telemetrias/?rover=${encodeURIComponent(idRover)}`,
            {
                method: "GET",
                headers: {
                    "Authorization": `Bearer ${token}`,
                    "Content-Type": "application/json"
                }
            }
        );

        if (!response.ok) {
            throw new Error(
                "Erro ao buscar telemetrias para os gráficos."
            );
        }

        const resultado = await response.json();

        const telemetrias =
            resultado.results || resultado;

        if (!telemetrias || telemetrias.length === 0) {
            return;
        }

        // Verifica se chegaram novas telemetrias
        if (
            telemetrias.length !==
            ultimoTotalTelemetrias
        ) {

            console.log(
                "📊 Novas telemetrias encontradas. Atualizando gráficos..."
            );

            ultimoTotalTelemetrias =
                telemetrias.length;

            carregarGraficos(idRover);
        }

    } catch (error) {

        console.error(
            "❌ Erro ao atualizar gráficos:",
            error
        );

    }
}
 


// ========================================
// MAPA - LEAFLET
// ========================================

let mapa = null;
let marcadorRover = null;


function inicializarMapa() {

    const elementoMapa = document.getElementById("map");

    if (!elementoMapa) {
        console.error("❌ Elemento #map não encontrado.");
        return;
    }


    // Coordenadas iniciais
    // Usadas apenas para criar o mapa.
    const latitudeInicial = -21.208;
    const longitudeInicial = -50.432;


    mapa = L.map("map").setView(
        [latitudeInicial, longitudeInicial],
        15
    );


    // Mapa OpenStreetMap
    L.tileLayer(
        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        {
            attribution:
                '&copy; OpenStreetMap contributors'
        }
    ).addTo(mapa);


    // Marcador inicial
    marcadorRover = L.marker(
        [latitudeInicial, longitudeInicial]
    ).addTo(mapa);


    marcadorRover.bindPopup(
        "<strong>ROVER-01</strong><br>Posição inicial"
    );


    console.log("🗺️ Mapa inicializado com sucesso!");
}

inicializarMapa();

// ========================================
// ATUALIZAR POSIÇÃO DO ROVER NO MAPA
// ========================================

function atualizarMapa(latitude, longitude, idRover) {

    // Verifica se o mapa existe
    if (!mapa) {
        console.error("❌ Mapa ainda não foi inicializado.");
        return;
    }

    // Verifica se existem coordenadas válidas
    if (
        latitude === null ||
        latitude === undefined ||
        longitude === null ||
        longitude === undefined
    ) {
        console.warn("⚠️ Coordenadas do Rover não disponíveis.");
        return;
    }

    const lat = Number(latitude);
    const lng = Number(longitude);

    // Verifica se os valores são números válidos
    if (isNaN(lat) || isNaN(lng)) {
        console.error("❌ Latitude ou longitude inválida.");
        return;
    }

    // Atualiza a posição do marcador
    marcadorRover.setLatLng([lat, lng]);

    // Centraliza o mapa no Rover
    mapa.setView([lat, lng]);

    // Atualiza o popup
    marcadorRover.bindPopup(
        `<strong>${idRover}</strong><br>` +
        `Latitude: ${lat}<br>` +
        `Longitude: ${lng}`
    );

    console.log(
        `📍 Posição atualizada: ${lat}, ${lng}`
    );
}
