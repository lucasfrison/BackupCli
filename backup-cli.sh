#!/bin/sh

. ./usr/bin/backup-lib.sh
#-------------------//--------------------------------//---------------------------------//--

#título...OK
titulo

echo "Vamos começar pela configuração da ORIGEM."
echo

#disponibilizar ajuda...OK
#ler diretório de origem...OK
until [ "$bool" = true ];
do
   menu "Selecione uma opção:" "Selecionar um diretório de ORIGEM."
   read opcao
   valida_op "$opcao"
   titulo
   echo "Digite o caminho do diretório de ORIGEM do backup:"
   read origem
   origem=${origem#/}
   origem=${origem%/}
   origem="/$origem"
   echo
   #verificação do diretório origem...OK
   check_dir "$origem"
   echo
done

titulo
echo "Diretório de ORIGEM selecionado com sucesso!"
echo "Seguindo para a configuração de DESTINO."
echo

bool=false

#ler diretório de destino...OK
until [ "$bool" = true ];
do
   opcao=2
   while [ "$opcao" = "2" ];
   do
      controle=1
      menu "Escolha uma opção:" "Selecionar um diretório de DESTINO."
      read opcao
      if [ "$opcao" != "3" ]; then
         controle=0
      fi
      valida_op "$opcao"
      titulo
   done
   echo "Digite o caminho do diretório de DESTINO (para criação, somente o nome):"
   read destino
   destino=${destino#/}
   destino=${destino%/}
   destino="/$destino"
   echo
   #verificaçao diretorio destino...OK
   check_dir "$destino"
   if [ "$controle" = "1" ]; then
      destino="$HOME$destino"
   fi
   controle=0
   echo
done

bool=false
titulo
echo "Diretório de DESTINO selecionado com sucesso!"
echo

#exibir diretórios para conferência...OK
echo "O diretório de ORIGEM é: $origem"
echo "O diretório de DESTINO é: $destino"
echo

#início das opções de backup...OK
echo "ATENÇÃO: Seguindo para a configuração do BACKUP com os diretórios acima!"
menu "Selecione uma opção:" "Iniciar configuração do BACKUP."
read opcao
valida_op "$opcao"
titulo

#tipo de backup...OK
logfile=$origem/logsync.txt
echo "Selecione o tipo de BACKUP:"
echo
echo "1. Copiar os arquivos da ORIGEM e APAGAR no DESTINO os arquivos que NÃO estão na ORIGEM."
echo "2. Copiar os arquivos da ORIGEM e MANTER todos os arquivos no destino."
read opcao
echo

#arquivos a serem ignorados...OK
bool=false
titulo
echo "Se houver algum arquivo ou diretório que NÃO deseja no backup, digite agora."
echo "Digite o nome do arquivo or diretório e aperte ENTER, quando terminar aperte somente ENTER para continuar."
echo "Se quiser ver o conteúdo do diretório, digite ls."
echo
echo "LISTE OS ARQUIVOS E DIRETÓRIOS:"

dir2=$PWD
control=0
cd "$origem"
until [ "$bool" = true ];
do
   read arquivo
   if [ "$arquivo" = "ls" ]; then
      echo
      echo "--------------------ARQUIVOS DO DIRETÓRIO $origem--------------------"
      echo
      ls -a
      echo
      echo "--------------------ARQUIVOS DO DIRETÓRIO $origem--------------------"
      echo
      echo "LISTE OS ARQUIVOS E DIRETÓRIOS:"
   elif [ "$arquivo" = "fim" ]; then
      bool=true
   elif [ -f "$arquivo" ] || [ -d "$arquivo" ]; then
      if [ "$control" = "0" ]; then
         echo "$arquivo" > .ignore.txt
         control=1
      else
         echo "$arquivo" >> .ignore.txt
      fi     
   elif [ "$arquivo" = "" ]; then
      if [ "$control" = "0" ]; then
         echo "$arquivo" > .ignore.txt
      fi
      bool=true
   fi
done

#confirmação de segurança...OK
echo "ÚLTIMA CHANCE DE CANCELAR. TEM CERTEZA QUE DESEJA CONTINUAR? ( s / n )"
read confirm
titulo

if [ "$confirm" != "s" ]; then
   echo
   echo "OPERAÇÃO CANCELADA. ENCERRANDO O PROGRAMA..." 
   exit
elif [ "$opcao" = "1" ]; then
    #início do backup...OK
    titulo
    echo "INICIANDO BACKUP..."
    echo
    rsync -auvh $origem/ $destino/ --progress --delete --exclude-from=$origem/.ignore.txt --log-file=$logfile
    backup="rsync -auvh $origem/ $destino/ --progress --delete --exclude-from=$origem/.ignore.txt --log-file=$logfile"
else
    titulo
    echo "INICIANDO BACKUP..."
    echo
    rsync -auvh $origem/ $destino/ --progress --exclude-from=$origem/.ignore.txt --log-file=$logfile
    backup="rsync -auvh $origem/ $destino/ --progress --exclude-from=$origem/.ignore.txt --log-file=$logfile"
fi
echo
echo "BACKUP CONCLUÍDO!"
echo "ENTER PARA CONTINUAR"
read key

#opções de agendamento...OK
bool=false
cd "$dir2"
until [ "$bool" = true ];
do
   titulo
   menu_agenda
   read opcao   
   case "$opcao" in
      0) titulo
         cat backup-help.txt
         echo
         echo "PRESSIONE ENTER PARA CONTINUAR"
         read key
      ;;
      1) agenda_msg "1 minuto." "Segundo 00."
         cront="* * * * * $backup"
      ;;
      2) agenda_msg "15 minutos." "Minutos 15, 30, 45, 00; segundo 00."
         cront="*/15 * * * * $backup"
      ;;
      3) cront="*/30 * * * * $backup"
         agenda_msg "30 minutos." "Minutos 30, 00; segundo 00."
      ;;
      4) cront="0 * * * * $backup"
         agenda_msg "1 hora." "Horas 0-23; minuto 00."
      ;; 
      5) cront="0 */12 * * * $backup"
         agenda_msg "12 horas." "Horas 12, 00; minuto 00."
      ;;
      6) cront="0 0 * * * $backup"
         agenda_msg "1 dia." "Hora 00; Minuto 00."
      ;;
      7) cront="0 0 * * 0 $backup"
         agenda_msg "1 semana." "Domingo; Hora 00; Minuto 00."
      ;;
      8) cront="0 0 1 * * $backup"
         agenda_msg "1 mês." "Dia 01; Hora 00; Minuto 00."
      ;;
      9) cront="0 0 1 1 * $backup"
         agenda_msg "1 ano." "Mês 01; Dia 01; Hora 00; Minuto 00."
      ;;
      999) echo
         echo "OPERAÇÃO CANCELADA. ENCERRANDO O PROGRAMA..."
         exit
      ;;
   esac
done

#agendamento crontab...OK
(crontab -l 2>/dev/null; echo "$cront") | crontab -
echo
echo "BACKUP AGENDADO COM SUCESSO! ENCERRANDO O PROGRAMA..."

