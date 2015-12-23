#!/usr/bin/env perl
use strict;
use warnings;
use Text::Table;
use Time::HiRes qw (time);

my @header = qw(TOTAL MAXMEM init load save iter iterF read write rehang remove add reorder);
my %in_header = map {$_ => 1} @header;
my $IN = $ARGV[0] || 'data/UD_Romanian/ro-ud-dev.conllu';

# Don't use any shell metacharacters (e.g. redirections) in the commands below.
# That would result in executing shell subprocess and the memory consumption
# would be of that subprocess not of the main process we want to evaluate.
my @experiments = (
    #[dummy    => './dummy.pl'],
    [old_Treex => "perl/bench_old-treex.pl $IN /tmp/out.conllu"],
    [pytreex   => "python -u python/bench_pytreex.py $IN /tmp/out.conllu"],
    [cpp_raw    => "cpp_raw/benchmark $IN /tmp/out.conllu"],
    [perl_plain => "perl/bench_plain.pl $IN /tmp/out.conllu"],
);

sub run {
    my ($command) = @_;
    my %t;
    @t{@header} = map {0} @header;
    my $maxmem = 0;
    my $start = time;
    my $last = $start;
    my $pid = open(CHILDPROC, "$command |");
    #warn "ps -ovsz,rss,size $pid\n";
    while(<CHILDPROC>){
        my $now = time;
        my $mem = `ps -ovsz $pid`;
        $mem =~ s/[^\d]//g;
        $mem = sprintf "%.3f", $mem/1024;
        $maxmem = $mem if $mem > $maxmem;
        chomp;
        my $time = sprintf '%.3f', $now - $last;
        $t{$_} = $time;
        printf STDERR "%20s %9ss %10sMiB\n", $_, $time, $mem;
        $last = $now;
    }
    $t{TOTAL} = sprintf '%.3f', time - $start;
    $t{MAXMEM} = $maxmem;
    return \%t;
}

warn "IN=$IN\n";
my @results;
foreach my $exp (@experiments){
    my ($name, $command) = @$exp;
    warn "Testing '$name' ($command)...\n";
    my $stats = run($command);
    my $other = join ', ', map {$in_header{$_} ? () : "$_=".$stats->{$_} } keys %$stats;
    push @results, [$name, @$stats{@header}, $other];
}

my $table = Text::Table->new('experiment', map {(\'|',$_)} @header, 'other');
$table->load(@results);
my $rule = $table->rule(
    sub {my ($i, $len) = @_; $i ? ('-' x ($len-1)).':' : '-' x $len;},
    sub {my ($i, $len) = @_; '|';},
);
print $table->title, $rule, $table->body, "\n";
