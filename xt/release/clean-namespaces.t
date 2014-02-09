use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::CleanNamespaces;

use Test::Requires { 'MooseX::Types' => '0.42' };
all_namespaces_clean();

done_testing;
