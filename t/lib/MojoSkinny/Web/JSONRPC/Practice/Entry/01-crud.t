use strict;
use warnings;
use utf8;

use Test::More;
use Test::Deep;
use Test::Mojo;

use MojoSkinny::Test::DB qw/DB_PRACTICE/;

use Test::MockTime qw/set_fixed_time/;
use Date::Calc qw/Mktime Today_and_Now/;

my $test_web = Test::Mojo->new('MojoSkinny::Web');

subtest q/crud/ => sub {

    my $expecting_entry;

    subtest q/create/ => sub {
        __post('create', {
            nickname => 'dummy nickname',
            body => 'dummy bodybodybody',
        });
        ok $expecting_entry = $test_web->tx->res->json->{result};
    };

    $expecting_entry->{updated_at} = '0000-00-00 00:00:00';

    subtest q/lookup/ => sub {
        __post('lookup',{id=>$expecting_entry->{id}});
        my $expects = {
            jsonrpc => '2.0',
            id => 1,
            result => $expecting_entry,
        };
        cmp_deeply $expects, $test_web->tx->res->json, q/json ok/;
    };

    # fix updated_at
    my $today_and_now = [Today_and_Now()];
    my $now = Mktime(@$today_and_now);
    set_fixed_time($now);
    $expecting_entry->{updated_at} = sprintf("%04d-%02d-%02d %02d:%02d:%02d", @$today_and_now);

    subtest q/update/ => sub {
        $expecting_entry->{nickname} = 'updated nickname';
        $expecting_entry->{body} = 'updated bodybodybody';
        __post('update', {
            id => $expecting_entry->{id},
            nickname => $expecting_entry->{nickname},
            body => $expecting_entry->{body},
        });
        my $expects = {
            jsonrpc => '2.0',
            id => 1,
            result => 1,
        };
        cmp_deeply $expects, $test_web->tx->res->json, q/json ok/;
    };

    subtest q/lookup after update/ => sub {
        __post('lookup',{id=>$expecting_entry->{id}});
        my $expects = {
            jsonrpc => '2.0',
            id => 1,
            result => $expecting_entry,
        };
        cmp_deeply $expects, $test_web->tx->res->json, q/json ok/;
    };

    subtest q/delete/ => sub {
        __post('delete',{id=>$expecting_entry->{id}});
        my $expects = {
            jsonrpc => '2.0',
            id => 1,
            result => 1,
        };
        cmp_deeply $expects, $test_web->tx->res->json, q/json ok/;
    };

    subtest q/lookup after delete/ => sub {
        __post('lookup',{id=>$expecting_entry->{id}});
        my $expects = {
            jsonrpc => '2.0',
            id => 1,
            result => undef,
        };
        cmp_deeply $expects, $test_web->tx->res->json, q/json ok/;
    };
};

sub __post {
    my ($method, $params) = @_;
    $test_web->post_ok(
        '/jsonrpc/practice/entry.json',
        json => {
            jsonrpc => '2.0',
            method  => $method,
            params  => $params,
            id => 1,
        })
    ->status_is(200)
    ->content_type_is('application/json-rpc')
    ->header_is('X-Powered-By' => 'Mojolicious (Perl)');
}

done_testing;
