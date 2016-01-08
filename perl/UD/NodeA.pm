package UD::NodeA;
use strict;
use warnings;
use Class::XSAccessor::Array {
    constructor => 'new',
    lvalue_accessors => {
        form => 0,
        lemma => 1,
        upostag => 2,
        xpostag => 3,
        deprel => 4,
        _parent => 5,
        _children => 6,
    },
};


1;