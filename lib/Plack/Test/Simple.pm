# ABSTRACT: Object-Oriented PSGI Application Testing
package Plack::Test::Simple;

use utf8;

use Carp;
use HTTP::Request;
use HTTP::Response;
use Moo;
use Plack::Test::Simple::Transaction;
use Plack::Util;
use URI;

use JSON qw(encode_json);

our $VERSION = '0.02'; # VERSION

sub BUILDARGS {
    my ($class, @args) = @_;

    @args = @args == 1 ? 'HASH' eq ref $args[0] ?
        %{$args[0]} : ('psgi', @args) : @args;

    return {@args};
}

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

sub transaction {
    my ($self, $meth, $path, $cont) = @_;

    my $trans = Plack::Test::Simple::Transaction->new(
        psgi    => $self->psgi,
        request => $self->request->clone
    );

    $meth ||= 'get';
    $path ||= '/';

    $trans->request->method(uc $meth);
    $trans->request->uri(URI->new($path));

    if (defined $cont) {
        $trans->request->content(ref $cont ? encode_json($cont) : $cont);
    }

    return $trans;
}

sub AUTOLOAD {
    my ($self, @args)  = @_;
    my @cmds = split /_/, ($Plack::Test::Simple::AUTOLOAD =~ /.*::([^:]+)/)[0];

    return $self->transaction($cmds[0], @args[0,1])->status_is(
            $cmds[2], $args[2]
        )
        if  @cmds == 3
        && $cmds[0] =~ /^(get|post|put|delete|head|options|connect|patch|trace)$/
        && $cmds[1] eq 'returns'
        && $cmds[2] =~ /^\d{3}$/
    ;

    croak sprintf q(Can't locate object method "%s" via package "%s"),
        join('_', @cmds), ((ref $_[0] || $_[0]) || 'main')
}

sub DESTROY {
    # noop
}

1;

__END__

=pod

=head1 NAME

Plack::Test::Simple - Object-Oriented PSGI Application Testing

=head1 VERSION

version 0.02

=head1 SYNOPSIS

    use Test::More;
    use Plack::Test::Simple;

    # prepare test container
    my $t = Plack::Test::Simple->new('/path/to/app.psgi');

    # global request configuration
    my $req = $t->request;
    $req->headers->authorization_basic('h@cker', 's3cret');
    $req->headers->content_type('application/json');

    # standard GET request test
    # automatic JSON serialization if content-body is a hash/array reference
    my $tx = $t->transaction('get', '/search?q=awesomeness', 'content body');
    $tx->data_has('/results/4/title', 'test description');

    done_testing;

=head1 DESCRIPTION

Plack::Test::Simple is a collection of testing helpers for anyone developing
Plack applications. This module is a wrapper around L<Plack::Test> providing a
unified interface to test PSGI applications using L<HTTP::Request> and
L<HTTP::Response> objects. Typically a Plack web application's deployment stack
includes various middlewares and utilities which are now even easier to test
along-side the actual web application code.

=head1 ATTRIBUTES

=head2 request

The request attribute contains the L<HTTP::Request> object which will be used
to process the HTTP requests. This attribute is never reset.

=head2 psgi

The psgi attribute contains a coderef containing the PSGI compliant application
code. If this value is a string containing the path to the psgi file, the
application code will be coerced.

=head1 METHODS

=head2 transaction

The transaction method returns a L<Plack::Test::Simple::Transaction> object
containing the HTTP request and response object that will be used to facilitate
the HTTP transaction. The actually HTTP request is deferred until the response
object is needed, this allows you to further modify the transactions HTTP
request object before it is processed. This method optionally accepts an HTTP
request method, a request path (or URI object), and content (any string) you
wish to place in the body of the request. If the content body argument is a
hash/array reference, we will attempt to encode and serialize it automatically
as a JSON object. These parameters are used to further modify the transaction's
request object. Please see L<Plack::Test::Simple::Transaction> for more
information on how to use the transaction object to further automate tests.

    my $tx = $self->transaction('post', '/path/to/resource', 'content body');

=head2 connect_returns_CODE

The connect_returns_CODE method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a CODE. The CODE in this method description is a variable which
represents any valid HTTP response code, e.g. 200.

    my $tx = $self->connect_returns_200(
        '/path/to/resource', 'content body'
    );

    # with content body and status test description included
    my $tx = $self->connect_returns_200(
        '/path/to/resource', 'content body', 'test description'
    );

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 delete_returns_CODE

The delete_returns_CODE method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a CODE. The CODE in this method description is a variable which
represents any valid HTTP response code, e.g. 200.

    my $tx = $self->delete_returns_200(
        '/path/to/resource', 'content body'
    );

    # with content body and status test description included
    my $tx = $self->delete_returns_200(
        '/path/to/resource', 'content body', 'test description'
    );

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 get_returns_CODE

The get_returns_CODE method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a CODE. The CODE in this method description is a variable which
represents any valid HTTP response code, e.g. 200.

    my $tx = $self->get_returns_200(
        '/path/to/resource', 'content body'
    );

    # with content body and status test description included
    my $tx = $self->get_returns_200(
        '/path/to/resource', 'content body', 'test description'
    );

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 head_returns_CODE

The head_returns_CODE method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a CODE. The CODE in this method description is a variable which
represents any valid HTTP response code, e.g. 200.

    my $tx = $self->head_returns_200(
        '/path/to/resource', 'content body'
    );

    # with content body and status test description included
    my $tx = $self->head_returns_200(
        '/path/to/resource', 'content body', 'test description'
    );

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 options_returns_CODE

The options_returns_CODE method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a CODE. The CODE in this method description is a variable which
represents any valid HTTP response code, e.g. 200.

    my $tx = $self->options_returns_200(
        '/path/to/resource', 'content body'
    );

    # with content body and status test description included
    my $tx = $self->options_returns_200(
        '/path/to/resource', 'content body', 'test description'
    );

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 patch_returns_CODE

The patch_returns_CODE method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a CODE. The CODE in this method description is a variable which
represents any valid HTTP response code, e.g. 200.

    my $tx = $self->patch_returns_200(
        '/path/to/resource', 'content body'
    );

    # with content body and status test description included
    my $tx = $self->patch_returns_200(
        '/path/to/resource', 'content body', 'test description'
    );

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 post_returns_CODE

The post_returns_CODE method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a CODE. The CODE in this method description is a variable which
represents any valid HTTP response code, e.g. 200.

    my $tx = $self->post_returns_200(
        '/path/to/resource', 'content body'
    );

    # with content body and status test description included
    my $tx = $self->post_returns_200(
        '/path/to/resource', 'content body', 'test description'
    );

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 put_returns_CODE

The put_returns_CODE method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a CODE. The CODE in this method description is a variable which
represents any valid HTTP response code, e.g. 200.

    my $tx = $self->put_returns_200(
        '/path/to/resource', 'content body'
    );

    # with content body and status test description included
    my $tx = $self->put_returns_200(
        '/path/to/resource', 'content body', 'test description'
    );

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 trace_returns_CODE

The trace_returns_CODE method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a CODE. The CODE in this method description is a variable which
represents any valid HTTP response code, e.g. 200.

    my $tx = $self->trace_returns_200(
        '/path/to/resource', 'content body'
    );

    # with content body and status test description included
    my $tx = $self->trace_returns_200(
        '/path/to/resource', 'content body', 'test description'
    );

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head1 AUTHOR

Al Newkirk <anewkirk@ana.io>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Al Newkirk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
