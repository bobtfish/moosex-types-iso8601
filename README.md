# NAME

MooseX::Types::ISO8601 - ISO8601 date and duration string type constraints and coercions for Moose

# SYNOPSIS

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

# DESCRIPTION

This module packages several [TypeConstraints](http://search.cpan.org/perldoc?Moose::Util::TypeConstraints) with
coercions for working with ISO8601 date strings and the DateTime suite of objects.

# DATE CONSTRAINTS

## ISO8601DateStr

An ISO8601 date string. E.g. `2009-06-11`

## ISO8601TimeStr

An ISO8601 time string. E.g. `12:06:34Z`

## ISO8601DateTimeStr

An ISO8601 combined datetime string. E.g. `2009-06-11T12:06:34Z`

## COERCIONS

The date types will coerce from:

- ` Num `

The number is treated as a time in seconds since the unix epoch

- ` DateTime `

The duration represented as a [DateTime](http://search.cpan.org/perldoc?DateTime) object.

- ` Str `

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

# DURATION CONSTRAINTS

## ISO8601DateDurationStr

An ISO8601 date duration string. E.g. `P01Y01M01D`

## ISO8601TimeDurationStr

An ISO8601 time duration string. E.g. `PT01H01M01S`

## ISO8601DateTimeDurationStr

An ISO8601 comboined date and time duration string. E.g. `P01Y01M01DT01H01M01S`

## COERCIONS

The duration types will coerce from:

- ` Num `

The number is treated as a time in seconds

- ` DateTime::Duration `

The duration represented as a [DateTime::Duration](http://search.cpan.org/perldoc?DateTime::Duration) object.

The duration types will coerce to:

- ` Duration `

A [DateTime::Duration](http://search.cpan.org/perldoc?DateTime::Duration), i.e. the ` Duration ` constraint from
[MooseX::Types::DateTime](http://search.cpan.org/perldoc?MooseX::Types::DateTime).

# SEE ALSO

- [MooseX::Types::DateTime](http://search.cpan.org/perldoc?MooseX::Types::DateTime)
- [DateTime](http://search.cpan.org/perldoc?DateTime)
- [DateTime::Duration](http://search.cpan.org/perldoc?DateTime::Duration)
- [DateTime::Format::Duration](http://search.cpan.org/perldoc?DateTime::Format::Duration)

# VERSION CONTROL

    http://github.com/bobtfish/moosex-types-iso8601/tree/master

Patches are welcome.

# SEE ALSO

- http://en.wikipedia.org/wiki/ISO_8601
- http://dotat.at/tmp/ISO_8601-2004_E.pdf

# FEATURES

## Fractional seconds

If provided, the number of seconds in time types is represented to microsecond
accuracy. A full stop character is used as the decimal seperator, which is
allowed, but deprecated in preference to the comma character in
_ISO 8601:2004_.

# BUGS

Probably full of them, patches are very welcome.

Specifically missing features:

- No timezone support - all times are assumed UTC
- No week number type
- "Basic format", which lacks seperator characters, is not supported for
reading or writing.
- Tests are rubbish.

# AUTHOR

Tomas Doran (t0m) `<bobtfish@bobtfish.net>`

The development of this code was sponsored by my employer [http://www.state51.co.uk](http://www.state51.co.uk).

# COPYRIGHT

    Copyright (c) 2009 Tomas Doran. Some rights reserved.
    This program is free software; you can redistribute
    it and/or modify it under the same terms as Perl itself.