/* $Header: dir.h,v 3.0.1.1 90/03/27 16:07:08 lwall Locked $
 *
 *    (C) Copyright 1987, 1990 Diomidis Spinellis.
 *
 *    You may distribute under the terms of the GNU General Public License
 *    as specified in the README file that comes with the perl 3.0 kit.
 *
 * $Log:	dir.h,v $
 * Revision 3.0.1.1  90/03/27  16:07:08  lwall
 * patch16: MSDOS support
 * 
 * Revision 1.1  90/03/18  20:32:29  dds
 * Initial revision
 *
 *
 */

/*
 * defines the type returned by the directory(3) functions
 */

#ifndef __DIR_INCLUDED
#define __DIR_INCLUDED

/*Directory entry size */
#ifdef DIRSIZ
#undef DIRSIZ
#endif
#define DIRSIZ(rp)	(sizeof(struct direct))

/*
 * Structure of a directory entry
 */
struct direct	{
	ino_t	d_ino;			/* inode number (not used by MS-DOS) */
	int	d_namlen;		/* Name length */
	char	d_name[13];		/* file name */
};

struct _dir_struc {			/* Structure used by dir operations */
	char *start;			/* Starting position */
	char *curr;			/* Current position */
	struct direct dirstr;		/* Directory structure to return */
};

typedef struct _dir_struc DIR;		/* Type returned by dir operations */

DIR *cdecl opendir(char *filename);
struct direct *readdir(DIR *dirp);
long telldir(DIR *dirp);
void seekdir(DIR *dirp,long loc);
void rewinddir(DIR *dirp);
void closedir(DIR *dirp);

#endif /* __DIR_INCLUDED */
