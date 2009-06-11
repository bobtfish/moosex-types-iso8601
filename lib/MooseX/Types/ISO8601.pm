package MooseX::Types::ISO8601;
use Moose ();
use DateTime;
use DateTime::Format::Duration;
use MooseX::Types::DateTime qw(Duration);
use MooseX::Types::Moose qw/Str Num/;
use namespace::autoclean;

our $VERSION = "0.00_01";

use MooseX::Types -declare => [qw(
    ISO8601Str
    ISO8601DurationStr
)];

subtype ISO8601Str,
    as Str,
    where { /^$/ };

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

=head1 AUTHOR

Tomas Doran (t0m) C<< <bobtfish@bobtfish.net> >>

The development of this code was sponsored by my employer L<http://www.state51.co.uk>.

=head1 COPYRIGHT

    Copyright (c) 2009 Tomas Doran. Some rights reserved.
    This program is free software; you can redistribute
    it and/or modify it under the same terms as Perl itself.

=cut

