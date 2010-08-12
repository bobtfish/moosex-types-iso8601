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
    is($i->date_duration, 'PT00Y40M02D',
        'Date duration number coerced');
    is($i->datetime_duration, 'P00Y28M02DT00H28M16S',
        'DateTime duration number coerced');
} 'Create with Numeric duration';

use MooseX::Types::ISO8601 qw/
        ISO8601TimeDurationStr
        ISO8601DateDurationStr
        ISO8601DateTimeDurationStr
    /;

ok is_ISO8601TimeDurationStr('PT0H15M.507S'), 'Non integer number of seconds';
ok is_ISO8601DateTimeDurationStr('P0Y1M1DT0H15M.507S');

done_testing;

