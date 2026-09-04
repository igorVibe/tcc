console.log("Histórico Rover AgroTech carregado!");

const API_URL = "http://127.0.0.1:8000";
const token = localStorage.getItem("access_token");

if (!token) {
    window.location.href = "login.html";
}

const roverSelect = document.getElementById("roverSelect");
const dataInicial = document.getElementById("dataInicial");
const dataFinal = document.getElementById("dataFinal");
const filtrarButton = document.getElementById("filtrarButton");
const limparButton = document.getElementById("limparButton");
const atualizarButton = document.getElementById("atualizarButton");
const historicoBody = document.getElementById("historicoBody");
const totalRegistros = document.getElementById("totalRegistros");
const mensagem = document.getElementById("mensagem");
const logoutButton = document.getElementById("logoutButton");

let todasTelemetrias = [];

function formatarNumero(valor, casas = 1) {
    if (valor === null || valor === undefined || valor === "") {
        return "--";
    }

    const numero = Number(valor);

    if (Number.isNaN(numero)) {
        return "--";
    }

    return numero.toLocaleString("pt-BR", {
        minimumFractionDigits: casas,
        maximumFractionDigits: casas
    });
}

function formatarData(dataISO) {
    if (!dataISO) {
        return "--";
    }

    const data = new Date(dataISO);

    if (Number.isNaN(data.getTime())) {
        return "--";
    }

    return data.toLocaleString("pt-BR");
}

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

        const resultado = await response.json();
        const rovers = resultado.results || resultado;

        roverSelect.innerHTML = "";

        rovers.forEach(rover => {
            const option = document.createElement("option");
            option.value = rover.id_rover;
            option.textContent = `${rover.id_rover} - ${rover.nome}`;
            roverSelect.appendChild(option);
        });

        const roverSalvo = localStorage.getItem("selected_rover");

        if (roverSalvo && rovers.some(rover => rover.id_rover === roverSalvo)) {
            roverSelect.value = roverSalvo;
        }

        if (rovers.length > 0) {
            await carregarHistorico();
        } else {
            mensagem.textContent = "Nenhum Rover cadastrado.";
        }

    } catch (error) {
        console.error("Erro ao carregar rovers:", error);
        mensagem.textContent = "Não foi possível carregar os Rovers.";
    }
}

async function carregarHistorico() {
    const idRover = roverSelect.value;

    if (!idRover) {
        return;
    }

    mensagem.textContent = "Carregando telemetrias...";

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

        if (response.status === 401) {
            localStorage.removeItem("access_token");
            localStorage.removeItem("refresh_token");
            window.location.href = "login.html";
            return;
        }

        if (!response.ok) {
            throw new Error("Erro ao buscar telemetrias.");
        }

        const resultado = await response.json();
        todasTelemetrias = resultado.results || resultado || [];

        todasTelemetrias.sort(
            (a, b) => new Date(b.data_hora) - new Date(a.data_hora)
        );

        aplicarFiltros();

    } catch (error) {
        console.error("Erro ao carregar histórico:", error);
        mensagem.textContent = "Erro ao carregar o histórico.";
        historicoBody.innerHTML = "";
        totalRegistros.textContent = "0 registros";
    }
}

function aplicarFiltros() {
    const inicio = dataInicial.value
        ? new Date(`${dataInicial.value}T00:00:00`)
        : null;

    const fim = dataFinal.value
        ? new Date(`${dataFinal.value}T23:59:59`)
        : null;

    const filtradas = todasTelemetrias.filter(item => {
        const data = new Date(item.data_hora);

        if (Number.isNaN(data.getTime())) {
            return false;
        }

        if (inicio && data < inicio) {
            return false;
        }

        if (fim && data > fim) {
            return false;
        }

        return true;
    });

    renderizarTabela(filtradas);
}

function renderizarTabela(telemetrias) {
    historicoBody.innerHTML = "";

    totalRegistros.textContent =
        `${telemetrias.length} ${telemetrias.length === 1 ? "registro" : "registros"}`;

    if (telemetrias.length === 0) {
        historicoBody.innerHTML = `
            <tr>
                <td colspan="8">Nenhuma telemetria encontrada para os filtros selecionados.</td>
            </tr>
        `;

        mensagem.textContent = "";
        return;
    }

    telemetrias.forEach(item => {
        const tr = document.createElement("tr");

        tr.innerHTML = `
            <td>${formatarData(item.data_hora)}</td>
            <td>${formatarNumero(item.temperatura_ar, 1)} °C</td>
            <td>${formatarNumero(item.umidade_solo, 1)} %</td>
            <td>${formatarNumero(item.umidade_ar, 1)} %</td>
            <td>${formatarNumero(item.qualidade_ar, 1)}</td>
            <td>${item.sinal_lora_rssi ?? "--"} dBm</td>
            <td>${item.latitude ?? "--"}</td>
            <td>${item.longitude ?? "--"}</td>
        `;

        historicoBody.appendChild(tr);
    });

    mensagem.textContent = "";
}

roverSelect.addEventListener("change", async () => {
    localStorage.setItem("selected_rover", roverSelect.value);
    await carregarHistorico();
});

filtrarButton.addEventListener("click", () => {
    aplicarFiltros();
});

limparButton.addEventListener("click", () => {
    dataInicial.value = "";
    dataFinal.value = "";
    aplicarFiltros();
});

atualizarButton.addEventListener("click", async () => {
    await carregarHistorico();
});

logoutButton.addEventListener("click", () => {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    localStorage.removeItem("selected_rover");
    window.location.href = "login.html";
});

carregarRovers();
