#!/bin/sh
#
# This file was produced by running the Configure script. It holds all the
# definitions figured out by Configure. Should you modify one of these values,
# do not forget to propagate your changes by running "Configure -der". You may
# instead choose to run each of the .SH files by yourself, or "Configure -S".
#

# Package name      : perl5
# Source directory  : .
# Configuration time: Mon Apr 19 22:33:54 EET DST 1999
# Configured by     : jhi
# Target system     : osf1 alpha.hut.fi v4.0 878 alpha 

Author=''
Date='$Date'
Header=''
Id='$Id'
Locker=''
Log='$Log'
Mcc='Mcc'
RCSfile='$RCSfile'
Revision='$Revision'
Source=''
State=''
_a='.a'
_exe=''
_o='.o'
afs='false'
alignbytes='8'
ansi2knr=''
aphostname=''
apiversion='5.00556'
ar='ar'
archlib='/opt/perl/lib/5.00556/alpha-dec_osf-thread'
archlibexp='/opt/perl/lib/5.00556/alpha-dec_osf-thread'
archname64=''
archname='alpha-dec_osf-thread'
archobjs=''
awk='awk'
baserev='5.0'
bash=''
bin='/opt/perl/bin'
binexp='/opt/perl/bin'
bison=''
byacc='byacc'
byteorder='12345678'
c='\c'
castflags='0'
cat='cat'
cc='cc'
cccdlflags=' '
ccdlflags='  -Wl,-rpath,/opt/perl/lib/5.00556/alpha-dec_osf-thread/CORE'
ccflags='-pthread -std -DLANGUAGE_C'
ccsymbols='LANGUAGE_C=1 SYSTYPE_BSD=1 _LONGLONG=1 __LANGUAGE_C__=1'
cf_by='jhi'
cf_email='yourname@yourhost.yourplace.com'
cf_time='Mon Apr 19 22:33:54 EET DST 1999'
chgrp=''
chmod=''
chown=''
clocktype='clock_t'
comm='comm'
compress=''
contains='grep'
cp='cp'
cpio=''
cpp='cpp'
cpp_stuff='42'
cppccsymbols='_SYSTYPE_BSD=1 __alpha=1 __osf__=1 __unix__=1 unix=1'
cppflags='-pthread -std -DLANGUAGE_C'
cpplast=''
cppminus=''
cpprun='/usr/bin/cpp'
cppstdin='cppstdin'
cppsymbols=''
crosscompile='undef'
cryptlib=''
csh='csh'
d_Gconvert='gcvt((x),(n),(b))'
d_access='define'
d_accessx='undef'
d_alarm='define'
d_archlib='define'
d_attribut='undef'
d_bcmp='define'
d_bcopy='define'
d_bsd='undef'
d_bsdgetpgrp='undef'
d_bsdsetpgrp='define'
d_bzero='define'
d_casti32='undef'
d_castneg='define'
d_charvspr='undef'
d_chown='define'
d_chroot='define'
d_chsize='undef'
d_closedir='define'
d_cmsghdr_s='define'
d_const='define'
d_crypt='define'
d_csh='define'
d_cuserid='define'
d_dbl_dig='define'
d_dbmclose64='undef'
d_dbminit64='undef'
d_delete64='undef'
d_difftime='define'
d_dirent64_s='undef'
d_dirnamlen='define'
d_dlerror='define'
d_dlopen='define'
d_dlsymun='undef'
d_dosuid='undef'
d_drand48proto='define'
d_dup2='define'
d_eaccess='undef'
d_endgrent='define'
d_endhent='define'
d_endnent='define'
d_endpent='define'
d_endpwent='define'
d_endsent='define'
d_eofnblk='define'
d_eunice='undef'
d_fchmod='define'
d_fchown='define'
d_fcntl='define'
d_fd_macros='define'
d_fd_set='define'
d_fds_bits='define'
d_fetch64='undef'
d_fgetpos64='undef'
d_fgetpos='define'
d_firstkey64='undef'
d_flexfnam='define'
d_flock64_s='undef'
d_flock='define'
d_fopen64='undef'
d_fork='define'
d_fpathconf='define'
d_freopen64='undef'
d_fseek64='undef'
d_fseeko64='undef'
d_fseeko='undef'
d_fsetpos64='undef'
d_fsetpos='define'
d_fstat64='undef'
d_fstatfs='define'
d_fstatvfs='define'
d_ftell64='undef'
d_ftello64='undef'
d_ftello='undef'
d_ftime='undef'
d_ftruncate64='undef'
d_getgrent='define'
d_getgrps='define'
d_gethbyaddr='define'
d_gethbyname='define'
d_gethent='define'
d_gethname='define'
d_gethostprotos='define'
d_getlogin='define'
d_getmntent='undef'
d_getnbyaddr='define'
d_getnbyname='define'
d_getnent='define'
d_getnetprotos='define'
d_getpbyname='define'
d_getpbynumber='define'
d_getpent='define'
d_getpgid='define'
d_getpgrp2='undef'
d_getpgrp='define'
d_getppid='define'
d_getprior='define'
d_getprotoprotos='define'
d_getpwent='define'
d_getsbyname='define'
d_getsbyport='define'
d_getsent='define'
d_getservprotos='define'
d_gettimeod='define'
d_gnulibc='undef'
d_grpasswd='define'
d_hasmntopt='undef'
d_htonl='define'
d_index='undef'
d_inetaton='define'
d_ino64_t='undef'
d_int64t='undef'
d_iovec_s='define'
d_isascii='define'
d_killpg='define'
d_lchown='define'
d_link='define'
d_llseek='undef'
d_locconv='define'
d_lockf64='undef'
d_lockf='define'
d_longdbl='define'
d_longlong='define'
d_lseek64='undef'
d_lstat64='undef'
d_lstat='define'
d_madvise='define'
d_mblen='define'
d_mbstowcs='define'
d_mbtowc='define'
d_memcmp='define'
d_memcpy='define'
d_memmove='define'
d_memset='define'
d_mkdir='define'
d_mkfifo='define'
d_mktime='define'
d_mmap='define'
d_mprotect='define'
d_msg='define'
d_msg_ctrunc='define'
d_msg_dontroute='define'
d_msg_oob='define'
d_msg_peek='define'
d_msg_proxy='undef'
d_msgctl='define'
d_msgget='define'
d_msghdr_s='define'
d_msgrcv='define'
d_msgsnd='define'
d_msync='define'
d_munmap='define'
d_mymalloc='undef'
d_nextkey64='undef'
d_nice='define'
d_off64_t='undef'
d_offset_t='undef'
d_old_pthread_create_joinable='undef'
d_oldpthreads='undef'
d_oldsock='undef'
d_open3='define'
d_open64='undef'
d_opendir64='undef'
d_pathconf='define'
d_pause='define'
d_phostname='undef'
d_pipe='define'
d_poll='define'
d_portable='define'
d_pthread_yield='undef'
d_pwage='undef'
d_pwchange='undef'
d_pwclass='undef'
d_pwcomment='define'
d_pwexpire='undef'
d_pwgecos='define'
d_pwpasswd='define'
d_pwquota='define'
d_readdir64='undef'
d_readdir='define'
d_readlink='define'
d_readv='define'
d_recvmsg='define'
d_rename='define'
d_rewinddir='define'
d_rmdir='define'
d_safebcpy='define'
d_safemcpy='undef'
d_sanemcmp='define'
d_sched_yield='define'
d_scm_rights='define'
d_seekdir64='undef'
d_seekdir='define'
d_select='define'
d_sem='define'
d_semctl='define'
d_semctl_semid_ds='define'
d_semctl_semun='define'
d_semget='define'
d_semop='define'
d_sendmsg='define'
d_setegid='define'
d_seteuid='define'
d_setgrent='define'
d_setgrps='define'
d_sethent='define'
d_setlinebuf='define'
d_setlocale='define'
d_setnent='define'
d_setpent='define'
d_setpgid='define'
d_setpgrp2='undef'
d_setpgrp='define'
d_setprior='define'
d_setpwent='define'
d_setregid='define'
d_setresgid='undef'
d_setresuid='undef'
d_setreuid='define'
d_setrgid='define'
d_setruid='define'
d_setsent='define'
d_setsid='define'
d_setvbuf='define'
d_sfio='undef'
d_shm='define'
d_shmat='define'
d_shmatprototype='define'
d_shmctl='define'
d_shmdt='define'
d_shmget='define'
d_sigaction='define'
d_sigsetjmp='define'
d_socket='define'
d_sockpair='define'
d_stat64='undef'
d_statblks='define'
d_statfs='define'
d_statfsflags='define'
d_statvfs='define'
d_stdio_cnt_lval='define'
d_stdio_ptr_lval='define'
d_stdiobase='define'
d_stdstdio='define'
d_store64='undef'
d_strchr='define'
d_strcoll='define'
d_strctcpy='define'
d_strerrm='strerror(e)'
d_strerror='define'
d_strtod='define'
d_strtol='define'
d_strtoul='define'
d_strxfrm='define'
d_suidsafe='undef'
d_symlink='define'
d_syscall='define'
d_sysconf='define'
d_sysernlst=''
d_syserrlst='define'
d_system='define'
d_tcgetpgrp='define'
d_tcsetpgrp='define'
d_telldir64='undef'
d_telldir='define'
d_telldirproto='define'
d_time='define'
d_times='define'
d_tmpfile64='undef'
d_truncate64='undef'
d_truncate='define'
d_tzname='define'
d_umask='define'
d_uname='define'
d_union_semun='undef'
d_vfork='undef'
d_void_closedir='undef'
d_voidsig='define'
d_voidtty=''
d_volatile='define'
d_vprintf='define'
d_wait4='define'
d_waitpid='define'
d_wcstombs='define'
d_wctomb='define'
d_writev='define'
d_xenix='undef'
date='date'
db_hashtype='u_int32_t'
db_prefixtype='size_t'
defvoidused='15'
direntrytype='struct dirent'
dlext='so'
dlsrc='dl_dlopen.xs'
doublesize='8'
drand01='drand48()'
dynamic_ext='B DB_File Data/Dumper Devel/Peek Fcntl IO IPC/SysV NDBM_File ODBM_File Opcode POSIX SDBM_File Socket Thread attrs re'
eagain='EAGAIN'
ebcdic='undef'
echo='echo'
egrep='egrep'
emacs=''
eunicefix=':'
exe_ext=''
expr='expr'
extensions='B DB_File Data/Dumper Devel/Peek Fcntl IO IPC/SysV NDBM_File ODBM_File Opcode POSIX SDBM_File Socket Thread attrs re Errno'
find=''
firstmakefile='makefile'
flex=''
fpostype='fpos_t'
freetype='void'
full_ar='/usr/bin/ar'
full_csh='/usr/bin/csh'
full_sed='/usr/bin/sed'
gccversion=''
gidtype='gid_t'
glibpth='/usr/shlib /usr/ccs/lib /usr/lib/cmplrs/cc /usr/lib /usr/local/lib /var/shlib'
grep='grep'
groupcat='cat /etc/group'
groupstype='gid_t'
gzip='gzip'
h_fcntl='false'
h_sysfile='true'
hint='recommended'
hostcat='cat /etc/hosts'
huge=''
i_arpainet='define'
i_bsdioctl=''
i_db='define'
i_dbm='define'
i_dirent='define'
i_dld='undef'
i_dlfcn='define'
i_fcntl='undef'
i_float='define'
i_gdbm='undef'
i_grp='define'
i_inttypes='undef'
i_limits='define'
i_locale='define'
i_machcthr='undef'
i_malloc='define'
i_math='define'
i_memory='undef'
i_mntent='undef'
i_ndbm='define'
i_netdb='define'
i_neterrno='undef'
i_niin='define'
i_poll='define'
i_pthread='define'
i_pwd='define'
i_rpcsvcdbm='undef'
i_sfio='undef'
i_sgtty='undef'
i_stdarg='define'
i_stddef='define'
i_stdlib='define'
i_string='define'
i_sysaccess='define'
i_sysdir='define'
i_sysfile='define'
i_sysfilio='undef'
i_sysin='undef'
i_sysioctl='define'
i_sysmman='define'
i_sysmount='define'
i_sysndir='undef'
i_sysparam='define'
i_sysresrc='define'
i_syssecrt='define'
i_sysselct='define'
i_syssockio=''
i_sysstat='define'
i_sysstatvfs='define'
i_systime='define'
i_systimek='undef'
i_systimes='define'
i_systypes='define'
i_sysuio='define'
i_sysun='define'
i_syswait='define'
i_termio='undef'
i_termios='define'
i_time='undef'
i_unistd='define'
i_utime='define'
i_values='define'
i_varargs='undef'
i_varhdr='stdarg.h'
i_vfork='undef'
ignore_versioned_solibs=''
incpath=''
inews=''
installarchlib='/opt/perl/lib/5.00556/alpha-dec_osf-thread'
installbin='/opt/perl/bin'
installman1dir='/opt/perl/man/man1'
installman3dir='/opt/perl/man/man3'
installprivlib='/opt/perl/lib/5.00556'
installscript='/opt/perl/bin'
installsitearch='/opt/perl/lib/site_perl/5.00556/alpha-dec_osf-thread'
installsitelib='/opt/perl/lib/site_perl/5.00556'
installusrbinperl='define'
intsize='4'
known_extensions='B DB_File Data/Dumper Devel/Peek Fcntl GDBM_File IO IPC/SysV NDBM_File ODBM_File Opcode POSIX SDBM_File Socket Thread attrs re'
ksh=''
large=''
ld='ld'
lddlflags='-shared -expect_unresolved "*" -O -msym -s'
ldflags=''
less='less'
lib_ext='.a'
libc='/usr/shlib/libc.so'
libperl='libperl.so'
libpth='/usr/shlib /usr/ccs/lib /usr/lib/cmplrs/cc /usr/lib /var/shlib'
libs='-lgdbm -ldbm -ldb -lm -lrt -lpthread -lexc'
libswanted='sfio socket inet nsl nm gdbm dbm db malloc dld ld sun m rt cposix posix ndir dir crypt ucb BSD x pthread exc'
line=''
lint=''
lkflags=''
ln='ln'
lns='/usr/bin/ln -s'
locincpth='/usr/local/include /opt/local/include /usr/gnu/include /opt/gnu/include /usr/GNU/include /opt/GNU/include'
loclibpth='/usr/local/lib /opt/local/lib /usr/gnu/lib /opt/gnu/lib /usr/GNU/lib /opt/GNU/lib'
longdblsize='8'
longlongsize='8'
longsize='8'
lp=''
lpr=''
ls='ls'
lseeksize='8'
lseektype='off_t'
mail=''
mailx=''
make='make'
make_set_make='#'
mallocobj=''
mallocsrc=''
malloctype='void *'
man1dir='/opt/perl/man/man1'
man1direxp='/opt/perl/man/man1'
man1ext='1'
man3dir='/opt/perl/man/man3'
man3direxp='/opt/perl/man/man3'
man3ext='3'
medium=''
mips=''
mips_type=''
mkdir='mkdir'
mmaptype='void *'
models='none'
modetype='mode_t'
more='more'
multiarch='undef'
mv=''
myarchname='alpha-dec_osf'
mydomain='.yourplace.com'
myhostname='yourhost'
myuname='osf1 alpha.hut.fi v4.0 878 alpha '
n=''
netdb_hlen_type='int'
netdb_host_type='const char *'
netdb_name_type='const char *'
netdb_net_type='int'
nm='nm'
nm_opt='-p'
nm_so_opt=''
nonxs_ext='Errno'
nroff='nroff'
o_nonblock='O_NONBLOCK'
obj_ext='.o'
old_pthread_create_joinable=''
optimize='-O'
orderlib='false'
osname='dec_osf'
osvers='4.0'
package='perl5'
pager='/c/bin/less'
passcat='cat /etc/passwd'
patchlevel='5'
path_sep=':'
perl=''
perladmin='yourname@yourhost.yourplace.com'
perlpath='/opt/perl/bin/perl'
pg='pg'
phostname=''
pidtype='pid_t'
plibpth=''
pmake=''
pr=''
prefix='/opt/perl'
prefixexp='/opt/perl'
privlib='/opt/perl/lib/5.00556'
privlibexp='/opt/perl/lib/5.00556'
prototype='define'
ptrsize='8'
randbits='48'
randfunc='drand48'
randseedtype='long'
ranlib=':'
rd_nodata='-1'
rm='rm'
rmail=''
runnm='true'
sched_yield='sched_yield()'
scriptdir='/opt/perl/bin'
scriptdirexp='/opt/perl/bin'
sed='sed'
seedfunc='srand48'
selectminbits='32'
selecttype='fd_set *'
sendmail=''
sh='/bin/sh'
shar=''
sharpbang='#!'
shmattype='void *'
shortsize='2'
shrpenv=''
shsharp='true'
sig_count='49'
sig_name='ZERO HUP INT QUIT ILL TRAP ABRT EMT FPE KILL BUS SEGV SYS PIPE ALRM TERM IOINT STOP TSTP CONT CHLD TTIN TTOU AIO XCPU XFSZ VTALRM PROF WINCH INFO USR1 USR2 RESV RTMIN NUM34 NUM35 NUM36 NUM37 NUM38 NUM39 NUM40 NUM41 NUM42 NUM43 NUM44 NUM45 NUM46 NUM47 MAX IOT LOST URG CLD IO POLL PTY PWR RTMAX '
sig_name_init='"ZERO", "HUP", "INT", "QUIT", "ILL", "TRAP", "ABRT", "EMT", "FPE", "KILL", "BUS", "SEGV", "SYS", "PIPE", "ALRM", "TERM", "IOINT", "STOP", "TSTP", "CONT", "CHLD", "TTIN", "TTOU", "AIO", "XCPU", "XFSZ", "VTALRM", "PROF", "WINCH", "INFO", "USR1", "USR2", "RESV", "RTMIN", "NUM34", "NUM35", "NUM36", "NUM37", "NUM38", "NUM39", "NUM40", "NUM41", "NUM42", "NUM43", "NUM44", "NUM45", "NUM46", "NUM47", "MAX", "IOT", "LOST", "URG", "CLD", "IO", "POLL", "PTY", "PWR", "RTMAX", 0'
sig_num='0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 6 6 16 20 23 23 23 29 48 '
sig_num_init='0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 6, 6, 16, 20, 23, 23, 23, 29, 48, 0'
signal_t='void'
sitearch='/opt/perl/lib/site_perl/5.00556/alpha-dec_osf-thread'
sitearchexp='/opt/perl/lib/site_perl/5.00556/alpha-dec_osf-thread'
sitelib='/opt/perl/lib/site_perl/5.00556'
sitelibexp='/opt/perl/lib/site_perl/5.00556'
sizetype='size_t'
sleep=''
smail=''
small=''
so='so'
sockethdr=''
socketlib=''
sort='sort'
spackage='Perl5'
spitshell='cat'
split=''
src='.'
ssizetype='ssize_t'
startperl='#!/opt/perl/bin/perl'
startsh='#!/bin/sh'
static_ext=' '
stdchar='unsigned char'
stdio_base='((fp)->_base)'
stdio_bufsiz='((fp)->_cnt + (fp)->_ptr - (fp)->_base)'
stdio_cnt='((fp)->_cnt)'
stdio_filbuf=''
stdio_ptr='((fp)->_ptr)'
strings='/usr/include/string.h'
submit=''
subversion='56'
sysman='/usr/man/man1'
tail=''
tar=''
tbl=''
tee=''
test='test'
timeincl='/usr/include/sys/time.h '
timetype='time_t'
touch='touch'
tr='tr'
trnl='\n'
troff=''
uidtype='uid_t'
uname='uname'
uniq='uniq'
use64bits='define'
usedl='define'
usemultiplicity='undef'
usemymalloc='n'
usenm='true'
useopcode='true'
useperlio='undef'
useposix='true'
usesfio='false'
useshrplib='true'
usethreads='define'
usevfork='false'
usrinc='/usr/include'
uuname=''
version='5.00556'
vi=''
voidflags='15'
xlibpth='/usr/lib/386 /lib/386'
zcat=''
zip='zip'
# Configure command line arguments.
config_arg0='Configure'
config_args='-Dprefix=/opt/perl -Doptimize=-O -Dusethreads -Duse64bits -Dcf_by=yourname -Dcf_email=yourname@yourhost.yourplace.com -Dperladmin=yourname@yourhost.yourplace.com -Dmydomain=.yourplace.com -Dmyhostname=yourhost -dE'
config_argc=10
config_arg1='-Dprefix=/opt/perl'
config_arg2='-Doptimize=-O'
config_arg3='-Dusethreads'
config_arg4='-Duse64bits'
config_arg5='-Dcf_by=yourname'
config_arg6='-Dcf_email=yourname@yourhost.yourplace.com'
config_arg7='-Dperladmin=yourname@yourhost.yourplace.com'
config_arg8='-Dmydomain=.yourplace.com'
config_arg9='-Dmyhostname=yourhost'
config_arg10='-dE'
PERL_REVISION=5
PERL_VERSION=5
PERL_SUBVERSION=56
CONFIGDOTSH=true
# Variables propagated from previous config.sh file.
pp_sys_cflags='ccflags="$ccflags -DNO_EFF_ONLY_OK"'
