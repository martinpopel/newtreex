#!/usr/bin/env perl
use strict;
use warnings;
use Text::Table;
use Time::HiRes qw (time);
use Getopt::Long;

my $HELP = 0;
my $REPEATS = 10;
my $IN = 'data/UD_Romanian/ro-ud-dev.conllu';

GetOptions(
    'help|h'      => \$HELP,
    'repeats|r=i' => \$REPEATS,
    'input|i=s'   => \$IN,
);

# Don't use any shell metacharacters (e.g. redirections) in the commands below.
# That would result in executing shell subprocess and the memory consumption
# would be of that subprocess not of the main process we want to evaluate.
my @COMMANDS = (
    #dummy     => './dummy.pl',
    old_Treex  => "perl/bench_old-treex.pl $IN /tmp/out.conllu",
    pytreex    => "python -u python/bench_pytreex.py $IN /tmp/out.conllu",
    utreex     => "python -u python/bench_utreex.py $IN /tmp/out.conlluzz",
    perlCa     => "perl/bench.pl $IN /tmp/out.conllu Ca",
    perlCl     => "perl/bench.pl $IN /tmp/out.conllu Cl",
    java       => "java -jar java/build/libs/newtreex.jar $IN /tmp/out.conllu",
    cpp_raw    => "cpp_raw/benchmark $IN /tmp/out.conllu",
);
my %COMMANDS_HASH = @COMMANDS;
my @COMMANDS_NAMES;
for my $i (0 .. $#COMMANDS/2){
    push @COMMANDS_NAMES, $COMMANDS[$i*2];
}

if ($HELP){
    print "Usage $0 --input=data.conllu --repeats=5 [exp1 exp2 ...]\n";
    print "Possible experiments are: " . join(', ', @COMMANDS_NAMES). "\n";
    exit;
}

my @header = qw(TOTAL MAXMEM init load save iter iterF read write rehang remove add reorder);
my %in_header = map {$_ => 1} @header;
my @experiments = @ARGV;
if (!@experiments) {
    @experiments = @COMMANDS_NAMES;
}

sub run {
    my ($command) = @_;
    my %t;
    @t{@header} = map {'skip'} @header;
    my $maxmem = 0;
    my $start = time;
    my $last = $start;
    my $pid = open(CHILDPROC, "$command |");
    #warn "ps -ovsz,rss,size $pid\n";
    while(<CHILDPROC>){
        my $now = time;
        my $mem = `ps -orss $pid`;
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

sub compute_average {
    my (@r_stats) = @_;
    my ($first_stat) = @r_stats;
    my (%minstat, %maxstat, %medstat, %devstat, %rsdstat);
    foreach my $key (keys %$first_stat){
        my @values = sort {$a <=> $b} grep {defined $_ && $_ ne 'skip'} map {$_->{$key}} @r_stats;
        my $mid = int @values/2;
        my ($min, $median, $max) = @values[0,$mid, -1];
        my ($sum, $sqsum) = (0, 0);
        for (@values){
            $sum += $_;
            $sqsum += $_**2;
        }
        my $mean = $sum / @values;
        my $stdev = sqrt( ($sqsum/@values) - ($mean**2));
        my $relstdev = $stdev / $mean;
        if ($sum == 0 && (!defined $first_stat->{$key} or $first_stat->{$key} eq 'skip')){
        } else {
            $first_stat->{$key} = sprintf '%.3f', $mean;
            $minstat{$key} = $min;
            $maxstat{$key} = $max;
            $medstat{$key} = $median;
            $devstat{$key} = sprintf '%.3f', $stdev;
            $rsdstat{$key} = sprintf '%.3f', $relstdev;
        }
    }
    return ($first_stat, \%minstat, \%maxstat, \%medstat, \%devstat, \%rsdstat);
}

warn "IN=$IN\n";
my @results;
my $is_other = 0;
EXP:
foreach my $exp (@experiments){
    my $command = $COMMANDS_HASH{$exp};
    if (!defined $command){
        warn "No command for '$exp' defined. Skipping.\n";
        next EXP;
    }
    my @r_stats;
    foreach my $repeat (1..$REPEATS){
        warn "Testing '$exp' ($command)\nrepeat#$repeat ...\n";
        push @r_stats, run($command);
    }
    my ($stats, $min, $max, $med, $dev, $rsd) = compute_average(@r_stats);
    my $other = join ', ', map {$in_header{$_} ? () : "$_=".$stats->{$_} } keys %$stats;
    $is_other = 1 if $other;
    push @results, ["$exp-avg", @$stats{@header}, $other];
    push @results, ["$exp-min", @$min{@header}, ''];
    push @results, ["$exp-med", @$med{@header}, ''];
    push @results, ["$exp-max", @$max{@header}, ''];
    #push @results, ["$exp-dev", @$dev{@header}, ''];
    push @results, ["$exp-rsd", @$dev{@header}, ''];
}

if (!$is_other){
    foreach my $res (@results){
        pop @$res;
    }
} else {
    push @header, 'other';
}

my $table = Text::Table->new('experiment', map {(\'|',$_)} @header);
$table->load(@results);
my $rule = $table->rule(
    sub {my ($i, $len) = @_; $i ? ('-' x ($len-1)).':' : '-' x $len;},
    sub {my ($i, $len) = @_; '|';},
);
print $table->title, $rule, $table->body, "\n";
