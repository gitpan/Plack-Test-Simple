# ABSTRACT: PSGI Automated Application Testing Layer
package Plack::Test::Simple::Transaction;

use utf8;
use HTTP::Request;
use HTTP::Response;
use URI;
use Moo;
use Plack::Util;
use JSON        qw(decode_json);
use Test::More  qw();
use Plack::Test qw();
use Data::DPath qw(dpath);



has data => (
    is      => 'rw',
    lazy    => 1,
    builder => 1
);

sub _build_data {
    my ($self) = @_;

    return {} unless $self->response->content;
    return {} unless $self->response->header('Content-Type');
    return {} unless $self->response->header('Content-Type') =~ /json/i;

    # only supporting JSON data currently !!!
    return decode_json $self->response->decoded_content;
}


has psgi => (
    is     => 'rw',
    isa    => sub {
        my $psgi = shift;

        die 'The psgi attribute must must be a valid PSGI filepath or code '.
            'reference' if !$psgi && ('CODE' eq ref($psgi) xor -f $psgi);
    },
    coerce => sub {
        my $psgi = shift;

        # return psgi
        return $psgi if (ref $psgi) =~ /Plack::Test::/; # very trusting
        return Plack::Test->create($psgi) if 'CODE' eq ref $psgi;
        return Plack::Test->create(Plack::Util::load_psgi($psgi));
    }
);


has request => (
    is      => 'rw',
    lazy    => 1,
    builder => 1
);

sub _build_request {
    return HTTP::Request->new(
        uri => URI->new(scheme => 'http', host => 'localhost', path => '/')
    )
}


has response => (
    is      => 'rw',
    lazy    => 1,
    builder => 1
);

sub _build_response {
    my $self = shift;
    return $self->psgi->request($self->request);
}


sub content_is {
    my ($self, $value, $desc) = @_;
    $desc ||= 'exact match for content';
    return $self->_test_more(
        'is', $self->response->decoded_content, $value, $desc
    );
}


sub content_isnt {
    my ($self, $value, $desc) = @_;
    $desc ||= 'not an exact match for content';
    return $self->_test_more(
        'isnt', $self->response->decoded_content, $value, $desc
    );
}


sub content_like {
    my ($self, $regex, $desc) = @_;
    $desc ||= 'content contains the expression specified';
    return $self->_test_more(
        'like', $self->response->decoded_content, $regex, $desc
    );
}


sub content_unlike {
    my ($self, $regex, $desc) = @_;
    $desc ||= 'content does not contain the expression specified';
    return $self->_test_more(
        'unlike', $self->response->decoded_content, $regex, $desc
    );
}


sub data_has {
    my ($self, $path, $desc) = @_;
    $desc ||= qq{has value for data path "$path"};
    my $rs = [ dpath($path)->match($self->data) ];
    return $self->_test_more(
        'ok', $rs->[0], $desc
    );
}


sub data_hasnt {
    my ($self, $path, $desc) = @_;
    $desc ||= qq{has no value for data path "$path"};
    my $rs = [ dpath($path)->match($self->data) ];
    return $self->_test_more(
        'ok', !$rs->[0], $desc
    );
}


sub data_is_deeply {
    my $self = shift;
    my ($path, $data) = ref $_[0] ? ('', shift) : (shift, shift);
    $path ||= '/';
    my $desc ||= qq{exact match for data path "$path"};
    my $rs = [ dpath($path)->match($self->data) ];
    return $self->_test_more(
        'is_deeply', $rs->[0], $data, $desc
    );
}


sub data_match {
    goto &data_is_deeply;
}


