use strict;
use warnings;

use MooseX::Types::DateTime;
use MooseX::Types::ISO8601 qw/
    ISO8601DateStr
    ISO8601TimeStr
    ISO8601DateTimeStr
/;

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
        time => '12:34:29Z',
        datetime => '2009-01-01T12:34:29Z',
    );
    is( $i->date, '2009-01-01', 'Date unmangled' );
    is( $i->time, '12:34:29Z', 'Time unmangled' );
    is( $i->datetime, '2009-01-01T12:34:29Z', 'Datetime unmangled' );
} 'Date class instance';

#lives_ok {
    my $date = DateTime->now;
    my $i = My::DateClass->new(
        map { $_ => $date } qw/date time datetime/
    );
    ok !ref($_) for map { $i->$_ } qw/date time datetime/;
    like( $i->date, qr/\d{4}-\d{2}-\d{2}/, 'Date mangled' );
    like( $i->time, qr/\d{2}:\d{2}Z/, 'Time mangled' );
    like( $i->datetime, qr/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/, 'Datetime mangled' );
#} 'Date class instance with coercion';

{
    my $datetime = MooseX::Types::DateTime::to_DateTime('2011-01-04T18:14:15.1234Z');
    isa_ok($datetime, 'DateTime');
    is($datetime->year, 2011);
    is($datetime->month, 1);
    is($datetime->day, 4);
    is($datetime->hour, 18);
    is($datetime->minute, 14);
    is($datetime->second, 15);
    is($datetime->nanosecond, 123400000);

    my $date = MooseX::Types::DateTime::to_DateTime('2011-01-04');
    isa_ok($date, 'DateTime');
    is($date->year, 2011);
    is($date->month, 1);
    is($date->day, 4);

# Cannot work as DateTime requires a year
#    my $time = MooseX::Types::DateTime::to_DateTime('18:14:15.1234Z');
#    isa_ok($time, 'DateTime');
#    is($time->hour, 18);
#    is($time->minute, 14);
#    is($time->second, 12);
#    is($time->nanosecond, 123400000);


}

{
    local $TODO = "UTC offsets are not yet supported";
    ok is_ISO8601DateTimeStr('2011-12-19T15:03:56+01:00');
    ok is_ISO8601DateTimeStr('2011-12-19T15:03:56-01:00');
    ok is_ISO8601DateTimeStr('2011-12-19T15:03:56+01:30');
    ok is_ISO8601DateTimeStr('2011-12-19T15:03:56-01:30');
    ok is_ISO8601DateTimeStr('2011-12-19T15:03:56+01');
    ok is_ISO8601DateTimeStr('2011-12-19T15:03:56-01');

    ok is_ISO8601DateTimeStr('15:03:56+01:00');
    ok is_ISO8601DateTimeStr('15:03:56-01:00');
    ok is_ISO8601DateTimeStr('15:03:56+01:30');
    ok is_ISO8601DateTimeStr('15:03:56-01:30');
    ok is_ISO8601DateTimeStr('15:03:56+01');
    ok is_ISO8601DateTimeStr('15:03:56-01');
}

done_testing;
