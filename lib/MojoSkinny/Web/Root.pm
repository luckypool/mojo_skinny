package MojoSkinny::Web::Root;
use strict;
use warnings;
use utf8;

use Mojo::Base 'Mojolicious::Controller';

sub home {
    my $self = shift;
    $self->render(
        title       => 'title',
        footer_text => 'footer_text'
    );
}

1;
