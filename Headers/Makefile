all: machine

machine: arch/${MACHINE_ARCH}
	ln -s arch/${MACHINE_ARCH} ${.TARGET}

clean:
	rm -f machine

.include <bsd.own.mk>
