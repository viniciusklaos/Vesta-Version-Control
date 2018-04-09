# (env) PATH:

# ----  Variáveis globais  ---- #

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/vesta/bin
DIAGERAL=`date | awk '{print $3}'`
MESGERAL=`date | awk '{print $2}'`
DATAGERAL="$DIAGERAL de $MESGERAL"


# --------- Funcoes ----------- #

limparexim (){
	find /var/spool/exim/input -type f | xargs rm -f {}/;
	echo "EXIM atingiu 25GB e foi limpo tudo - $DATAGERAL" >> /var/log/manutencao.log
}

limparpmta (){
	find /var/spool/pmta -type f | xargs rm -f {}/;
	echo "PMTA atingiu 15GB e foi limpo tudo - $DATAGERAL" >> /var/log/manutencao.log
}

processar_spool_pmta (){
	find /var/spool/pmta -type f -daystart -mtime +3.5 | xargs rm -f {}/;
	echo "Limpeza PMTA-SPOOL - $DATAGERAL" >> /var/log/manutencao.log
}

processar_spool_exim (){
	find /var/spool/exim/input -type f -daystart -mtime +3.5 | xargs rm -f {}/;
	echo "Limpeza EXIM-SPOOL - $DATAGERAL" >> /var/log/manutencao.log
}

