#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

OBTENER_ID_SERVICIOS() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  LISTA_SERVICIOS=$($PSQL "SELECT * FROM services")
  echo "$LISTA_SERVICIOS" | while read ID_SERVICIO BAR SERVICIO
  do
    ID=$(echo $ID_SERVICIO | sed 's/ //g')
    NOMBRE=$(echo $SERVICIO | sed 's/ //g')
    echo "$ID) $SERVICIO"
  done
  read ID_SERVICIO_SELECCIONADO
  case $ID_SERVICIO_SELECCIONADO in
    [1-5]) SIGUIENTE ;;
    *) OBTENER_ID_SERVICIOS "I could not find that service. What would you like today?" ;;
  esac
}

SIGUIENTE() {
  echo -e "\nWhat's your phone number?"
  read TELEFONO_CLIENTE
  NOMBRE=$($PSQL "SELECT name FROM customers WHERE phone='$TELEFONO_CLIENTE'")
  NOMBRE_CLIENTE=$(echo $NOMBRE | sed 's/ //g')
  if [[ -z $NOMBRE ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read NOMBRE_CLIENTE
    NOMBRE=$(echo $NOMBRE_CLIENTE | sed 's/ //g')
    GUARDADO_EN_TABLA_CLIENTES=$($PSQL "INSERT INTO customers(name,phone) VALUES('$NOMBRE','$TELEFONO_CLIENTE')")
  fi
  
  OBTENER_NOMBRE_SERVICIO=$($PSQL "SELECT name FROM services WHERE service_id=$ID_SERVICIO_SELECCIONADO")
  NOMBRE_SERVICIO=$(echo $OBTENER_NOMBRE_SERVICIO | sed 's/ //g')
  ID_CLIENTE=$($PSQL "SELECT customer_id FROM customers WHERE phone='$TELEFONO_CLIENTE'")
  
  echo -e "\nWhat time would you like your $NOMBRE_SERVICIO, $NOMBRE_CLIENTE?"
  read HORA_SERVICIO
  GUARDADO_EN_TABLA_CITAS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($ID_CLIENTE, $ID_SERVICIO_SELECCIONADO, '$HORA_SERVICIO')")
  if [[ $GUARDADO_EN_TABLA_CITAS == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $NOMBRE_SERVICIO at $HORA_SERVICIO, $NOMBRE_CLIENTE."
  fi

}

OBTENER_ID_SERVICIOS