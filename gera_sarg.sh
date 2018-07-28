#!/bin/bash
# Script para montagem do relatorios do SARG

function MAIN()
{
	DATA
	. /etc/scripts/gera_sarg/variaveis.conf
        . /etc/scripts/gera_sarg/servers.conf
        . /etc/scripts/gera_sarg/emails.conf
		
	TESTE=0 	# Verificar se existe o diretorio de log
	VERIFICA_ARQ
	
	echo "" > $CAMINHO_LOG/$ARQ_DEBUG

  	echo -e "$ASSUNTO\n" > $CAMINHO_LOG/$ARQ_LOG
        echo "#----------------- INICIO - GERA_SARG.SH - $DATA - $HORA ---------------#" >> $CAMINHO_LOG/$ARQ_LOG
        echo "" >> $CAMINHO_LOG/$ARQ_LOG

	for((s=1;s<=${#IP[@]};s++));
	do
		echo "- - - - - - - - - - - - - SITE: ${SITE[$s]} - - - - - - - - - - - -" >> $CAMINHO_LOG/$ARQ_LOG
		echo "" >> $CAMINHO_LOG/$ARQ_LOG
		
		TESTE="1.0" # Verifica se existe o arquivo access.log
		VERIFICA_ARQ
		#ERRO=0 # Teste de sem erro
		if [ $ERRO -eq 0 ];then
			echo "Executando funcao BACKUP_LOG $DATA - $HORA"
			BACKUP_LOG		# OK 
			echo "Executando funcao DELETAR_SARG $DATA - $HORA"
			DELETA_SARG		# OK
			echo "Executando funcao CRIA_INDEX $DATA - $HORA"
			CRIA_INDEX 		# OK
			echo "Executando funcao GERA_SARG $DATA - $HORA"
			GERA_SARG		# OK
			echo "Executando funcao DELETA_LOG_DIARIO $DATA - $HORA"
			DELETA_LOG_DIARIO	# OK
			echo "Executando funcao DELETA_BKP_DIARIO $DATA - $HORA"
			DELETA_BKP_DIARIO	# OK
		fi
		echo "" >> $CAMINHO_LOG/$ARQ_LOG
		echo "- - - - - - - - - - - - CONCLUIDO - - - - - - - - - - - -" >> $CAMINHO_LOG/$ARQ_LOG
		echo "" >> $CAMINHO_LOG/$ARQ_LOG
	done
	DATA
	if [ $ENV_DEBUG -eq 1 ];then
		echo "- - - - - - ATIVADO ENVIO DE DEBUG - - - - - -" >> $CAMINHO_LOG/$ARQ_LOG
		cat $CAMINHO_LOG/$ARQ_DEBUG >> $CAMINHO_LOG/$ARQ_LOG
		echo "" >> $CAMINHO_LOG/$ARQ_LOG
		echo "- - - - - - FIM DO ARQUIVO DE DEBUG - - - - - -" >> $CAMINHO_LOG/$ARQ_LOG
		echo "" >> $CAMINHO_LOG/$ARQ_LOG
	fi	
	echo "#--------------------- FIM - GERA_SARG.SH - $DATA - $HORA ---------------#" >> $CAMINHO_LOG/$ARQ_LOG

        for ((e=1; e<=${#DESTINATARIO[@]}; e++));
        do
                $ESOFTWARE $REMETENDE ${DESTINATARIO[$e]} < $CAMINHO_LOG/$ARQ_LOG
        done
}

function DATA()
{
        DATA=`date "+%y-%m-%d"` > /dev/null # Data yy-mm-dd
        HORA=`date "+%H:%M:%S"` > /dev/null # Hora hh-mm-ss
        DIAM=`date "+%d"` > /dev/null # Dia em numero dd
	DIAS=`date "+%a"` > /dev/null # Dia da semana abreviado Sab, Dom, Seg.
	 MES=`date "+%m"` > /dev/null # Mes em numero mm
}

function BACKUP_LOG()
{
	TESTE="2.0"
	VERIFICA_ARQ

	N_LOGS=`ls $CAMINHO_ARQ/${SITE[$s]} | grep $ARQ_DIARIO | wc -l`
	for ((i=1;i<=$N_LOGS;i++))
	do
		ARQ_LOG_BKP[$i]=`ls $CAMINHO_ARQ/${SITE[$s]} | grep $ARQ_DIARIO | head -n $i | tail -n 1`
	done	
	cd $CAMINHO_ARQ/${SITE[$s]}/ #Caminho que o limpa_log.sh move os access.log diariamente
	echo "" >> $CAMINHO_LOG/$ARQ_DEBUG
	echo "- - - - - SITE: ${SITE[$s]} - - - - -" >> $CAMINHO_LOG/$ARQ_DEBUG
	echo "" >> $CAMINHO_LOG/$ARQ_DEBUG
	echo "- - - - - Arquivos que foram Backupeados - - - - -" >> $CAMINHO_LOG/$ARQ_DEBUG
	for ((i=1;i<=$N_LOGS;i++))
	do	
		tar -vzcf ${ARQ_LOG_BKP[$i]}.tar.gz ${ARQ_LOG_BKP[$i]} >> /dev/null
		mv -v $CAMINHO_ARQ/${SITE[$s]}/${ARQ_LOG_BKP[$i]}.tar.gz $CAMINHO_BKP_DIARIO/${SITE[$s]}/ >> $CAMINHO_LOG/$ARQ_DEBUG
	done
}
function CRIA_INDEX()
{
	TESTE="4.0"
	VERIFICA_ARQ

	#CAMINHO_SARG_DADOS2="/var/www/sarg" ## Usado para teste # ALTERAR NOME DA VARIAVEL!!!!
	#mkdir -p $CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]} >> /dev/null # Usado para teste
	
	HTML=$CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]}/index.html
	echo "	<html>" > $HTML
	echo "	  <head>" >> $HTML
	echo " 		<title>Relatorio de acesso da Internet</title>" >> $HTML
	echo "	  </head>" >> $HTML
	echo "	  <body> " >> $HTML
	echo "	  <div align=center> " >> $HTML
	#echo "	   <a href=http://$HOSTNAME/><img border=0 src=/sarg/images/sarg.png></a>" >> $HTML # IMAGEM ARRUMAR DIRETORIO
	echo "	    <table border=0 cellspacing=6 cellpadding=7> " >> $HTML
	echo "	      <tr> " >> $HTML
	echo "	        <th align=center nowrap><b><font face=Arial size=4 color=green>Relatorio de acesso da Internet</font></b></th> " >> $HTML
	echo "	      </tr> " >> $HTML
	echo "	      <tr> " >> $HTML
	echo "	        <td align=center bgcolor=beige><font face=Arial size=3><a href=${PERIODO[1]}>Diario</a></font></td> " >> $HTML
	echo "	      </tr> " >> $HTML
	echo "	      <tr> " >> $HTML
	echo "	        <td align=center bgcolor=beige><font face=Arial size=3><a href=${PERIODO[2]}>Semanal</a></font></td> " >> $HTML
	echo "	      </tr> " >> $HTML
	echo "	      <tr> " >> $HTML
	echo "	        <td align=center bgcolor=beige><font face=Arial size=3><a href=${PERIODO[3]}>Mensal</a></font></td> " >> $HTML
	echo "	      </tr> " >> $HTML
	echo "	    </table> " >> $HTML
	echo "	  </div> " >> $HTML
	echo "	  </body> " >> $HTML
	echo "	</html> " >> $HTML
	
	TESTE="5.0"
	VERIFICA_ARQ
}

function GERA_SARG()
{
	TESTE="6.0"
	VERIFICA_ARQ

	for ((d=1;d<=3;d++))
	do
		DATA
		#----- GERANDO RELATORIO DIARIO -----#
		if [ $d == 1 ];then
			echo "" > $CAMINHO_TEMP/$ARQ_LISTA
		      	echo "- - - - - - - - Gerando Relatorio Diario - - - - - - - -" >> $CAMINHO_LOG/$ARQ_DEBUG
			for ((i=1;i<=$N_LOGS;i++))
			do
				#echo "Gerando relatorio do Sarg Diario - $i" # > /dev/null # Teste
				CHECK_LOG
				$SARG $CAMINHO_SARG_CONF/$DIR_SARG${SITE[$s]}.conf -o $CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]}/${PERIODO[$d]} -l $CAMINHO_ARQ/${SITE[$s]}/${ARQ_LOG_BKP[$i]} 
				echo "$SARG $CAMINHO_SARG_CONF/$DIR_SARG${SITE[$s]}.conf -o $CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]}/${PERIODO[$d]} -l $CAMINHO_ARQ/${SITE[$s]}/${ARQ_LOG_BKP[$i]}" >> $CAMINHO_LOG/$ARQ_DEBUG
				echo "${ARQ_LOG_BKP[$i]}" >> $CAMINHO_TEMP/$ARQ_LISTA	
				
			done
			LISTA=`cat $CAMINHO_TEMP/$ARQ_LISTA`
			TESTE="7.1"
			VERIFICA_ARQ
		fi
		#----- GERANDO RELATORIO SEMANAL -----#
		if [ $d == 2 ];then
			#DIAS="Dom" # TESTE APENAS!
			if [ $DIAS == $SEMANAL ];then
			       	echo "- - - - - - - - - - Gerando Relatorio Semanal - - - - - - - - - -" >> $CAMINHO_LOG/$ARQ_DEBUG
				#echo "Gerando relatorio do Sarg Semanal." # Teste
				MINIMO=2
				GERENCIA_SARG
				TESTE="7.2"
				VERIFICA_ARQ
				unset ARQ_ACCESS_OK
				unset ARQ_TOTAL
			fi
		fi
		#----- GERANDO RELATORIO MENSAL ------#
		if [ $d == 3 ];then
			#DIAM=01 # Para simular o Dia 01, e gerar relatorio Mensal
			if [ $DIAM == $MENSAL ];then
				MINIMO=10	
			      	echo "- - - - - - - - - - Gerando Relatorio Mensal - - - - - - - - - -" >> $CAMINHO_LOG/$ARQ_DEBUG
				GERENCIA_SARG
				TESTE="7.3"
				VERIFICA_ARQ
				unset ARQ_ACCESS_OK
				unset ARQ_TOTAL
			fi
		fi
	done
}

function CHECK_LOG()
{
	cat $CAMINHO_ARQ/${SITE[$s]}/${ARQ_LOG_BKP[$i]} | grep -v $PARAMETRO > $CAMINHO_ARQ/${SITE[$s]}/$LOG_CORRIGIDO
	mv $CAMINHO_ARQ/${SITE[$s]}/$LOG_CORRIGIDO $CAMINHO_ARQ/${SITE[$s]}/${ARQ_LOG_BKP[$i]}
}

function GERENCIA_SARG()
{
	q=0
	#----- Para relatorio Semanal ----#
	if [ $d == 2 ];then
		#--- Coletando os arquivos da ultima semana ---# 
		for ((u=1;u<=7;u++))
		do
			V_DIA=`date +%y-%m-%d -d "$u days ago"` # Retorno de V_DIA 13-06-27
			#echo "ARQ_ACCESS[$u]=`ls $CAMINHO_BKP_DIARIO/${SITE[$s]} | grep "$V_DIA"`" #TESTE!
			#echo "ls $CAMINHO_BKP_DIARIO/${SITE[$s]} | grep "$V_DIA"" #TESTE!
			ARQ_ACCESS[$u]=`ls $CAMINHO_BKP_DIARIO/${SITE[$s]} | grep "$V_DIA"`
			#echo "${ARQ_ACCESS[$u]}" #TESTE!
			#echo "Posicao $u - ${ARQ_ACCESS[$u]}" # TESTE
			
			#--- Retirando arquivos/datas nao encontradas do vetor ---#
			T=1
			#[ -z $CAMINHO_BKP_DIARIO/${SITE[$s]}/${ARQ_ACCESS[$u]} ]
			[ -z ${ARQ_ACCESS[$u]} ]
			T=$?
			if [ $T == 1 ];then
				let q=$q+1
				#echo "arquivo ${ARQ_ACCESS[$u]}" 
				ARQ_ACCESS_OK[$q]=${ARQ_ACCESS[$u]}
				#echo "Semanal = ${ARQ_ACCESS_OK[$q]}" # TESTE
			fi
		done
	fi
	#----- Para relatorio Mensal -----#
	if [ $d == 3 ];then
		M=`date +%m --date='1 month ago'`
		M_LOGS=`ls $CAMINHO_BKP_DIARIO/${SITE[$s]} | grep -re "-$M-" | wc -l` # -12- numero do mes vai ser variavel
		#echo "######ls $CAMINHO_BKP_DIARIO/${SITE[$s]} | grep -re "-$M-" | wc -l" # -12- numero do mes vai ser variavel # TESTE!!!
		for ((q=1;q<=$M_LOGS;q++))
		do
			ARQ_ACCESS_OK[$q]=`ls $CAMINHO_BKP_DIARIO/${SITE[$s]} | grep -re "-$M-" | head -n $q | tail -n 1`
			#echo "ls $CAMINHO_BKP_DIARIO/${SITE[$s]} | grep -re -$M- | head -n $q | tail -n 1" # Teste
			#echo "Mensal = ${ARQ_ACCESS_OK[$q]}" # TESTE
		done	
	fi
	#----- Se o numero de arquivos for MAIOR que 2 -----#
	# ira gerar o relatorio semanal, caso contrario nao # 
	##if [ ${#ARQ_ACCESS_OK[@]} -gt 2 ];then # OLD
	if [ ${#ARQ_ACCESS_OK[@]} -gt $MINIMO ];then 
		#--- Criando diretorio temporario para extracao dos arquivos
		mkdir -p $CAMINHO_TEMP > /dev/null
		mkdir -p $CAMINHO_TEMP/${SITE[$s]} > /dev/null
		cd $CAMINHO_TEMP/${SITE[$s]}
		#----- Decompactando todos os arquivos do backupeados
		for ((u=1;u<=${#ARQ_ACCESS_OK[@]};u++))
		do
			#echo "tar -vzxf $CAMINHO_BKP_DIARIO/${SITE[$s]}/${ARQ_ACCESS_OK[$u]}" #> /dev/null #Teste
			tar -vzxf $CAMINHO_BKP_DIARIO/${SITE[$s]}/${ARQ_ACCESS_OK[$u]} > /dev/null #Teste
			ARQ_ACCESS_DESC[$u]=`echo ${ARQ_ACCESS_OK[$u]} | cut -c1-19`
		done
		#--- Juntando todos os arquivos em uma unica linha
		echo "" > $CAMINHO_TEMP/$ARQ_LISTA
		for ((u=1;u<=${#ARQ_ACCESS_OK[@]};u++)) # TESTE
		do
			#echo "posicao $u = ${ARQ_ACCESS_DESC[$u]} " # Teste
			ARQ_TOTAL=$ARQ_TOTAL"-l $CAMINHO_TEMP/${SITE[$s]}/${ARQ_ACCESS_DESC[$u]} "
			echo "${ARQ_ACCESS_DESC[$u]}" >> $CAMINHO_TEMP/$ARQ_LISTA
		done
	fi
 	$SARG $CAMINHO_SARG_CONF/$DIR_SARG${SITE[$s]}.conf -o $CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]}/${PERIODO[$d]} $ARQ_TOTAL
	echo " $SARG $CAMINHO_SARG_CONF/$DIR_SARG${SITE[$s]}.conf -o $CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]}/${PERIODO[$d]} $ARQ_TOTAL" >> $CAMINHO_LOG/$ARQ_DEBUG
}

function DELETA_LOG_DIARIO()
{
	rm $CAMINHO_ARQ/${SITE[$s]}/$ARQ_DIARIO* > /dev/null # Deletando arquivo diario dos logs
	TESTE="8.0"
	VERIFICA_ARQ	

	mkdir -p $CAMINHO_TEMP/${SITE[$s]} > /dev/null
	rm $CAMINHO_TEMP/${SITE[$s]}/$ARQ_DIARIO* > /dev/null # Deletando arquivos descompactados do TMP
	TESTE="9.0"
	VERIFICA_ARQ
}

function DELETA_BKP_DIARIO()
{
	CAMINHO=$CAMINHO_BKP_DIARIO/${SITE[$s]}
	LOGS_SARG=$LOGS_DIARIO
	FUNCAO="DIARIO"
	DELETA # Esta apresentando problema
	LIMPA_VET

	TESTE="10.0"
	VERIFICA_ARQ
	
	TESTE="11.0"
	VERIFICA_ARQ
}

function DELETA_SARG()
{
	for ((w=1;w<=3;w++))
	do
		TESTE="3.$w"
		VERIFICA_ARQ

		CAMINHO=$CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]}/${PERIODO[$w]}
		LOGS_SARG=${LOGS_SARG_GERADOS[$w]}
		FUNCAO="SARG"
		CONTA_SARG
		DELETA	
	done
	LIMPA_VET
}

function DELETA()
{
	if [ $FUNCAO == "DIARIO" ];then
		LOGS_GUARDADOS=`ls $CAMINHO | wc -l`
		for ((j=1;j<=LOGS_GUARDADOS;j++))
		do
			DELETAR[$j]=`ls $CAMINHO | grep -re "^$ARQ_DIARIO" | head -n $j | tail -n 1` 
		done
		echo "Arquivos que sera deletados do access.log de backup" >> $CAMINHO_LOG/$ARQ_DEBUG
	fi
	let DELETA_SARG=$LOGS_GUARDADOS-$LOGS_SARG
	echo "##### TOTAL DE ARQUIVOS PARA DELETAR $DELETA_SARG #####" >> $CAMINHO_LOG/$ARQ_DEBUG # APENAS PARA TESTE
	z=1

	while [ $z -le $DELETA_SARG ]
	do
		echo "- - - Arquivos que foram deletados SARG - Periodo: ${PERIODO[$w]} - - -" >> $CAMINHO_LOG/$ARQ_DEBUG
		if [ $FUNCAO == "SARG" ];then
			DELETAR[$z]=`ls $CAMINHO | grep -re "^${SARG_DATA[$z]}"`
		fi
		
		#echo "${DELETAR[$z]}" >> /tmp/scripts/script_gera_sarg # USADO PARA TESTE
		echo "rm -r $CAMINHO/${DELETAR[$z]}" >> $CAMINHO_LOG/$ARQ_DEBUG
		#echo "Z = $z" >> /tmp/scripts/script_gera_sarg # teste
		rm -r $CAMINHO/${DELETAR[$z]} 
		let z=$z+1

	done
	#X=`ls $CAMINHO | wc -l`	#usado para teste
	#echo "### ARQUIVOS NO DIRETORIO: $X" #usado para teste
}

function CONTA_SARG()
{
	LOGS_GUARDADOS=`ls $CAMINHO | grep 20 | wc -l`
	v=1
	if [ $LOGS_GUARDADOS -gt $LOGS_SARG ];then
		#----- For do ANO -----#
		#--- Coletando todos os anos existendes nos logs ---#
		for ((i=1;i<=$LOGS_GUARDADOS;i++))
	        do
			SARG_ANO[$i]=`ls $CAMINHO | cut -c1-9 | grep 20 | head -n $i | tail -n 1 | cut -c6-9`        	
	       	done
		#----- Retirando todos os numeros repetidos do vetor -----#
		SARG_ANO_CONTA[1]=${SARG_ANO[1]}
		k=0
		for ((i=1;i<=$LOGS_GUARDADOS;i++))
		do
			OK=0
			for ((y=1;y<=${#SARG_ANO_CONTA[@]};y++))
			do
				if [ ${SARG_ANO[$i]} != ${SARG_ANO_CONTA[$y]} ];then
					let OK=$OK+1
				fi
				if [ $OK == ${#SARG_ANO_CONTA[@]} ];then
					let k=$k+1
					SARG_ANO_CONTA[$k]=${SARG_ANO[$i]}
				fi
			done
		done
		#----- Ordenando vetor do MENOR para o MAIOR -----#
		for ((i=1;i<=${#SARG_ANO_CONTA[@]};i++))
		do
			for ((y=1;y<=${#SARG_ANO_CONTA[@]};y++))
			do
				if [ ${SARG_ANO_CONTA[$i]} -lt ${SARG_ANO_CONTA[$y]} ];then
					aux=${SARG_ANO_CONTA[$i]}
					SARG_ANO_CONTA[$i]=${SARG_ANO_CONTA[$y]}
					SARG_ANO_CONTA[$y]=$aux
				fi
			done
		done
		#----- For do MES -----#
		for ((a=1;a<=${#SARG_ANO_CONTA[@]};a++))
		do
		 	#----- Coletando todos os meses existende por do ano do vetor -----#
			LOGS_SARG_MES=`ls $CAMINHO | cut -c1-9 | grep ${SARG_ANO_CONTA[$a]} | wc -l`
			for ((i=1;i<=$LOGS_SARG_MES;i++))
		        do
				SARG_MES[$i]=`ls $CAMINHO | cut -c1-9 | grep ${SARG_ANO_CONTA[$a]} | head -n $i | tail -n 1 | cut -c3-5`      
			done
			#----- Retirando todos os numeros repetidos do vetor -----#
			SARG_MES_CONTA[1]=${SARG_MES[1]}
			k=1 # ALTERADO PARA 1 (era 0) TESTE
			for ((i=1;i<=$LOGS_SARG_MES;i++))
			do
				OK=0
				for ((y=1;y<=${#SARG_MES_CONTA[@]};y++))
				do
					if [ ${SARG_MES[$i]} != ${SARG_MES_CONTA[$y]} ];then
						let OK=$OK+1
					fi
					if [ $OK == ${#SARG_MES_CONTA[@]} ];then
						let k=$k+1
						SARG_MES_CONTA[$k]=${SARG_MES[$i]}
					fi
				done
			done
			#----- Convertendo o Mes em numeros -----#
			for ((i=1;i<=${#SARG_MES_CONTA[@]};i++))
			do
				case ${SARG_MES_CONTA[$i]} in
				"Jan")
					SARG_MES_N[$i]=1	
					;;	
				"Feb")
					SARG_MES_N[$i]=2	
					;;
				"Mar")
					SARG_MES_N[$i]=3
					;;
				"Apr")
					SARG_MES_N[$i]=4	
					;;
				"May")
					SARG_MES_N[$i]=5	
					;;
				"Jun")
					SARG_MES_N[$i]=6	
					;;
				"Jul")
					SARG_MES_N[$i]=7	
					;;
				"Aug")	
					SARG_MES_N[$i]=8	
					;;
				"Sep")	
					SARG_MES_N[$i]=9	
					;;
				"Oct")
					SARG_MES_N[$i]=10	
					;;
				"Nov")	
					SARG_MES_N[$i]=11	
					;;
				"Dec")
					SARG_MES_N[$i]=12	
					;;
				*)
					echo "#### ERRO! MES NAO RECONHECIDO MES: ${SARG_MES_CONTA[$i]} ###" >> $CAMINHO_LOG/$ARQ_LOG
					;;
				esac
			done
			#----- Ordenando o Mes do MENOR para o MAIOR respeitando o ano que esta -----#
			for ((i=1;i<=${#SARG_MES_CONTA[@]};i++))
			do
				for ((y=1;y<=${#SARG_MES_CONTA[@]};y++))
				do
					if [ ${SARG_MES_N[$i]} -lt ${SARG_MES_N[$y]} ];then
						aux=${SARG_MES_N[$i]}
						SARG_MES_N[$i]=${SARG_MES_N[$y]}
						SARG_MES_N[$y]=$aux

						aux2=${SARG_MES_CONTA[$i]}
						SARG_MES_CONTA[$i]=${SARG_MES_CONTA[$y]}
						SARG_MES_CONTA[$y]=$aux2
					fi
				done
			done
			#----- for do DIA -----#
			for ((b=1;b<=${#SARG_MES_CONTA[@]};b++))
			do
				#----- Coletando todos os dias existentes-----#
				#--- Respeitando o ano e mes que pertence ---#
				LOGS_SARG_DIA=`ls $CAMINHO | cut -c1-9 | grep ${SARG_ANO_CONTA[$a]} | grep ${SARG_MES_CONTA[$b]}| wc -l`
				for ((i=1;i<=$LOGS_SARG_DIA;i++))
				do
					SARG_DIA_CONTA[$i]=`ls $CAMINHO | cut -c1-9 | grep ${SARG_ANO_CONTA[$a]} | grep ${SARG_MES_CONTA[$b]} | head -n $i | tail -n 1 | cut -c1-2`      
					#---- Guardando todos os logs do sarg ordenado em um novo vetor -----#
					SARG_DATA[$v]=${SARG_DIA_CONTA[$i]}${SARG_MES_CONTA[$b]}${SARG_ANO_CONTA[$a]}
					#echo ${SARG_DATA[$v]} # APENAS PARA TESTE DE VISUALIZAR NA TELA
					let v=$v+1
				done
			done
		done		
		## FUNCAO PARA TESTAR OS ELEMENTOS DO VETOR FINAL!
		#for ((i=1;i<=${#SARG_DATA[@]};i++))
		#do
		#	echo "DATA: ${SARG_DATA[$i]}"
		#done
	fi
}

function LIMPA_VET()
{
	unset DELETAR	
	unset SARG_ANO
	unset SARG_ANO_CONTA
	unset SARG_MES
	unset SARG_MES_N
	unset SARG_MES_CONTA
	unset SARG_DIA_CONTA
	unset SARG_DATA
}

function VERIFICA_ARQ()
{
        case $TESTE in
                "0")
			TIPO="ARQUIVO"	
				CAMINHO_TESTE=$CAMINHO_LOG/
	                        ARQ_TESTE=""
                	        FUN="-d"
        	                ACAO="Verificado se existe o diretorio de log: $CAMINHO_TESTE$ARQ_TESTE"
        	                TESTE_ARQ
                        ;;
                "1.0")
			TIPO="NUMERO"
				CAMINHO_TESTE=$CAMINHO_ARQ/${SITE[$s]}
        	               	ACAO="Verificado se existe algum arquivo de access.log: $CAMINHO_ARQ/${SITE[$s]}"
                        	FUN="-gt 0"
	                        ARQ_TESTE=""
                        	TESTE_ARQ
                        ;;
                "2.0")
                        TIPO="ARQUIVO"
				CAMINHO_TESTE=$CAMINHO_BKP_DIARIO/${SITE[$s]} # verificar se esta ok
                        	ARQ_TESTE=""
        	                FUN="-d"
	                        ACAO="Verificado se existe o diretorio de backup: $CAMINHO_TESTE"
				TESTE_ARQ
                        ;;
        	"3.1")
			TIPO="ARQUIVO"
	        		CAMINHO_TESTE=$CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]}/${PERIODO[1]}
                                ARQ_TESTE=""
        	                FUN="-d"
                	        ACAO="Verificado se existe o diretorio ${PERIODO[1]} : $CAMINHO_TESTE"
                        	TESTE_ARQ
			;;
	    	"3.2")
			TIPO="ARQUIVO"
	        		CAMINHO_TESTE=$CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]}/${PERIODO[2]}
                                ARQ_TESTE=""
        	                FUN="-d"
                	        ACAO="Verificado se existe o diretorio ${PERIODO[2]} : $CAMINHO_TESTE"
                        	TESTE_ARQ
			;;

    		"3.3")
			TIPO="ARQUIVO"
	        		CAMINHO_TESTE=$CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]}/${PERIODO[3]}
                                ARQ_TESTE=""
        	                FUN="-d"
                	        ACAO="Verificado se existe o diretorio ${PERIODO[3]} : $CAMINHO_TESTE"
                        	TESTE_ARQ
			;;
		"4.0")
			TIPO="ARQUIVO"
                        	CAMINHO_TESTE=$CAMINHO_SARG_DADOS/
	                        ARQ_TESTE=""
        	                FUN="-d"
                	        ACAO="Verificado se existe o diretorio de pagina Web SARG: $CAMINHO_TESTE"
                        	TESTE_ARQ
			;;
                "5.0")
			TIPO="ARQUIVO"
				CAMINHO_TESTE=$CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]}/
        	                ARQ_TESTE="index.html"
                        	FUN="-f"
                	        ACAO="Verificado se a pagina principal foi criado em $CAMINHO_TESTE/$ARQ_TESTE"
	                        TESTE_ARQ
                        ;;
		"6.0")
			TIPO="ARQUIVO"
	                        CAMINHO_TESTE=$CAMINHO_SARG_CONF/
        	                ARQ_TESTE=$DIR_SARG${SITE[$s]}.conf
                        	FUN="-f"
                	        ACAO="Verificado se existe o arquivo de configuracao do SARG: $CAMINHO_TESTE$ARQ_TESTE"
	                        TESTE_ARQ
                        ;;
                "7.1")
			TIPO="LISTA"
	                        NARQUIVOS=${#ARQ_LOG_BKP[@]} #arquivos #variavel que contem os arquivos que seram feitos os logs
				LISTA=`cat $CAMINHO_TEMP/$ARQ_LISTA`
				ACAO="Gerado relatorios do SARG - ${PERIODO[$d]}"
				TESTE_ARQ
	                ;;
                "7.2")
			TIPO="LISTA"
				NARQUIVOS=${#ARQ_ACCESS_OK[@]}
				LISTA=`cat $CAMINHO_TEMP/$ARQ_LISTA`
				ACAO="Gerado relatorios do SARG - ${PERIODO[$d]}"
        	               	TESTE_ARQ
		        ;;
		"7.3")
			TIPO="LISTA"
				NARQUIVOS=${#ARQ_ACCESS_OK[@]}
				LISTA=`cat $CAMINHO_TEMP/$ARQ_LISTA`
				ACAO="Gerado relatorios do SARG - ${PERIODO[$d]}"
				TESTE_ARQ
			;;

		"8.0")
			TIPO="NUMERO"
				CAMINHO_TESTE=$CAMINHO_ARQ/${SITE[$s]}/
				FUN="-eq 0"
	                        ACAO="Verificado limpeza do diretorio $CAMINHO_TESTE"
        	                TESTE_ARQ
			;;
		"9.0")
			TIPO="NUMERO"
				CAMINHO_TESTE=$CAMINHO_TEMP/${SITE[$s]}/
				FUN="-eq 0"
                	        ACAO="Verificado limpeza do diretorio $CAMINHO_TESTE"
				TESTE_ARQ
			;;
		"10.0")
			TIPO="NUMERO"
				CAMINHO_TESTE=$CAMINHO_BKP_DIARIO/${SITE[$s]}/
				FUN="-le $LOGS_DIARIO"
                        	ACAO="Verificado limpeza do diretorio $CAMINHO_TESTE"
				TESTE_ARQ
			;;
		"11.0")
			TIPO="LISTA"
				DATA
				CHECK="( x )"
				ACAO="Resumo da quantidade de arquivos armazenados"
				for ((h=1;h<=${#PERIODO[@]};h++))
				do
					LINHAS=`ls $CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]}/${PERIODO[$h]} | grep 20 | wc -l`
					echo "- $LINHAS arquivos - $CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]}/${PERIODO[$h]}" >> $CAMINHO_LOG/$ARQ_LOG
				done
				LINHAS=`ls $CAMINHO_BKP_DIARIO/${SITE[$s]} | wc -l`
				echo "- $LINHAS arquivos - $CAMINHO_BKP_DIARIO/${SITE[$s]}" >> $CAMINHO_LOG/$ARQ_LOG
				#echo "" >> $CAMINHO_LOG/$ARQ_LOG
			 ;;
                *)
                        echo "#------------------------------------------------------------------------------#" >> $CAMINHO_LOG/$ARQ_LOG
                        echo "#-------------- ERRO AO ATRIBUIR VALOR A VARIAVEL TESTE = $TESTE -------------------#" >> $CAMINHO_LOG/$ARQ_LOG
                        echo "#----------------------- O SCRIPT SERA FINALIZADO -----------------------------#" >> $CAMINHO_LOG/$ARQ_LOG
                        echo "#------------------------------------------------------------------------------#" >> $CAMINHO_LOG/$ARQ_LOG
                        exit;
                        ;;
        esac
}

function TESTE_ARQ()
{
	DATA
	#echo "ETAPA : $TESTE" >> $CAMINHO_LOG/$ARQ_LOG
	#echo "ACAO  : $ACAO" >> $CAMINHO_LOG/$ARQ_LOG
        #echo "HORA  : $HORA" >> $CAMINHO_LOG/$ARQ_LOG
	case $TIPO in	
		"ARQUIVO")
			if [ $FUN $CAMINHO_TESTE$ARQ_TESTE ];then
				CHECK="( x )"
				ERRO=0
			else
				#echo "STATUS: ***Falha***" >> $CAMINHO_LOG/$ARQ_LOG
				if [ $FUN == "-d" ];then	
					ACAO="Diretorio $CAMINHO_TESTE nao encontrado, criado diretorio automaticamente."
					mkdir -p $CAMINHO_TESTE >> /dev/null
				else
					ACAO="Arquivo $CAMINHO_TESTE$ARQ_TESTE nao encontrado."
				fi
				CHECK="(   )"
				ERRO=1
			fi
			;;
		"LISTA")
			#echo "Gerando relatorio do SARG - ${PERIODO[$d]}" >> $CAMINHO_LOG/$ARQ_DEBUG
			echo "Numero de arquivos a serem processados : $NARQUIVOS" >> $CAMINHO_LOG/$ARQ_DEBUG
                        echo "$LISTA" >> $CAMINHO_LOG/$ARQ_DEBUG 

			ERRO=0
		        #TESTE=0
			CHECK="( x )"
			;;
		"NUMERO")
			LINHAS=`ls $CAMINHO_TESTE | wc -l`
			if [ $LINHAS $FUN ];then
				CHECK="( x )"
				ERRO=0
			#else
			#	if [ $TESTE -eq 1 ];then
 			#		ACAO="Nao foi encontrado nenhum arquivo em $CAMINHO_ARQ/${SITE[$s]}."
			#	fi
			#	CHECK="(    )"		
			#	ERRO=1
			fi	
			;;
		*)
			echo "### ERRO: TESTE $TESTE TIPO NAO RECONHECIDO: $TIPO ###" >> $CAMINHO_LOG/$ARQ_LOG
			;;
	esac
	echo -e "$TESTE - $CHECK - $HORA - $ACAO" >> $CAMINHO_LOG/$ARQ_LOG
        TESTE=0
}

MAIN
exit;
