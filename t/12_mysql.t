use strict;
use warnings;
use Test::More;

use Test::Requires 'MooseX::Types::DateTime::MySQL';

use MooseX::Types::ISO8601 qw/
    ISO8601DateStr
    ISO8601TimeStr
    ISO8601DateTimeStr
/;

my $mysql_dt = '2010-08-16 09:26:25';

is to_ISO8601DateStr($mysql_dt), '2010-08-16';
is to_ISO8601DateTimeStr($mysql_dt), '2010-08-16T09:26:25Z';

done_testing;

