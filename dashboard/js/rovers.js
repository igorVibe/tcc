const API_URL = "http://127.0.0.1:8000";

const roversContainer = document.getElementById("roversContainer");
const refreshButton = document.getElementById("refreshButton");
const logoutButton = document.getElementById("logoutButton");
const pageMessage = document.getElementById("message");
const roverSearch = document.getElementById("roverSearch");
const statusFilter = document.getElementById("statusFilter");
const sortOrder = document.getElementById("sortOrder");
const resultCount = document.getElementById("resultCount");
const totalRovers = document.getElementById("totalRovers");
const connectedRovers = document.getElementById("connectedRovers");
const offlineRovers = document.getElementById("offlineRovers");
const averageBattery = document.getElementById("averageBattery");

const linkRoverButton = document.getElementById("linkRoverButton");
const linkRoverModal = document.getElementById("linkRoverModal");
const linkRoverForm = document.getElementById("linkRoverForm");
const newRoverId = document.getElementById("newRoverId");
const newRoverName = document.getElementById("newRoverName");
const linkRoverMessage = document.getElementById("linkRoverMessage");
const cancelLinkRoverButton = document.getElementById("cancelLinkRoverButton");
const confirmLinkRoverButton = document.getElementById("confirmLinkRoverButton");

let roversData = [];
let carregamentoAtual = null;
let cadastroEmAndamento = false;

function headersComToken(token) {
    return {
        "Authorization": `Bearer ${token}`,
        "Content-Type": "application/json"
    };
}

function redirecionarParaLogin() {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    window.location.href = "login.html";
}

function mostrarMensagem(elemento, texto, tipo = "") {
    elemento.textContent = texto;
    elemento.dataset.type = tipo;
}

function extrairLista(resultado, recurso) {
    if (Array.isArray(resultado)) return resultado;
    if (resultado && Array.isArray(resultado.results)) return resultado.results;
    throw new Error(`A API retornou uma lista de ${recurso} em formato inesperado.`);
}

function valorNumerico(valor) {
    if (valor === null || valor === undefined || valor === "") return null;
    const numero = Number(valor);
    return Number.isFinite(numero) ? numero : null;
}

function obterBateria(rover) {
    return valorNumerico(rover.bateria);
}

function obterUltimaTelemetria(telemetrias) {
    if (telemetrias.length === 0) return null;

    return telemetrias.reduce((maisRecente, telemetria) => {
        if (!maisRecente) return telemetria;
        const dataAtual = Date.parse(telemetria.data_hora);
        const dataMaisRecente = Date.parse(maisRecente.data_hora);
        if (Number.isNaN(dataAtual)) return maisRecente;
        if (Number.isNaN(dataMaisRecente) || dataAtual > dataMaisRecente) return telemetria;
        return maisRecente;
    }, null);
}

async function buscarTelemetria(rover, token) {
    const response = await fetch(
        `${API_URL}/telemetrias/?rover=${encodeURIComponent(rover.id_rover)}`,
        { method: "GET", headers: headersComToken(token) }
    );

    if (response.status === 401) {
        redirecionarParaLogin();
        return { rover, telemetria: null, erroTelemetria: false, naoAutorizado: true };
    }
    if (!response.ok) {
        throw new Error(`Erro HTTP ${response.status} ao buscar a telemetria de ${rover.id_rover}.`);
    }

    const registros = extrairLista(await response.json(), "telemetrias");
    return {
        rover,
        telemetria: obterUltimaTelemetria(registros),
        erroTelemetria: false
    };
}

