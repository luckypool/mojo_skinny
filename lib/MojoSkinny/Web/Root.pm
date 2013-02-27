package MojoSkinny::Web::Root;
use strict;
use warnings;
use utf8;

use Mojo::Base 'Mojolicious::Controller';

sub home {
    my $self = shift;
    $self->render(message=>'home message');
}

1;
