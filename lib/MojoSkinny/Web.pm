package MojoSkinny::Web;
use strict;
use warnings;
use utf8;

use Mojo::Base 'Mojolicious';
use MojoSkinny::Web::JSONRPC::Practice::Entry;

use constant {
    ENDPOINT_ENTRY => '/jsonrpc/practice/entry.json',
};

sub startup {
    my $self = shift;

    my $r = $self->routes;
    $r->get('/')->to('root#home');

    $self->plugin(
        'json_rpc_dispatcher',
        services => {
            ENDPOINT_ENTRY() => MojoSkinny::Web::JSONRPC::Practice::Entry->new,
        },
        exception_handler => sub {
             my ( $dispatcher, $err, $m ) = @_;
             # $dispatcher is the dispatcher Mojolicious::Controller object
             # $err is $@ received from the exception
             # $m is the MojoX::JSON::RPC::Dispatcher::Method object to be returned.
             return $m->invalid_params($err->{message}) if defined $err->{message};
             return $m->invalid_params;
        }
    );
}

1;
