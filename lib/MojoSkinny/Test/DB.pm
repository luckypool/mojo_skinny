package MojoSkinny::Test::DB;
use strict;
use warnings;
use utf8;

use UNIVERSAL::require;
use MojoSkinny::Test::mysqld;

use Test::MockObject;

sub import {
    my $parent = shift;
    my @sql_name_list = @_;
    my %sql_to_classname_hash = map {
        my $module = (split /_/, $_)[1];
        $_ => 'MojoSkinny::DB::Skinny::' . ucfirst(lc $module )
    } @sql_name_list;

    for my $name (keys %sql_to_classname_hash) {
        my $class_name = $sql_to_classname_hash{$name};
        $class_name->require;
        my $db = MojoSkinny::Test::mysqld->get_db($class_name, $name);
        Test::MockObject->fake_module($class_name,
            new => sub {
                my $self = shift;
                my ($param) = @_;
                my @dsn_param = split /:/, $param->{dsn};
                $db->do("USE $dsn_param[2]");
                return $db;
            }
        );
    }
}

=encode utf8

=head1 NAME

MojoSkinny::Test::DB

=head1 DESCRIPTION

MojoSkinny::DB::Skinny::* のものを new する際に
db-schema 以下に作られた sql ファイルの内容として扱う
ただし、

=over 2

=item * DB_HOGE.sql には hoge という dbname が対応する

=item * DB_HOGE.sql の名前に対して MojoSkinny::DB::Skinny::Hoge が対応する

=back

=head1 SYNOPSIS

 use MojoSkinny::Test::DB qw/DB_PRACTICE/;

=cut

1;
