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

typedef	unsigned short		u16;
typedef	unsigned int		u32;

typedef	unsigned int		t_32;
typedef	unsigned short		t_16;
typedef	unsigned char		t_8;
typedef	int			        t_bool;

typedef	unsigned int		t_port;

typedef	void	(*t_pf_int_handler)	();

#endif//TYPES_H