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
    foreach my $date qw( 2012-01-12 20120112 ) {
        foreach my $time qw( 17:05:00 17:05:00.0001 17:05:00,0001 170500 170500,0001 170500.0001 ) {
            foreach my $zone qw( +0000 +00:00 +00 Z ) {
                ok is_ISO8601DateTimeStr( to_ISO8601DateTimeStr($date.'T'.$time.$zone) ), $date.'T'.$time.$zone;
            }
            ok !is_ISO8601DateTimeStr( to_ISO8601DateTimeStr($date.'T'.$time) ), $date.'T'.$time;
        }
    }
    
    foreach my $date qw( 2012-01-12 20120112 ) {
        ok is_ISO8601DateTimeStr( to_ISO8601DateTimeStr($date) ), $date;
    }
    
    foreach my $time qw( 17:05:00 17:05:00.0001 17:05:00,0001 170500 170500,0001 170500.0001 ) {
        foreach my $zone qw( +0000 +00:00 +00 Z ) {
            ok is_ISO8601DateTimeStr( to_ISO8601DateTimeStr($time.$zone) ), $time.$zone;
        }
        ok !is_ISO8601DateTimeStr( to_ISO8601DateTimeStr($time) ), $time;
    }
}

{
    my $datetime = DateTime->new(
        year => 2011,
        month => 1,
        day => 1,
        hour => 0,
        minute => 0,
        second => 0,
        time_zone => 'Asia/Taipei'
    );
    dies_ok { to_ISO8601DateTimeStr($datetime) };

    $datetime->set_time_zone('UTC');
    lives_ok { to_ISO8601DateTimeStr($datetime) };
}
{
    # You must say Zulu, or we cannot make sense of the date.
    ok  is_ISO8601DateTimeStr('2011-12-19T15:03:56Z');
    ok !is_ISO8601DateTimeStr('2011-12-19T15:03:56');
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

{
    is(to_ISO8601DateTimeStr(5), '1970-01-01T00:00:05Z');
    is_ISO8601DateTimeStr(to_ISO8601DateTimeStr(time));
}

done_testing;
