cd /tmp
DOMAIN=`hostname | cut -d. -f2-100`
IPPRINCIPAL=`ip a | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | cut -f1 -d/ | grep -n ^ | grep -w ^1 | cut -f2 -d:`
# Baixando e instalando o VESTACP
curl -O http://vestacp.com/pub/vst-install.sh
echo y | bash vst-install.sh --nginx no --apache yes --phpfpm no --named yes --remi no --vsftpd yes --proftpd no --iptables no --fail2ban no --quota no --exim yes --dovecot yes --spamassassin no --clamav no --softaculous no --mysql yes --postgresql no --hostname vesta.$DOMAIN --email contato@$DOMAIN --password phCA24bgK --force
# Permissoes para o WEBMAIL funcionar
chmod 777 /etc/roundcubemail/defaults.inc.php
chmod 777 /etc/roundcubemail/config.inc.php
# Criacao do MAILIPS e EXIM.PL
> /etc/mailips
> /etc/exim/exim.pl
# PUBLIC_HTML padrao
if [ -d /usr/local/vesta/data/templates/web/skel/public_html ]; then
  cd /usr/local/vesta/data/templates/web/skel/public_html/
  rm -Rf *
  curl -O http://rep.vitalhost.com.br/v4/semcpanel/public.tar.gz
  tar -vxzf public.tar.gz
  rm -Rf public.tar.gz
  cd /tmp
fi
# Criacao das pastas VT
[ -d /home/vtinstall/vartemp ] || mkdir -p /home/vtinstall/vartemp;
[ -d /home/vtinstall/scripts ] || mkdir -p /home/vtinstall/scripts;
echo "$DOMAIN" > /home/vtinstall/vartemp/dominiobase
#
# Download dos packs do VESTA
curl -O http://rep.vitalhost.com.br/v4/vestacp/pack.zip
unzip -q pack.zip
#
cat remover > /usr/local/bin/remover
cat dedicar > /usr/local/bin/dedicar
cat redirect > /usr/local/bin/redirect
cat ipuso > /usr/local/bin/ipuso
cat instalar > /usr/local/bin/instalar
cat instalarsigno > /usr/local/bin/instalarsigno
cat dominios > /usr/local/bin/dominios
cat ips > /usr/local/bin/ips
cat status > /usr/local/bin/status
cat res_backup_cp > /usr/local/bin/res_backup_cp
cat res_backup_cp_start > /usr/local/bin/res_backup_cp_start
cat suspender > /usr/local/bin/suspender
cat unsuspender > /usr/local/bin/unsuspender
cat installpmta > /usr/local/bin/installpmta
cat vtbackup > /usr/local/bin/vtbackup
cat vtbackup_start > /usr/local/bin/vtbackup_start
cat manutencao > /usr/local/bin/manutencao
cat manutencao_start > /usr/local/bin/manutencao_start
#
# Permissoes globais
chmod a+x /usr/local/bin/ipuso
chmod a+x /usr/local/bin/instalar
chmod a+x /usr/local/bin/instalarsigno
chmod a+x /usr/local/bin/dominios
chmod a+x /usr/local/bin/ips
chmod a+x /usr/local/bin/status
chmod a+x /usr/local/bin/redirect
chmod a+x /usr/local/bin/dedicar
chmod a+x /usr/local/bin/remover
chmod a+x /usr/local/bin/res_backup_cp
chmod a+x /usr/local/bin/res_backup_cp_start
chmod a+x /usr/local/bin/unsuspender
chmod a+x /usr/local/bin/suspender
chmod a+x /usr/local/bin/installpmta
chmod a+x /usr/local/bin/vtbackup
chmod a+x /usr/local/bin/vtbackup_start
chmod a+x /usr/local/bin/manutencao
chmod a+x /usr/local/bin/manutencao_start
#
# Download dos configs do VESTA
curl -O http://rep.vitalhost.com.br/v4/vestacp/config.zip
unzip -q config.zip
#
cat php.ini > /etc/php.ini
cat exim.conf > /etc/exim/exim.conf
cat manutencao_diaria.sh > /home/vtinstall/scripts/manutencao_diaria.sh
cat uptodate.sh > /home/vtinstall/scripts/uptodate.sh
#
chmod 777 /home/vtinstall/scripts/uptodate.sh
chmod 777 /home/vtinstall/scripts/manutencao_diaria.sh
#
# Cron de gerenciamento
echo "0 0 */1 * * sh /home/vtinstall/scripts/manutencao_diaria.sh" >> /var/spool/cron/root
# Cron de update
echo "0 8 * * * sh /home/vtinstall/scripts/uptodate.sh" >> /var/spool/cron/root
#
# Fallback hosts do EXIM
sed -i "s/IPPRINCIPAL/$IPPRINCIPAL/g" /etc/exim/exim.conf
#
# Processamento EXIM
sed -i "s/QUEUE=1h/QUEUE=3m/g" /etc/init.d/exim
#
# Dados FTP
echo "tv2.revendabrasil.com.br" > /home/vtinstall/vartemp/hostftp.info
echo "backupvp" > /home/vtinstall/vartemp/usuarioftp.info
echo "phCA24bgK" > /home/vtinstall/vartemp/senhaftp.info
#
# MOTD
echo "" > /etc/motd
echo "Bem vindo(a)" >> /etc/motd
echo "Servidor de plataforma VestaCP" >> /etc/motd
echo "" >> /etc/motd
#
# Ajutes de memoria RAM para o MySQL
if ! grep -q innodb_buffer_pool_size /etc/my.cnf; then
  RAM=`free -m | grep Mem: | awk '{print $2}'`
  POOL=`echo "scale=2; (($RAM / 100 * 25) * 1024 * 1024) " | bc | cut -d. -f1`
  sed -i "2s/^/innodb_buffer_pool_size = $POOL\n/" /etc/my.cnf
