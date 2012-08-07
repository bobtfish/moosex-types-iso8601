package MooseX::Types::ISO8601;
use Moose ();
use aliased DateTime => 'DT';
use DateTime::Format::Duration;
use MooseX::Types::DateTime qw(Duration DateTime);
use MooseX::Types::Moose qw/Str Num/;
use List::MoreUtils qw/ zip /;
use Scalar::Util qw/ looks_like_number /;
use Try::Tiny qw/try/;

our $MYSQL;
BEGIN {
    $MYSQL = 0;
    if (try { Class::MOP::load_class('MooseX::Types::DateTime::MySQL') }) {
            MooseX::Types::DateTime::MySQL->import(qw/ MySQLDateTime /);
            $MYSQL = 1;
    }
}
use namespace::autoclean;

our $VERSION = "0.11";

use MooseX::Types -declare => [qw(
    ISO8601DateStr
    ISO8601TimeStr
    ISO8601DateTimeStr
    ISO8601DateTimeTZStr
    ISO8601TimeDurationStr
    ISO8601DateDurationStr
    ISO8601DateTimeDurationStr
    ISO8601DateTimeDurationStr
)];

my $date_re = qr/^(\d{4})-(\d{2})-(\d{2})$/;
subtype ISO8601DateStr,
    as Str,
    where { /$date_re/ };

my $time_re = qr/^(\d{2}):(\d{2}):(\d{2})(?:(?:\.|,)(\d+))?Z?$/;
subtype ISO8601TimeStr,
    as Str,
    where { /$time_re/ };

my $datetime_re = qr/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:(?:\.|,)(\d+))?Z?$/;
subtype ISO8601DateTimeStr,
    as Str,
    where { /$datetime_re/ };

my $datetimetz_re = qr/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:(?:\.|,)(\d+))?((?:\+|-)\d\d:\d\d)$/;
 subtype ISO8601DateTimeTZStr,
    as Str,
    where { /$datetimetz_re/ };

# TODO: According to ISO 8601:2004(E), the lowest order components may be
# omitted, if less accuracy is required.  The lowest component may also have
# a decimal fraction.  We don't support these both together, you may only have
# a fraction on the seconds component.

my $timeduration_re = qr/^PT(?:(\d{1,2})H)?(?:(\d{1,2})M)?(?:(\d{0,2})(?:(?:\.|,)(\d+))?S)?$/;
subtype ISO8601TimeDurationStr,
    as Str,
    where { grep { looks_like_number($_) } /$timeduration_re/; };

my $dateduration_re = qr/^P(?:(\d+)Y)?(?:(\d{1,2})M)?(?:(\d{1,2})D)?$/;
subtype ISO8601DateDurationStr,
    as Str,
    where { grep { looks_like_number($_) } /$dateduration_re/ };

my $datetimeduration_re = qr/^P(?:(\d+)Y)?(?:(\d{1,2})M)?(?:(\d{1,2})D)?(?:T(?:(\d{1,2})H)?(?:(\d{1,2})M)?(?:(\d{0,2})(?:(?:\.|,)(\d+))?)S)?$/;
subtype ISO8601DateTimeDurationStr,
    as Str,
    where { grep { looks_like_number($_) } /$datetimeduration_re/ };

