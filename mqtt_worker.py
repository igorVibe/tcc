import os
import json
import django
import paho.mqtt.client as mqtt

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "setup.settings")
django.setup()

from api_rover.models import Rover, Telemetria


# ========================================
# CONFIGURAÇÕES
# ========================================

BROKER = "broker.emqx.io"
PORTA = 1883
TOPICO = "rover/telemetria"

CLIENT_ID = "rover-agrotech-worker-2026-01"


# ========================================
# CONEXÃO
# ========================================

def on_connect(client, userdata, flags, reason_code, properties):

    print()
    print("========================================")
    print("        MQTT CONECTADO")
    print("========================================")

    print(f"Broker: {BROKER}")
    print(f"Porta: {PORTA}")
    print(f"Tópico: {TOPICO}")
    print(f"Client ID: {CLIENT_ID}")
    print(f"Reason code: {reason_code}")
    print()

    if reason_code == 0:

        print("✅ Conexão MQTT estabelecida!")

        resultado, mid = client.subscribe(
            TOPICO,
            qos=0
        )

        print("📡 Inscrição enviada!")
        print(f"Resultado: {resultado}")
        print(f"Message ID: {mid}")

    else:

        print("❌ Broker recusou a conexão!")
        print(f"Código: {reason_code}")


# ========================================
# INSCRIÇÃO
# ========================================

def on_subscribe(client, userdata, mid, reason_codes, properties):

    print()
    print("========================================")
    print("📡 INSCRIÇÃO CONFIRMADA")
    print("========================================")

    print(f"Message ID: {mid}")
    print(f"Reason codes: {reason_codes}")

    print()
    print("🔄 Aguardando mensagens...")
    print(f"📡 Tópico: {TOPICO}")
    print()


# ========================================
# MENSAGEM RECEBIDA
# ========================================

def on_message(client, userdata, msg):

    print()
    print("========================================")
    print("📩 MENSAGEM MQTT RECEBIDA")
    print("========================================")

    print(f"Tópico: {msg.topic}")

    try:

        mensagem = msg.payload.decode("utf-8")

        print(f"Mensagem: {mensagem}")

        dados = json.loads(mensagem)

        print()
        print("📦 JSON convertido com sucesso!")

        id_rover = dados.get("id_rover")

        if not id_rover:

            print("❌ Erro: id_rover não foi enviado.")

            return

        print(f"🆔 Rover recebido: {id_rover}")

        # Buscar Rover no banco
        try:

            rover = Rover.objects.get(
                id_rover=id_rover
            )

        except Rover.DoesNotExist:

            print(
                f"❌ Rover '{id_rover}' não encontrado no banco."
            )

            return

        print(f"✅ Rover encontrado: {rover.nome}")

        # Salvar telemetria
        telemetria = Telemetria.objects.create(

            rover=rover,

            umidade_solo=dados.get(
                "umidade_solo"
            ),

            umidade_ar=dados.get(
                "umidade_ar"
            ),

            temperatura_ar=dados.get(
                "temperatura_ar"
            ),

            qualidade_ar=dados.get(
                "qualidade_ar"
            ),

            latitude=dados.get(
                "latitude"
            ),

            longitude=dados.get(
                "longitude"
            ),

            sinal_lora_rssi=dados.get(
                "sinal_lora_rssi"
            )
        )

        print()
        print("========================================")
        print("✅ TELEMETRIA SALVA NO BANCO!")
        print("========================================")

        print(f"🆔 Rover: {rover.id_rover}")
        print(f"🌱 Umidade do solo: {telemetria.umidade_solo}%")
        print(f"💧 Umidade do ar: {telemetria.umidade_ar}%")
        print(f"🌡️ Temperatura: {telemetria.temperatura_ar}°C")
        print(f"🌬️ Qualidade do ar: {telemetria.qualidade_ar}")
        print(f"📍 Latitude: {telemetria.latitude}")
        print(f"📍 Longitude: {telemetria.longitude}")
        print(f"📡 RSSI: {telemetria.sinal_lora_rssi} dBm")

        print()

    except json.JSONDecodeError:

        print(
            "❌ ERRO: mensagem recebida não é JSON válido."
        )

    except Exception as e:

        print("❌ ERRO AO SALVAR TELEMETRIA:")

        print(type(e).__name__)
        print(e)


# ========================================
# DESCONECTADO
# ========================================

def on_disconnect(
    client,
    userdata,
    disconnect_flags,
    reason_code,
    properties
):

    print()
    print("========================================")
    print("❌ MQTT DESCONECTADO")
    print("========================================")

    print(f"Código da desconexão: {reason_code}")

    print()


# ========================================
# CLIENTE MQTT
# ========================================

client = mqtt.Client(
    mqtt.CallbackAPIVersion.VERSION2,
    client_id=CLIENT_ID,
    protocol=mqtt.MQTTv311
)


# ========================================
# CALLBACKS
# ========================================

client.on_connect = on_connect
client.on_subscribe = on_subscribe
client.on_message = on_message
client.on_disconnect = on_disconnect


# ========================================
# RECONEXÃO
# ========================================

client.reconnect_delay_set(
    min_delay=2,
    max_delay=10
)


# ========================================
# INICIAR
# ========================================

print()
print("========================================")
print("     ROVER AGROTECH - MQTT WORKER")
print("========================================")
print()

print("🔌 Conectando ao broker MQTT...")
print(f"🌐 Broker: {BROKER}")
print(f"🔌 Porta: {PORTA}")
print(f"📡 Tópico: {TOPICO}")
print(f"🆔 Client ID: {CLIENT_ID}")
print()


try:

    client.connect(
        BROKER,
        PORTA,
        60
    )

    print("🔄 Iniciando loop MQTT...")
    print()

    client.loop_forever()


except KeyboardInterrupt:

    print()
    print("🛑 Worker encerrado pelo usuário.")

    client.disconnect()


except Exception as e:

    print()
    print("========================================")
    print("❌ ERRO NO MQTT WORKER")
    print("========================================")

    print(type(e).__name__)
    print(e)