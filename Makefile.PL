use strict;
use warnings;
use inc::Module::Install 0.91;

name 'MooseX-Types-ISO8601';
all_from 'lib/MooseX/Types/ISO8601.pm';

license 'perl';

requires 'Moose' => '0.79';
requires 'MooseX::Types' => '0.10';
requires 'namespace::autoclean' => '0.05';

WriteAll;

