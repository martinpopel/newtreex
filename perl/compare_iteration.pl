#!/usr/bin/env perl
use strict;
use warnings;
use Benchmark qw(:all);
use feature 'say';
use Data::Dumper;

my $SIZE = 30;
my ($DATA,$PREV,$NEXT) = (0,1,2);
my @array = map {["a$_", undef, undef]} (0..$SIZE);

for my $i (0..$SIZE){
    #$array[$i][$PREV] = $i > 0     ? $array[$i-1] : undef;
    $array[$i][$NEXT] = $array[$i+1];
}


#print Dumper \@array;


sub copy1 {
    return [@array];
}

sub copy2 {
    my @new = [@array];
    return @new;
}

sub ar_push {
    my @new;
    foreach my $node (@array){
        push @new, $node;
    }
    return @new;
}

sub li_push {
    my @new;
    my $node = $array[0];
    while ($node){
        push @new, $node;
        $node = $node->[$NEXT];
    }
    return @new;
}

cmpthese(
    -10,
    {
        copy1   => 'my @ar=copy1(); foreach my $n (@ar){}',
        copy2   => 'my @ar=copy2(); foreach my $n (@ar){}',
        ar_push => 'my @ar=ar_push(); foreach my $n (@ar){}',
        li_push => 'my @ar=li_push(); foreach my $n (@ar){}',
    }
);

__END__

cmpthese(
    -10,
    {
        copy1  => \&copy1,
        copy2  => \&copy2,
        ar_push => \&ar_push,
        li_push => \&li_push,
    }
);

SIZE=3        Rate li_push ar_push   copy2   copy1
li_push  530 636/s      --    -29%    -49%    -70%
ar_push  746 840/s     41%      --    -28%    -58%
copy2   1043 126/s     97%     40%      --    -41%
copy1   1771 422/s    234%    137%     70%      --

SIZE=30      Rate li_push ar_push   copy2   copy1
li_push  92 990/s      --    -35%    -76%    -79%
ar_push 144 156/s     55%      --    -62%    -68%
copy2   383 388/s    312%    166%      --    -14%
copy1   444 068/s    378%    208%     16%      --

SIZE=100     Rate li_push ar_push   copy2   copy1
li_push  29 259/s      --    -37%    -80%    -81%
ar_push  46 375/s     58%      --    -68%    -69%
copy2   144 455/s    394%    211%      --     -5%
copy1   151 593/s    418%    227%      5%      --


----
            Rate li_push ar_push   copy2   copy1
li_push  62 125/s      --    -24%    -79%    -82%
ar_push  81 920/s     32%      --    -72%    -76%
copy2   296 209/s    377%    262%      --    -14%
copy1   344 295/s    454%    320%     16%      --
