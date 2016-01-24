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
    utreex     => "python -u python/bench_utreex.py $IN /tmp/out.conllu",
    perlCa     => "perl/bench.pl $IN /tmp/out.conllu Ca",
    perlCl     => "perl/bench.pl $IN /tmp/out.conllu Cl",
    perlClAa   => "perl/bench.pl $IN /tmp/out.conllu ClAa",
    perlClAl   => "perl/bench.pl $IN /tmp/out.conllu ClAl",
    perlA      => "perl/bench.pl $IN /tmp/out.conllu A",
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

my @HEADER = qw(TOTAL MAXMEM init load save iter iterF read write rehang remove add reorder);
my %IN_HEADER = map {$_ => 1} @HEADER;
my @experiments = @ARGV;
@experiments = @COMMANDS_NAMES if !@experiments;
@experiments = grep {$COMMANDS_HASH{$_} ? 1 : warn("WARN: No command for '$_' defined. Skipping.\n") && 0;} @experiments;

sub run {
    my ($command) = @_;
    my %t;
    @t{@HEADER} = map {'skip'} @HEADER;
    my $maxmem = 0;
    my $start = time;
    my $last = $start;
    # TODO Ideally we would like 'trap "" SIGINT' for the CHILDPROC,
    # but we need to know $pid of the process, we want to test with `ps -orss $pid`.
    my $pid = open(CHILDPROC, "$command |");
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
    my $total = sprintf '%.3f', time - $start;
    printf STDERR "%20s %9ss %10sMiB\n", 'TOTAL', $total, $maxmem;
    $t{TOTAL} = $total;
    $t{MAXMEM} = $maxmem;
    return \%t;
}

my %results;
sub run_all {
    warn "IN=$IN\n";
    foreach my $repeat (1..$REPEATS){
        foreach my $exp (@experiments){
            my $command = $COMMANDS_HASH{$exp};
            warn "Testing '$exp' ($command)\nrepeat#$repeat ...\n";
            $results{$exp}[$repeat] = run($command);
        }
    }
    return;
}

sub compute_statistics {
    my (@values) = @_;
    my $n = @values;
    return if !$n;
    my $mid = int $n/2;
    my ($min, $median, $max) = @values[0,$mid, -1];
    my ($sum, $variance) = (0, 0);
    $sum += $_ for @values;
    my $mean = $sum / $n;
    if ($n > 1) {
        $variance += ($_-$mean)**2 for @values;
        # Bessel's correction for sample variance
        $variance /= ($n - 1);
    }
    my $stdev = sqrt $variance;
    my $relstdev = $stdev / $mean;
    return {avg=>sprintf('%.3f', $mean), min=>$min, max=>$max, med=>$median, dev=>sprintf('%.3f', $stdev), rsd=>sprintf('%.3f', $relstdev)};
}

my $hostname = `hostname`;
sub print_table {
    my ($header, $data) = @_;
    my $table = Text::Table->new('experiment', map {(\'|',$_)} @$header);
    $table->load(@$data);
    my $rule = $table->rule(
        sub {my ($i, $len) = @_; $i ? ('-' x ($len-1)).':' : '-' x $len;},
        sub {my ($i, $len) = @_; '|';},
    );
    print "REPEATS=$REPEATS hostname=$hostname";
    print $table->title, $rule, $table->body, "\n";
    return;
}

sub print_results {
    my (@details, @summary);
    my $is_other = 0;
    foreach my $exp (@experiments){
        my $res = $results{$exp};
        next if !$res; # when Ctrl+C forced early print
        my $repeats = @$res - 1;
        my $first_rep = $res->[1];
        my @extra_tasks = grep {!$IN_HEADER{$_}} keys %$first_rep;
        $is_other = 1 if @extra_tasks;

        my %tmp;
        foreach my $key (keys %$first_rep){
            my @values = sort {$a <=> $b} grep {defined $_ && $_ ne 'skip'} map {$_->{$key}} @{$res}[1..$repeats];
            $tmp{$key} = compute_statistics(@values);
        }
        my $other = join ', ', map {"$_=" . $tmp{$_}{avg} } @extra_tasks;
        my @avg_times = map {$tmp{$_}{avg}} @HEADER;
        my $total_rsd = $tmp{TOTAL}{rsd};
        push @summary, [$exp, @avg_times, ($REPEATS>1 ? $total_rsd : ()), $other];

        push @details, [$exp];
        for my $stat_type (qw(avg min med max rsd)){
            my @times = map {$tmp{$_}{$stat_type}} @HEADER;
            my $other = join ', ', map {"$_=" . $tmp{$_}{$stat_type} } @extra_tasks;
            push @details, ["$exp-$stat_type", @times, $other];
        }
    }
    my @oth = $is_other ? ('other') : ();
    if ($REPEATS>1){
        print "\nDETAILS\n";
        print_table([@HEADER, @oth], \@details);
        print "SUMMARY\n";
    }
    unshift @oth, 'RSD' if $REPEATS>1;
    print_table([@HEADER, @oth], \@summary);
    return;
}

$SIG{INT} = sub {warn "\nCtrl+C (SIGINT) detected, printing statistics. Use Ctrl+\\ (SIGQUIT) to exit\n"; print_results;};
$SIG{QUIT} = sub {warn "\nEarly terminating because of SIGQUIT\n"; print_results; exit;};
#warn "Use Ctrl+C (SIGINT) for printing results and Ctrl+\\ (SIGQUIT) for early printing results and early termination.\n";

run_all();

print_results();