{
    my %coerce = (
        ISO8601TimeDurationStr, 'PT%02HH%02MM%02S.%06NS',
        ISO8601DateDurationStr, 'P%02YY%02mM%02dD',
        ISO8601DateTimeDurationStr, 'P%02YY%02mM%02dDT%02HH%02MM%02S.%06NS',
    );

    foreach my $type_name (keys %coerce) {

        my $code = sub {
            my $str = DateTime::Format::Duration->new(
                normalize => 1,
                pattern   => $coerce{$type_name},
            )
            ->format_duration( shift );

            # Remove fractional seconds if there aren't any.
            $str =~ s/\.0+S$/S/;
            return $str;
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
        ISO8601TimeStr, sub { die "cannot coerce non-UTC time" if ($_[0]->offset!=0); $_[0]->hms(':') . 'Z' },
        ISO8601DateStr, sub { $_[0]->ymd('-') },
        ISO8601DateTimeStr, sub { die "cannot coerce non-UTC time" if ($_[0]->offset!=0); $_[0]->ymd('-') . 'T' . $_[0]->hms(':') . 'Z' },
        ISO8601DateTimeTZStr, sub {
            DateTime::TimeZone->offset_as_string($_[0]->offset) =~ /(.\d\d)(\d\d)/;
            $_[0]->ymd('-') . 'T' . $_[0]->hms(':') . "$1:$2"
        },
    );

    foreach my $type_name (keys %coerce) {

        coerce $type_name,
        from DateTime,
            via { $coerce{$type_name}->($_) },
        from Num,
            via { $coerce{$type_name}->(DT->from_epoch( epoch => $_ )) };

        if ($MYSQL) {
            coerce $type_name, from MySQLDateTime(),
            via { $coerce{$type_name}->(to_DateTime($_)) };
        }
    }
}

{
    my %coerce = (
        ISO8601TimeStr, sub {
            $_ =~ s/^(\d\d) \:? (\d\d) \:? (\d\d([\.\,]\d+)?) (([+-]00\:?(00)?)|Z) $
                    /${1}:${2}:${3}Z/x;
            return $_;
        },
        ISO8601DateStr, sub {
            $_ =~ s/^(\d{4}) \-? (\d\d) \-? (\d\d)$
                    /${1}-${2}-${3}/x;
            return $_;
        },
        ISO8601DateTimeStr, sub {
            $_ =~ s/^(\d{4}) \-? (\d\d) \-? (\d\d)
                    T(\d\d) \:? (\d\d) \:? (\d\d([\.\,]\d+)?)
                    (([+-]00\:?(00)?)|Z)$
                    /${1}-${2}-${3}T${4}:${5}:${6}Z/x;
            return $_;
        },
    );

    foreach my $type_name (keys %coerce) {

        coerce $type_name,
        from Str,
            via { $coerce{$type_name}->($_) },
    }
}

{
    my @datefields = qw/ years months days /;
    my @timefields = qw/ hours minutes seconds nanoseconds /;
    my @datetimefields = (@datefields, @timefields);
    coerce Duration,
        from ISO8601DateTimeDurationStr,
            via {
                my @fields = map { $_ || 0 } $_ =~ /$datetimeduration_re/;
                if ($fields[6]) {
                    my $missing = 9 - length($fields[6]);
                    $fields[6] .= "0" x $missing;
                }
                DateTime::Duration->new( zip @datetimefields, @fields );
            },
        from ISO8601DateDurationStr,
            via {
                my @fields = map { $_ || 0 } $_ =~ /$dateduration_re/;
                DateTime::Duration->new( zip @datefields, @fields );
            },
        from ISO8601TimeDurationStr,
            via {
                my @fields = map { $_ || 0 } $_ =~ /$timeduration_re/;
                if ($fields[3]) {
                    my $missing = 9 - length($fields[3]);
                    $fields[3] .= "0" x $missing;
                }
                DateTime::Duration->new( zip @timefields, @fields );
            };
}

{
    my @datefields = qw/ year month day /;
    my @timefields = qw/ hour minute second nanosecond /;
    my @datetimefields = (@datefields, @timefields);
    my @datetimetzfields = (@datefields, @timefields, "time_zone");
    coerce DateTime,
        from ISO8601DateTimeStr,
            via {
                my @fields = map { $_ || 0 } $_ =~ /$datetime_re/;
                if ($fields[6]) {
                    my $missing = 9 - length($fields[6]);
                    $fields[6] .= "0" x $missing;
                }
                DT->new( zip(@datetimefields, @fields), time_zone => 'UTC' );
            },
        from ISO8601DateTimeTZStr,
            via {
                my @fields = map { $_ || 0 } $_ =~ /$datetimetz_re/;
                if ($fields[6]) {
                    my $missing = 9 - length($fields[6]);
                    $fields[6] .= "0" x $missing;
                }
                DT->new( zip(@datetimetzfields, @fields ) );
            },
        from ISO8601DateStr,
            via {
                my @fields = map { $_ || 0 } $_ =~ /$date_re/;
                DT->new( zip @datefields, @fields );
            },

        # XXX This coercion does not work as DateTime requires a year.
        from ISO8601TimeStr,
            via {
                my @fields = map { $_ || 0 } $_ =~ /$time_re/;
                if ($fields[3]) {
                    my $missing = 9 - length($fields[3]);
                    $fields[3] .= "0" x $missing;
                }
                DT->new( zip(@timefields, @fields), 'time_zone' => 'UTC' );
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

=head2 ISO8601DateTimeTZStr

An ISO8601 combined datetime string with a fully specified timezone. E.g. C<< 2009-06-11T12:06:34+00:00 >>

=head2 COERCIONS

The date types will coerce from:

=over

=item C< Num >

The number is treated as a time in seconds since the unix epoch

=item C< DateTime >

The duration represented as a L<DateTime> object.

=item C< Str >

Non-expanded date and time string representations.

e.g.:-

20120113         => 2012-01-13
170500Z          => 17:05:00Z
20120113T170500Z => 2012-01-13T17:05:00Z

Representations of UTC time zone (only an offset of zero is supported)

e.g.:-

17:05:00+00:00 => 17:05:00Z
17:05:00+00    => 17:05:00Z
170500+0000    => 17:05:00Z

2012-01-13T17:05:00+00:00 => 2012-01-13T17:05:00Z
2012-01-13T17:05:00+00    => 2012-01-13T17:05:00Z
20120113T170500+0000      => 2012-01-13T17:05:00Z

Also supports non-standards mixing of expanded and non-expanded representations

e.g.:-

2012-01-13T170500Z => 2012-01-13T17:05:00Z
20120113T17:05:00Z => 2012-01-13T17:05:00Z

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

=head1 FEATURES

=head2 Fractional seconds

If provided, the number of seconds in time types is represented to microsecond
accuracy. A full stop character is used as the decimal seperator, which is
allowed, but deprecated in preference to the comma character in
I<ISO 8601:2004>.

=head1 BUGS

Probably full of them, patches are very welcome.

Specifically missing features:

=over

=item *

No timezone support - all times are assumed UTC

=item *

No week number type

=item *

"Basic format", which lacks seperator characters, is not supported for
reading or writing.

=item *

Tests are rubbish.

=back

=head1 AUTHOR

=over

=item Tomas Doran (t0m) C<< <bobtfish@bobtfish.net> >>

=item Dave Lambley C<< <davel@state51.co.uk> >>

=back

The development of this code was sponsored by my employer L<http://www.state51.co.uk>.

=head2 Contributors

=over

=item Aaron Moses

=back

=head1 COPYRIGHT

    Copyright (c) 2009 Tomas Doran. Some rights reserved.
    This program is free software; you can redistribute
    it and/or modify it under the same terms as Perl itself.

=cut

