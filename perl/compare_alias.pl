#!/usr/bin/env perl
use strict;
use warnings;

my @ATTRS;
BEGIN {
    @ATTRS = qw(form lemma upos xpos deprel feats deps misc ord);
}

{   package Node::H;
    use Class::XSAccessor {
        constructor => 'new',
        setters => { map {("set_$_" => $_)} @ATTRS},
        getters => { map {(      $_ => $_)} @ATTRS },
    };
    sub perlnew { my $class = shift; return bless {@_}, $class; }
    sub hashnew { return bless $_[1], $_[0];}
    
}

{   package Node::A;
    use Class::XSAccessor::Array {
        constructor => 'new',
        setters => { map {('set_'.$ATTRS[$_] => $_)} (0..$#ATTRS) },
        getters => { map {(       $ATTRS[$_] => $_)} (0..$#ATTRS) },
    };

    sub fastnew { my $class = shift; return bless [@_], $class; }
}

{   package Node::ManualH;
    sub new { my $class = shift; return bless {@_}, $class; }
    sub hashnew { return bless $_[1], $_[0];}
    #foreach my $attr (@ATTRS){eval "sub $attr {\$_[0]->{$attr}}";}
    #foreach my $attr (@ATTRS){eval "sub set_$attr {\$_[0]->{$attr} = \$_[1];}";}

    #sub set_form  { $_[0]->{form} = $_[1];}
    #sub set_lemma { $_[0]->{lemma} = $_[1];} # etc
}

{   package Node::ManualA;
    #sub new { my $class = shift; my $ind = 0; return bless [grep {$ind++ % 2} @_], $class; }
    sub fastnew { my $class = shift; return bless [@_], $class; }
    sub new {
        my ($class, %h) = @_;
        my $array = [ map {$h{$_}} @ATTRS];
        return bless $array, $class;
    }
    sub set_form  { $_[0][0] = $_[1];}
    sub set_lemma { $_[0][1] = $_[1];}
    sub set_upos  { $_[0][2] = $_[1];}
    sub set_xpos  { $_[0][3] = $_[1];}
    sub set_deprel{ $_[0][4] = $_[1];}
    sub set_feats { $_[0][5] = $_[1];}
    sub set_deps  { $_[0][6] = $_[1];}
    sub set_misc  { $_[0][7] = $_[1];}
    sub set_ord   { $_[0][8] = $_[1];}
    sub form  { $_[0][0];}
    sub lemma { $_[0][1];}
    sub upos  { $_[0][2];}
    sub xpos  { $_[0][3];}
    sub deprel{ $_[0][4];}
    sub feats { $_[0][5];}
    sub deps  { $_[0][6];}
    sub misc  { $_[0][7];}
    sub ord   { $_[0][8];}
}


use UD::Node;

use Benchmark qw(:all :hireswallclock);

my @VALUES = map {$_.rand} @ATTRS;
my ($form, $lemma, $upos, $xpos, $deprel, $feats, $deps, $misc, $ord) = @VALUES;
my @INIT = map {$ATTRS[$_] => $VALUES[$_]} 0..$#ATTRS;
my $HINIT = {@INIT};
print "Testing Perl $], Class::XSAccessor $Class::XSAccessor::VERSION, Class::XSAccessor::Array $Class::XSAccessor::Array::VERSION\n";

cmpthese(
    -10,
    {
        #UD       => sub { my $n = UD::Node->new(@INIT); },
        XSAccH   => sub { my $n = Node::H->new(@INIT); },
        XSAccHh  => sub { my $n = Node::H->hashnew({@INIT}); },
        XSAccHhh => sub { my $n = Node::H->hashnew($HINIT); },
        XSAccHp  => sub { my $n = Node::H->perlnew(@INIT); },
        XSAccAf  => sub { my $n = Node::A->fastnew(@VALUES); },
        ManualH  => sub { my $n = Node::ManualH->new(@INIT); },
        ManualHh => sub { my $n = Node::ManualH->hashnew({@INIT}); },
        ManualHhh=> sub { my $n = Node::ManualH->hashnew($HINIT); },
        ManualA  => sub { my $n = Node::ManualA->new(@INIT); },
        ManualAf => sub { my $n = Node::ManualA->fastnew(@VALUES); },
        XSAccAs  => sub { my $n = Node::A->new(); $n->set_form($form); $n->set_lemma($lemma); $n->set_upos($upos); $n->set_xpos($xpos); $n->set_deprel($deprel); $n->set_feats($feats); $n->set_deps($deps); $n->set_misc($misc); $n->set_ord($ord);},
    }
);


__END__
Testing Perl 5.014002, Moose 2.1204, Moo 2.000002, Class::XSAccessor 1.19, Class::XSAccessor::Array 1.19
             Rate MooseMut Moose  Moo ManualA ManualH XSAccHp XSAccAs   UD XSAccH XSAccAf ManualAf
MooseMut   4509/s       --  -93% -94%    -95%    -98%    -98%    -98% -98%   -98%    -99%     -99%
Moose     65941/s    1362%    -- -16%    -34%    -66%    -67%    -71% -72%   -72%    -80%     -80%
Moo       78156/s    1633%   19%   --    -21%    -59%    -60%    -65% -66%   -67%    -76%     -77%
ManualA   99508/s    2107%   51%  27%      --    -48%    -50%    -56% -57%   -58%    -69%     -70%
ManualH  191911/s    4156%  191% 146%     93%      --     -3%    -14% -18%   -19%    -41%     -42%
XSAccHp  197371/s    4277%  199% 153%     98%      3%      --    -12% -15%   -16%    -39%     -41%
XSAccAs  224108/s    4870%  240% 187%    125%     17%     14%      --  -4%    -5%    -31%     -33%
UD       233073/s    5069%  253% 198%    134%     21%     18%      4%   --    -1%    -28%     -30%
XSAccH   235633/s    5125%  257% 201%    137%     23%     19%      5%   1%     --    -27%     -29%
XSAccAf  324620/s    7099%  392% 315%    226%     69%     64%     45%  39%    38%      --      -3%
ManualAf 333188/s    7289%  405% 326%    235%     74%     69%     49%  43%    41%      3%       --

Kolik objektů (uzlů s 9 stringovými atributy) se vytvoří za 1 sekundu:

MooseMut   4509 Moose bez __PACKAGE__->meta->make_immutable
Moose     65941
Moo       78156
ManualA   99508 Manual array-based object, konstruktor vytvoří hash, aby zjistil, které atributy byly zadány
ManualH  191911 Manual hash-based object
XSAccHp  197371 Class::XSAccessor ale sub new {my $c=shift; bless {@_}, $c;}
XSAccAs  224108 Class::XSAccessor::Array, new bez parametrů, třeba volat settery
XSAccH   235633 Class::XSAccessor { constructor => 'new'}
--- následující implementace mají konstruktory, které berou jen hodnoty atributů, nikoli jména, tedy musejí být zadané ve správném pořadí
XSAccAf  324620 Class::XSAccessor::Array, sub fastnew {my $c=shift; bless [@_], $c;}
ManualAf 333188 Manual array-based object, sub fastnew {my $c=shift; bless [@_], $c;}
