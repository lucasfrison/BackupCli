#!/bin/sh

#var
controle=0
bool=false

#funções

#titulo
titulo () {
   clear
   echo "               #################################"
   echo "               # BACKUP COMMAND LINE INTERFACE #"
   echo "               #################################"
   echo
}

#validação de opção
valida_op () {
   op=$1
   if [ "$op" = "2" ]; then
       titulo
       cat /usr/bin/backup-help.txt
       echo
       echo "APERTE ENTER PARA CONTINUAR"
       read key
       clear
   elif [ "$op" = "3" ] && [ "$controle" = "1" ]; then
       return 0
   elif [ "$op" != "1" ]; then
       echo 
       echo "OPERAÇÃO CANCELADA. ENCERRANDO O PROGRAMA..."
       exit
   fi
}

#menu de opçoes
menu () {
   linha=$1
   linha2=$2
   echo "$linha"
   echo
   echo "1. $linha2"
   echo "2. Ver a AJUDA antes de $linha2"
   if [ "$controle" = "1" ]; then
      echo "3. Criar novo diretório de DESTINO no HOME do USUÁRIO."
   fi
   echo "OU Pressione qualquer outra tecla para encerrar o programa."  
}

#validação do diretório
check_dir () {
   DIRECTORY=$1
   if [ "$controle" = "1" ]; then
      dir=$PWD
      cd "$HOME"
      DIRECTORY=${DIRECTORY#/}
      DIRECTORY=${DIRECTORY%/}
      mkdir "$DIRECTORY"
      cd "$dir"
      DIRECTORY="$HOME/$DIRECTORY"
   fi
   if [ -d "$DIRECTORY" ]; then
      echo "O diretótio selecionado foi: $DIRECTORY"
      echo "Confirmar? ( s / n )"
      read conf 
      if [ "$conf" = "s" ]; then
         bool=true
      fi
   else
      echo "O diretório $DIRECTORY é INVÁLIDO ou NÂO existe."
   fi
}

#menu de agendamento
menu_agenda () {
   echo
   echo "Configurações de agendamento."
   echo "Selecione uma opção:"
   echo
   echo "0. Preciso de AJUDA!"
   echo "1. Backup a cada 01 minuto."
   echo "2. Backup a cada 15 minutos."
   echo "3. Backup a cada 30 minutos."
   echo "4. Backup a cada 01 hora."
   echo "5. Backup a cada 12 horas."
   echo "6. Backup a cada 01 dia."
   echo "7. Backup a cada 01 semana."
   echo "8. Backup a cada 01 mês."
   echo "9. Backup a cada 01 ano."
   echo "999. Cancelar e encerrar o programa."
}

#mensagem de confirmação de escolha do agendamento
agenda_msg () {
   p1=$1
   p2=$2
   echo
   echo "Agendamento selecionado: A cada $p1"
   echo "Execução do backup: $p2"
   echo
   echo "DESEJA CONTINUAR COM A OPÇÃO ACIMA? ( s / n )"
   read conf
   if [ "$conf" = "s" ]; then
      bool=true
   fi   
}
