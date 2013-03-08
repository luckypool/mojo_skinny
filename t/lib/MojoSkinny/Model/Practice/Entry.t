use strict;
use warnings;
use utf8;

use Test::More;
use Test::Deep;
use Test::MockTime;
use MojoSkinny::Test::DB qw/DB_PRACTICE/;

use Date::Calc qw/Localtime/;

my $class;
BEGIN {
    use_ok($class='MojoSkinny::Model::Practice::Entry');
}

my $obj = new_ok $class;

# for debug
use Devel::Peek qw/Dump/;
use Data::Dumper;
$obj->master->reset_query_log;
$obj->slave->reset_query_log;
sub __show_query_log {
    warn Data::Dumper::Dumper $obj->master->query_log;
    warn Data::Dumper::Dumper $obj->slave->query_log;
    $obj->master->reset_query_log;
    $obj->slave->reset_query_log;
}

# --
# Utils
sub __time_to_mysqldatetime {
    my $time = shift;
    my @datetime = defined $time ? Localtime($time) : split '', (0 x 6);
    return sprintf("%04d-%02d-%02d %02d:%02d:%02d", @datetime);
};

sub __create_dummy_data {
    my $id = int rand 1000000;
    return {
        nickname  => "nickname:$id",
        body      => qq{bodyボディ本文だああああああああ$id},
        tag_id    => int rand 10,
    };
}

subtest q/crud/ => sub {
    my $now = time();
    Test::MockTime::set_fixed_time($now);

    my $dummy_data1 = __create_dummy_data();

    subtest q/create/ => sub {
        my $row = $obj->insert($dummy_data1);
        my $expecting = {%$dummy_data1};
        $expecting->{id} = 1;
        $expecting->{created_at} = __time_to_mysqldatetime($now);
        cmp_deeply $row, $expecting;
    };

    subtest q/read/ => sub {
        my $expecting = {%$dummy_data1};
        $expecting->{id} = 1;
        $expecting->{created_at} = __time_to_mysqldatetime($now);
        $expecting->{updated_at} = __time_to_mysqldatetime();

        my $row = $obj->select_by_id({id=>$expecting->{id}});
        ok $row;
        cmp_deeply $expecting, $row;
    };

    subtest q/update/ => sub {
        my $update_time = $now+600;
        Test::MockTime::set_fixed_time($update_time);
        my $expecting = {%$dummy_data1};
        $expecting->{id} = 1;
        $expecting->{body} = 'ほげええ';
        $expecting->{created_at} = __time_to_mysqldatetime($now);
        $expecting->{updated_at} = __time_to_mysqldatetime($update_time);
        ok $obj->update({
            map { $_ => $expecting->{$_} } qw/id tag_id nickname body/
        });
        my $row = $obj->select_by_id(id=>1);
        cmp_deeply $expecting, $row;
    };

    Test::MockTime::restore_time();

    subtest q/delete/ => sub {
        is $obj->exists(id=>1), 1;
        ok $obj->delete_by_id({id=>1});
        is $obj->exists(id=>1), 0;
    };
};

subtest q/find/ => sub {
    ok 1;
    my @dummy_data_list = map { __create_dummy_data() } (1..50);
    my @expecting_list;
    my $current = time - 60 * 60 * 50;

    # THE WORLD!!!
    Test::MockTime::set_fixed_time($current);

    # WRYYYYYYY!!!!!
    for my $dummy (@dummy_data_list){
        my $expecting = {%$dummy};
        $expecting->{created_at} = __time_to_mysqldatetime($current);
        unshift @expecting_list, $expecting;
        $obj->insert($dummy);
        $current = $current + 60 * 60;
        Test::MockTime::set_fixed_time($current);
    };

    # ... THEN THE TIME STARTS MOVING
    Test::MockTime::restore_time();

    my $rows = $obj->find({
        limit  => 30,
        offset => 0,
        order  => 'DESC',
    });

    map {
        $_->{updated_at}= __time_to_mysqldatetime();
        my $got = shift @$rows;
        delete $got->{id};
        cmp_deeply $_, $got, "ok $_->{created_at}";
    } splice @expecting_list, 0, 30;
    is_deeply $rows, [], 'length ok';
};

done_testing;
