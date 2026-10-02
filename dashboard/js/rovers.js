    // ========================================
// CONFIGURAÇÕES
// ========================================

const API_URL = "http://127.0.0.1:8000";


// ========================================
// ELEMENTOS DA PÁGINA
// ========================================

const roversContainer =
    document.getElementById("roversContainer");

const refreshButton =
    document.getElementById("refreshButton");

const logoutButton =
    document.getElementById("logoutButton");


// ========================================
// CARREGAR ROVERS
// ========================================

async function carregarRovers() {

    try {

        // Pega o token atual
        const token =
            localStorage.getItem("access_token");


        console.log(
            "🔐 Token encontrado:",
            token ? "SIM" : "NÃO"
        );


        // ========================================
        // VERIFICAR TOKEN
        // ========================================

        if (!token) {

            console.error(
                "❌ Nenhum token encontrado."
            );

            window.location.href =
                "login.html";

            return;

        }


        // ========================================
        // MENSAGEM DE CARREGAMENTO
        // ========================================

        roversContainer.innerHTML = `
            <div class="loading">
                Carregando rovers...
            </div>
        `;


        // ========================================
        // REQUISIÇÃO PARA A API
        // ========================================

        const response = await fetch(
            `${API_URL}/rovers/`,
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


        console.log(
            "📡 Status da API:",
            response.status
        );


        // ========================================
        // TOKEN INVÁLIDO
        // ========================================

        if (response.status === 401) {

            console.error(
                "❌ Token inválido ou expirado."
            );


            localStorage.removeItem(
                "access_token"
            );

            localStorage.removeItem(
                "refresh_token"
            );


            window.location.href =
                "login.html";


            return;

        }


        // ========================================
        // OUTRO ERRO
        // ========================================

        if (!response.ok) {

            throw new Error(
                `Erro HTTP ${response.status}`
            );

        }


        // ========================================
        // CONVERTER RESPOSTA
        // ========================================

        const resultado =
            await response.json();


        console.log(
            "🤖 Rovers recebidos:",
            resultado
        );


        // ========================================
        // TRATAR PAGINAÇÃO
        // ========================================

        const rovers =
            resultado.results || resultado;


        // ========================================
        // VERIFICAR ROVERS
        // ========================================

        if (
            !rovers ||
            rovers.length === 0
        ) {

            roversContainer.innerHTML = `
                <div class="loading">
                    Nenhum Rover cadastrado.
                </div>
            `;

            return;

        }


        // ========================================
        // LIMPAR CONTAINER
        // ========================================

        roversContainer.innerHTML = "";


        // ========================================
        // CRIAR CARDS
        // ========================================

        rovers.forEach(
            rover => {

                const card =
                    document.createElement("div");


                card.className = "rover-card";

                // ========================================
                // ABRIR DASHBOARD DO ROVER
                // ========================================
                
                card.style.cursor = "pointer";

                card.addEventListener("click", () => {
                    localStorage.setItem(
                        "selected_rover",
                        rover.id_rover
    );
                    window.location.href = "index.html";

                    });


                // ========================================
                // STATUS
                // ========================================

                // auto_now atualiza ultima_conexao no cadastro: não comprova conexão.
                const status = "Não confirmado";
                const statusClass = "unconfirmed";


                // ========================================
                // CARD
                // ========================================

                card.innerHTML = `

                    <div class="rover-card-header">

                        <div>

                            <h3>
                                ${escaparHtml(rover.nome)}
                            </h3>

                            <small>
                                ${escaparHtml(rover.id_rover)}
                            </small>

                        </div>


                        <span
                            class="rover-status ${statusClass}"
                        >

                            ${status}

                        </span>

                    </div>


                    <div class="rover-info">


                        <div
                            class="rover-info-item"
                        >

                            <span>
                                <svg class="ui-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M4 16V9h12l4 7M4 12h15M10 9V5h4"/><circle cx="6" cy="17" r="3"/><circle cx="18" cy="17" r="3"/></svg> ID
                            </span>

                            <strong>
                                ${escaparHtml(rover.id_rover)}
                            </strong>

                        </div>


                        <div
                            class="rover-info-item"
                        >

                            <span>
                                <svg class="ui-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><rect x="2" y="6" width="17" height="12" rx="2"/><path d="M22 10v4M6 10v4M10 10v4M14 10v4"/></svg> Bateria no cadastro
                            </span>

                            <strong>
                                ${escaparHtml(rover.bateria ?? "--")}%
                            </strong>

                        </div>


                        <div
                            class="rover-info-item"
                        >

                            <span>
                                <svg class="ui-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg> Atualização do cadastro
                            </span>

                            <strong>
                                ${formatarData(
                                    rover.ultima_conexao
                                )}
                            </strong>

                        </div>


                    </div>

                `;


                roversContainer.appendChild(
                    card
                );

            }
        );


        console.log(
            "✅ Rovers carregados com sucesso!"
        );


    } catch (error) {

        console.error(
            "❌ Erro ao carregar Rovers:",
            error
        );


        roversContainer.innerHTML = `
            <div class="loading">

                Não foi possível
                conectar à API.

            </div>
        `;

    }

}


// ========================================
// FORMATAR DATA
// ========================================

function formatarData(data) {

    if (!data) {

        return "--";

    }


    const dataFormatada =
        new Date(data);


    return dataFormatada.toLocaleString(
        "pt-BR"
    );

}


// ========================================
// BOTÃO ATUALIZAR
// ========================================

if (refreshButton) {

    refreshButton.addEventListener(
        "click",
        carregarRovers
    );

}


// ========================================
// LOGOUT
// ========================================

if (logoutButton) {

    logoutButton.addEventListener(
        "click",
        () => {

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

}


// ========================================
// INICIAR
// ========================================

function escaparHtml(valor) {
    return String(valor).replace(/[&<>"']/g, caractere => ({
        "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
    }[caractere]));
}

const linkRoverButton = document.getElementById("linkRoverButton");
const linkRoverModal = document.getElementById("linkRoverModal");
const linkRoverForm = document.getElementById("linkRoverForm");
const newRoverId = document.getElementById("newRoverId");
const newRoverName = document.getElementById("newRoverName");
const linkRoverMessage = document.getElementById("linkRoverMessage");
const cancelLinkRoverButton = document.getElementById("cancelLinkRoverButton");
const confirmLinkRoverButton = document.getElementById("confirmLinkRoverButton");
const pageMessage = document.getElementById("message");
let cadastroEmAndamento = false;

function mostrarMensagem(elemento, texto, tipo = "") {
    elemento.textContent = texto;
    elemento.dataset.type = tipo;
}

function formatarErroCadastro(dados, status) {
    const rotulos = { id_rover: "ID do rover", nome: "Nome", detail: "Detalhe", non_field_errors: "Cadastro" };
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
    const controles = [newRoverId, newRoverName, confirmLinkRoverButton, cancelLinkRoverButton, linkRoverButton, refreshButton];
    controles.forEach(controle => { controle.disabled = true; });
    confirmLinkRoverButton.textContent = "Cadastrando...";
    mostrarMensagem(linkRoverMessage, "Aguardando confirmação da API...");
    try {
        const response = await fetch(`${API_URL}/rovers/`, {
            method: "POST",
            headers: { "Authorization": `Bearer ${token}`, "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });
        if (response.status === 401) {
            localStorage.removeItem("access_token");
            localStorage.removeItem("refresh_token");
            window.location.href = "login.html";
            return;
        }
        const dados = await response.json().catch(() => null);
        if (!response.ok) {
            mostrarMensagem(linkRoverMessage, formatarErroCadastro(dados, response.status), "error");
            return;
        }
        if (response.status !== 201 || !dados || dados.id_rover !== payload.id_rover) {
            mostrarMensagem(linkRoverMessage, "A API não confirmou o cadastro esperado. Atualize a lista antes de tentar novamente.", "error");
            return;
        }
        linkRoverModal.close();
        mostrarMensagem(pageMessage, `Rover ${dados.id_rover} cadastrado com sucesso. A conexão do equipamento ainda não foi confirmada.`, "success");
        await carregarRovers();
    } catch (error) {
        mostrarMensagem(linkRoverMessage, "Não foi possível confirmar o cadastro com a API. Verifique sua conexão e atualize a lista antes de tentar novamente.", "error");
    } finally {
        cadastroEmAndamento = false;
        linkRoverForm.setAttribute("aria-busy", "false");
        controles.forEach(controle => { controle.disabled = false; });
        confirmLinkRoverButton.textContent = "Confirmar cadastro";
        if (!linkRoverModal.open) linkRoverButton.focus();
    }
});

carregarRovers();
