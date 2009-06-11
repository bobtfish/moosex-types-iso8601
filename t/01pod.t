use strict;
use warnings;
use Test::More;
use FindBin qw/$Bin/;

eval "use Test::Pod 1.14";
plan skip_all => 'Test::Pod 1.14 required' if $@;

push(@Pod::Simple::Known_directives => 'meta'); # Need more meta!
$Pod::Simple::Known_directives{meta} = 'Plain';

my @pods = all_pod_files("$Bin/../");

all_pod_files_ok(@pods);

