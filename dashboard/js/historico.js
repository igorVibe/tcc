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
const buscaRegistros = document.getElementById("buscaRegistros");
const roverName = document.getElementById("roverName");
const roverIdentifier = document.getElementById("roverIdentifier");
const resumoRegistros = document.getElementById("resumoRegistros");
const resumoTemperatura = document.getElementById("resumoTemperatura");
const resumoUmidadeSolo = document.getElementById("resumoUmidadeSolo");
const resumoUltimaColeta = document.getElementById("resumoUltimaColeta");

let todasTelemetrias = [];

function formatarNumero(valor, casas = 1) {
    if (valor === null || valor === undefined || valor === "") {
        return "--";
    }

    const numero = Number(valor);

    if (!Number.isFinite(numero)) {
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

function obterMedia(telemetrias, campo) {
    const valores = telemetrias
        .map(item => item[campo])
        .filter(valor => valor !== null && valor !== undefined && valor !== "")
        .map(Number)
        .filter(Number.isFinite);

    if (valores.length === 0) {
        return "--";
    }

    const media = valores.reduce((total, valor) => total + valor, 0) / valores.length;
    return formatarNumero(media);
}

function formatarUltimaColeta(dataISO) {
    if (!dataISO) {
        return "--";
    }

    const data = new Date(dataISO);

    if (Number.isNaN(data.getTime())) {
        return "--";
    }

    const hora = data.toLocaleTimeString("pt-BR", {
        hour: "2-digit",
        minute: "2-digit"
    });
    const hoje = new Date();

    if (data.toDateString() === hoje.toDateString()) {
        return `Hoje, ${hora}`;
    }

    const ontem = new Date(hoje);
    ontem.setDate(hoje.getDate() - 1);

    if (data.toDateString() === ontem.toDateString()) {
        return `Ontem, ${hora}`;
    }

    return `${data.toLocaleDateString("pt-BR")}, ${hora}`;
}

function atualizarResumo(telemetrias) {
    resumoRegistros.textContent = String(telemetrias.length);
    resumoTemperatura.textContent = obterMedia(telemetrias, "temperatura_ar");
    resumoUmidadeSolo.textContent = obterMedia(telemetrias, "umidade_solo");
    resumoUltimaColeta.textContent = formatarUltimaColeta(
        telemetrias[0]?.data_hora
    );
}

function atualizarRoverSelecionado() {
    const option = roverSelect.options[roverSelect.selectedIndex];

    if (!option) {
        roverName.textContent = "Nenhum rover selecionado";
        roverIdentifier.textContent = "";
        return;
    }

    const separador = option.textContent.indexOf(" - ");
    roverIdentifier.textContent = separador === -1
        ? option.value
        : option.textContent.slice(0, separador);
    roverName.textContent = separador === -1
        ? option.textContent
        : option.textContent.slice(separador + 3);
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

        atualizarRoverSelecionado();

        if (rovers.length > 0) {
            await carregarHistorico();
        } else {
            atualizarResumo([]);
            totalRegistros.textContent = "0 registros";
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
        atualizarResumo([]);
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

    atualizarResumo(filtradas);

    const termoBusca = buscaRegistros.value.trim().toLocaleLowerCase("pt-BR");
    const encontradas = termoBusca
        ? filtradas.filter(item => {
            const conteudo = [
                formatarData(item.data_hora),
                item.temperatura_ar,
                item.umidade_solo,
                item.umidade_ar,
                item.qualidade_ar,
                item.sinal_lora_rssi,
                item.latitude,
                item.longitude
            ].filter(valor => valor !== null && valor !== undefined)
                .join(" ")
                .toLocaleLowerCase("pt-BR");

            return conteudo.includes(termoBusca);
        })
        : filtradas;

    renderizarTabela(encontradas, filtradas.length);
}

function renderizarTabela(telemetrias, totalNoPeriodo) {
    historicoBody.innerHTML = "";

    totalRegistros.textContent =
        `${telemetrias.length} ${telemetrias.length === 1 ? "registro" : "registros"}`;

    if (telemetrias.length === 0) {
        const linha = document.createElement("tr");
        const celula = document.createElement("td");
        celula.colSpan = 8;
        celula.textContent = buscaRegistros.value.trim() && totalNoPeriodo > 0
            ? "Nenhum registro corresponde à busca."
            : "Nenhuma telemetria encontrada para os filtros selecionados.";
        linha.appendChild(celula);
        historicoBody.appendChild(linha);

        mensagem.textContent = "";
        return;
    }

    telemetrias.forEach(item => {
        const tr = document.createElement("tr");
        const valores = [
            formatarData(item.data_hora),
            item.temperatura_ar === null || item.temperatura_ar === undefined
                ? "--"
                : `${formatarNumero(item.temperatura_ar, 1)} °C`,
            item.umidade_solo === null || item.umidade_solo === undefined
                ? "--"
                : `${formatarNumero(item.umidade_solo, 1)} %`,
            item.umidade_ar === null || item.umidade_ar === undefined
                ? "--"
                : `${formatarNumero(item.umidade_ar, 1)} %`,
            formatarNumero(item.qualidade_ar, 1),
            item.sinal_lora_rssi === null || item.sinal_lora_rssi === undefined
                ? "--"
                : `${item.sinal_lora_rssi} dBm`,
            item.latitude ?? "--",
            item.longitude ?? "--"
        ];

        valores.forEach(valor => {
            const celula = document.createElement("td");
            celula.textContent = String(valor);
            tr.appendChild(celula);
        });

        historicoBody.appendChild(tr);
    });

    mensagem.textContent = "";
}

roverSelect.addEventListener("change", async () => {
    localStorage.setItem("selected_rover", roverSelect.value);
    atualizarRoverSelecionado();
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

buscaRegistros.addEventListener("input", () => {
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
