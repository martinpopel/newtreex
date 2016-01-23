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
        lvalue_accessors => {lv_lemma_xs => 5},
        setters => { set_lemma_xs => 5},
        getters => { get_lemma_xs => 5},
    };
    sub set_lemma_perl { $_[0]->[5] = $_[1];}
    sub set_check_perl { die "nic" if !defined $_[1]; $_[0]->[5] = $_[1];}
    sub lv_lemma_perl : lvalue { $_[0]->[5]; }
    no warnings 'once';
    *lv_check_sentinel = sub : lvalue { sentinel obj=>shift, set=>\&set_check_perl;};
    sub get_lemma_perl { $_[0]->[0];}
}

use Benchmark qw(:all);
#use NodeH; use NodeA;
my $nh = NodeH->new(); $nh->set_lemma_perl('ahoj');
my $na = NodeA->new(); $na->set_lemma_perl('ahoj');
my $LEMMA=5;
use constant LEMA=>5;

cmpthese(-1, {
     'H-direct'              => sub {$nh->{lemma} = 'ahoj';},
     'H-set-lemma-perl'      => sub {$nh->set_lemma_perl('ahoj');},
     'H-set-lemma-xs'        => sub {$nh->set_lemma_xs('ahoj');},
     'H-lv-lemma-perl'       => sub {$nh->lv_lemma_perl = 'ahoj';},
     'H-lv-lemma-xs'         => sub {$nh->lv_lemma_xs = 'ahoj';},
     'H-set-check-perl'      => sub {$nh->set_check_perl('ahoj');},
     'H-lv-check-sentinel'   => sub {$nh->lv_check_sentinel = 'ahoj';},
     'A-direct-var'          => sub {$na->[$LEMMA] = 'ahoj';},
     'A-direct-con'          => sub {$na->[LEMA] = 'ahoj';},
     'A-direct'              => sub {$na->[5] = 'ahoj';},
     'A-set-lemma-perl'      => sub {$na->set_lemma_perl('ahoj');},
     'A-set-lemma-xs'        => sub {$na->set_lemma_xs('ahoj');},
     'A-lv-lemma-perl'       => sub {$na->lv_lemma_perl = 'ahoj';},
     'A-lv-lemma-xs'         => sub {$na->lv_lemma_xs = 'ahoj';},
     'A-set-check-perl'      => sub {$na->set_check_perl('ahoj');},
     'A-lv-check-sentinel'   => sub {$na->lv_check_sentinel = 'ahoj';},
});
my $l;
cmpthese(-1,{
     'h-direct'         => sub {$l = $nh->{lemma};},
     'h-get_lemma_perl' => sub {$l = $nh->get_lemma_perl();},
     'h-get_lemma_xs'   => sub {$l = $nh->get_lemma_xs();},
     'h-lv_lemma_xs'    => sub {$l = $nh->lv_lemma_xs();},
     'h-lv_lemma_perl'  => sub {$l = $nh->lv_lemma_perl();},
     'h-lv_check_sentinel'  => sub {$l = $nh->lv_check_sentinel;},
     'a-direct'         => sub {$l = $na->[5];},
     'a-direct-var'     => sub {$l = $na->[$LEMMA];},
     'a-direct-con'     => sub {$l = $na->[LEMA];},
     'a-get_lemma_perl' => sub {$l = $na->get_lemma_perl();},
     'a-get_lemma_xs'   => sub {$l = $na->get_lemma_xs();},
     'a-lv_lemma_xs'    => sub {$l = $na->lv_lemma_xs();},
     'a-lv_lemma_perl'  => sub {$l = $na->lv_lemma_perl();},
     'a-lv_check_sentinel'  => sub {$l = $na->lv_check_sentinel;},
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
--------
cosmos perl 5.22.1
Zapis
H-lv-check-sentinel    796 444/s
A-lv-check-sentinel    827 077/s
A-set-check-perl     2 970 871/s
H-set-check-perl     3 113 701/s
H-set-lemma-perl     3 185 778/s
A-set-lemma-perl     3 429 921/s
H-lv-lemma-perl      3 495 253/s
A-lv-lemma-perl      3 674 915/s
H-set-lemma-xs       5 086 675/s
A-set-lemma-xs       5 397 081/s
H-lv-lemma-xs        5 518 821/s
A-lv-lemma-xs        6 371 555/s
A-direct-con        11 362 278/s
A-direct            11 362 278/s
H-direct            11 877 074/s
A-direct-var        15 252 015/s

Cteni
a-lv_check_sentinel  1 323 322/s
h-lv_check_sentinel  1 336 171/s
h-get_lemma_perl     3 028 065/s
h-lv_lemma_perl      4 192 706/s
a-get_lemma_perl     4 327 849/s
a-lv_lemma_perl      4 453 902/s
h-lv_lemma_xs        6 616 615/s
a-lv_lemma_xs        7 887 518/s
h-get_lemma_xs       8 498 074/s
a-get_lemma_xs       9 354 331/s
h-direct            13 912 028/s
a-direct-con        16 096 561/s
a-direct-var        16 770 827/s
a-direct            16 990 814/s

sol4
zapis             Rate     A-direct A-direct-var A-direct-con
A-direct     5 133 174/s           --          -1%          -2%
A-direct-var 5 159 377/s           1%           --          -1%
A-direct-con 5 215 314/s           2%           1%           --
cteni             Rate a-direct-con a-direct-var     a-direct
a-direct-con 4 172 459/s           --          -1%          -5%
a-direct-var 4 209 527/s           1%           --          -4%
a-direct     4 404 929/s           6%           5%           --

zapis                  Rate A-set-lemma-perl A-set-lemma-xs A-direct A-direct-con A-direct-var
A-set-lemma-perl  3 703 905/s               --           -31%     -72%         -72%         -77%
A-set-lemma-xs    5 396 991/s              46%             --     -59%         -59%         -67%
A-direct         13 010 616/s             251%           141%       --          -2%         -20%
A-direct-con     13 268 552/s             258%           146%       2%           --         -18%
A-direct-var     16 209 656/s             338%           200%      25%          22%           --
cteni                  Rate a-get_lemma_perl a-get_lemma_xs a-direct-var a-direct a-direct-con
a-get_lemma_perl  4 037 717/s               --           -54%         -71%     -72%         -74%
a-get_lemma_xs    8 684 626/s             115%             --         -39%     -41%         -44%
a-direct-var     14 132 690/s             250%            63%           --      -4%          -8%
a-direct         14 681 978/s             264%            69%           4%       --          -5%
a-direct-con     15 413 044/s             282%            77%           9%       5%           --