async function buscarRovers() {
    const token = localStorage.getItem("access_token");
    if (!token) {
        window.location.href = "login.html";
        return;
    }

    roversContainer.setAttribute("aria-busy", "true");
    roversContainer.innerHTML = '<div class="loading" aria-live="polite">Carregando rovers e telemetrias...</div>';

    const response = await fetch(`${API_URL}/rovers/`, {
        method: "GET",
        headers: headersComToken(token)
    });

    if (response.status === 401) {
        redirecionarParaLogin();
        return;
    }
    if (!response.ok) {
        throw new Error(`Não foi possível carregar os rovers (HTTP ${response.status}).`);
    }

    const listaRovers = extrairLista(await response.json(), "rovers");
    if (listaRovers.length === 0) {
        roversData = [];
        atualizarResumo();
        renderizarRovers();
        return;
    }

    const resultados = await Promise.all(listaRovers.map(async rover => {
        try {
            return await buscarTelemetria(rover, token);
        } catch (error) {
            console.error(`Erro ao carregar telemetria do rover ${rover.id_rover}:`, error);
            return { rover, telemetria: null, erroTelemetria: true };
        }
    }));

    if (resultados.some(resultado => resultado.naoAutorizado)) return;

    roversData = resultados;
    atualizarResumo();
    renderizarRovers();

    const falhasTelemetria = resultados.filter(resultado => resultado.erroTelemetria).length;
    if (falhasTelemetria > 0) {
        mostrarMensagem(
            pageMessage,
            `Os rovers foram carregados, mas não foi possível consultar a telemetria de ${falhasTelemetria} equipamento(s). O status desses rovers não foi verificado.`,
            "error"
        );
    }
}

function carregarRovers() {
    if (carregamentoAtual) return carregamentoAtual;

    const botaoEstavaDesabilitado = refreshButton.disabled;
    refreshButton.disabled = true;
    refreshButton.classList.add("is-loading");
    refreshButton.setAttribute("aria-busy", "true");

    carregamentoAtual = buscarRovers()
        .catch(error => {
            console.error("Erro ao carregar rovers:", error);
            totalRovers.textContent = "—";
            connectedRovers.textContent = "—";
            offlineRovers.textContent = "—";
            averageBattery.textContent = "Sem leitura";
            resultCount.textContent = "";
            mostrarMensagem(
                pageMessage,
                error instanceof Error ? error.message : "Não foi possível carregar os rovers.",
                "error"
            );
            roversContainer.innerHTML = '<div class="empty-state">Não foi possível carregar os rovers. Verifique a conexão e tente atualizar a lista.</div>';
        })
        .finally(() => {
            roversContainer.removeAttribute("aria-busy");
            refreshButton.disabled = botaoEstavaDesabilitado;
            refreshButton.classList.remove("is-loading");
            refreshButton.removeAttribute("aria-busy");
            carregamentoAtual = null;
        });

    return carregamentoAtual;
}

function atualizarResumo() {
    totalRovers.textContent = String(roversData.length);
    connectedRovers.textContent = String(
        roversData.filter(item => !item.erroTelemetria && item.telemetria).length
    );
    offlineRovers.textContent = String(
        roversData.filter(item => !item.erroTelemetria && !item.telemetria).length
    );

    const baterias = roversData
        .map(item => obterBateria(item.rover))
        .filter(bateria => bateria !== null);
    averageBattery.textContent = baterias.length > 0
        ? `${(baterias.reduce((soma, bateria) => soma + bateria, 0) / baterias.length).toLocaleString("pt-BR", { maximumFractionDigits: 1 })}%`
        : "Sem leitura";
}

function obterStatus(item) {
    if (item.erroTelemetria) return { rotulo: "Não verificado", classe: "unknown", filtro: "unknown" };
    if (item.telemetria) return { rotulo: "Com telemetria", classe: "online", filtro: "connected" };
    return { rotulo: "Sem telemetria", classe: "offline", filtro: "offline" };
}

function formatarData(data) {
    if (!data) return "Sem leitura";
    const dataFormatada = new Date(data);
    if (Number.isNaN(dataFormatada.getTime())) return "Sem leitura";
    return dataFormatada.toLocaleString("pt-BR");
}

function formatarCoordenada(valor) {
    const numero = valorNumerico(valor);
    return numero === null
        ? escaparHtml(valor)
        : numero.toLocaleString("pt-BR", { maximumFractionDigits: 6 });
}

