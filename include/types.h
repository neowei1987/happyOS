#ifndef TYPES_H
#define TYPES_H

/* EXTERN */
#define	EXTERN	extern

/* 函数类型 */
#define	PUBLIC		/* PUBLIC is the opposite of PRIVATE */
#define	PRIVATE	static	/* PRIVATE x limits the scope of x */

/* Boolean */
#define	TRUE	1
#define	FALSE	0

typedef	unsigned char		u8;
typedef	unsigned short		u16;
typedef	unsigned int		u32;

typedef	unsigned int		t_32;
typedef	unsigned short		t_16;
typedef	unsigned char		t_8;
typedef	int			        t_bool;

typedef	unsigned int		t_port;

typedef	void	(*t_pf_int_handler)	();

typedef void (*irq_handler) (int);

typedef	void*	t_sys_call;

#endif//TYPES_H