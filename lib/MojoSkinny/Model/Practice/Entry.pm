package MojoSkinny::Model::Practice::Entry;
use strict;
use warnings;
use utf8;

use parent qw/MojoSkinny::Model::Practice::Base/;

use constant {
    TABLE_NAME => 'entry',
};

sub table {
    return TABLE_NAME;
};

sub validate_basic_params {
    my $self = shift;
    return Params::Validate::validate(@_, {
        nickname => { type  => Params::Validate::SCALAR },
        body     => { type  => Params::Validate::SCALAR },
    });
}

sub get_update_params {
    my $self = shift;
    my ($params) = @_;
    return {
        map { $_ => $params->{$_} } qw/nickname body/
    };
}

sub find {
    my $self = shift;
    my $params = Params::Validate::validate(@_, {
        offset => { regex => qr/^\d+$/, default => DEFAULT_OFFSET() },
        limit  => { regex => qr/^\d+$/, default => DEFAULT_LIMIT() },
        order  => { regex => qr/^(DESC|ASC)$/, default => DEFAULT_ORDER() },
    });
    my $row = $self->slave->search(
        $self->table, undef, {
            limit    => $params->{limit},
            offset   => $params->{offset},
            order_by => {
                id => $params->{order}
            },
        }
    )->all;
    return unless $row;
    return [ map {$_->get_columns} @$row ];
}

1;