function obterCoordenadas(telemetria) {
    if (!telemetria || telemetria.latitude == null || telemetria.longitude == null) {
        return "Sem leitura";
    }
    return `${formatarCoordenada(telemetria.latitude)}, ${formatarCoordenada(telemetria.longitude)}`;
}

function escaparHtml(valor) {
    return String(valor ?? "").replace(/[&<>"']/g, caractere => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;"
    })[caractere]);
}

function ordenarRovers(itens) {
    const ordenacao = sortOrder.value;
    return itens.sort((a, b) => {
        if (ordenacao === "name-desc") {
            return String(b.rover.nome).localeCompare(String(a.rover.nome), "pt-BR");
        }
        if (ordenacao === "telemetry-desc") {
            const dataA = Date.parse(a.telemetria?.data_hora) || 0;
            const dataB = Date.parse(b.telemetria?.data_hora) || 0;
            return dataB - dataA || String(a.rover.nome).localeCompare(String(b.rover.nome), "pt-BR");
        }
        if (ordenacao === "battery-desc") {
            const bateriaA = obterBateria(a.rover);
            const bateriaB = obterBateria(b.rover);
            if (bateriaA === null) return bateriaB === null ? 0 : 1;
            if (bateriaB === null) return -1;
            return bateriaB - bateriaA;
        }
        return String(a.rover.nome).localeCompare(String(b.rover.nome), "pt-BR");
    });
}

function renderizarRovers() {
    const consulta = roverSearch.value.trim().toLocaleLowerCase("pt-BR");
    const statusEscolhido = statusFilter.value;
    const filtrados = roversData.filter(item => {
        const nome = String(item.rover.nome ?? "").toLocaleLowerCase("pt-BR");
        const id = String(item.rover.id_rover ?? "").toLocaleLowerCase("pt-BR");
        return (!consulta || nome.includes(consulta) || id.includes(consulta))
            && (statusEscolhido === "all" || obterStatus(item).filtro === statusEscolhido);
    });

    resultCount.textContent = `${filtrados.length} ${filtrados.length === 1 ? "rover" : "rovers"}`;

    if (roversData.length === 0) {
        roversContainer.innerHTML = '<div class="empty-state">Nenhum rover cadastrado. Use “Vincular rover” para adicionar um equipamento.</div>';
        return;
    }
    if (filtrados.length === 0) {
        roversContainer.innerHTML = '<div class="empty-state">Nenhum rover corresponde à busca e aos filtros selecionados.</div>';
        return;
    }

    roversContainer.innerHTML = ordenarRovers(filtrados).map(item => {
        const rover = item.rover;
        const status = obterStatus(item);
        const bateria = obterBateria(rover);
        const valorBateria = bateria === null
            ? "Sem leitura"
            : `${bateria.toLocaleString("pt-BR", { maximumFractionDigits: 1 })}%`;
        const telemetria = item.telemetria;
        const dataTelemetria = formatarData(telemetria?.data_hora);

        return `
            <article class="rover-card">
                <div class="rover-card-header">
                    <img class="rover-image" src="imgs/rover01.png" alt="" loading="lazy">
                    <div class="rover-heading">
                        <h3>${escaparHtml(rover.nome)}</h3>
                        <small>${escaparHtml(rover.id_rover)}</small>
                        <span class="rover-status ${status.classe}">${status.rotulo}</span>
                    </div>
                </div>
                <div class="rover-info">
                    <div class="rover-info-item">
                        <span><svg class="ui-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="2" y="6" width="17" height="12" rx="2"/><path d="M22 10v4M6 10v4M10 10v4M14 10v4"/></svg>Bateria</span>
                        <strong>${valorBateria}</strong>
                    </div>
                    <div class="rover-info-item">
                        <span><svg class="ui-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>Última telemetria</span>
                        <strong>${escaparHtml(dataTelemetria)}</strong>
                    </div>
                    <div class="rover-info-item">
                        <span><svg class="ui-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 10c0 5-7 11-7 11S5 15 5 10a7 7 0 1 1 14 0Z"/><circle cx="12" cy="10" r="2.5"/></svg>Localização</span>
                        <strong>${obterCoordenadas(telemetria)}</strong>
                    </div>
                </div>
                <div class="rover-card-actions">
                    <button type="button" class="primary-button rover-details-button" data-rover-id="${escaparHtml(rover.id_rover)}">Ver detalhes</button>
                    <details class="rover-options">
                        <summary aria-label="Opções do rover ${escaparHtml(rover.nome)} (${escaparHtml(rover.id_rover)})">
                            <svg class="ui-icon" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><circle cx="5" cy="12" r="1.8"/><circle cx="12" cy="12" r="1.8"/><circle cx="19" cy="12" r="1.8"/></svg>
                        </summary>
                        <button type="button" class="rover-delete-button" data-rover-id="${escaparHtml(rover.id_rover)}">Excluir rover</button>
                    </details>
                </div>
            </article>
        `;
    }).join("");

    roversContainer.querySelectorAll(".rover-details-button").forEach(button => {
        button.addEventListener("click", () => {
            const item = roversData.find(roverItem => roverItem.rover.id_rover === button.dataset.roverId);
            if (!item) return;
            localStorage.setItem("selected_rover", item.rover.id_rover);
            window.location.href = "index.html";
        });
    });

    roversContainer.querySelectorAll(".rover-delete-button").forEach(button => {
        button.addEventListener("click", evento => {
            evento.stopPropagation();
            button.closest(".rover-options").open = false;
            const item = roversData.find(roverItem => roverItem.rover.id_rover === button.dataset.roverId);
            if (item) excluirRover(item.rover, button);
        });
    });
}

