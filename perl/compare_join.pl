#!/usr/bin/env perl
use strict;
use warnings;
use Benchmark qw(:all);
use feature 'say';
use Data::Dumper;

my @fields = qw(1 Tatra Tatra PROPN NNFS1-----A---- Case=Nom|Gender=Fem|NameType=Com|Negative=Pos|Number=Sing 0 root _ SpaceAfter=No|LId=Tatra-1);

sub print_join {
    print STDERR join("\t", @fields)."\n";
}

sub print_join_n {
    print STDERR join("\t", @fields), "\n";
}


sub say_join {
    say STDERR join("\t", @fields);
}

sub say_ofs {
    #local $, = "\t";
    say STDERR @fields;
}

sub print_ofs {
    #local $, = "\t";
    #local $\ = "\n";
    print STDERR @fields, "\n";
}


sub print_ofs_ors {
    #local $, = "\t";
    #local $\ = "\n";
    print STDERR @fields;
}

local $, = "\t";
local $\ = "\n";


cmpthese(
    -1,
    {
        print_join     => \&print_join,
        print_join_n   => \&print_join,
        say_join       => \&say_join,
        say_ofs        => \&say_ofs,
        print_ofs      => \&print_ofs,
        print_ofs_ors  => \&print_ofs_ors,
    }
);

__END__

