package MojoSkinny::DB::Skinny::Base;
use strict;
use warnings;
use utf8;

sub debug {
    my ($class, $debug) = @_;
}

sub query_log {
    my $class = shift;
    $class->profiler->query_log;
}

sub reset_query_log {
    my $class = shift;
    $class->profiler->reset;
}

1;