processar_logs_pmta (){
	# Criando o diretorio para salvar os LOGS separados
	
	[ -d /home/vtinstall ] || mkdir /home/vtinstall/; cd /home/vtinstall
	[ -d /home/vtinstall/PMTA-Logs ] || mkdir /home/vtinstall/PMTA-Logs; cd /home/vtinstall/PMTA-Logs
	
	# Processo de separacao de LOGS
	
	for logs in `find /var/log/pmta/ -type f -name "acct*.csv" -print`; do 
		sed '/4.4.1/!d' $logs | cut -d, -f 5 | awk '!a[$0]++' | sort | uniq >> /home/vtinstall/PMTA-Logs/Status_indefinido.txt;
		sed '/5.0.0/!d' $logs | cut -d, -f 5 | awk '!a[$0]++' | sort | uniq >> /home/vtinstall/PMTA-Logs/Status_indefinido.txt;
		sed '/5.2.1/!d' $logs | cut -d, -f 5 | awk '!a[$0]++' | sort | uniq >> /home/vtinstall/PMTA-Logs/Invalido.txt;
		sed '/5.3.0/!d' $logs | cut -d, -f 5 | awk '!a[$0]++' | sort | uniq >> /home/vtinstall/PMTA-Logs/Invalido.txt;
		sed '/5.4.4/!d' $logs | cut -d, -f 5 | awk '!a[$0]++' | sort | uniq >> /home/vtinstall/PMTA-Logs/Invalido.txt;
		sed '/5.1.2/!d' $logs | cut -d, -f 5 | awk '!a[$0]++' | sort | uniq >> /home/vtinstall/PMTA-Logs/Invalido.txt;
		sed '/5.1.2/!d' $logs | cut -d, -f 5 | awk '!a[$0]++' | sort | uniq >> /home/vtinstall/PMTA-Logs/Invalido.txt;
		sed '/5.1.1/!d' $logs | cut -d, -f 5 | awk '!a[$0]++' | sort | uniq >> /home/vtinstall/PMTA-Logs/Invalido.txt;
		sed '/5.3.2/!d' $logs | cut -d, -f 5 | awk '!a[$0]++' | sort | uniq >> /home/vtinstall/PMTA-Logs/Mensagem_Recusada.txt;
		sed '/5.7.1/!d' $logs | cut -d, -f 5 | awk '!a[$0]++' | sort | uniq >> /home/vtinstall/PMTA-Logs/Mensagem_Recusada.txt;
		sed '/5.4.6/!d' $logs | cut -d, -f 5 | awk '!a[$0]++' | sort | uniq >> /home/vtinstall/PMTA-Logs/Mensagem_Recusada.txt;
		sed '/2.0.0/!d' $logs | cut -d, -f 5 | awk '!a[$0]++' | sort | uniq >> /home/vtinstall/PMTA-Logs/Sucesso.txt;
		sed '/5.2.2/!d' $logs | cut -d, -f 5 | awk '!a[$0]++' | sort | uniq >> /home/vtinstall/PMTA-Logs/Caixa_cheia.txt;
	done
	
	# Criando novos temporarios
	
	cat /home/vtinstall/PMTA-Logs/Status_indefinido.txt | sort | uniq > /home/vtinstall/PMTA-Logs/Status_indefinido.tmp
	cat /home/vtinstall/PMTA-Logs/Invalido.txt | sort | uniq > /home/vtinstall/PMTA-Logs/Invalido.tmp
	cat /home/vtinstall/PMTA-Logs/Mensagem_Recusada.txt | sort | uniq > /home/vtinstall/PMTA-Logs/Mensagem_Recusada.tmp
	cat /home/vtinstall/PMTA-Logs/Caixa_cheia.txt | sort | uniq > /home/vtinstall/PMTA-Logs/Caixa_cheia.tmp
	cat /home/vtinstall/PMTA-Logs/Sucesso.txt | sort | uniq > /home/vtinstall/PMTA-Logs/Sucesso.tmp
	
	# Trazendo temporarios para original
	
	cat /home/vtinstall/PMTA-Logs/Status_indefinido.tmp > /home/vtinstall/PMTA-Logs/Status_indefinido.txt
	cat /home/vtinstall/PMTA-Logs/Invalido.tmp > /home/vtinstall/PMTA-Logs/Invalido.txt
	cat /home/vtinstall/PMTA-Logs/Mensagem_Recusada.tmp > /home/vtinstall/PMTA-Logs/Mensagem_Recusada.txt
	cat /home/vtinstall/PMTA-Logs/Caixa_cheia.tmp > /home/vtinstall/PMTA-Logs/Caixa_cheia.txt
	cat /home/vtinstall/PMTA-Logs/Sucesso.tmp > /home/vtinstall/PMTA-Logs/Sucesso.txt
	
	# Apagando arquivos temporarios
	
	rm -f /home/vtinstall/PMTA-Logs/Status_indefinido.tmp
	rm -f /home/vtinstall/PMTA-Logs/Invalido.tmp
	rm -f /home/vtinstall/PMTA-Logs/Mensagem_Recusada.tmp
	rm -f /home/vtinstall/PMTA-Logs/Caixa_cheia.tmp
	rm -f /home/vtinstall/PMTA-Logs/Sucesso.tmp
	
	
	# Limpando filas SE NAO TIVER ENVIOS
	
	QUEUE=`pmta show status | grep SMTP | awk '{print $2}'`
	
	if [ $QUEUE -eq 0 ]; then
		
		service pmta stop
		service exim stop
	
		rm -fr /var/spool/pmta/
		mkdir /var/spool/pmta/
		chmod 770 /var/spool/pmta/ -R
		chown pmta.pmta /var/spool/pmta/ -R
	
		rm -fr /var/spool/exim
		mkdir /var/spool/exim
		chmod 750 /var/spool/exim -R
		chown exim.exim /var/spool/exim -R
	
		rm -fr /var/log/pmta/
		mkdir /var/log/pmta/
		chmod 770 /var/log/pmta/ -R
		chown pmta. /var/log/pmta/ -R
	
		rm -fr /var/log/exim/
		mkdir /var/log/exim/
		chmod 750 /var/log/exim/ -R
		chown exim.exim /var/log/exim/ -R
	
		service pmta start
		service exim start
	
		pmta clear dnscache domain
	fi
	echo "Processado LOGs do PMTA - $DATAGERAL" >> /var/log/manutencao.log
}

processar_logs_exim () {
	cd /var/log/exim
	
	DIA=`date | awk '{print $3}'`
	MES=`date | awk '{print $2}'`
	DATA="$DIA-$MES"
	
	array=("main" "panic" "reject")
	
	for LOG in ${array[@]}; do
		if [ -f ${LOG}.log-* ]; then
			tar -cf ${LOG}_log_$DATA.tar ${LOG}.log-*
			rm -f ${LOG}.log-*;
		fi
	done;

	find /var/log/exim -type f -name "*.tar" -mtime +15 | xargs rm -f {}/;

	echo "Processado LOGs do EXIM - $DATAGERAL" >> /var/log/manutencao.log
}

