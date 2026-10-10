import random
import time
from prometheus_client import start_http_server, Counter, Gauge, Histogram

LEITURAS = Counter("iot_leituras_total", "Total de leituras recebidas", ["tipo"])
FALHAS = Counter("iot_falhas_eletricas_total", "Total de falhas eletricas detectadas")
TEMPERATURA = Gauge("iot_temperatura_motor_celsius", "Temperatura do motor", ["oficina"])
LATENCIA = Histogram("iot_processamento_segundos", "Tempo de processamento de uma leitura")

OFICINAS = ["oficina-01", "oficina-02", "oficina-03"]


def processar_leitura(oficina):
    with LATENCIA.time():
        time.sleep(random.uniform(0.01, 0.1)) 
        TEMPERATURA.labels(oficina).set(random.uniform(70, 120))
        LEITURAS.labels("temperatura").inc()
        if random.random() < 0.05:
            FALHAS.inc()
            LEITURAS.labels("falha_eletrica").inc()


if __name__ == "__main__":
    start_http_server(8000) 
    print("Simulador IoT rodando. Metricas em :8000/metrics")
    while True:
        for oficina in OFICINAS:
            processar_leitura(oficina)
        time.sleep(1)