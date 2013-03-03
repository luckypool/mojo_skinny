use strict;
use warnings;
use utf8;

use Test::More;
use Test::Mojo;

my $test_web = Test::Mojo->new('MojoSkinny::Web');

$test_web->get_ok('/')->status_is(200);

done_testing;
