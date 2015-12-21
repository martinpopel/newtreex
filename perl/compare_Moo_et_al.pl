#!/usr/bin/env perl

use strict;
use warnings;

use Carp;

BEGIN {
     # uncomment to test pure Perl Mouse
#    $ENV{MOUSE_PUREPERL} = 1;
}

# ...........hash...............

my $hash = {};
sub hash_nc {
    $hash->{bar} = 32;
    my $x = $hash->{bar};
}


# ...........hash with check...............

my $hash_check = {};
sub hash {
    my $arg = 32;
    croak "we take an integer" unless defined $arg and $arg =~ /^[+-]?\d+$/;
    $hash_check->{bar} = $arg;
    my $x = $hash_check->{bar};
}


# ...........by hand..............
{
    package Foo::Manual::NoChecks;
    sub new { bless {} => shift }
    sub bar {
        my $self = shift;
        return $self->{bar} unless @_;
        $self->{bar} = shift;
    }
}
my $manual_nc = Foo::Manual::NoChecks->new;
sub manual_nc {
    $manual_nc->bar(32);
    my $x = $manual_nc->bar;
}


# ...........by hand with checks..............
{
    package Foo::Manual;
    use Carp;

    sub new { bless {} => shift }
    sub bar {
        my $self = shift;
        if( @_ ) {
            # Simulate argument checking
            my $arg = shift;
            croak "we take an integer" unless defined $arg and $arg =~ /^[+-]?\d+$/;
            $self->{bar} = $arg;
        }
        return $self->{bar};
    }
}
my $manual = Foo::Manual->new;
sub manual {
    $manual->bar(32);
    my $x = $manual->bar;
}


#.............Mouse.............
{
    package Foo::Mouse;
    use Mouse;
    has bar => (is => 'rw', isa => "Int");
    __PACKAGE__->meta->make_immutable;
}
my $mouse = Foo::Mouse->new;
sub mouse {
    $mouse->bar(32);
    my $x = $mouse->bar;
}


#............Moose............
{
    package Foo::Moose;
    use Moose;
    has bar => (is => 'rw', isa => "Int");
    __PACKAGE__->meta->make_immutable;
}
my $moose = Foo::Moose->new;
sub moose {
    $moose->bar(32);
    my $x = $moose->bar;
}


#.............Moo...........
{
    package Foo::Moo;
    use Moo;
    has bar => (is => 'rw', isa => sub { $_[0] =~ /^[+-]?\d+$/ });
}
my $moo = Foo::Moo->new;
sub moo {
    $moo->bar(32);
    my $x = $moo->bar;
}


#........... Moo using Sub::Quote..............
{
    package Foo::Moo::QS;
    use Moo;
    use Sub::Quote;
    has bar => (is => 'rw', isa => quote_sub q{ $_[0] =~ /^[+-]?\d+$/ });
}
my $mooqs = Foo::Moo::QS->new;
sub mooqs {
    $mooqs->bar(32);
    my $x = $mooqs->bar;
}


#............Object::Tiny::RW..............
{
    package Foo::Object::Tiny::RW;
    use Object::Tiny::RW qw(bar);
}
my $ot = Foo::Object::Tiny::RW->new();
sub ot {
    $ot->bar(32);
    my $x = $ot->bar;
}


#............Object::Tiny::RW::XS..............
{
    package Foo::Object::Tiny::RW::XS;
    use Object::Tiny::RW::XS qw(bar);
}
my $otxs = Foo::Object::Tiny::RW::XS->new();
sub otxs {
    $otxs->bar(32);
    my $x = $otxs->bar;
}

#........... Moops
use Moops;
class Moops::Check {
    has bar => (is => 'rw', isa => "Int");
}
my $moops = Moops::Check->new();
sub moops {
    $moops->bar(32);
    my $x = $moops->bar;
}

#...........
use Benchmark qw(:all);

