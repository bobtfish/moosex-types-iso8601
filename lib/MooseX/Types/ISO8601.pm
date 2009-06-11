package MooseX::Types::ISO8601;
use Moose ();
use DateTime;
use DateTime::Format::Duration;
use MooseX::Types::DateTime qw(Duration);
use MooseX::Types::Moose qw/Str Num/;
use namespace::autoclean;

use MooseX::Types -declare => [qw(
    ISO8601Str
    ISO8601DurationStr
)];

subtype ISO8601DurationStr,
    as Str,
    where { /^PT\d{2}H\d{2}M\d{2}S$/ };

my $_Duration_coerce_to_ISO8601 = sub {
    DateTime::Format::Duration->new(normalize => 1, pattern   => 'PT%02HH%02MM%02SS' )->format_duration( shift );
};

coerce ISO8601DurationStr,
    from Duration,
        via { $_Duration_coerce_to_ISO8601->($_) },
    from Num,
        via { $_Duration_coerce_to_ISO8601->(to_Duration($_)) };
        # FIXME - should be able to say => via_type 'DateTime::Duration';
        # nothingmuch promised to make that syntax happen if I got
        # Stevan to approve and/or wrote a test case.

1;

