package MooseX::Types::ISO8601;
use Moose ();
use DateTime;
use DateTime::Format::Duration;
use MooseX::Types::DateTime qw(Duration DateTime);
use MooseX::Types::Moose qw/Str Num/;
use List::MoreUtils qw/ zip /;
use namespace::autoclean;

our $VERSION = "0.02";

use MooseX::Types -declare => [qw(
    ISO8601DateStr
    ISO8601TimeStr
    ISO8601DateTimeStr
    ISO8601TimeDurationStr
    ISO8601DateDurationStr
    ISO8601DateTimeDurationStr
)];

subtype ISO8601DateStr,
    as Str,
    where { /^\d{4}-\d{2}-\d{2}$/ };

subtype ISO8601TimeStr,
    as Str,
    where { /^\d{2}:\d{2}:\d{2}Z?$/ };

subtype ISO8601DateTimeStr,
    as Str,
    where { /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z?$/ };

my $timeduration_re = qr/^PT(?:(\d{1,2})H)?(\d{1,2})M(\d{0,2})(?:\.(\d+))?S$/;
subtype ISO8601TimeDurationStr,
    as Str,
    where { /$timeduration_re/ };

my $dateduration_re = qr/^PT(\d+)Y(\d{1,2})M(\d{1,2})D$/;
subtype ISO8601DateDurationStr,
    as Str,
    where { /$dateduration_re/ };

my $datetimeduration_re = qr/^P(\d+)Y(\d{1,2})M(\d{1,2})DT(\d{1,2})H(\d{1,2})M(\d{0,2})(?:\.(\d+))?S$/;
subtype ISO8601DateTimeDurationStr,
    as Str,
    where { /$datetimeduration_re/ };

{
    my %coerce = (
        ISO8601TimeDurationStr, 'PT%02HH%02MM%02SS',
        ISO8601DateDurationStr, 'PT%02YY%02mM%02DD',
        ISO8601DateTimeDurationStr, 'P%02YY%02mM%02DDT%02HH%02MM%02SS',
    );

    foreach my $type_name (keys %coerce) {

        my $code = sub {
            DateTime::Format::Duration->new(
                normalize => 1,
                pattern   => $coerce{$type_name},
            )
            ->format_duration( shift );
        };

        coerce $type_name,
        from Duration,
            via { $code->($_) },
        from Num,
            via { $code->(to_Duration($_)) };
            # FIXME - should be able to say => via_type 'DateTime::Duration';
            # nothingmuch promised to make that syntax happen if I got
            # Stevan to approve and/or wrote a test case.
    }
}

{
    my %coerce = (
        ISO8601TimeStr, sub { $_[0]->hms(':') . 'Z' },
        ISO8601DateStr, sub { $_[0]->ymd('-') },
        ISO8601DateTimeStr, sub { $_[0]->ymd('-') . 'T' . $_[0]->hms(':') . 'Z' },
    );

    foreach my $type_name (keys %coerce) {

        coerce $type_name,
        from DateTime,
            via { $coerce{$type_name}->($_) },
        from Num,
            via { $coerce{$type_name}->(DateTime->from_epoch( epoch => $_ )) };
    }
}

{
    my @datefields = qw/ years months days /;
    my @timefields = qw/ hours minutes seconds nanoseconds /;
    my @datetimefields = (@datefields, @timefields);
    coerce Duration,
        from ISO8601DateTimeDurationStr,
            via {
                my @fields = $_ =~ /$datetimeduration_re/;
                if ($fields[6]) {
                    my $missing = 9 - length($fields[6]);
                    $fields[6] .= "0" x $missing;
                }
                else {
                    $fields[6] = 0;
                }
                DateTime::Duration->new( zip @datetimefields, @fields );
            },
        from ISO8601DateDurationStr,
            via {
                my @fields = $_ =~ /$dateduration_re/;
                DateTime::Duration->new( zip @datefields, @fields );
            },
        from ISO8601TimeDurationStr,
            via {
                my @fields = $_ =~ /$timeduration_re/;
                $fields[0] ||= 0;
                if ($fields[3]) {
                    my $missing = 9 - length($fields[3]);
                    $fields[3] .= "0" x $missing;
                }
                else {
                    $fields[3] = 0;
                }
                DateTime::Duration->new( zip @timefields, @fields );
            };
}

1;

__END__

=head1 NAME

MooseX::Types::ISO8601 - ISO8601 date and duration string type constraints and coercions for Moose

=head1 SYNOPSIS

    use MooseX::Types::ISO8601 qw/
        ISO8601TimeDurationStr
    /;

    has duration => (
        isa => ISO8601TimeDurationStr,
        is => 'ro',
        coerce => 1,
    );

    Class->new( duration => 60 ); # 60s => PT00H01M00S
    Class->new( duration => DateTime::Duration->new(%args) )

=head1 DESCRIPTION

This module packages several L<TypeConstraints|Moose::Util::TypeConstraints> with
coercions for working with ISO8601 date strings and the DateTime suite of objects.

=head1 DATE CONSTRAINTS

=head2 ISO8601DateStr

An ISO8601 date string. E.g. C<< 2009-06-11 >>

=head2 ISO8601TimeStr

An ISO8601 time string. E.g. C<< 12:06:34Z >>

=head2 ISO8601DateTimeStr

An ISO8601 combined datetime string. E.g. C<< 2009-06-11T12:06:34Z >>

=head2 COERCIONS

The date types will coerce from:

=over

=item C< Num >

The number is treated as a time in seconds since the unix epoch

=item C< DateTime >

The duration represented as a L<DateTime> object.

=back

=head1 DURATION CONSTRAINTS

=head2 ISO8601DateDurationStr

An ISO8601 date duration string. E.g. C<< P01Y01M01D >>

=head2 ISO8601TimeDurationStr

An ISO8601 time duration string. E.g. C<< PT01H01M01S >>

=head2 ISO8601DateTimeDurationStr

An ISO8601 comboined date and time duration string. E.g. C<< P01Y01M01DT01H01M01S >>

=head2 COERCIONS

The duration types will coerce from:

=over

=item C< Num >

The number is treated as a time in seconds

=item C< DateTime::Duration >

The duration represented as a L<DateTime::Duration> object.

=back

The duration types will coerce to:

=over

=item C< Duration >

A L<DateTime::Duration>, i.e. the C< Duration > constraint from
L<MooseX::Types::DateTime>.

=back

=head1 SEE ALSO

=over

=item *

L<MooseX::Types::DateTime>

=item *

L<DateTime>

=item *

L<DateTime::Duration>

=item *

L<DateTime::Format::Duration>

=back

=head1 VERSION CONTROL

    http://github.com/bobtfish/moosex-types-iso8601/tree/master

Patches are welcome.

=head1 SEE ALSO

=over

=item *

http://en.wikipedia.org/wiki/ISO_8601

=item *

http://dotat.at/tmp/ISO_8601-2004_E.pdf

=back

=head1 BUGS

Probably full of them, patches are very welcome.

Specifically missing features:

=over

=item No timezone support - all times are assumed UTC

=item No week number type

=item Tests are rubbish.

=back

=head1 AUTHOR

Tomas Doran (t0m) C<< <bobtfish@bobtfish.net> >>

The development of this code was sponsored by my employer L<http://www.state51.co.uk>.

=head1 COPYRIGHT

    Copyright (c) 2009 Tomas Doran. Some rights reserved.
    This program is free software; you can redistribute
    it and/or modify it under the same terms as Perl itself.

=cut

