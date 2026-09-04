import json
import time
import threading
import paho.mqtt.client as mqtt


# ============================================================
# CONFIGURAÇÃO MQTT
# ============================================================

BROKER = "mqtt.eclipseprojects.io"
PORTA = 1883
TOPICO = "rover/telemetria"

CLIENT_ID = "rover-agrotech-teste-01"


# ============================================================
# DADOS FALSOS DO ROVER
# ============================================================

dados = {

    "id_rover": "ROVER-01",

    "umidade_solo": 62.5,

    "umidade_ar": 70.2,

    "temperatura_ar": 28.4,

    "qualidade_ar": 85.0,

    "latitude": -21.20880000,

    "longitude": -50.43280000,

    "sinal_lora_rssi": -72
}


mensagem = json.dumps(
    dados
)


# ============================================================
# EVENTO DE CONEXÃO
# ============================================================

conectado = threading.Event()


def on_connect(
    client,
    userdata,
    connect_flags,
    reason_code,
    properties
):

    if reason_code == 0:

        print("✅ Conectado ao broker!")

        conectado.set()

    else:

        print("❌ Erro ao conectar!")

        print(
            f"❌ Código: {reason_code}"
        )


# ============================================================
# EVENTO DE PUBLICAÇÃO
# ============================================================

def on_publish(
    client,
    userdata,
    mid,
    reason_code,
    properties
):

    print(
        f"📤 Broker confirmou publicação! "
        f"MID: {mid}"
    )


# ============================================================
# CRIA CLIENTE
# ============================================================

client = mqtt.Client(
    callback_api_version=mqtt.CallbackAPIVersion.VERSION2,
    client_id=CLIENT_ID
)

client.on_connect = on_connect
client.on_publish = on_publish


# ============================================================
# TESTE
# ============================================================

print("")
print("=" * 60)
print("🧪 TESTE MQTT - ROVER AGROTECH")
print("=" * 60)

print(
    f"🌐 Broker: {BROKER}"
)

print(
    f"🔌 Porta: {PORTA}"
)

print(
    f"📡 Tópico: {TOPICO}"
)

print("")
print("🔌 Conectando ao broker...")


try:

    client.connect(
        BROKER,
        PORTA,
        60
    )

    # Inicia processamento MQTT
    client.loop_start()

    # Aguarda conexão
    if not conectado.wait(timeout=10):

        print(
            "❌ Timeout aguardando conexão MQTT."
        )

        client.loop_stop()
        client.disconnect()

        exit()

    print("")
    print("📤 Enviando mensagem...")

    print(
        f"📡 Tópico: {TOPICO}"
    )

    print("")
    print("📦 Dados enviados:")

    print(
        json.dumps(
            dados,
            indent=4,
            ensure_ascii=False
        )
    )

    # --------------------------------------------------------
    # PUBLICA
    # --------------------------------------------------------

    resultado = client.publish(

        TOPICO,

        mensagem,

        qos=0,

        retain=True
    )

    print("")
    print(
        f"📤 Resultado do publish: {resultado}"
    )

    # Aguarda processamento MQTT
    time.sleep(3)

    print("")
    print("✅ Mensagem publicada!")

    print("")
    print("🔌 Desconectando...")

    client.loop_stop()

    client.disconnect()

    print("✅ Teste finalizado!")

except Exception as e:

    print("")
    print("❌ ERRO NO TESTE MQTT!")

    print(
        f"❌ Tipo: {type(e).__name__}"
    )

    print(
        f"❌ Detalhes: {e}"
    )