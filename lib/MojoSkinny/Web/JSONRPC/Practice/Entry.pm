package MojoSkinny::Web::JSONRPC::Practice::Entry;
use strict;
use warnings;
use utf8;
use Mojo::Base 'MojoX::JSON::RPC::Service';
use Mojo::Exception;

use Params::Validate;
use MojoSkinny::Model::Practice::Entry;

__PACKAGE__->register_rpc_method_names( 'lookup', 'find', 'create', 'update', 'delete' );

sub lookup {
    my $self = shift;
    my $params = __validate_id(@_);
    my $model = MojoSkinny::Model::Practice::Entry->new;
    return $model->select_by_id($params);
}

sub delete {
    my $self = shift;
    my $params = __validate_id(@_);
    my $model = MojoSkinny::Model::Practice::Entry->new;
    return $model->delete_by_id($params);
}

sub __validate_id {
    return Params::Validate::validate_with(
        params => @_,
        spec =>  {
            id => {
                type    => Params::Validate::SCALAR,
                regex   => qr/^\d{1,5}$/,
            },
        },
        on_fail => sub { __throw(@_) },
    );
}

sub find {
    my $self = shift;
    my $params = __validate_find_param(@_);
    my $model = MojoSkinny::Model::Practice::Entry->new;
    my $find_row = $model->find($params);
    return $find_row;
}

sub __validate_find_param {
    return Params::Validate::validate_with(
        params => @_,
        spec =>  {
            offset => {
                type    => Params::Validate::SCALAR,
                regex   => qr/^\d{1,3}$/,
            },
            limit => {
                type    => Params::Validate::SCALAR,
                regex   => qr/^\d{1,3}$/,
            },
            order => {
                type    => Params::Validate::SCALAR,
                regex   => qr/^(DESC|ASC)$/,
            },
        },
        on_fail => sub { __throw(@_) },
    );
}

sub create {
    my $self = shift;
    my $params = __validate_create_param(@_);
    my $model = MojoSkinny::Model::Practice::Entry->new;
    return $model->insert($params);
}

sub __validate_create_param {
    return Params::Validate::validate_with(
        params => @_,
        spec =>  {
            nickname => {
                type    => Params::Validate::SCALAR,
                regex   => qr/^.{1,32}$/,
            },
            body => {
                type    => Params::Validate::SCALAR,
                regex   => qr/^.{1,1000}$/,
            },
            tag_id => {
                type    => Params::Validate::SCALAR,
                regex   => qr/^\d{1,3}$/,
            },
        },
        on_fail => sub { __throw(@_) },
    );
}

sub update {
    my $self = shift;
    my $params = __validate_update_param(@_);
    my $model = MojoSkinny::Model::Practice::Entry->new;
    return $model->update($params);
}

sub __validate_update_param {
    return Params::Validate::validate_with(
        params => @_,
        spec =>  {
            id => {
                type    => Params::Validate::SCALAR,
                regex   => qr/^\d{1,5}$/,
            },
            nickname => {
                type    => Params::Validate::SCALAR,
                regex   => qr/^.{1,32}$/,
            },
            body => {
                type    => Params::Validate::SCALAR,
                regex   => qr/^.{1,500}$/,
            },
            tag_id => {
                type    => Params::Validate::SCALAR,
                regex   => qr/^\d{1,3}$/,
            },
        },
        on_fail => sub {
            __throw(@_)
        },
    );
}


sub __throw {
    my $message = shift;
    Mojo::Exception->throw([$message]);
}
1;