async function excluirRover(rover, button) {
    const confirmado = window.confirm(
        `Deseja excluir o rover "${rover.nome}" (${rover.id_rover})? ` +
        "As telemetrias associadas a ele também serão excluídas."
    );
    if (!confirmado) return;

    const token = localStorage.getItem("access_token");
    if (!token) {
        window.location.href = "login.html";
        return;
    }

    button.disabled = true;
    button.textContent = "Excluindo...";
    try {
        const response = await fetch(
            `${API_URL}/rovers/${encodeURIComponent(rover.id_rover)}/`,
            {
                method: "DELETE",
                headers: headersComToken(token)
            }
        );

        if (response.status === 401) {
            redirecionarParaLogin();
            return;
        }
        if (!response.ok) {
            const dados = await response.json().catch(() => null);
            const detalhe = dados && typeof dados.detail === "string" ? `: ${dados.detail}` : "";
            throw new Error(`Não foi possível excluir o rover (HTTP ${response.status})${detalhe}.`);
        }

        if (localStorage.getItem("selected_rover") === rover.id_rover) {
            localStorage.removeItem("selected_rover");
        }
        mostrarMensagem(pageMessage, `Rover ${rover.id_rover} excluído com sucesso.`, "success");
        await carregarRovers();
    } catch (error) {
        console.error("Erro ao excluir rover:", error);
        mostrarMensagem(
            pageMessage,
            error instanceof Error
                ? error.message
                : "Não foi possível confirmar a exclusão do rover. Atualize a lista antes de tentar novamente.",
            "error"
        );
        button.disabled = false;
        button.textContent = "Excluir rover";
    }
}

function formatarErroCadastro(dados, status) {
    const rotulos = {
        id_rover: "ID do rover",
        nome: "Nome",
        detail: "Detalhe",
        non_field_errors: "Cadastro"
    };
    if (typeof dados === "string") return dados;
    if (dados && typeof dados === "object") {
        return Object.entries(dados).map(([campo, erros]) =>
            `${rotulos[campo] || campo}: ${Array.isArray(erros) ? erros.join(" ") : String(erros)}`
        ).join("\n") || `Não foi possível cadastrar o rover (HTTP ${status}).`;
    }
    return `Não foi possível cadastrar o rover (HTTP ${status}).`;
}

