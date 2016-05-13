#!/usr/bin/env perl
use strict;
use warnings;
use Text::Table;
use Time::HiRes qw (time);
use Getopt::Long;
use Scalar::Util 'looks_like_number';

my $HELP = 0;
my $REPEATS = 10;
my $ITERS = 1;
my $IN = 'data/UD_Romanian/ro-ud-dev.conllu';

GetOptions(
    'help|h'      => \$HELP,
    'repeats|r=i' => \$REPEATS, # repetitions of the whole benchmark
    'n=i'         => \$ITERS, # how many files to process within one benchmark (so far, the same file again)
    'input|i=s'   => \$IN,
);

my $iter = '';
if ($ITERS > 1){
    $iter = "-n $ITERS";
}

# Don't use any shell metacharacters (e.g. redirections) in the commands below.
# That would result in executing shell subprocess and the memory consumption
# would be of that subprocess not of the main process we want to evaluate.
my @COMMANDS = (
    #dummy     => './dummy.pl',
    old_Treex  => "perl/bench_old-treex.pl $iter $IN /tmp/out.conllu",
    pytreex    => "python -u python/bench_pytreex.py $iter $IN /tmp/out.conllu",
    udapi     => "python -u python/bench_udapi.py $iter $IN /tmp/out.conllu",
    perl       => "perl/bench.pl $iter $IN /tmp/out.conllu",
    java       => "java -jar java/build/libs/udapi.jar $iter $IN /tmp/out.conllu",
    cpp_raw    => "cpp_raw/benchmark $iter $IN /tmp/out.conllu",
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

my @HEADER = qw(REAL CPU MAXMEM init load save iter iterF iterS iterN read write rehang remove add reorder exit);
my %IN_HEADER = map {$_ => 1} @HEADER;
my @experiments = @ARGV;
@experiments = @COMMANDS_NAMES if !@experiments;
@experiments = grep {$COMMANDS_HASH{$_} ? 1 : warn("WARN: No command for '$_' defined. Skipping.\n") && 0;} @experiments;

sub run {
    my ($command) = @_;
    my %t;
    my ($start, $last);
    # TODO Ideally we would like 'trap "" SIGINT' for the CHILDPROC,
    open(CHILDPROC, "/usr/bin/time -f '%e %U %S %M' ./printpid.sh $command 2>&1 |");
    chomp(my $pid = <CHILDPROC>);
    $start = $last = time;
    while(<CHILDPROC>){
        chomp;
        last if $_ eq 'end';
        my $now = time;
        my $mem = `ps -orss= $pid`;
        $mem = looks_like_number($mem) && $mem>0 ? sprintf('%.3fMiB', $mem/1024) : 'N/A';
        my $time = sprintf '%.3f', $now - $last;
        $t{$_} += $time;
        printf STDERR "%20s %9ss %13s\n", $_, $time, $mem;
        $last = $now;

    }
    my $timeoutput = <CHILDPROC>;
    my $now = time;
    my $total = sprintf '%.3f', $now - $start;
    my $time = sprintf '%.3f', $now - $last;
    $t{exit} = $time;
    printf STDERR "%20s %9ss %13s\n", 'exit', $time, 'N/A';
    chomp $timeoutput;
    my ($real, $user, $sys, $maxmem) = split / /, $timeoutput;
    my $cpu = $user + $sys;
    $maxmem = sprintf '%.3f', $maxmem/1024;
    print STDERR "REAL=$real ($total) CPU=$cpu ($user+$sys) maxmem=$maxmem MiB\n";
    $t{CPU} = $cpu;
    $t{REAL} = $real;
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
        my $total_rsd = $tmp{REAL}{rsd};
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
