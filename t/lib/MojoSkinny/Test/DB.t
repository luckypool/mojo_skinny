use strict;
use warnings;
use utf8;

use Test::More;

my $class;
BEGIN {
    use_ok($class='MojoSkinny::Test::DB', qw/DB_PRACTICE/);
}

done_testing;