sub header_is {
    my ($self, $name, $value, $desc) = @_;
    $desc ||= "exact match for header $name with value " . ($value // '');
    return $self->_test_more(
        'is', $self->response->header($name), $value, $desc
    );
}


sub header_isnt {
    my ($self, $name, $value, $desc) = @_;
    $desc ||= "not an exact match for header $name with value " . ($value // '');
    return $self->_test_more(
        'isnt', $self->response->header($name), $value, $desc
    );
}


sub header_like {
    my ($self, $name, $regex, $desc) = @_;
    $desc ||= "header $name contains the expression specified";
    return $self->_test_more(
        'like', $self->response->header($name), $regex, $desc
    );
}


sub header_unlike {
    my ($self, $name, $regex, $desc) = @_;
    $desc ||= "header $name does not contain the expression specified";
    return $self->_test_more(
        'unlike', $self->response->header($name), $regex, $desc
    );
}


sub status_is {
    my ($self, $code, $desc) = @_;
    $desc ||= "status is $code";
    return $self->_test_more(
        'is', $self->response->code, $code, $desc
    );
}


sub status_isnt {
    my ($self, $code, $desc) = @_;
    $desc ||= "status is not $code";
    return $self->_test_more(
        'isnt', $self->response->code, $code, $desc
    );
}

sub _test_more {
    my ($self, $name, @args) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 2;
    Test::More->can($name)->(@args);

    return $self;
}

1;

__END__

=pod

=head1 NAME

Plack::Test::Simple::Transaction - PSGI Automated Application Testing Layer

=head1 VERSION

version 0.000007

=head1 SYNOPSIS

    Test::More;
    use Plack::Test::Simple::Transaction;

    # prepare test container
    my $tx  = Plack::Test::Simple::Transaction->new('/path/to/app.psgi');
    my $req = $tx->request;

    # get request setup
    $req->method('GET');
    $request->uri(URI->new('/path/to/resource'));
    $req->headers->authorization_basic('h@cker', 's3cret');
    $req->headers->content_type('application/json');
    $request->content('...');

    # test the requesting
    $tx->content_like(qr/hello world/i, 'test description');

    done_testing;

=head1 DESCRIPTION

Plack::Test::Simple::Transaction is a container for testing HTTP transactions
against a PSGI web application.

=head1 ATTRIBUTES

=head2 data

The data attribute contains the pre-processed data found in the HTTP
response body.

=head2 psgi

The psgi attribute contains a coderef containing the PSGI compliant application
code. If this value is a string containing the path to the psgi file, the
application code will be coerced.

=head2 request

The request attribute contains the L<HTTP::Request> object which will be used
to process the HTTP requests.

=head2 response

The response attribute contains the L<HTTP::Response> object which will be
automatically set upon resolving the corresponding HTTP requests.

=head1 METHODS

=head2 content_is

The content_is method tests if the decoded HTTP response body matches the
value specified.

    $self->content_is($value);
    $self->content_is($value => 'test description');

=head2 content_isnt

The content_isnt method tests if the decoded HTTP response body does not
match the value specified.

    $self->content_isnt($value);
    $self->content_isnt($value => 'test description');

=head2 content_like

The content_like method tests if the decoded HTTP response body contains
matches for the regex value specified.

    $self->content_like(qr/body/);
    $self->content_like(qr/body/ => 'test description');

=head2 content_unlike

The content_unlike method tests if the decoded HTTP response body does not
contain matches for the regex value specified.

    $self->content_isnt(qr/body/);
    $self->content_is(qr/body/ => 'test description');

=head2 data_has

The data_has method tests if the decoded HTTP response data structure
contains matches for the L<Data::DPath> path value specified.

    $self->data_has('/results');
    $self->data_has('/results' => 'test description');

=head2 data_hasnt

The data_hasnt method tests if the decoded HTTP response data structure
does not contain matches for the L<Data::DPath> path value specified.

    $self->data_hasnt('/results');
    $self->data_hasnt('/results' => 'test description');

=head2 data_is_deeply

The data_is_deeply method tests if the decoded HTTP response data structure
contains matches for the L<Data::DPath> path value specified, then tests if
the first match matches the supplied Perl data structure exactly.

    $self->data_is_deeply('/results', $data);
    $self->data_is_deeply('/results', $data => 'test description');

=head2 data_match

The data_match method is an alias for the data_is_deeply method which tests if
the decoded HTTP response data structure contains matches for the
L<Data::DPath> path value specified, then tests if the first match matches the
supplied Perl data structure exactly.

    $self->data_match('/results', $data);
    $self->data_match('/results', $data => 'test description');

=head2 header_is

The header_is method tests if the HTTP response header specified matches
the value specified.

    $self->header_is('Server', 'nginx');
    $self->header_is('Server', 'nginx' => 'test description');

=head2 header_isnt

The header_isnt method tests if the HTTP response header specified does not
match the value specified.

    $self->header_isnt('Server', 'nginx');
    $self->header_isnt('Server', 'nginx' => 'test description');

=head2 header_like

The header_like method tests if the HTTP response header specified contains
matches for the regex value specified.

    $self->header_like('Server', qr/nginx/);
    $self->header_like('Server', qr/nginx/ => 'test description');

=head2 header_unlike

The header_unlike method tests if the HTTP response header specified does
not contain matches for the regex value specified.

    $self->header_unlike('Server', qr/nginx/);
    $self->header_unlike('Server', qr/nginx/ => 'test description');

=head2 status_is

The status_is method tests if the HTTP response code matches the value
specified.

    $self->status_is(404);
    $self->status_is(404 => 'test description');

=head2 status_isnt

The status_isnt method tests if the HTTP response code does not match the
value specified.

    $self->status_isnt(404);
    $self->status_isnt(404 => 'test description');

=head1 AUTHOR

Al Newkirk <anewkirk@ana.io>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Al Newkirk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
