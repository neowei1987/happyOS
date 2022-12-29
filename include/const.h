#ifndef	_TINIX_CONST_H_
#define	_TINIX_CONST_H_


/* 函数类型 */
#define	PUBLIC		/* PUBLIC is the opposite of PRIVATE */
#define	PRIVATE	static	/* PRIVATE x limits the scope of x */
#define EXTERN extern 

/* GDT 和 IDT 中描述符的个数 */
#define	GDT_SIZE	128


#endif /* _TINIX_CONST_H_ */