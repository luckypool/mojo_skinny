package MojoSkinny::DB::Handler::Practice;
use strict;
use warnings;
use utf8;

use parent qw/MojoSkinny::DB::Handler::Base/;
use MojoSkinny::DB::Config;
use MojoSkinny::DB::Skinny::Practice;
use MojoSkinny::DB::Skinny::Practice::Schema;

sub get_dbh {
    my ($self, $user) = @_;
    my $config = MojoSkinny::DB::Config->new;
    return MojoSkinny::DB::Skinny::Practice->new(+{
        dsn => $config->practice,
        username => $user,
        connect_options => {
            mysql_enable_utf8 => 1,
        }
    });
}

1;
