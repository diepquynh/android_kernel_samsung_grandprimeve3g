#
# Makefile for the linux journaling routines.
#
CFLAGS_KERNEL := -fno-strict-aliasing

obj-$(CONFIG_JBD2) += jbd2.o

jbd2-objs := transaction.o commit.o recovery.o checkpoint.o revoke.o journal.o
