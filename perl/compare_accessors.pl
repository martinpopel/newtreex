#!/usr/bin/env perl
use strict;
use warnings;

{   package NodeH;
    use Sentinel;
    use Class::XSAccessor {
        constructor => 'new',
        lvalue_accessors => {lv_lemma_xs => 'lemma'},
        setters => { set_lemma_xs => 'lemma'},
        getters => { get_lemma_xs => 'lemma'},
    };
    sub set_lemma_perl { $_[0]->{lemma} = $_[1];}
    sub set_check_perl { die "nic" if !defined $_[1]; $_[0]->{lemma} = $_[1];}
    sub lv_lemma_perl : lvalue { $_[0]->{lemma}; }
    no warnings 'once';
    *lv_check_sentinel = sub : lvalue { sentinel obj=>shift, set=>\&set_check_perl;};
    sub get_lemma_perl { $_[0]->{lemma};}
}

{   package NodeA;
    use Sentinel;
    use Class::XSAccessor::Array {
        constructor => 'new',
        lvalue_accessors => {lv_lemma_xs => 0},
        setters => { set_lemma_xs => 0},
        getters => { get_lemma_xs => 0},
    };
    sub set_lemma_perl { $_[0]->[0] = $_[1];}
    sub set_check_perl { die "nic" if !defined $_[1]; $_[0]->[0] = $_[1];}
    sub lv_lemma_perl : lvalue { $_[0]->[0]; }
    no warnings 'once';
    *lv_check_sentinel = sub : lvalue { sentinel obj=>shift, set=>\&set_check_perl;};
    sub get_lemma_perl { $_[0]->[0];}
}

use Benchmark qw(:all);
use NodeH; use NodeA;
my $nh = NodeH->new(); $nh->set_lemma_perl('ahoj');
my $na = NodeA->new(); $na->set_lemma_perl('ahoj');

cmpthese(-1, {
    'H-direct'              => sub {$nh->{lemma} = 'ahoj';},
    'H-set-lemma-perl'      => sub {$nh->set_lemma_perl('ahoj');},
    'H-set-lemma-xs'        => sub {$nh->set_lemma_xs('ahoj');},
    'H-lv-lemma-perl'       => sub {$nh->lv_lemma_perl = 'ahoj';},
    'H-lv-lemma-xs'         => sub {$nh->lv_lemma_xs = 'ahoj';},
    'H-set-check-perl'      => sub {$nh->set_check_perl('ahoj');},
    'H-lv-check-sentinel'   => sub {$nh->lv_check_sentinel = 'ahoj';},
    'A-direct'              => sub {$na->[0] = 'ahoj';},
    'A-set-lemma-perl'      => sub {$na->set_lemma_perl('ahoj');},
    'A-set-lemma-xs'        => sub {$na->set_lemma_xs('ahoj');},
    'A-lv-lemma-perl'       => sub {$na->lv_lemma_perl = 'ahoj';},
    'A-lv-lemma-xs'         => sub {$na->lv_lemma_xs = 'ahoj';},
    'A-set-check-perl'      => sub {$na->set_check_perl('ahoj');},
    'A-lv-check-sentinel'   => sub {$na->lv_check_sentinel = 'ahoj';},
});                            
                               
cmpthese(-1,{
    'h-direct'         => sub {my $l = $nh->{lemma};},
    'h-get_lemma_perl' => sub {my $l = $nh->get_lemma_perl();},
    'h-get_lemma_xs'   => sub {my $l = $nh->get_lemma_xs();},
    'h-lv_lemma_xs'    => sub {my $l = $nh->lv_lemma_xs();},
    'h-lv_lemma_perl'  => sub {my $l = $nh->lv_lemma_perl();},
    'h-lv_check_sentinel'  => sub {my $l = $nh->lv_check_sentinel;},
    'a-direct'         => sub {my $l = $na->[0];},
    'a-get_lemma_perl' => sub {my $l = $na->get_lemma_perl();},
    'a-get_lemma_xs'   => sub {my $l = $na->get_lemma_xs();},
    'a-lv_lemma_xs'    => sub {my $l = $na->lv_lemma_xs();},
    'a-lv_lemma_perl'  => sub {my $l = $na->lv_lemma_perl();},
    'a-lv_check_sentinel'  => sub {my $l = $na->lv_check_sentinel;},
});

__END__
#system "ps -ovsz $$";

=pod

  Zápis atributu
  H-lv-check-sentinel    714 566/s
  A-lv-check-sentinel    735 179/s
  A-set-check-perl     2 366 578/s
  H-set-check-perl     2 383 127/s
  ---
  H-set-lemma-perl     2 725 258/s
  A-set-lemma-perl     2 780 315/s
  A-lv-lemma-perl      3 143 931/s
  H-lv-lemma-perl      3 174 754/s
  ---
  A-set-lemma-xs       4 542 098/s
  H-set-lemma-xs       4 955 017/s
  H-lv-lemma-xs        5 090 174/s
  A-lv-lemma-xs        5 716 536/s
  ---
  H-direct             9 442 579/s
  A-direct            10 180 350/s

  Čtení atributu:
  h-lv_check_sentinel  1 147 836/s
  a-lv_check_sentinel  1 147 836/s
  ---
  h-get_lemma_perl     2 453 219/s
  a-get_lemma_perl     2 572 440/s
  h-lv_lemma_perl      3 206 187/s
  a-lv_lemma_perl      3 406 574/s
  ---
  h-lv_lemma_xs        5 825 422/s
  a-lv_lemma_xs        6 412 374/s
  h-get_lemma_xs       6 859 843/s
  a-get_lemma_xs       7 489 828/s
  ---
  h-direct            10 144 688/s
  a-direct            12 112 263/s
