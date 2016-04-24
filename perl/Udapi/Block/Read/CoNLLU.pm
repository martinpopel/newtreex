package Udapi::Block::Read::CoNLLU;
use Udapi::Core::Common;
extends 'Udapi::Core::Block';
#extends 'Udapi::Core::DocumentReader';

has_ro zone => (
  default => 'keep',
  doc => 'What should be the zone of the new trees. Default="keep" means keep the zone saved in the CoNLLU file or use "und".'
);

sub process_document {
    my ($self, $doc) = @_;

    # TODO $self->from
    #open my $fh, '<:utf8', $conllu_file;
    my $conllu_file = '/dev/stdin';
    my $fh = \*STDIN;
    my $zone = $self->zone;

    while (my $root = $doc->_read_conllu_tree_from_fh($fh, $conllu_file)){
        if ($zone ne 'keep'){
            $root->_set_zone($zone);
        }
        my $bundle = $doc->create_bundle();
        $bundle->add_tree($root);
    }

    return;
}

1;