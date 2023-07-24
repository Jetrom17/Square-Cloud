Claro, aqui está o script com todas as ocorrências de `echo "texto"` substituídas pelo texto em espanhol:

```
#!/bin/bash

# ¿Te gustaría hacer una donación a través de pix ?!
#
# Cualquier monto: https://iti.itau/receber-pix/?chargeId=9bdcfe03-f432-473c-9487-782f3f3f6b9b
#
# Nota: El proyecto no está afiliado a Square Cloud directa o indirectamente.

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
  echo "1. Verificar el estado de la aplicación" | lolcat
  echo "2. Verificar los registros de la aplicación" | lolcat
  echo "3. Acceder a la copia de seguridad de la aplicación" | lolcat
  echo "4. Agregar otra aplicación" | lolcat
  echo "5. Salir" | lolcat
}

ler_escolha() {
  read -p "Ingrese una opción: " escolha
}

ler() {
  read -p "Ingrese el valor del ID: " ID
  read -p "Ingrese el valor de AUTORIZACIÓN: " AUTORIZACIÓN

  # Guardar en el archivo CONFIG.SH
  echo "export ID=\"$ID\"" >> "$CONFIG_FILE"
  echo "export AUTORIZATION=\"$AUTHORIZATION\"" >> "$CONFIG_FILE"
}

carrega() {
  # Carga los datos registrados en el archivo creado
  if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
  fi
}

adicionar_outra_aplicacao() {
  read -p "¿Desea reemplazar esta aplicación? (S/N): " resposta
  if [[ $resposta == "S" || $resposta == "s" ]]; then
    ler
    adicionar_outra_aplicacao
  fi
}

executar_opcao() {
  case $escolha in
    1)
      echo "Verificando el estado de la aplicación..." | lolcat
      curl -X GET "https://api.squarecloud.app/v2/apps/$ID/status" \
        -H "Authorization: $AUTHORIZATION" \
        | jq
      sleep 3
      ;;
    2)
      echo "Verificando los registros de la aplicación..." | lolcat
      curl -X GET "https://api.squarecloud.app/v2/apps/$ID/logs" \
        -H "Authorization: $AUTHORIZATION" \
        | jq
      sleep 5
      ;;
    3)
      echo "Accediendo a la copia de seguridad de la aplicación..." | lolcat
      json=$(curl -X GET "https://api.squarecloud.app/v2/apps/$ID/backup" \
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
          echo "No se encontró ningún navegador predeterminado para abrir la URL." | lolcat
        fi
      fi
      ;;
    4)
      echo "Agregando otra aplicación..." | lolcat
      ler
