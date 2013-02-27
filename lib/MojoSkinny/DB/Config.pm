package MojoSkinny::DB::Config;
use strict;
use warnings;
use utf8;

use parent qw/Class::Accessor::Fast/;
__PACKAGE__->mk_ro_accessors(qw/
    practice
/);

use constant {
    DB_PRACTICE => 'DBI:mysql:practice',
};

sub new {
    my $class = shift;
    my $self = {
        practice => DB_PRACTICE(),
    };
    return bless $self, $class;
}

1;
