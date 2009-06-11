use strict;
use warnings;
use inc::Module::Install 0.91;

name 'MooseX-Types-ISO8601';
all_from 'lib/MooseX/Types/ISO8601.pm';

license 'perl';

requires 'Moose' => '0.79';
requires 'MooseX::Types' => '0.10';
requires 'MooseX::Types::DateTime' => '0.03';
requires 'DateTime' => '0.41';
requires 'DateTime::Format::Duration' => '1.03';
requires 'namespace::autoclean' => '0.05';

test_requires 'Test::More';
test_requires 'Test::Exception';

WriteAll;

