package MojoSkinny::DB::Handler::Base;
use strict;
use warnings;
use utf8;

use parent qw/Class::Accessor::Fast/;
use Params::Validate;

__PACKAGE__->mk_accessors(qw/db/);

sub new {
    my $class = shift;
    my $params = Params::Validate::validate(@_, {
        role => {
            type => Params::Validate::SCALAR,
            regex => qr/^(m|s)$/,
        },
    });
    my $db = $params->{role} eq 'm' ? $class->get_dbh('master_user') : $class->get_dbh('readonly_user');
    my $self = {
        db => $db,
    };
    return bless $self, $class;
}

sub get_dbh {
    die 'override me!!';
}

1;
