use strict;
use warnings;
use utf8;

use Test::More;
use Test::Deep;
use Test::Mojo;

use MojoSkinny::Test::DB qw/DB_PRACTICE/;

use List::MoreUtils qw/indexes/;
use Data::Dumper;

my $test_web = Test::Mojo->new('MojoSkinny::Web');

subtest q/find/ => sub {
    my $create_response = __batch_request(
        'create',
        [ map {+{
            nickname => "nick: $_",
            body => "body: $_",
            tag_id => $_,
        }} (1..30) ],
    );
    my $expecting_entries = [ map {
        my $result = $_->{result};
        $result->{updated_at} = '0000-00-00 00:00:00';
        $result
    } @$create_response ];

    subtest q/find/ => sub {
        __post('find', {
            limit  => 30,
            offset => 0,
            order  =>'ASC',
        });
        cmp_deeply $test_web->tx->res->json, {
            jsonrpc => '2.0',
            id => 1,
            result => $expecting_entries,
        };
    };
};

sub __batch_request {
    my ($method, $params_array_ref) = @_;
    my $json_array_ref = [];
    for my $index (indexes {defined $_} @$params_array_ref) {
        push $json_array_ref, {
            jsonrpc => '2.0',
            method  => $method,
            id      => $index,
            params  => $params_array_ref->[$index],
        };
    }
    $test_web->post_ok(
            '/jsonrpc/practice/entry.json',
            json => $json_array_ref,
        )
    ->status_is(200)
    ->content_type_is('application/json-rpc')
    ->header_is('X-Powered-By' => 'Mojolicious (Perl)');
    return $test_web->tx->res->json;
}

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
