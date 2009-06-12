package MooseX::Types::ISO8601;
use Moose ();
use DateTime;
use DateTime::Format::Duration;
use MooseX::Types::DateTime qw(Duration);
use MooseX::Types::Moose qw/Str Num/;
use namespace::autoclean;

our $VERSION = "0.00_01";

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
    where { /^\d{2}:\d{2}Z?$/ };

subtype ISO8601DateTimeStr,
    as Str,
    where { /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}Z?$/ };

subtype ISO8601TimeDurationStr,
    as Str,
    where { /^PT\d{2}H\d{2}M\d{2}S$/ };

subtype ISO8601DateDurationStr,
    as Str,
    where { /^PT\d+Y\d{2}M\d{2}D$/ };

subtype ISO8601DateTimeDurationStr,
    as Str,
    where { /^P\d+Y\d{2}M\d{2}DT\d{2}H\d{2}M\d{2}S$/ };

my %coerce = (
    ISO8601TimeDurationStr, 'PT%02HH%02MM%02SS',
    ISO8601DateDurationStr, 'PT%02YY%02MM%02DD',
    ISO8601DateTimeDurationStr, 'PT%02YY%02MM%02DD%02HH%02MM%02SS',
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

1;

__END__

=head1 NAME

MooseX::Types::ISO8601 - ISO8601 date and duration string type constraints and coercions for Moose

=head1 SYNOPSIS

    use MooseX::Types::ISO8601 qw/ISO8601DurationStr/;

    has duration => (
        isa => ISO8601DurationStr,
        is => 'ro',
        coerce => 1,
    );

    Class->new( duration => 60 ); # 60s => PT00H01M00S
    Class->new( duration => DateTime::Duration->new(%args) )

=head1 DESCRIPTION

This module packages several L<TypeConstraints|Moose::Util::TypeConstraints> with coercions,
designed to work with the DateTime suite of objects.

=head1 CONSTRAINTS

=over

=item ISO8601DurationStr

An ISO8601 duration string

=over

=item from C< Num >

The number is treated as a time in seconds

=item from C< DateTime::Duration >

The duration represented as a L<DateTime::Duration> object.

=back

=back

=head1 SEE ALSO

=over

=item L<MooseX::Types::DateTime>

=item L<DateTime>

=item L<DateTime::Duration>

=item L<DateTime::Format::Duration>

=back

=head1 VERSION CONTROL

    http://github.com/bobtfish/moosex-types-iso8601/tree/master

=head1 BUGS

Probably full of them, patches are very welcome.

Specifically missing features:

=over

=item Currently no time string support, just durations

=item Duration string support only supports durations measured in hours

=item No timezone string support

=item Unsure if strings are proprly accurate to the spec

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

