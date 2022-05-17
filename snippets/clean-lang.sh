# for an obscure reason, Debian Testing (11) is installing all these differents languages even when you specify you are in EN-US.
# for an even more obscure rease; this is anoying me.

apt purge aspell-{am,ar,bg,ca,cs,cy,da,de,el,eo,es,et,eu,fa,ga,he,hr,hu,is,it,kk,ku,lt,lv,nl,pl,ro,ru,sk,sv,tl,uk}
apt purge hunspell-{am,ar,bg,ca,cs,cy,da,de,el,eo,es,et,eu,fa,ga,he,hr,hu,is,it,kk,ku,lt,lv,nl,pl,ro,ru,sk,sv,tl,uk}
apt purge myspell-{am,ar,bg,ca,cs,cy,da,de,el,eo,es,et,eu,fa,ga,he,hr,hu,is,it,kk,ku,lt,lv,nl,pl,ro,ru,sk,sv,tl,uk}

apt purge aspell-{ar-large,gl-minimos,no,pt-br,pt-pt,sl}
apt purge hunspell-{be,bs,de-at,de-ch,de-de,en-gb,gl,gl-es,gu,hi,id,kmr,ko,ml,ne,pt-br,pt-pt,si,sl,sr,te,th,vi 

apt purge i{brazilian,british,bulgarian,catalan,danish,dutch,hungarian,italian,lithuanian,ngerman,norwegian,polish,portuguese,russian,spanish,swiss,ukrainian}

apt purge libreoffice-l10n-{ar,ast,be,bh,bn,bs,ca,cs,by,da,de,dz,el,en-gb,en-za,eo,es,et,eu,fa,fi,ga,gl,gu,he,hi,hr,hu,km,ko,lt,lv,mk,mk,mr,nb,ne,nl,nn,pa-in,pl,pt,pt-br,ro,ru,si,sk,sl,sr,sv,ta,te,th,tr,ug,uk,vi,xh,zh-cn,zh-tw,voikko}
apt purge myspell-{nb,nn,sq,de-ch}
apt purge voikko-fi w{brazilian,bulgarian,danish,dutch,italian,polish,portuguese}

apt purge hyphen-{de,hr,hu,lt}

apt purge xfonts-thai-* xiterm+thai
