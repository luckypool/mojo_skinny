package MojoSkinny::Web::JSONRPC::Practice::Entry;
use strict;
use warnings;
use utf8;
use Mojo::Base 'MojoX::JSON::RPC::Service';
use Mojo::Exception;

use Params::Validate;
use FormValidator::Simple;
use MojoSkinny::Model::Practice::Entry;

__PACKAGE__->register_rpc_method_names( 'lookup', 'find', 'create' );

sub lookup {
    my $self = shift;
    my ($params) = @_;
    my $result = FormValidator::Simple->check($params => [
        id => [qw/NOT_BLANK UINT/],
    ]);
    Mojo::Exception->throw([$result->error]) if $result->has_error;
    eval {
        Params::Validate::validate(@$params, {
            id => 1
        });
    };
    Mojo::Exception->throw(['unnecesarry params']) if $@;
    my $model = MojoSkinny::Model::Practice::Entry->new;
    my $find_row = $model->select_by_id({
        id => $params->{id}
    });
    return $find_row;
}

sub find {
    my $self = shift;
    my ($params) = @_;
    my $result = FormValidator::Simple->check($params => [
        offset => [qw/UINT/],
        limit  => [qw/UINT/],
        order  => [[qw/IN_ARRAY DESC ASC/]],
    ]);
    Mojo::Exception->throw([$result->error]) if $result->has_error;
    eval {
        Params::Validate::validate(@$params, {
            map { $_ => 0 } qw/offset limit order/,
        });
    };
    Mojo::Exception->throw(['unnecesarry params']) if $@;
    my $find_param = {};
    $find_param->{offset} = $params->{offset} if defined $params->{offset};
    $find_param->{limit}  = $params->{limit}  if defined $params->{limit};
    $find_param->{order}  = $params->{order}  if defined $params->{order};
    my $model = MojoSkinny::Model::Practice::Entry->new;
    my $find_row = $model->find($find_param);
    return $find_row;
}

sub create {
    my $self = shift;
    my ($params) = @_;
    my $result = FormValidator::Simple->check($params => [
        nickname => [qw/NOT_BLANK/, [qw/LENGTH 1 32/]],
        body     => [qw/NOT_BLANK/, [qw/LENGTH 1 500/]],
    ]);
    Mojo::Exception->throw([$result->error]) if $result->has_error;
    eval {
        Params::Validate::validate(@$params, {
            map { $_ => 1 } qw/body nickname/,
        });
    };
    Mojo::Exception->throw(['unnecesarry params']) if $@;
    my $model = MojoSkinny::Model::Practice::Entry->new;
    $model->insert({
        nickname => $params->{nickname},
        body     => $params->{body},
    });
    return 1;
}

1;
