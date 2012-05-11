use strict;
use warnings;

use MooseX::Types::DateTime;
use MooseX::Types::ISO8601 qw/
    ISO8601DateTimeTZStr
/;

use Test::More;

{
    diag "String with offset into datetime";
    my $datetime = MooseX::Types::DateTime::to_DateTime('2011-02-03T04:05:06+01:30');
    isa_ok($datetime, 'DateTime');
    is($datetime->offset, 3600+1800);
    is($datetime->datetime, "2011-02-03T04:05:06");
    is($datetime->nanosecond, 0);

    diag "DateTime into string";
    is(to_ISO8601DateTimeTZStr($datetime), "2011-02-03T04:05:06+01:30");
}

{
    diag "String with offset into datetime, with precision";
    my $datetime = MooseX::Types::DateTime::to_DateTime('2011-02-03T04:05:06.000000001+01:30');
    isa_ok($datetime, 'DateTime');
    is($datetime->offset, 3600+1800);
    is($datetime->datetime, "2011-02-03T04:05:06");
    is($datetime->nanosecond, '000000001');

    # XXX - currently we don't generate nanosecond offsets for compatibility.
    diag "DateTime into string";
    is(to_ISO8601DateTimeTZStr($datetime), "2011-02-03T04:05:06+01:30");
}

done_testing;
