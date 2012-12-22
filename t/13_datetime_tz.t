use strict;
use warnings;

use MooseX::Types::DateTime;
use MooseX::Types::ISO8601 qw/
    ISO8601DateTimeTZStr
/;

use Test::More tests => 5;
use Test::Deep;
use Test::NoWarnings 1.04 ':early';

{
    note "String with offset into datetime";
    my $datetime = MooseX::Types::DateTime::to_DateTime('2011-02-03T04:05:06+01:30');
    cmp_deeply(
        $datetime,
        all(
            isa('DateTime'),
            methods(
                offset => 3600+1800,
                datetime => "2011-02-03T04:05:06",
                nanosecond => 0,
            ),
        ),
    );

    note "DateTime into string";
    is(to_ISO8601DateTimeTZStr($datetime), "2011-02-03T04:05:06+01:30");
}

{
    note "String with offset into datetime, with precision";
    my $datetime = MooseX::Types::DateTime::to_DateTime('2011-02-03T04:05:06.000000001+01:30');
    cmp_deeply(
        $datetime,
        all(
            isa('DateTime'),
            methods(
                offset => 3600+1800,
                datetime => "2011-02-03T04:05:06",
                nanosecond => '000000001',
            ),
        ),
    );

    # XXX - currently we don't generate nanosecond offsets for compatibility.
    note "DateTime into string";
    is(to_ISO8601DateTimeTZStr($datetime), "2011-02-03T04:05:06+01:30");
}

