#!/bin/bash

# Would you like to make a donation via pix ?!
#
# Any amount is appreciated: https://iti.itau/receber-pix/?chargeId=9bdcfe03-f432-473c-9487-782f3f3f6b9b
#
# Note: The project is not affiliated with Square Cloud directly or indirectly.

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
    echo "1. Check application status" | lolcat
    echo "2. Check application logs" | lolcat
    echo "3. Access application backup" | lolcat
    echo "4. Add another application" | lolcat
    echo "5. Exit" | lolcat
}

ler_escolha() {
    read -p "Enter an option: " choice
}

ler() {
    read -p "Enter the APIKey value: " APIKey
    read -p "Enter the AUTHORIZATION value: " AUTHORIZATION

    # Save in the CONFIG.SH file
    echo "export APIKey=\"$APIKey\"" >> "$CONFIG_FILE"
    echo "export AUTHORIZATION=\"$AUTHORIZATION\"" >> "$CONFIG_FILE"
}

carrega() {
    # Load the saved data from the created file
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
}

adicionar_outra_aplicacao() {
    read -p "Do you want to replace this application? (Y/N): " resposta
    if [[ $resposta == "Y" || $resposta == "y" ]]; then
        ler
        adicionar_outra_aplicacao
    fi
}

executar_opcao() {
    case $choice in
        1)
            echo "Checking application status..." | lolcat
            curl -k GET "https://api.squarecloud.app/v2/apps/$APIKey/status" \
                -H "Authorization: $AUTHORIZATION" \
                | jq
            sleep 3
            ;;
        2)
            echo "Checking application logs..." | lolcat
            curl -k GET "https://api.squarecloud.app/v2/apps/$APIKey/logs" \
                -H "Authorization: $AUTHORIZATION" \
                | jq
            sleep 5
            ;;
        3)
            echo "Accessing application backup..." | lolcat
            json=$(curl -k GET "https://api.squarecloud.app/v2/apps/$APIKey/backup" \
                -H "Authorization: $AUTHORIZATION" \
                | jq)
            downloadURL=$(echo "$json" | jq -r '.response.downloadURL')
            if [[ $downloadURL == "null" ]]; then
                echo "Error."
            else
                echo "Opening the download URL in the browser..." | lolcat
                if xdg-open "$downloadURL" > /dev/null 2>&1; then
                    echo "Done!"
                else
                    echo "No default browser found to open the URL." | lolcat
                fi
            fi
            ;;
        4)
            echo "Adding another application..." | lolcat
            ler
            adicionar_outra_aplicacao
            ;;
        5)
            echo "Exiting..." | lolcat
            exit
            ;;
        *)
            echo "Invalid choice. Please try again." | lolcat
            ;;
    esac
}

# Configuration of the file
CONFIG_FILE="config.sh"

# Load the saved data
carrega

# Check for saved data
if [ -z "$APIKey" ] || [ -z "$AUTHORIZATION" ]; then
    echo "The environment credentials APIKey and AUTHORIZATION are not defined."
    ler
    adicionar_outra_aplicacao
fi

while true; do
    exibir_menu
    ler_escolha
    executar_opcao
done
