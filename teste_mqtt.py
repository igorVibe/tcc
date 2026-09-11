import json
import time
import paho.mqtt.client as mqtt


# ========================================
# CONFIGURAÇÕES
# ========================================

BROKER = "broker.emqx.io"
PORTA = 1883
TOPICO = "rover/telemetria"


# ========================================
# TELEMETRIA
# ========================================

telemetria = {

    "id_rover": "ROVER-01",

    "umidade_solo": 62.5,

    "umidade_ar": 70.2,

    "temperatura_ar": 28.4,

    "qualidade_ar": 85,

    "latitude": -21.2088,

    "longitude": -50.4328,

    "sinal_lora_rssi": -72
}


# ========================================
# CLIENTE MQTT
# ========================================

client = mqtt.Client(
    client_id="rover-agrotech-teste-02",
    protocol=mqtt.MQTTv311
)


# ========================================
# PROGRAMA
# ========================================

print()
print("========================================")
print("       TESTE MQTT - ROVER AGROTECH")
print("========================================")

print()
print(f"🌐 Broker: {BROKER}")
print(f"🔌 Porta: {PORTA}")
print(f"📡 Tópico: {TOPICO}")
print("📡 Protocolo: MQTT 3.1.1")
print()


try:

    # ========================================
    # CONECTAR
    # ========================================

    print("🔌 Conectando ao broker...")

    client.connect(
        BROKER,
        PORTA,
        60
    )

    client.loop_start()

    time.sleep(2)

    print("✅ Conexão realizada!")

    print()


    # ========================================
    # JSON
    # ========================================

    mensagem = json.dumps(
        telemetria
    )


    # ========================================
    # PUBLICAR
    # ========================================

    print("📤 Enviando telemetria...")

    resultado = client.publish(
        TOPICO,
        mensagem,
        qos=0
    )


    if resultado.rc == mqtt.MQTT_ERR_SUCCESS:

        print("✅ Publicação aceita pelo cliente MQTT.")

    else:

        print("❌ Erro na publicação.")

        print(
            f"Código: {resultado.rc}"
        )


    print()
    print("📦 Mensagem:")
    print(mensagem)

    print()
    print("⏳ Aguardando 5 segundos...")

    time.sleep(5)


    # ========================================
    # FINALIZA
    # ========================================

    client.loop_stop()

    client.disconnect()

    print()
    print("========================================")
    print("          TESTE FINALIZADO")
    print("========================================")


except Exception as e:

    print()
    print("========================================")
    print("❌ ERRO")
    print("========================================")

    print(type(e).__name__)
    print(e)