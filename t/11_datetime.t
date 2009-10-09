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

use Test::More;
use Test::Exception;

use DateTime;

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

lives_ok {
    my $date = DateTime->now;
    my $i = My::DateClass->new(
        map { $_ => $date } qw/date time datetime/
    );
    ok !ref($_) for map { $i->$_ } qw/date time datetime/;
    like( $i->date, qr/\d{4}-\d{2}-\d{2}/, 'Date mangled' );
    like( $i->time, qr/\d{2}:\d{2}Z/, 'Time mangled' );
    like( $i->datetime, qr/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}Z/, 'Datetime mangled' );
} 'Date class instance with coercion';

done_testing;

