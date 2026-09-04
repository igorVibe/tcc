import socket

BROKER = "broker.emqx.io"
PORTA = 1883

print("🔌 Testando conexão TCP...")
print(f"🌐 Broker: {BROKER}")
print(f"🔌 Porta: {PORTA}")

try:

    sock = socket.create_connection(
        (BROKER, PORTA),
        timeout=10
    )

    print("✅ TCP conectado!")

    # Pacote MQTT CONNECT mínimo
    pacote = bytes([
        0x10, 0x0C,
        0x00, 0x04,
        0x4D, 0x51, 0x54, 0x54,
        0x04,
        0x02,
        0x00, 0x3C,
        0x00, 0x00
    ])

    print("📤 Enviando pacote MQTT CONNECT...")

    sock.sendall(pacote)

    print("📥 Aguardando resposta do broker...")

    resposta = sock.recv(10)

    print("📦 Resposta recebida:")
    print(resposta)

    if resposta:

        print("✅ O broker respondeu ao protocolo MQTT!")

    else:

        print("❌ O broker não respondeu.")

    sock.close()

except Exception as e:

    print("❌ ERRO:")
    print(type(e).__name__)
    print(e)