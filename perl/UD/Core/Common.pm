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
    my $caller = caller;
    eval "package $caller;" .
<<'END';
use Moo;
use Carp;
use List::Util qw(first min max all any none);
use Scalar::Util qw(weaken);
use Data::Printer;
sub has_ro {my $name = shift; has($name, is=>'ro', @_);};
sub has_rw {my $name = shift; has($name, is=>'ro', writer => "set_$name", @_);};
END
    return;
}

1;

__END__

sub importOLD {
    my $caller = caller;
    my $callerhas = $caller . '::has';
    {
        no strict 'refs';
        *{ $caller . '::has_ro'} = sub {my $name = shift; $callerhas->($name, is=>'ro', @_);};
        *{ $caller . '::has_rw'} = sub {my $name = shift; $callerhas->($name, is=>'ro', writer => "set_$name", @_);};
    }
    feature->import('say');
    utf8::import();
    # strict and warnings will be imported by Moo::import

    # TODO: This does not work
    List::Util->import(qw(first min max all any none));
    #List::MoreUtils->import(qw(first_index uniq));
    #Scalar::Util::import(qw(weaken));
    #Data::Printer->import();

    # We cannot use here "Moo->import();
    # because Moo::import uses "caller" to detect the target package
    # which should become a Moo class.
    # So we need to fake caller with goto &sub;
    @_ = qw(Moo);
    goto &Moo::import;
}

=encoding utf-8

=head1 NAME

UD::Core::Common - shorten the "C<use>" part of your Perl codes

=head1 SYNOPSIS

Write just

 use UD::Core::Common;
 has_ro foo => (default=>42);
 has_rw bar => (default=>43);
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

 has foo => (is=>'ro', default=>42);
 has bar => (is=>'ro', default=>43, writer=>'set_bar');

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
