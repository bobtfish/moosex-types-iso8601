use strict;
use warnings;
use Test::More;
use Test::Exception;

{
    package MyClass;
    use Moose;
    use MooseX::Types::ISO8601 qw/
        ISO8601TimeDurationStr
        ISO8601DateDurationStr
        ISO8601DateTimeDurationStr
    /;
    use namespace::autoclean;

    foreach my $attr (
            [time_duration => ISO8601TimeDurationStr],
            [date_duration => ISO8601DateDurationStr],
            [datetime_duration => ISO8601DateTimeDurationStr],
    ) {
        has $attr->[0] => ( 
            isa => $attr->[1], coerce => 1, required => 1, is => 'ro'
        );
    }
}

lives_ok {
    my ($time_duration, $date_duration, $datetime_duration)
        = ('PT00H00M00S', 'PT01Y01M01D', 'P01Y01M01DT00H00M00S');
    my $i = MyClass->new(
        time_duration => $time_duration,
        date_duration => $date_duration,
        datetime_duration => $datetime_duration,
    );
    is($i->time_duration, $time_duration,
        'Time duration string unmangled');
    is($i->date_duration, $date_duration,
        'Date duration string unmangled');
    is($i->datetime_duration, $datetime_duration,
        'DateTime duration string unmangled');
} 'Create with string duration';

lives_ok {
    my $i = MyClass->new(
        time_duration => 60,
        date_duration => 60000000000,
        datetime_duration => 6666666666666666666666,
    );
    is($i->time_duration, 'PT00H01M00S',
        'Time duration number coerced');
    is($i->date_duration, 'PT00Y00M02D',
        'Date duration number coerced');
    is($i->datetime_duration, 'P00Y00M02DT00H28M16S',
        'DateTime duration number coerced');
} 'Create with Numeric duration';

use MooseX::Types::ISO8601 qw/
        ISO8601TimeDurationStr
        ISO8601DateDurationStr
        ISO8601DateTimeDurationStr
    /;
use MooseX::Types::DateTime qw/ Duration /;

# Time durations
foreach my $tp (
        ['PT0H15M.507S', 'PT00H15M00S'], # Note pairs, as we normalise whilst
                                         # roundtripping..
    ) {
    my $t = $tp->[0];
    my $ret = $tp->[1] || $t;
    ok is_ISO8601TimeDurationStr($t), $t . ' is an ISO8601TimeDurationStr';
    ok !is_ISO8601DateTimeDurationStr($t), $t . ' is not an ISO8601DateTimeDurationStr';
    ok !is_ISO8601DateDurationStr($t), $t . ' is not an ISO8601DateDurationStr';
    my $dt = to_Duration($t);
    ok $dt, 'Appears to coerce to DateTime::Duration';
    isa_ok $dt, 'DateTime::Duration';
    is to_ISO8601TimeDurationStr($dt), $ret, $t . ' round trips';
}

# DateTime durations
foreach my $tp (
        ['P00Y08M02DT0H15M.507S', 'P00Y08M02DT00H15M00S'],
    ) {
    my $t = $tp->[0];
    my $ret = $tp->[1] || $t;
    ok !is_ISO8601TimeDurationStr($t), $t . ' is no an ISO8601TimeDurationStr';
    ok is_ISO8601DateTimeDurationStr($t), $t . ' is an ISO8601DateTimeDurationStr';
    ok !is_ISO8601DateDurationStr($t), $t . ' is not an ISO8601DateDurationStr';
    my $dt = to_Duration($t);
    ok $dt, 'Appears to coerce to DateTime::Duration';
    isa_ok $dt, 'DateTime::Duration';
    is to_ISO8601DateTimeDurationStr($dt), $ret, $t . ' round trips';
}

# Date durations
foreach my $tp (
        ['PT02Y08M02D'],
    ) {
    my $t = $tp->[0];
    my $ret = $tp->[1] || $t;
    ok !is_ISO8601TimeDurationStr($t), $t . ' is no an ISO8601TimeDurationStr';
    ok !is_ISO8601DateTimeDurationStr($t), $t . ' not is an ISO8601DateTimeDurationStr';
    ok is_ISO8601DateDurationStr($t), $t . ' is an ISO8601DateDurationStr';
    my $dt = to_Duration($t);
    ok $dt, 'Appears to coerce to DateTime::Duration';
    isa_ok $dt, 'DateTime::Duration';
    is to_ISO8601DateDurationStr($dt), $ret, $t . ' round trips';
}

done_testing;

