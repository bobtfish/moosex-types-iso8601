use strict;
use warnings;

{
    package MyClass;
    use Moose;
    use MooseX::Types::ISO8601 qw/ISO8601DurationStr/;
    use namespace::autoclean;

    has duration => ( isa => ISO8601DurationStr, coerce => 1, required => 1, is => 'ro' );
}

use Test::More tests => 4;
use Test::Exception;

lives_ok {
    my $duration = 'PT00H00M00S';
    is(MyClass->new( duration => $duration )->duration, $duration,
        'Duration string unmangled');
} 'Create with string duration';
lives_ok {
    is(MyClass->new( duration => 60 )->duration, 'PT00H01M00S',
        'Duration number coerced');
} 'Create with Numeris duration';

