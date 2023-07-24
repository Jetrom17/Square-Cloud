#!/bin/bash

# Queira fazer uma doação via pix ?!
#
# Quaisquer valor que seja: https://iti.itau/receber-pix/?chargeId=9bdcfe03-f432-473c-9487-782f3f3f6b9b
#
# Nota: Projeto não tem filiação ao Square Cloud diretamente ou indiretamente.

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
    echo "1. Verificar status da aplicação" | lolcat
    echo "2. Verificar logs da aplicação" | lolcat
    echo "3. Acessar backup da aplicação" | lolcat
    echo "4. Adicionar outra aplicação" | lolcat
    echo "5. Sair" | lolcat
}

ler_escolha() {
    read -p "Digite uma opção: " choice
}

ler() {
    read -p "Digite o valor do APIKey: " APIKey
    read -p "Digite o valor do AUTHORIZATION: " AUTHORIZATION

    # Salva no arquivo CONFIG.SH
    echo "export APIKey=\"$APIKey\"" >> "$CONFIG_FILE"
    echo "export AUTHORIZATION=\"$AUTHORIZATION\"" >> "$CONFIG_FILE"
}

carrega() {
    # Carrega os dados gravados no arquivo criado
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
}

adicionar_outra_aplicacao() {
    read -p "Deseja substituir esta aplicação? (S/N): " resposta
    if [[ $resposta == "S" || $resposta == "s" ]]; then
        ler
        adicionar_outra_aplicacao
    fi
}

executar_opcao() {
    case $choice in
        1)
            echo "Verificando status da aplicação..." | lolcat
            curl -k GET "https://api.squarecloud.app/v2/apps/$APIKey/status" \
                -H "Authorization: $AUTHORIZATION" \
                | jq
            sleep 3
            ;;
        2)
            echo "Verificando logs da aplicação..." | lolcat
            curl -k GET "https://api.squarecloud.app/v2/apps/$APIKey/logs" \
                -H "Authorization: $AUTHORIZATION" \
                | jq
            sleep 5
            ;;
        3)
            echo "Acessando backup da aplicação..." | lolcat
            json=$(curl -k GET "https://api.squarecloud.app/v2/apps/$APIKey/backup" \
                -H "Authorization: $AUTHORIZATION" \
                | jq)
            downloadURL=$(echo "$json" | jq -r '.response.downloadURL')
            if [[ $downloadURL == "null" ]]; then
                echo "Erro."
            else
                echo "Abrindo a URL de download no navegador..." | lolcat
                if xdg-open "$downloadURL" > /dev/null 2>&1; then
                    echo "Feito!"
                else
                    echo "Nenhum navegador padrão encontrado para abrir a URL." | lolcat
                fi
            fi
            ;;
        4)
            echo "Adicionando outra aplicação..." | lolcat
            ler
            adicionar_outra_aplicacao
            ;;
        5)
            echo "Saindo..." | lolcat
            exit
            ;;
        *)
            echo "Escolha inválida. Tente novamente." | lolcat
            ;;
    esac
}

# Configuração do arquivo
CONFIG_FILE="config.sh"

# Carrega os dados gravados
carrega

# Dados gravados a verificar
if [ -z "$APIKey" ] || [ -z "$AUTHORIZATION" ]; then
    echo "As credenciais de ambiente APIKey e AUTHORIZATION não estão definidas."
    ler
    adicionar_outra_aplicacao
fi

while true; do
    exibir_menu
    ler_escolha
    executar_opcao
done
