#!/usr/bin/env perl
use strict;
use warnings;
STDOUT->autoflush(1);
use Treex::Block::Read::CoNLLU;
use Treex::Block::Write::CoNLLU;
use Treex::Core::Log;
Treex::Core::Log::log_set_error_level('WARN');
my ($in_conllu, $out_conllu) = @ARGV;

print "init\n";
my $reader = Treex::Block::Read::CoNLLU->new({from=>$in_conllu});
my $doc = $reader->next_document();
print "load\n";
my $writer = Treex::Block::Write::CoNLLU->new({to=>$out_conllu});
$writer->process_document($doc);
print "save\n";