print "Testing Perl $], Moose $Moose::VERSION, Mouse $Mouse::VERSION, Moo $Moo::VERSION, Moops $Moops::VERSION\n";
cmpthese(
    -10,
    {
        Moose                   => \&moose,
        Mouse                   => \&mouse,
        manual                  => \&manual,
        "manual, no check"      => \&manual_nc,
        'hash, no check'        => \&hash_nc,
        hash                    => \&hash,
        Moo                     => \&moo,
        "Moo w/quote_sub"       => \&mooqs,
        "Object::Tiny::RW"      => \&ot,
        "Object::Tiny::RW::XS"  => \&otxs,
        "Moops"                 => \&moops,
    }
);


__END__
Testing Perl 5.012002, Moose 1.24, Mouse 0.91, Moo 0.009007, Object::Tiny 1.08, Object::Tiny::XS 1.01
Benchmark: timing 6000000 iterations of Moo, Moo w/quote_sub, Moose, Mouse, Object::Tiny, Object::Tiny::XS, hash, manual, manual with no checks...
Object::Tiny::XS:  1 secs ( 1.20 usr + -0.01 sys =  1.19 CPU) @ 5042016.81/s
hash, no check  :  3 secs ( 1.86 usr +  0.01 sys =  1.87 CPU) @ 3208556.15/s
Mouse           :  3 secs ( 3.66 usr +  0.00 sys =  3.66 CPU) @ 1639344.26/s
Object::Tiny    :  3 secs ( 3.80 usr +  0.00 sys =  3.80 CPU) @ 1578947.37/s
hash            :  5 secs ( 5.53 usr +  0.01 sys =  5.54 CPU) @ 1083032.49/s
manual, no check:  9 secs ( 9.11 usr +  0.02 sys =  9.13 CPU) @  657174.15/s
Moo             : 17 secs (17.37 usr +  0.03 sys = 17.40 CPU) @  344827.59/s
manual          : 17 secs (17.89 usr +  0.02 sys = 17.91 CPU) @  335008.38/s
Mouse no XS     : 20 secs (20.50 usr +  0.03 sys = 20.53 CPU) @  292255.24/s
Moose           : 21 secs (21.33 usr +  0.03 sys = 21.36 CPU) @  280898.88/s
Moo w/quote_sub : 23 secs (23.07 usr +  0.04 sys = 23.11 CPU) @  259627.87/s


Moje
Testing Perl 5.018002, Moose 2.1603, Mouse 2.3.0, Moo 2.000002
                      Rate   Moo Moops Moo w/quote_sub Moose manual manual, no check hash Object::Tiny Mouse hash, no check Object::Tiny::XS
Moo               225989/s    --   -1%             -6%  -56%   -61%             -82% -84%         -93%  -93%           -96%             -97%
Moops             229095/s    1%    --             -5%  -55%   -61%             -81% -84%         -93%  -93%           -96%             -97%
Moo w/quote_sub   240192/s    6%    5%              --  -53%   -59%             -81% -83%         -92%  -93%           -96%             -97%
Moose             514139/s  128%  124%            114%    --   -12%             -58% -64%         -83%  -84%           -90%             -93%
manual            581395/s  157%  154%            142%   13%     --             -53% -59%         -81%  -82%           -89%             -92%
manual, no check 1232033/s  445%  438%            413%  140%   112%               -- -14%         -60%  -62%           -77%             -84%
hash             1435407/s  535%  527%            498%  179%   147%              17%   --         -53%  -56%           -73%             -81%
Object::Tiny     3061224/s 1255% 1236%           1174%  495%   427%             148% 113%           --   -5%           -43%             -59%
Mouse            3225806/s 1327% 1308%           1243%  527%   455%             162% 125%           5%    --           -40%             -57%
hash, no check   5357143/s 2271% 2238%           2130%  942%   821%             335% 273%          75%   66%             --             -29%
Object::Tiny::XS 7500000/s 3219% 3174%           3023% 1359%  1190%             509% 423%         145%  133%            40%               --