processar_backups (){
	find /home/backup/ -name "admin.*" | xargs rm -f {}/;
	find /home/backup/ -name "*.tar" -daystart -mtime +0.5 | xargs rm -f {}/;
	echo "Limpeza da pasta backup - $DATAGERAL" >> /var/log/manutencao.log
}

processar_emails (){
	for dominio in `v-list-users | tail -n +3 | awk '{print "v-list-web-domains "$1" | tail -n +3"}' | bash | awk '{print $1}' | sed '/vesta./d'`; do
		for conta in `find /home/*/web -type d -name $dominio | cut -d/ -f3`; do
        	for email in `find /home/$conta/mail/$dominio/ -type d  | cut -d/ -f6 | uniq | tail -n +2`; do
        	    find /home/$conta/mail/$dominio/$email/new/ -type f -daystart -mtime +2.5 | xargs rm -f {}/;
        	    echo "Limpeza : /home/$conta/mail/$dominio/$email/new/ - $DATAGERAL" >> /var/log/manutencao.log
        	done;
    	done;
	done;
	for dominio in `v-list-users | tail -n +3 | awk '{print "v-list-web-domains "$1" | tail -n +3"}' | bash | awk '{print $1}' | sed '/vesta./d'`; do
		for conta in `find /home/*/web -type d -name $dominio | cut -d/ -f3`; do
        	for email in `find /home/$conta/mail/$dominio/ -type d  | cut -d/ -f6 | uniq | tail -n +2`; do
        	    find /home/$conta/mail/$dominio/$email/cur/ -type f -daystart -mtime +2.5 | xargs rm -f {}/;
        	    echo "Limpeza : /home/$conta/mail/$dominio/$email/cur/ - $DATAGERAL" >> /var/log/manutencao.log
        	done;
    	done;
	done;
}



# Higienizacao do PMTA #
if [ -f /etc/pmta/config ]; then
	processar_logs_pmta;
	processar_spool_pmta;
	PMTATAMANHO=`du -sh /var/spool/pmta | awk '{print $1}'`
	echo "$PMTATAMANHO" | grep -q G && PMTATAMANHO=`echo "$PMTATAMANHO" | cut -d'G' -f1` || sleep 0;
	echo "$PMTATAMANHO" | grep -q M && PMTATAMANHO=`echo "$PMTATAMANHO" | cut -d'M' -f1` || sleep 0;
	echo "$PMTATAMANHO" | grep -q K && PMTATAMANHO=`echo "$PMTATAMANHO" | cut -d'K' -f1` || sleep 0;
	PMTATAMANHO=`echo $PMTATAMANHO | bc | cut -d. -f1`
	if [ $PMTATAMANHO -ge "15" ]; then
        limparpmta;
	fi
fi

# Higienizacao do EXIM #
processar_logs_exim;
processar_spool_exim;

EXIMTAMANHO=`du -sh /var/spool/exim/input | awk '{print $1}'`
echo "$EXIMTAMANHO" | grep -q G && EXIMTAMANHO=`echo "$EXIMTAMANHO" | cut -d'G' -f1` || sleep 0;
echo "$EXIMTAMANHO" | grep -q M && EXIMTAMANHO=`echo "$EXIMTAMANHO" | cut -d'M' -f1` || sleep 0;
echo "$EXIMTAMANHO" | grep -q K && EXIMTAMANHO=`echo "$EXIMTAMANHO" | cut -d'K' -f1` || sleep 0;
EXIMTAMANHO=`echo $EXIMTAMANHO | bc | cut -d. -f1`

if [ $EXIMTAMANHO -ge "25" ]; then
        limparexim;
fi

# Higienizacao dos backups #
processar_backups;

# Higienizacao dos e-mails #
processar_emails;
