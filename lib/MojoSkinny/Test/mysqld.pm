package MojoSkinny::Test::mysqld;
use strict;
use warnings;
use utf8;

use parent qw/Class::Accessor::Fast/;
use Test::More;
use Test::mysqld;
use Test::Fixture::DBIxSkinny;

__PACKAGE__->mk_accessors(qw/mysqld/);

my $instance;

BEGIN {
    my $mysqld = Test::mysqld->new(
        my_cnf => {
            'skip-networking' => '',
        }
    ) or plan skip_all => $Test::mysqld::errstr;
    my $self = { mysqld => $mysqld };
    $instance = bless $self, __PACKAGE__;
}

sub get_db {
    my $self = shift;
    my ($db_class, $db_name) = @_;
    my $db = $db_class->new({
        dsn => $instance->mysqld->dsn.';mysql_multi_statements=1',
    });
    $db->debug(1);
    $db->do(__get_db_schema($db_name));
    return $db;
}

sub __get_db_schema {
    my ($db_name) = @_;
    my $db_schema = '';
    for(glob("./db-schema/$db_name*.sql")){
        open my $fh, '<', $_
            or die "failed to open file: $!";
        $db_schema .= do { local $/; <$fh> };
    }
    return $db_schema;
}

1;
