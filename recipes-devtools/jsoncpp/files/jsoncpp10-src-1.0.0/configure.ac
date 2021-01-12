#                                               -*- Autoconf -*-

# configure.ac -- Autoconf script for MNC MSP
#

# Process this file with autoconf to produce a configure script

# Requires autoconf tool later than 2.61
#AC_PREREQ(2.61)
AC_INIT([jsoncpp],1.0.0)
# Does not strictly follow GNU Coding standards
# Leave object files in their subdirectories 
AM_INIT_AUTOMAKE([foreign subdir-objects])
# Disables auto rebuilding of configure, Makefile.ins
AM_MAINTAINER_MODE
# Verifies the --srcdir is correct by checking for the path
# defines some macros variable to be included by source
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

# Checks for programs.
AC_PROG_CC
AM_PROG_CC_C_O
#m4_pattern_allow([AC_PROG_LIBTOOL])
#AC_PROG_LIBTOOL
AC_PROG_AWK
AC_PROG_CPP
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_RANLIB

AC_CONFIG_FILES([ Makefile \
	jsoncpp.pc ]) 
AC_PROG_LIBTOOL
m4_pattern_allow([AC_PROG_LIBTOOL])
LT_INIT
AC_OUTPUT
