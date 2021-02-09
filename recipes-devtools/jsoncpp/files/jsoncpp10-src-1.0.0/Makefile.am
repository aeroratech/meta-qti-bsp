# Makefile.am - Automake script for MNC MSP
#
AM_CFLAGS = -Wall \
        -Wundef \
        -Wstrict-prototypes \
	-Wno-trigraphs \
        -fexceptions

AUTOMAKE_OPTIONS = subdir-objects

ACLOCAL_AMFLAGS = -I m4

AM_CPPFLAGS = \
	-fpermissive \
	-I $(top_srcdir)/include


lib_LTLIBRARIES = libjsoncpp.la

nobase_pkginclude_HEADERS = \
	include/json/autolink.h \
	include/json/config.h \
	include/json/features.h \
	include/json/forwards.h \
	include/json/json.h \
	include/json/reader.h \
	include/json/value.h \
	include/json/writer.h
 	
libjsoncpp_la_SOURCES = src/lib_json/json_value.cpp \
	src/lib_json/json_reader.cpp \
       src/lib_json/json_writer.cpp

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = jsoncpp.pc
EXTRA_DIST = $(pkgconfig_DATA)
