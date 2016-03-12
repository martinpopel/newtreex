package UD::Core::Common;
use strict;
use warnings;
use 5.010;
use utf8;
use Moo;
use List::Util 1.33;
use Scalar::Util;
use Data::Printer;

sub import {
    feature->import('say');
    utf8::import();
    my $caller = caller;
    eval "package $caller;" .
<<'END';
use Moo;
use Carp;
use List::Util qw(first min max all any none);
use Scalar::Util qw(weaken);
use Data::Printer;
use MooX::TypeTiny;
use Types::Standard qw(Int Bool);

sub has_ro {my $name = shift; has($name, is=>'ro', @_);};
sub has_rw {my $name = shift; has($name, is=>'ro', writer => "set_$name", @_);};
END
    return;
}

1;

__END__

=encoding utf-8

=head1 NAME

UD::Core::Common - shorten the "C<use>" part of your Perl codes

=head1 SYNOPSIS

Write just

 use UD::Core::Common;
 has_ro foo => (default=>42);
 has_rw bar => (default=>43, isa=>Int);
 # now you can use $self->set_bar(44);

Instead of

 use utf8;
 use strict;
 use warnings;
 use feature 'say';
 use Moo;
 use Carp;
 use List::Util qw(first min max all any none);
 use Scalar::Util qw(weaken);
 use Data::Printer;
 use MooX::TypeTiny;
 use Types::Standard qw(Int Bool);

 has foo => (is=>'ro', default=>42);
 has bar => (is=>'ro', default=>43, writer=>'set_bar', isa=>Int);

=head1 DESCRIPTION

This module saves boilerplate lines from Moo based classes.
Unlike Moose, Moo has no L<MooseX::SemiAffordanceAccessor>,
which would allow for having setters with "set_" prefix
(and getters without any prefix).
So we include pseudokeywords C<has_ro> and C<has_rw>,
which also automatically include the respective "is" type.

=head1 AUTHOR

Martin Popel <popel@ufal.mff.cuni.cz>

=head1 COPYRIGHT AND LICENSE

Copyright © 2016 by Institute of Formal and Applied Linguistics, Charles University in Prague

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