linkRoverButton.addEventListener("click", () => {
    linkRoverForm.reset();
    mostrarMensagem(linkRoverMessage, "");
    linkRoverModal.showModal();
});

cancelLinkRoverButton.addEventListener("click", () => {
    if (!cadastroEmAndamento) linkRoverModal.close();
});

linkRoverModal.addEventListener("cancel", evento => {
    if (cadastroEmAndamento) evento.preventDefault();
});

linkRoverModal.addEventListener("close", () => linkRoverButton.focus());

linkRoverForm.addEventListener("submit", async evento => {
    evento.preventDefault();
    if (cadastroEmAndamento) return;

    newRoverId.value = newRoverId.value.trim();
    newRoverName.value = newRoverName.value.trim();
    if (!linkRoverForm.reportValidity()) return;
    if (newRoverId.value.length > 50 || newRoverName.value.length > 100) {
        mostrarMensagem(linkRoverMessage, "O ID deve ter até 50 caracteres e o nome até 100.", "error");
        return;
    }

    const token = localStorage.getItem("access_token");
    if (!token) {
        window.location.href = "login.html";
        return;
    }

    const payload = { id_rover: newRoverId.value, nome: newRoverName.value };
    cadastroEmAndamento = true;
    linkRoverForm.setAttribute("aria-busy", "true");
    const controles = [
        newRoverId,
        newRoverName,
        confirmLinkRoverButton,
        cancelLinkRoverButton,
        linkRoverButton,
        refreshButton
    ];
    controles.forEach(controle => { controle.disabled = true; });
    confirmLinkRoverButton.textContent = "Cadastrando...";
    mostrarMensagem(linkRoverMessage, "Aguardando confirmação da API...");

    try {
        const response = await fetch(`${API_URL}/rovers/`, {
            method: "POST",
            headers: headersComToken(token),
            body: JSON.stringify(payload)
        });
        if (response.status === 401) {
            redirecionarParaLogin();
            return;
        }

        const dados = await response.json().catch(() => null);
        if (!response.ok) {
            mostrarMensagem(linkRoverMessage, formatarErroCadastro(dados, response.status), "error");
            return;
        }
        if (response.status !== 201 || !dados || dados.id_rover !== payload.id_rover) {
            mostrarMensagem(
                linkRoverMessage,
                "A API não confirmou o cadastro esperado. Atualize a lista antes de tentar novamente.",
                "error"
            );
            return;
        }

        linkRoverModal.close();
        mostrarMensagem(
            pageMessage,
            `Rover ${dados.id_rover} cadastrado com sucesso. A conexão do equipamento ainda não foi confirmada.`,
            "success"
        );
        await carregarRovers();
    } catch (error) {
        console.error("Erro ao cadastrar rover:", error);
        mostrarMensagem(
            linkRoverMessage,
            "Não foi possível confirmar o cadastro com a API. Verifique sua conexão e atualize a lista antes de tentar novamente.",
            "error"
        );
    } finally {
        cadastroEmAndamento = false;
        linkRoverForm.setAttribute("aria-busy", "false");
        controles.forEach(controle => { controle.disabled = false; });
        confirmLinkRoverButton.textContent = "Confirmar cadastro";
        if (!linkRoverModal.open) linkRoverButton.focus();
    }
});

refreshButton.addEventListener("click", carregarRovers);
roverSearch.addEventListener("input", renderizarRovers);
statusFilter.addEventListener("change", renderizarRovers);
sortOrder.addEventListener("change", renderizarRovers);

if (logoutButton) {
    logoutButton.addEventListener("click", () => {
        localStorage.removeItem("access_token");
        localStorage.removeItem("refresh_token");
        window.location.href = "login.html";
    });
}

carregarRovers();
