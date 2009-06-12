use strict;
use warnings;

{
    package My::DateClass;
    use Moose;
    use MooseX::Types::ISO8601 qw/
        ISO8601DateStr
        ISO8601TimeStr
        ISO8601DateTimeStr
    /;
    use namespace::autoclean;

    foreach my $type (
        [date => ISO8601DateStr],
        [time => ISO8601TimeStr],
        [datetime => ISO8601DateTimeStr],
    ) {
        has $type->[0] => (
            isa => $type->[1], is => 'ro', required => 1, coerce => 1,
        );
    }
}

use Test::More tests => 4;
use Test::Exception;

lives_ok {
    my $i = My::DateClass->new(
        date => '2009-01-01',
        time => '12:34Z',
        datetime => '2009-01-01T12:34Z',
    );
    is( $i->date, '2009-01-01', 'Date unmangled' );
    is( $i->time, '12:34Z', 'Time unmangled' );
    is( $i->datetime, '2009-01-01T12:34Z', 'Datetime unmangled' );
} 'Date class instance';

