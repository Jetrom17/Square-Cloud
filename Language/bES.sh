#!/bin/bash

# ¿Te gustaría hacer una donación a través de pix ?!
#
# Cualquier cantidad es bienvenida: https://iti.itau/receber-pix/?chargeId=9bdcfe03-f432-473c-9487-782f3f3f6b9b
#
# Nota: El proyecto no está afiliado directa o indirectamente a Square Cloud.

exibir_menu() {
    cubo="
  ______                                       _______  _                     _ 
 / _____)                                     (_______)| |                   | |
( (____    ____  _   _  _____   ____  _____    _       | |   ___   _   _   __| |
 \____ \  / _  || | | |(____ | / ___)| ___ |  | |      | |  / _ \ | | | | / _  |
 _____) )| |_| || |_| |/ ___ || |    | ____|  | |_____ | | | |_| || |_| |( (_| |
(______/  \__  ||____/ \_____||_|    |_____)   \______) \_) \___/ |____/  \____|
             |_|                                                                
"
    echo "$cubo" | lolcat
    echo "1. Verificar estado de la aplicación" | lolcat
    echo "2. Verificar registros de la aplicación" | lolcat
    echo "3. Acceder a la copia de seguridad de la aplicación" | lolcat
    echo "4. Añadir otra aplicación" | lolcat
    echo "5. Salir" | lolcat
}

ler_escolha() {
    read -p "Ingrese una opción: " choice
}

ler() {
    read -p "Ingrese el valor de APIKey: " APIKey
    read -p "Ingrese el valor de AUTHORIZATION: " AUTHORIZATION

    # Guardar en el archivo CONFIG.SH
    echo "export APIKey=\"$APIKey\"" >> "$CONFIG_FILE"
    echo "export AUTHORIZATION=\"$AUTHORIZATION\"" >> "$CONFIG_FILE"
}

carrega() {
    # Cargar los datos guardados del archivo creado
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
}

adicionar_outra_aplicacao() {
    read -p "¿Desea reemplazar esta aplicación? (S/N): " respuesta
    if [[ $respuesta == "S" || $respuesta == "s" ]]; then
        ler
        adicionar_outra_aplicacao
    fi
}

executar_opcao() {
    case $choice in
        1)
            echo "Verificando estado de la aplicación..." | lolcat
            curl -k GET "https://api.squarecloud.app/v2/apps/$APIKey/status" \
                -H "Authorization: $AUTHORIZATION" \
                | jq
            sleep 3
            ;;
        2)
            echo "Verificando registros de la aplicación..." | lolcat
            curl -k GET "https://api.squarecloud.app/v2/apps/$APIKey/logs" \
                -H "Authorization: $AUTHORIZATION" \
                | jq
            sleep 5
            ;;
        3)
            echo "Accediendo a la copia de seguridad de la aplicación..." | lolcat
            json=$(curl -k GET "https://api.squarecloud.app/v2/apps/$APIKey/backup" \
                -H "Authorization: $AUTHORIZATION" \
                | jq)
            downloadURL=$(echo "$json" | jq -r '.response.downloadURL')
            if [[ $downloadURL == "null" ]]; then
                echo "Error."
            else
                echo "Abriendo la URL de descarga en el navegador..." | lolcat
                if xdg-open "$downloadURL" > /dev/null 2>&1; then
                    echo "¡Hecho!"
                else
                    echo "No se encontró un navegador predeterminado para abrir la URL." | lolcat
                fi
            fi
            ;;
        4)
            echo "Añadiendo otra aplicación..." | lolcat
            ler
            adicionar_outra_aplicacao
            ;;
        5)
            echo "Saliendo..." | lolcat
            exit
            ;;
        *)
            echo "Opción inválida. Por favor, intente nuevamente." | lolcat
            ;;
    esac
}

# Configuración del archivo
CONFIG_FILE="config.sh"

# Cargar los datos guardados
carrega

# Verificar los datos guardados
if [ -z "$APIKey" ] || [ -z "$AUTHORIZATION" ]; then
    echo "Las credenciales de entorno APIKey y AUTHORIZATION no están definidas."
    ler
    adicionar_outra_aplicacao
fi

while true; do
    exibir_menu
    ler_escolha
    executar_opcao
done