fi
#
sed -i '/^#/d' /etc/my.cnf
sed -i '/max_connections/d' /etc/my.cnf
sed -i '/max_user_connections/d' /etc/my.cnf
sed -i '/wait_timeout/d' /etc/my.cnf
sed -i '/interactive_timeout/d' /etc/my.cnf
sed -i '/long_query_time/d' /etc/my.cnf
sed -i '/symbolic-links/d' /etc/my.cnf
#
# Pagina de suspensao personalizada com chat:
echo "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">
<html>
<head>
<title>Conta Suspensa!!</title>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">
</head>
<body bgcolor=\"#CCCCCC\">
<center>
<table width=\"633\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" bgcolor=\"#FFFFFF\">
<!--DWLayoutTable-->
<tr>
  <td width=\"23\" height=\"17\"></td>
  <td width=\"590\"></td>
  <td width=\"20\"></td>
</tr>
<tr>
  <td height=\"310\"></td>
  <td valign=\"top\"><p align=\"center\">&nbsp;</p>
    <p align=\"center\"><font size=\"4\" face=\"verdana\"><strong>Sua conta de Email Marketing est&aacute;
      suspensa por motivos administrativos!</strong></font></p>
    <p align=\"center\"><font size=\"2\" face=\"verdana\">Para ativ&aacute;-la novamente
      ou at&eacute; mesmo verificar o que houve, entre em contato conosco
      atrav&eacute;s dos telefones abaixo: </font></p>
    <p><font size=\"2\" face=\"verdana\"> (31) 2565 9120 - Belo Horizonte <br>
      (31) 4063 9358 - Belo Horizonte<br>
      (11) 4063 6505 - SP Voip<br>
      (21) 4063 7590 - Rio de Janeiro<br>
      (41) 4063 7742 - Curitiba</font></p>
    <p><font size=\"2\" face=\"verdana\"><font color=\"#FF0000\" size=\"1\"><em>Segunda &agrave; Sexta-Feira
      9:00 &aacute;s 18:00Hs - *exceto feriados</em></font></font></p>
    <p align=\"center\"><font size=\"2\" face=\"verdana\"><em>Se preferir clique
      no link abaixo para abrir um Ticket/Chamado.</em><br>
      <a href=\"http://www.centraldousuario.com.br/submitticket.php?step=2&deptid=1\">[Abrir
      Ticket]</a></font></p>

       <p><font size=\"2\" face=\"verdana\"><font color=\"#FF0000\" size=\"1\"><em>Nosso CHAT ON-LINE est&aacute;  disponivel para melhor atende-lo no fim desta p&aacute;gina.</em></font></font></p>


    </td>
  <td></td>
</tr>
<tr>
  <td height=\"33\"></td>
  <td>&nbsp;</td>
  <td></td>
</tr>
</table>
</center>
</body>
<!--Start of Tawk.to Script-->
<script type=\"text/javascript\">
var Tawk_API=Tawk_API||{}, Tawk_LoadStart=new Date();
(function(){
var s1=document.createElement(\"script\"),s0=document.getElementsByTagName(\"script\")[0];
s1.async=true;
s1.src='https://embed.tawk.to/5829e4487295ad7394c88221/default';
s1.charset='UTF-8';
s1.setAttribute('crossorigin','*');
s0.parentNode.insertBefore(s1,s0);
})();
</script>
<!--End of Tawk.to Script-->
</html>" > /usr/local/vesta/data/templates/web/suspend/index.html
#
service exim restart
service mysqld restart
service crond restart
#
rm -Rf *
reboot