UPDATELINK="rep.vitalhost.com.br/v4/vestacp/update.sh"
if curl --output /dev/null --silent --head --fail "$UPDATELINK"; then
	cd /home/vtinstall/vartemp
	curl -s -O  "$UPDATELINK"
	if [ -f update.sh ]; then sh update.sh; rm -f update.sh; fi
fi