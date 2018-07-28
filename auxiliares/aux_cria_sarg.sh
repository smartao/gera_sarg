#!/bin/bash

. /etc/scripts/gera_sarg/servers.conf

# Diretorio de simulacao do sarg
DIR_SIMULACAO=/tmp/simulacao

mkdir $DIR_SIMULACAO
mkdir $DIR_SIMULACAO/etc
mkdir $DIR_SIMULACAO/etc/sarg/

mkdir $DIR_SIMULACAO/dados/logs #Diretorio do access.log 
mkdir $DIR_SIMULACAO/dados/logs/scripts/ #Diretorio do access.log 

mkdir $DIR_SIMULACAO/dados
mkdir $DIR_SIMULACAO/dados/www/
mkdir $DIR_SIMULACAO/dados/www/sarg

mkdir $DIR_SIMULACAO/dados/backups
#mkdir $DIR_SIMULACAO/dados/backups/diario	# Nao sera mais utilizado
#mkdir $DIR_SIMULACAO/dados/backups/sarg  	# Nao sera mais utilizado

for ((w=1;w<=${#IP[@]};w++));
do
	mkdir $DIR_SIMULACAO/dados/logs/${SITE[$w]}
	mkdir $DIR_SIMULACAO/dados/www/sarg/sarg_${SITE[$w]}

	mkdir $DIR_SIMULACAO/dados/www/sarg/sarg_${SITE[$w]}/Daily
	mkdir $DIR_SIMULACAO/dados/www/sarg/sarg_${SITE[$w]}/Weekly
	mkdir $DIR_SIMULACAO/dados/www/sarg/sarg_${SITE[$w]}/Monthly
	
	#mkdir $DIR_SIMULACAO/dados/backups/sarg/${SITE[$w]}
	mkdir $DIR_SIMULACAO/dados/backups/access_log_diario/${SITE[$w]}
	
	for ((a=1;a<=3;a++))
	do
		if [ $a -eq 1 ];then
			ANOA=11
			ANOS=2011
		elif [ $a -eq 2 ];then
			ANOA=12
			ANOS=2012
		elif [ $a -eq 3 ];then
			ANOA=13
			ANOS=2013
		fi
		
		for ((b=1;b<=12;b++))
		do
			case $b in
				"1")
					MESS="Jan"
					MESA="01"
					;;
				"2")
					MESS="Feb"
					MESA="02"
					;;
				"3")
					MESS="Mar"
					MESA="03"
					;;
				"4")
					MESS="Apr"
					MESA="04"
					;;
				"5")
					MESS="May"
					MESA="05"
					;;
				"6")
					MESS="Jun"
					MESA="06"
					;;
				"7")
					MESS="Jul"
					MESA="07"
					;;
				"8")
					MESS="Aug"
					MESA="08"
					;;
				"9")
					MESS="Sep"
					MESA="09"
					;;
				"10")
					MESS="Oct"
					MESA="10"
					;;
				"11")
					MESS="Nov"
					MESA="11"
					;;
				"12")
					MESS="Dec"
					MESA="12"
					;;
				*)
					echo "##### ERRO NUMERO FORA DO PADRAO"
					;;
			esac
			for ((i=1,y=2;i<=30;i++,y++)) # Usado o n 10 para manter o padrao de 2 digitos do dia
			do
				if [ $i -lt 10 ];then
					DIA1="0$i"
				else
					DIA1=$i
				fi
				if [ $y -lt 10 ];then
					DIA2="0$y"
				else
					DIA2=$y
				fi	
				if [ $ANOS == 2013 ];then
					if [ $MESS == "Oct" ] || [ $MESS == "Nov" ];then # TESTE
					#if [ $MESS == "Dec" ] || [ $MESS == "Nov" ];then OLD
						#echo "access.log - site $DIA1 teste ${SITE[$w]}" > $DIR_SIMULACAO/dados/logs/${SITE[$w]}/access.log-$ANOA-$MESA-$DIA2 # OLD
						echo "1371783827.716     26 10.2.4.5 TCP_DENIED/403 1522 GET http://mail.yimg.com/zz/combo? - NONE/- text/html
" > $DIR_SIMULACAO/dados/logs/${SITE[$w]}/access.log-$ANOA-$MESA-$DIA2
					fi
				else
					mkdir $DIR_SIMULACAO/dados/www/sarg/sarg_${SITE[$w]}/Daily/"$DIA1$MESS$ANOS-$DIA2$MESS$ANOS" > /dev/null
					echo "1372129436.451     13 10.2.6.234 TCP_REFRESH_HIT/304 379 GET http://jsuol.com/h/2013/min.js? - DIRECT/200.147.67.184 -" > $DIR_SIMULACAO/dados/www/sarg/sarg_${SITE[$w]}/Daily/"$DIA1$MESS$ANOS-$DIA2$MESS$ANOS"/user_$DIA1
				fi
			done
		done
	done

done

#echo "################################"
#echo  "$DIR_SIMULACAO/dados/www/sarg/sarg_${SITE[$s]}"

exit;
