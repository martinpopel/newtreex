#!/usr/bin/env perl
use strict;
use warnings;
STDOUT->autoflush(1);
print "init\n";
my @ar=(1,2);
print "array2\n";
@ar = (@ar) x @ar for (1..4); # don't try 5 or more:-)
print "array65k\n";
undef @ar;
sleep 2;
print "load\n";
sleep 1;
print "save\n";

