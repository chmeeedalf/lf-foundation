SUBDIR=Headers src

CSCOPEDIRS=src Headers

cscope:	${.CURDIR}/cscopenamefile
	cd ${.CURDIR}; cscope -k -p4 -i cscopenamefile

${.CURDIR}/cscopenamefile: 
	cd ${.CURDIR}; find ${CSCOPEDIRS} -name "*.[cshm]" > ${.TARGET}
	
.include <bsd.subdir.mk>
