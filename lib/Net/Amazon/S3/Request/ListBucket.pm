package Net::Amazon::S3::Request::ListBucket;

use Moose 0.85;
use MooseX::StrictConstructor 0.16;
use URI::Escape qw(uri_escape_utf8);
extends 'Net::Amazon::S3::Request::Bucket';

# ABSTRACT: An internal class to list a bucket

has 'prefix'    => ( is => 'ro', isa => 'Maybe[Str]', required => 0 );
has 'delimiter' => ( is => 'ro', isa => 'Maybe[Str]', required => 0 );
has 'max_keys' =>
    ( is => 'ro', isa => 'Maybe[Int]', required => 0, default => 1000 );
has 'marker' => ( is => 'ro', isa => 'Maybe[Str]', required => 0 );

__PACKAGE__->meta->make_immutable;

sub http_request {
    my $self = shift;

    my $path = $self->_request_path;

    my @post;
    foreach my $method ( qw(delimiter marker max_keys prefix) ) {
        my $value = $self->$method;
        next unless $value;
        my $key = $method;
        $key = 'max-keys' if $method eq 'max_keys';
        push @post, $key . "=" . $self->_urlencode($value);
    }
    if (@post) {
        $path .= '?' . join( '&', @post );
    }

    return $self->_build_http_request(
        method => 'GET',
        path   => $path,
    );
}

sub _urlencode {
    my ( $self, $unencoded ) = @_;
    return uri_escape_utf8( $unencoded, '^A-Za-z0-9_-' );
}

1;

__END__

=for test_synopsis
no strict 'vars'

=head1 SYNOPSIS

  my $http_request = Net::Amazon::S3::Request::ListBucket->new(
    s3        => $s3,
    bucket    => $bucket,
    delimiter => $delimiter,
    max_keys  => $max_keys,
    marker    => $marker,
  )->http_request;

=head1 DESCRIPTION

This module lists a bucket.

=head1 METHODS

=head2 http_request

This method returns a HTTP::Request object.

