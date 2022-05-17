# for an obscure reason, Debian Testing (11) is installing all these differents languages fonts even when you specify you are in EN-US.
# for an even more obscure rease; this is anoying me.

apt purge fonts-{lohit,samyak,sil,smc,tlwg}*
apt purge fonts-{beng,bpg,deva,dzongkha,farsiweb,gargi,gujr,guru,hosny,ipafont,kacst,kacst,kalapi,khmeros,sahadeva,sarai,takao,telu}*
