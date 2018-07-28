#!/bin/bash

DS=/tmp/simulacao

DIR[1]=$DS/dados/logs/vo/
DIR[2]=$DS/dados/www/sarg/sarg_vo/Daily
DIR[3]=$DS/dados/www/sarg/sarg_vo/Weekly
DIR[4]=$DS/dados/www/sarg/sarg_vo/Monthly
DIR[5]=$DS/dados/backups/access_log_diario/vo
#DIR[4]=$DS/dados/backups/access_log_diario/vo/Weekly
#DIR[5]=$DS/dados/backups/access_log_diario/vo/Monthly

for ((g=1;g<=${#DIR[@]};g++))
do
	LINHAS=`ls ${DIR[$g]} | grep 20 | wc -l`
	if [ $g -eq 1 ] || [ $g -eq 5 ];then
		LINHAS=`ls ${DIR[$g]} | wc -l`
	fi
	echo "Diretorio: ${DIR[$g]} - contem:$LINHAS arquivos."
done
