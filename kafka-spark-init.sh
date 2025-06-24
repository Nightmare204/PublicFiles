#!/bin/bash

set -euxo pipefail

readonly JARS_DIR="/usr/lib/spark/jars"

# JARs necesarios para integración Spark + Kafka (versión 3.3.2 y Scala 2.12)
declare -A JARS_URLS=(
  ["spark-sql-kafka-0-10_2.12-3.3.2.jar"]="https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-0-10_2.12/3.3.2/spark-sql-kafka-0-10_2.12-3.3.2.jar"
  ["kafka-clients-3.3.2.jar"]="https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.3.2/kafka-clients-3.3.2.jar"
  ["spark-token-provider-kafka-0-10_2.12-3.3.2.jar"]="https://repo1.maven.org/maven2/org/apache/spark/spark-token-provider-kafka-0-10_2.12/3.3.2/spark-token-provider-kafka-0-10_2.12-3.3.2.jar"
  ["commons-pool2-2.11.1.jar"]="https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.11.1/commons-pool2-2.11.1.jar"
)

install_kafka_connectors() {
  echo "📦 Instalando JARs requeridos en ${JARS_DIR}"
  mkdir -p "${JARS_DIR}"

  for jar in "${!JARS_URLS[@]}"; do
    if [[ ! -f "${JARS_DIR}/${jar}" ]]; then
      echo "⬇️ Descargando $jar"
      wget -q "${JARS_URLS[$jar]}" -P "${JARS_DIR}/"
    else
      echo "✅ $jar ya está presente"
    fi
  done
}

main() {
  echo "🚀 Ejecutando init-action extendida para Kafka + Spark"

  # Ejecutar script oficial de Kafka (si está disponible)
  if [[ -f "/usr/lib/systemd/system/zookeeper.service" ]]; then
    echo "🔁 Kafka ya parece estar instalado, omitiendo parte base"
  else
    echo "📡 Ejecutando kafka.sh base de Google..."
    curl -sSL "https://storage.googleapis.com/goog-dataproc-initialization-actions-us-east1/kafka/kafka.sh" | bash
  fi

  install_kafka_connectors

  echo "✅ Init-action finalizada"
}

main "$@"
