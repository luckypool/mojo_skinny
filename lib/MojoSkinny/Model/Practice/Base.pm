package MojoSkinny::Model::Practice::Base;
use strict;
use warnings;
use utf8;

use parent qw/Class::Accessor::Fast/;
use MojoSkinny::DB::Handler::Practice;
use Params::Validate;

__PACKAGE__->mk_accessors(qw/master slave/);

sub new {
    my $class = shift;
    my $self = {
        master => MojoSkinny::DB::Handler::Practice->new(role=>'m')->db,
        slave  => MojoSkinny::DB::Handler::Practice->new(role=>'s')->db,
    };
    return bless $self, $class;
}

sub table { die q/override me!/ };
sub primary_key { die q/override me!/ };

# --
# common functions
sub insert {
    my $self = shift;
    my $params = $self->validate_basic_params(@_);
    return $self->master->insert($self->table, $params)->get_columns;
}

sub replace {
    my $self = shift;
    my $params = $self->validate_basic_params(@_);
    return $self->master->replace($self->table, $params)->get_columns;
}

sub select_by_id {
    my $self = shift;
    my $params = Params::Validate::validate(@_, {
        id => { regex => qr/^\d+$/ },
    });
    my $row = $self->slave->search($self->table, {
        id => $params->{id},
    })->first;
    return unless $row;
    return $row->get_columns;
}

sub update {
    my $self = shift;
    my $params_with_id = shift;
    die unless defined $params_with_id->{id};
    my $id = $params_with_id->{id};
    delete $params_with_id->{id};
    my $basic_param = {%$params_with_id};
    my $params = $self->validate_basic_params($basic_param);
    return $self->master->update(
        $self->table,
        $self->get_update_params($params),
        { id => $id },
    );
}

sub delete_by_id {
    my $self = shift;
    my $params = Params::Validate::validate(@_, {
        id => { regex => qr/^\d+$/ },
    });
    return $self->master->delete($self->table, {
        id => $params->{id},
    });
}

sub exists {
    my $self = shift;
    my $row = $self->select_by_id(@_);
    return defined $row ? 1 : 0;
}

sub get_count {
    my $self = shift;
    return $self->slave->count($self->table, $self->primary_key, {});
}

1;
