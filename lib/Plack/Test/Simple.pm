# ABSTRACT: Object-Oriented PSGI Application Testing
package Plack::Test::Simple;

use utf8;
use Carp;
use HTTP::Request;
use HTTP::Response;
use URI;
use Moo;
use Plack::Util;
use Plack::Test::Simple::Transaction;

our $VERSION = '0.000004'; # VERSION


sub BUILDARGS {
    my ($class, @args) = @_;

    unshift @args, 'psgi' if $args[0] && !$args[1];
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
    is   => 'rw',
);


sub transaction {
    my ($self, $meth, $path) = @_;

    my $trans = Plack::Test::Simple::Transaction->new(
        psgi    => $self->psgi,
        request => $self->request->clone
    );

    $meth ||= 'get';
    $path ||= '/';

    $trans->request->method(uc $meth);
    $trans->request->uri(URI->new($path));

    return $trans;
}



























































































































































































































































































































































































sub AUTOLOAD {
    my ($self, @args)  = @_;
    my @cmds = split /_/, ($Plack::Test::Simple::AUTOLOAD =~ /.*::([^:]+)/)[0];

    return $self->transaction($cmds[0], $args[0])->status_is($cmds[2], $args[1])
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

version 0.000004

=head1 SYNOPSIS

    Test::More;
    use Plack::Test::Simple;

    # prepare test container
    my $t = Plack::Test::Simple->new('/path/to/app.psgi');

    # global request configuration
    my $req = $t->request;
    $req->headers->authorization_basic('h@cker', 's3cret');
    $req->headers->content_type('application/json');

    # standard GET request test
    my $tx = $t->transaction('get', '/', 'test description');

    # shorthand GET request test
    my $tx = $t->get_returns_200('/', 'test description');
    $tx->content_like(qr/hello world/i, 'test description');

    # shorthand POST request
    my $tx = $t->post_returns_200('/search', {}, 'test description');
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
code or a string containing the path to the psgi file.

=head1 METHODS

=head2 transaction

The transaction method returns a L<Plack::Test::Simple::Transaction> object
containing the HTTP request and response object that will be used to facilitate
the HTTP transaction. The actually HTTP request is deferred until the response
object is needed, this allows you to further modify the transactions HTTP
request object before it is processed. This method optionally accepts an HTTP
request method and a request path (or URI object), and these parameters are
used to further modify the transaction request object. Please see the
L<Plack::Test::Simple::Transaction> for more information on how to use the
transaction object to further automate tests.

    my $tx = $self->transaction('get', '/?query=Perl');

=head2 connect_returns_100

The connect_returns_100 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 100.

    my $tx = $self->connect_returns_100('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(100, 'test description');

=head2 connect_returns_101

The connect_returns_101 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 101.

    my $tx = $self->connect_returns_101('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(101, 'test description');

=head2 connect_returns_200

The connect_returns_200 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 200.

    my $tx = $self->connect_returns_200('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 connect_returns_201

The connect_returns_201 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 201.

    my $tx = $self->connect_returns_201('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(201, 'test description');

=head2 connect_returns_202

The connect_returns_202 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 202.

    my $tx = $self->connect_returns_202('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(202, 'test description');

=head2 connect_returns_203

The connect_returns_203 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 203.

    my $tx = $self->connect_returns_203('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(203, 'test description');

=head2 connect_returns_204

The connect_returns_204 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 204.

    my $tx = $self->connect_returns_204('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(204, 'test description');

=head2 connect_returns_205

The connect_returns_205 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 205.

    my $tx = $self->connect_returns_205('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(205, 'test description');

=head2 connect_returns_206

The connect_returns_206 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 206.

    my $tx = $self->connect_returns_206('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(206, 'test description');

=head2 connect_returns_300

The connect_returns_300 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 300.

    my $tx = $self->connect_returns_300('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(300, 'test description');

=head2 connect_returns_301

The connect_returns_301 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 301.

    my $tx = $self->connect_returns_301('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(301, 'test description');

=head2 connect_returns_302

The connect_returns_302 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 302.

    my $tx = $self->connect_returns_302('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(302, 'test description');

=head2 connect_returns_303

The connect_returns_303 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 303.

    my $tx = $self->connect_returns_303('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(303, 'test description');

=head2 connect_returns_304

The connect_returns_304 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 304.

    my $tx = $self->connect_returns_304('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(304, 'test description');

=head2 connect_returns_305

The connect_returns_305 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 305.

    my $tx = $self->connect_returns_305('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(305, 'test description');

=head2 connect_returns_306

The connect_returns_306 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 306.

    my $tx = $self->connect_returns_306('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(306, 'test description');

=head2 connect_returns_307

The connect_returns_307 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 307.

    my $tx = $self->connect_returns_307('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(307, 'test description');

=head2 connect_returns_308

The connect_returns_308 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 308.

    my $tx = $self->connect_returns_308('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(308, 'test description');

=head2 connect_returns_400

The connect_returns_400 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 400.

    my $tx = $self->connect_returns_400('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(400, 'test description');

=head2 connect_returns_401

The connect_returns_401 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 401.

    my $tx = $self->connect_returns_401('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(401, 'test description');

=head2 connect_returns_402

The connect_returns_402 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 402.

    my $tx = $self->connect_returns_402('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(402, 'test description');

=head2 connect_returns_403

The connect_returns_403 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 403.

    my $tx = $self->connect_returns_403('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(403, 'test description');

=head2 connect_returns_404

The connect_returns_404 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 404.

    my $tx = $self->connect_returns_404('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(404, 'test description');

=head2 connect_returns_405

The connect_returns_405 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 405.

    my $tx = $self->connect_returns_405('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(405, 'test description');

=head2 connect_returns_406

The connect_returns_406 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 406.

    my $tx = $self->connect_returns_406('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(406, 'test description');

=head2 connect_returns_407

The connect_returns_407 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 407.

    my $tx = $self->connect_returns_407('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(407, 'test description');

=head2 connect_returns_408

The connect_returns_408 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 408.

    my $tx = $self->connect_returns_408('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(408, 'test description');

=head2 connect_returns_409

The connect_returns_409 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 409.

    my $tx = $self->connect_returns_409('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(409, 'test description');

=head2 connect_returns_410

The connect_returns_410 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 410.

    my $tx = $self->connect_returns_410('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(410, 'test description');

=head2 connect_returns_411

The connect_returns_411 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 411.

    my $tx = $self->connect_returns_411('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(411, 'test description');

=head2 connect_returns_412

The connect_returns_412 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 412.

    my $tx = $self->connect_returns_412('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(412, 'test description');

=head2 connect_returns_413

The connect_returns_413 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 413.

    my $tx = $self->connect_returns_413('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(413, 'test description');

=head2 connect_returns_414

The connect_returns_414 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 414.

    my $tx = $self->connect_returns_414('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(414, 'test description');

=head2 connect_returns_415

The connect_returns_415 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 415.

    my $tx = $self->connect_returns_415('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(415, 'test description');

=head2 connect_returns_416

The connect_returns_416 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 416.

    my $tx = $self->connect_returns_416('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(416, 'test description');

=head2 connect_returns_417

The connect_returns_417 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 417.

    my $tx = $self->connect_returns_417('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(417, 'test description');

=head2 connect_returns_500

The connect_returns_500 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 500.

    my $tx = $self->connect_returns_500('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(500, 'test description');

=head2 connect_returns_501

The connect_returns_501 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 501.

    my $tx = $self->connect_returns_501('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(501, 'test description');

=head2 connect_returns_502

The connect_returns_502 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 502.

    my $tx = $self->connect_returns_502('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(502, 'test description');

=head2 connect_returns_503

The connect_returns_503 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 503.

    my $tx = $self->connect_returns_503('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(503, 'test description');

=head2 connect_returns_504

The connect_returns_504 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 504.

    my $tx = $self->connect_returns_504('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(504, 'test description');

=head2 connect_returns_505

The connect_returns_505 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 505.

    my $tx = $self->connect_returns_505('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('connect', '/path/to/resource');
    $tx->status_is(505, 'test description');

=head2 delete_returns_100

The delete_returns_100 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 100.

    my $tx = $self->delete_returns_100('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(100, 'test description');

=head2 delete_returns_101

The delete_returns_101 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 101.

    my $tx = $self->delete_returns_101('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(101, 'test description');

=head2 delete_returns_200

The delete_returns_200 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 200.

    my $tx = $self->delete_returns_200('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 delete_returns_201

The delete_returns_201 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 201.

    my $tx = $self->delete_returns_201('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(201, 'test description');

=head2 delete_returns_202

The delete_returns_202 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 202.

    my $tx = $self->delete_returns_202('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(202, 'test description');

=head2 delete_returns_203

The delete_returns_203 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 203.

    my $tx = $self->delete_returns_203('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(203, 'test description');

=head2 delete_returns_204

The delete_returns_204 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 204.

    my $tx = $self->delete_returns_204('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(204, 'test description');

=head2 delete_returns_205

The delete_returns_205 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 205.

    my $tx = $self->delete_returns_205('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(205, 'test description');

=head2 delete_returns_206

The delete_returns_206 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 206.

    my $tx = $self->delete_returns_206('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(206, 'test description');

=head2 delete_returns_300

The delete_returns_300 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 300.

    my $tx = $self->delete_returns_300('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(300, 'test description');

=head2 delete_returns_301

The delete_returns_301 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 301.

    my $tx = $self->delete_returns_301('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(301, 'test description');

=head2 delete_returns_302

The delete_returns_302 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 302.

    my $tx = $self->delete_returns_302('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(302, 'test description');

=head2 delete_returns_303

The delete_returns_303 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 303.

    my $tx = $self->delete_returns_303('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(303, 'test description');

=head2 delete_returns_304

The delete_returns_304 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 304.

    my $tx = $self->delete_returns_304('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(304, 'test description');

=head2 delete_returns_305

The delete_returns_305 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 305.

    my $tx = $self->delete_returns_305('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(305, 'test description');

=head2 delete_returns_306

The delete_returns_306 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 306.

    my $tx = $self->delete_returns_306('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(306, 'test description');

=head2 delete_returns_307

The delete_returns_307 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 307.

    my $tx = $self->delete_returns_307('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(307, 'test description');

=head2 delete_returns_308

The delete_returns_308 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 308.

    my $tx = $self->delete_returns_308('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(308, 'test description');

=head2 delete_returns_400

The delete_returns_400 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 400.

    my $tx = $self->delete_returns_400('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(400, 'test description');

=head2 delete_returns_401

The delete_returns_401 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 401.

    my $tx = $self->delete_returns_401('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(401, 'test description');

=head2 delete_returns_402

The delete_returns_402 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 402.

    my $tx = $self->delete_returns_402('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(402, 'test description');

=head2 delete_returns_403

The delete_returns_403 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 403.

    my $tx = $self->delete_returns_403('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(403, 'test description');

=head2 delete_returns_404

The delete_returns_404 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 404.

    my $tx = $self->delete_returns_404('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(404, 'test description');

=head2 delete_returns_405

The delete_returns_405 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 405.

    my $tx = $self->delete_returns_405('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(405, 'test description');

=head2 delete_returns_406

The delete_returns_406 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 406.

    my $tx = $self->delete_returns_406('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(406, 'test description');

=head2 delete_returns_407

The delete_returns_407 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 407.

    my $tx = $self->delete_returns_407('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(407, 'test description');

=head2 delete_returns_408

The delete_returns_408 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 408.

    my $tx = $self->delete_returns_408('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(408, 'test description');

=head2 delete_returns_409

The delete_returns_409 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 409.

    my $tx = $self->delete_returns_409('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(409, 'test description');

=head2 delete_returns_410

The delete_returns_410 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 410.

    my $tx = $self->delete_returns_410('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(410, 'test description');

=head2 delete_returns_411

The delete_returns_411 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 411.

    my $tx = $self->delete_returns_411('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(411, 'test description');

=head2 delete_returns_412

The delete_returns_412 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 412.

    my $tx = $self->delete_returns_412('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(412, 'test description');

=head2 delete_returns_413

The delete_returns_413 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 413.

    my $tx = $self->delete_returns_413('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(413, 'test description');

=head2 delete_returns_414

The delete_returns_414 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 414.

    my $tx = $self->delete_returns_414('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(414, 'test description');

=head2 delete_returns_415

The delete_returns_415 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 415.

    my $tx = $self->delete_returns_415('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(415, 'test description');

=head2 delete_returns_416

The delete_returns_416 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 416.

    my $tx = $self->delete_returns_416('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(416, 'test description');

=head2 delete_returns_417

The delete_returns_417 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 417.

    my $tx = $self->delete_returns_417('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(417, 'test description');

=head2 delete_returns_500

The delete_returns_500 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 500.

    my $tx = $self->delete_returns_500('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(500, 'test description');

=head2 delete_returns_501

The delete_returns_501 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 501.

    my $tx = $self->delete_returns_501('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(501, 'test description');

=head2 delete_returns_502

The delete_returns_502 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 502.

    my $tx = $self->delete_returns_502('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(502, 'test description');

=head2 delete_returns_503

The delete_returns_503 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 503.

    my $tx = $self->delete_returns_503('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(503, 'test description');

=head2 delete_returns_504

The delete_returns_504 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 504.

    my $tx = $self->delete_returns_504('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(504, 'test description');

=head2 delete_returns_505

The delete_returns_505 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 505.

    my $tx = $self->delete_returns_505('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('delete', '/path/to/resource');
    $tx->status_is(505, 'test description');

=head2 get_returns_100

The get_returns_100 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 100.

    my $tx = $self->get_returns_100('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(100, 'test description');

=head2 get_returns_101

The get_returns_101 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 101.

    my $tx = $self->get_returns_101('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(101, 'test description');

=head2 get_returns_200

The get_returns_200 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 200.

    my $tx = $self->get_returns_200('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 get_returns_201

The get_returns_201 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 201.

    my $tx = $self->get_returns_201('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(201, 'test description');

=head2 get_returns_202

The get_returns_202 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 202.

    my $tx = $self->get_returns_202('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(202, 'test description');

=head2 get_returns_203

The get_returns_203 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 203.

    my $tx = $self->get_returns_203('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(203, 'test description');

=head2 get_returns_204

The get_returns_204 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 204.

    my $tx = $self->get_returns_204('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(204, 'test description');

=head2 get_returns_205

The get_returns_205 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 205.

    my $tx = $self->get_returns_205('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(205, 'test description');

=head2 get_returns_206

The get_returns_206 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 206.

    my $tx = $self->get_returns_206('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(206, 'test description');

=head2 get_returns_300

The get_returns_300 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 300.

    my $tx = $self->get_returns_300('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(300, 'test description');

=head2 get_returns_301

The get_returns_301 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 301.

    my $tx = $self->get_returns_301('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(301, 'test description');

=head2 get_returns_302

The get_returns_302 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 302.

    my $tx = $self->get_returns_302('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(302, 'test description');

=head2 get_returns_303

The get_returns_303 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 303.

    my $tx = $self->get_returns_303('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(303, 'test description');

=head2 get_returns_304

The get_returns_304 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 304.

    my $tx = $self->get_returns_304('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(304, 'test description');

=head2 get_returns_305

The get_returns_305 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 305.

    my $tx = $self->get_returns_305('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(305, 'test description');

=head2 get_returns_306

The get_returns_306 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 306.

    my $tx = $self->get_returns_306('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(306, 'test description');

=head2 get_returns_307

The get_returns_307 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 307.

    my $tx = $self->get_returns_307('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(307, 'test description');

=head2 get_returns_308

The get_returns_308 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 308.

    my $tx = $self->get_returns_308('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(308, 'test description');

=head2 get_returns_400

The get_returns_400 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 400.

    my $tx = $self->get_returns_400('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(400, 'test description');

=head2 get_returns_401

The get_returns_401 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 401.

    my $tx = $self->get_returns_401('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(401, 'test description');

=head2 get_returns_402

The get_returns_402 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 402.

    my $tx = $self->get_returns_402('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(402, 'test description');

=head2 get_returns_403

The get_returns_403 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 403.

    my $tx = $self->get_returns_403('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(403, 'test description');

=head2 get_returns_404

The get_returns_404 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 404.

    my $tx = $self->get_returns_404('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(404, 'test description');

=head2 get_returns_405

The get_returns_405 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 405.

    my $tx = $self->get_returns_405('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(405, 'test description');

=head2 get_returns_406

The get_returns_406 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 406.

    my $tx = $self->get_returns_406('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(406, 'test description');

=head2 get_returns_407

The get_returns_407 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 407.

    my $tx = $self->get_returns_407('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(407, 'test description');

=head2 get_returns_408

The get_returns_408 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 408.

    my $tx = $self->get_returns_408('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(408, 'test description');

=head2 get_returns_409

The get_returns_409 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 409.

    my $tx = $self->get_returns_409('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(409, 'test description');

=head2 get_returns_410

The get_returns_410 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 410.

    my $tx = $self->get_returns_410('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(410, 'test description');

=head2 get_returns_411

The get_returns_411 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 411.

    my $tx = $self->get_returns_411('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(411, 'test description');

=head2 get_returns_412

The get_returns_412 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 412.

    my $tx = $self->get_returns_412('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(412, 'test description');

=head2 get_returns_413

The get_returns_413 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 413.

    my $tx = $self->get_returns_413('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(413, 'test description');

=head2 get_returns_414

The get_returns_414 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 414.

    my $tx = $self->get_returns_414('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(414, 'test description');

=head2 get_returns_415

The get_returns_415 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 415.

    my $tx = $self->get_returns_415('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(415, 'test description');

=head2 get_returns_416

The get_returns_416 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 416.

    my $tx = $self->get_returns_416('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(416, 'test description');

=head2 get_returns_417

The get_returns_417 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 417.

    my $tx = $self->get_returns_417('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(417, 'test description');

=head2 get_returns_500

The get_returns_500 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 500.

    my $tx = $self->get_returns_500('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(500, 'test description');

=head2 get_returns_501

The get_returns_501 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 501.

    my $tx = $self->get_returns_501('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(501, 'test description');

=head2 get_returns_502

The get_returns_502 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 502.

    my $tx = $self->get_returns_502('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(502, 'test description');

=head2 get_returns_503

The get_returns_503 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 503.

    my $tx = $self->get_returns_503('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(503, 'test description');

=head2 get_returns_504

The get_returns_504 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 504.

    my $tx = $self->get_returns_504('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(504, 'test description');

=head2 get_returns_505

The get_returns_505 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 505.

    my $tx = $self->get_returns_505('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('get', '/path/to/resource');
    $tx->status_is(505, 'test description');

=head2 head_returns_100

The head_returns_100 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 100.

    my $tx = $self->head_returns_100('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(100, 'test description');

=head2 head_returns_101

The head_returns_101 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 101.

    my $tx = $self->head_returns_101('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(101, 'test description');

=head2 head_returns_200

The head_returns_200 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 200.

    my $tx = $self->head_returns_200('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 head_returns_201

The head_returns_201 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 201.

    my $tx = $self->head_returns_201('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(201, 'test description');

=head2 head_returns_202

The head_returns_202 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 202.

    my $tx = $self->head_returns_202('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(202, 'test description');

=head2 head_returns_203

The head_returns_203 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 203.

    my $tx = $self->head_returns_203('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(203, 'test description');

=head2 head_returns_204

The head_returns_204 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 204.

    my $tx = $self->head_returns_204('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(204, 'test description');

=head2 head_returns_205

The head_returns_205 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 205.

    my $tx = $self->head_returns_205('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(205, 'test description');

=head2 head_returns_206

The head_returns_206 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 206.

    my $tx = $self->head_returns_206('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(206, 'test description');

=head2 head_returns_300

The head_returns_300 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 300.

    my $tx = $self->head_returns_300('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(300, 'test description');

=head2 head_returns_301

The head_returns_301 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 301.

    my $tx = $self->head_returns_301('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(301, 'test description');

=head2 head_returns_302

The head_returns_302 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 302.

    my $tx = $self->head_returns_302('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(302, 'test description');

=head2 head_returns_303

The head_returns_303 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 303.

    my $tx = $self->head_returns_303('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(303, 'test description');

=head2 head_returns_304

The head_returns_304 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 304.

    my $tx = $self->head_returns_304('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(304, 'test description');

=head2 head_returns_305

The head_returns_305 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 305.

    my $tx = $self->head_returns_305('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(305, 'test description');

=head2 head_returns_306

The head_returns_306 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 306.

    my $tx = $self->head_returns_306('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(306, 'test description');

=head2 head_returns_307

The head_returns_307 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 307.

    my $tx = $self->head_returns_307('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(307, 'test description');

=head2 head_returns_308

The head_returns_308 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 308.

    my $tx = $self->head_returns_308('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(308, 'test description');

=head2 head_returns_400

The head_returns_400 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 400.

    my $tx = $self->head_returns_400('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(400, 'test description');

=head2 head_returns_401

The head_returns_401 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 401.

    my $tx = $self->head_returns_401('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(401, 'test description');

=head2 head_returns_402

The head_returns_402 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 402.

    my $tx = $self->head_returns_402('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(402, 'test description');

=head2 head_returns_403

The head_returns_403 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 403.

    my $tx = $self->head_returns_403('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(403, 'test description');

=head2 head_returns_404

The head_returns_404 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 404.

    my $tx = $self->head_returns_404('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(404, 'test description');

=head2 head_returns_405

The head_returns_405 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 405.

    my $tx = $self->head_returns_405('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(405, 'test description');

=head2 head_returns_406

The head_returns_406 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 406.

    my $tx = $self->head_returns_406('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(406, 'test description');

=head2 head_returns_407

The head_returns_407 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 407.

    my $tx = $self->head_returns_407('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(407, 'test description');

=head2 head_returns_408

The head_returns_408 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 408.

    my $tx = $self->head_returns_408('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(408, 'test description');

=head2 head_returns_409

The head_returns_409 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 409.

    my $tx = $self->head_returns_409('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(409, 'test description');

=head2 head_returns_410

The head_returns_410 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 410.

    my $tx = $self->head_returns_410('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(410, 'test description');

=head2 head_returns_411

The head_returns_411 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 411.

    my $tx = $self->head_returns_411('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(411, 'test description');

=head2 head_returns_412

The head_returns_412 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 412.

    my $tx = $self->head_returns_412('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(412, 'test description');

=head2 head_returns_413

The head_returns_413 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 413.

    my $tx = $self->head_returns_413('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(413, 'test description');

=head2 head_returns_414

The head_returns_414 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 414.

    my $tx = $self->head_returns_414('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(414, 'test description');

=head2 head_returns_415

The head_returns_415 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 415.

    my $tx = $self->head_returns_415('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(415, 'test description');

=head2 head_returns_416

The head_returns_416 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 416.

    my $tx = $self->head_returns_416('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(416, 'test description');

=head2 head_returns_417

The head_returns_417 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 417.

    my $tx = $self->head_returns_417('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(417, 'test description');

=head2 head_returns_500

The head_returns_500 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 500.

    my $tx = $self->head_returns_500('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(500, 'test description');

=head2 head_returns_501

The head_returns_501 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 501.

    my $tx = $self->head_returns_501('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(501, 'test description');

=head2 head_returns_502

The head_returns_502 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 502.

    my $tx = $self->head_returns_502('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(502, 'test description');

=head2 head_returns_503

The head_returns_503 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 503.

    my $tx = $self->head_returns_503('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(503, 'test description');

=head2 head_returns_504

The head_returns_504 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 504.

    my $tx = $self->head_returns_504('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(504, 'test description');

=head2 head_returns_505

The head_returns_505 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 505.

    my $tx = $self->head_returns_505('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('head', '/path/to/resource');
    $tx->status_is(505, 'test description');

=head2 options_returns_100

The options_returns_100 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 100.

    my $tx = $self->options_returns_100('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(100, 'test description');

=head2 options_returns_101

The options_returns_101 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 101.

    my $tx = $self->options_returns_101('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(101, 'test description');

=head2 options_returns_200

The options_returns_200 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 200.

    my $tx = $self->options_returns_200('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 options_returns_201

The options_returns_201 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 201.

    my $tx = $self->options_returns_201('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(201, 'test description');

=head2 options_returns_202

The options_returns_202 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 202.

    my $tx = $self->options_returns_202('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(202, 'test description');

=head2 options_returns_203

The options_returns_203 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 203.

    my $tx = $self->options_returns_203('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(203, 'test description');

=head2 options_returns_204

The options_returns_204 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 204.

    my $tx = $self->options_returns_204('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(204, 'test description');

=head2 options_returns_205

The options_returns_205 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 205.

    my $tx = $self->options_returns_205('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(205, 'test description');

=head2 options_returns_206

The options_returns_206 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 206.

    my $tx = $self->options_returns_206('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(206, 'test description');

=head2 options_returns_300

The options_returns_300 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 300.

    my $tx = $self->options_returns_300('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(300, 'test description');

=head2 options_returns_301

The options_returns_301 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 301.

    my $tx = $self->options_returns_301('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(301, 'test description');

=head2 options_returns_302

The options_returns_302 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 302.

    my $tx = $self->options_returns_302('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(302, 'test description');

=head2 options_returns_303

The options_returns_303 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 303.

    my $tx = $self->options_returns_303('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(303, 'test description');

=head2 options_returns_304

The options_returns_304 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 304.

    my $tx = $self->options_returns_304('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(304, 'test description');

=head2 options_returns_305

The options_returns_305 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 305.

    my $tx = $self->options_returns_305('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(305, 'test description');

=head2 options_returns_306

The options_returns_306 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 306.

    my $tx = $self->options_returns_306('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(306, 'test description');

=head2 options_returns_307

The options_returns_307 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 307.

    my $tx = $self->options_returns_307('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(307, 'test description');

=head2 options_returns_308

The options_returns_308 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 308.

    my $tx = $self->options_returns_308('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(308, 'test description');

=head2 options_returns_400

The options_returns_400 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 400.

    my $tx = $self->options_returns_400('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(400, 'test description');

=head2 options_returns_401

The options_returns_401 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 401.

    my $tx = $self->options_returns_401('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(401, 'test description');

=head2 options_returns_402

The options_returns_402 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 402.

    my $tx = $self->options_returns_402('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(402, 'test description');

=head2 options_returns_403

The options_returns_403 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 403.

    my $tx = $self->options_returns_403('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(403, 'test description');

=head2 options_returns_404

The options_returns_404 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 404.

    my $tx = $self->options_returns_404('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(404, 'test description');

=head2 options_returns_405

The options_returns_405 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 405.

    my $tx = $self->options_returns_405('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(405, 'test description');

=head2 options_returns_406

The options_returns_406 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 406.

    my $tx = $self->options_returns_406('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(406, 'test description');

=head2 options_returns_407

The options_returns_407 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 407.

    my $tx = $self->options_returns_407('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(407, 'test description');

=head2 options_returns_408

The options_returns_408 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 408.

    my $tx = $self->options_returns_408('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(408, 'test description');

=head2 options_returns_409

The options_returns_409 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 409.

    my $tx = $self->options_returns_409('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(409, 'test description');

=head2 options_returns_410

The options_returns_410 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 410.

    my $tx = $self->options_returns_410('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(410, 'test description');

=head2 options_returns_411

The options_returns_411 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 411.

    my $tx = $self->options_returns_411('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(411, 'test description');

=head2 options_returns_412

The options_returns_412 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 412.

    my $tx = $self->options_returns_412('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(412, 'test description');

=head2 options_returns_413

The options_returns_413 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 413.

    my $tx = $self->options_returns_413('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(413, 'test description');

=head2 options_returns_414

The options_returns_414 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 414.

    my $tx = $self->options_returns_414('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(414, 'test description');

=head2 options_returns_415

The options_returns_415 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 415.

    my $tx = $self->options_returns_415('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(415, 'test description');

=head2 options_returns_416

The options_returns_416 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 416.

    my $tx = $self->options_returns_416('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(416, 'test description');

=head2 options_returns_417

The options_returns_417 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 417.

    my $tx = $self->options_returns_417('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(417, 'test description');

=head2 options_returns_500

The options_returns_500 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 500.

    my $tx = $self->options_returns_500('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(500, 'test description');

=head2 options_returns_501

The options_returns_501 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 501.

    my $tx = $self->options_returns_501('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(501, 'test description');

=head2 options_returns_502

The options_returns_502 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 502.

    my $tx = $self->options_returns_502('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(502, 'test description');

=head2 options_returns_503

The options_returns_503 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 503.

    my $tx = $self->options_returns_503('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(503, 'test description');

=head2 options_returns_504

The options_returns_504 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 504.

    my $tx = $self->options_returns_504('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(504, 'test description');

=head2 options_returns_505

The options_returns_505 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 505.

    my $tx = $self->options_returns_505('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('options', '/path/to/resource');
    $tx->status_is(505, 'test description');

=head2 patch_returns_100

The patch_returns_100 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 100.

    my $tx = $self->patch_returns_100('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(100, 'test description');

=head2 patch_returns_101

The patch_returns_101 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 101.

    my $tx = $self->patch_returns_101('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(101, 'test description');

=head2 patch_returns_200

The patch_returns_200 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 200.

    my $tx = $self->patch_returns_200('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 patch_returns_201

The patch_returns_201 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 201.

    my $tx = $self->patch_returns_201('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(201, 'test description');

=head2 patch_returns_202

The patch_returns_202 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 202.

    my $tx = $self->patch_returns_202('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(202, 'test description');

=head2 patch_returns_203

The patch_returns_203 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 203.

    my $tx = $self->patch_returns_203('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(203, 'test description');

=head2 patch_returns_204

The patch_returns_204 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 204.

    my $tx = $self->patch_returns_204('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(204, 'test description');

=head2 patch_returns_205

The patch_returns_205 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 205.

    my $tx = $self->patch_returns_205('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(205, 'test description');

=head2 patch_returns_206

The patch_returns_206 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 206.

    my $tx = $self->patch_returns_206('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(206, 'test description');

=head2 patch_returns_300

The patch_returns_300 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 300.

    my $tx = $self->patch_returns_300('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(300, 'test description');

=head2 patch_returns_301

The patch_returns_301 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 301.

    my $tx = $self->patch_returns_301('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(301, 'test description');

=head2 patch_returns_302

The patch_returns_302 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 302.

    my $tx = $self->patch_returns_302('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(302, 'test description');

=head2 patch_returns_303

The patch_returns_303 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 303.

    my $tx = $self->patch_returns_303('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(303, 'test description');

=head2 patch_returns_304

The patch_returns_304 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 304.

    my $tx = $self->patch_returns_304('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(304, 'test description');

=head2 patch_returns_305

The patch_returns_305 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 305.

    my $tx = $self->patch_returns_305('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(305, 'test description');

=head2 patch_returns_306

The patch_returns_306 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 306.

    my $tx = $self->patch_returns_306('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(306, 'test description');

=head2 patch_returns_307

The patch_returns_307 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 307.

    my $tx = $self->patch_returns_307('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(307, 'test description');

=head2 patch_returns_308

The patch_returns_308 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 308.

    my $tx = $self->patch_returns_308('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(308, 'test description');

=head2 patch_returns_400

The patch_returns_400 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 400.

    my $tx = $self->patch_returns_400('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(400, 'test description');

=head2 patch_returns_401

The patch_returns_401 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 401.

    my $tx = $self->patch_returns_401('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(401, 'test description');

=head2 patch_returns_402

The patch_returns_402 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 402.

    my $tx = $self->patch_returns_402('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(402, 'test description');

=head2 patch_returns_403

The patch_returns_403 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 403.

    my $tx = $self->patch_returns_403('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(403, 'test description');

=head2 patch_returns_404

The patch_returns_404 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 404.

    my $tx = $self->patch_returns_404('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(404, 'test description');

=head2 patch_returns_405

The patch_returns_405 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 405.

    my $tx = $self->patch_returns_405('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(405, 'test description');

=head2 patch_returns_406

The patch_returns_406 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 406.

    my $tx = $self->patch_returns_406('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(406, 'test description');

=head2 patch_returns_407

The patch_returns_407 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 407.

    my $tx = $self->patch_returns_407('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(407, 'test description');

=head2 patch_returns_408

The patch_returns_408 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 408.

    my $tx = $self->patch_returns_408('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(408, 'test description');

=head2 patch_returns_409

The patch_returns_409 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 409.

    my $tx = $self->patch_returns_409('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(409, 'test description');

=head2 patch_returns_410

The patch_returns_410 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 410.

    my $tx = $self->patch_returns_410('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(410, 'test description');

=head2 patch_returns_411

The patch_returns_411 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 411.

    my $tx = $self->patch_returns_411('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(411, 'test description');

=head2 patch_returns_412

The patch_returns_412 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 412.

    my $tx = $self->patch_returns_412('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(412, 'test description');

=head2 patch_returns_413

The patch_returns_413 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 413.

    my $tx = $self->patch_returns_413('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(413, 'test description');

=head2 patch_returns_414

The patch_returns_414 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 414.

    my $tx = $self->patch_returns_414('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(414, 'test description');

=head2 patch_returns_415

The patch_returns_415 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 415.

    my $tx = $self->patch_returns_415('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(415, 'test description');

=head2 patch_returns_416

The patch_returns_416 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 416.

    my $tx = $self->patch_returns_416('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(416, 'test description');

=head2 patch_returns_417

The patch_returns_417 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 417.

    my $tx = $self->patch_returns_417('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(417, 'test description');

=head2 patch_returns_500

The patch_returns_500 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 500.

    my $tx = $self->patch_returns_500('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(500, 'test description');

=head2 patch_returns_501

The patch_returns_501 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 501.

    my $tx = $self->patch_returns_501('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(501, 'test description');

=head2 patch_returns_502

The patch_returns_502 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 502.

    my $tx = $self->patch_returns_502('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(502, 'test description');

=head2 patch_returns_503

The patch_returns_503 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 503.

    my $tx = $self->patch_returns_503('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(503, 'test description');

=head2 patch_returns_504

The patch_returns_504 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 504.

    my $tx = $self->patch_returns_504('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(504, 'test description');

=head2 patch_returns_505

The patch_returns_505 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 505.

    my $tx = $self->patch_returns_505('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('patch', '/path/to/resource');
    $tx->status_is(505, 'test description');

=head2 post_returns_100

The post_returns_100 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 100.

    my $tx = $self->post_returns_100('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(100, 'test description');

=head2 post_returns_101

The post_returns_101 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 101.

    my $tx = $self->post_returns_101('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(101, 'test description');

=head2 post_returns_200

The post_returns_200 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 200.

    my $tx = $self->post_returns_200('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 post_returns_201

The post_returns_201 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 201.

    my $tx = $self->post_returns_201('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(201, 'test description');

=head2 post_returns_202

The post_returns_202 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 202.

    my $tx = $self->post_returns_202('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(202, 'test description');

=head2 post_returns_203

The post_returns_203 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 203.

    my $tx = $self->post_returns_203('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(203, 'test description');

=head2 post_returns_204

The post_returns_204 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 204.

    my $tx = $self->post_returns_204('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(204, 'test description');

=head2 post_returns_205

The post_returns_205 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 205.

    my $tx = $self->post_returns_205('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(205, 'test description');

=head2 post_returns_206

The post_returns_206 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 206.

    my $tx = $self->post_returns_206('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(206, 'test description');

=head2 post_returns_300

The post_returns_300 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 300.

    my $tx = $self->post_returns_300('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(300, 'test description');

=head2 post_returns_301

The post_returns_301 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 301.

    my $tx = $self->post_returns_301('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(301, 'test description');

=head2 post_returns_302

The post_returns_302 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 302.

    my $tx = $self->post_returns_302('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(302, 'test description');

=head2 post_returns_303

The post_returns_303 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 303.

    my $tx = $self->post_returns_303('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(303, 'test description');

=head2 post_returns_304

The post_returns_304 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 304.

    my $tx = $self->post_returns_304('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(304, 'test description');

=head2 post_returns_305

The post_returns_305 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 305.

    my $tx = $self->post_returns_305('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(305, 'test description');

=head2 post_returns_306

The post_returns_306 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 306.

    my $tx = $self->post_returns_306('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(306, 'test description');

=head2 post_returns_307

The post_returns_307 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 307.

    my $tx = $self->post_returns_307('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(307, 'test description');

=head2 post_returns_308

The post_returns_308 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 308.

    my $tx = $self->post_returns_308('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(308, 'test description');

=head2 post_returns_400

The post_returns_400 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 400.

    my $tx = $self->post_returns_400('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(400, 'test description');

=head2 post_returns_401

The post_returns_401 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 401.

    my $tx = $self->post_returns_401('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(401, 'test description');

=head2 post_returns_402

The post_returns_402 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 402.

    my $tx = $self->post_returns_402('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(402, 'test description');

=head2 post_returns_403

The post_returns_403 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 403.

    my $tx = $self->post_returns_403('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(403, 'test description');

=head2 post_returns_404

The post_returns_404 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 404.

    my $tx = $self->post_returns_404('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(404, 'test description');

=head2 post_returns_405

The post_returns_405 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 405.

    my $tx = $self->post_returns_405('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(405, 'test description');

=head2 post_returns_406

The post_returns_406 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 406.

    my $tx = $self->post_returns_406('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(406, 'test description');

=head2 post_returns_407

The post_returns_407 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 407.

    my $tx = $self->post_returns_407('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(407, 'test description');

=head2 post_returns_408

The post_returns_408 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 408.

    my $tx = $self->post_returns_408('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(408, 'test description');

=head2 post_returns_409

The post_returns_409 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 409.

    my $tx = $self->post_returns_409('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(409, 'test description');

=head2 post_returns_410

The post_returns_410 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 410.

    my $tx = $self->post_returns_410('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(410, 'test description');

=head2 post_returns_411

The post_returns_411 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 411.

    my $tx = $self->post_returns_411('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(411, 'test description');

=head2 post_returns_412

The post_returns_412 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 412.

    my $tx = $self->post_returns_412('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(412, 'test description');

=head2 post_returns_413

The post_returns_413 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 413.

    my $tx = $self->post_returns_413('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(413, 'test description');

=head2 post_returns_414

The post_returns_414 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 414.

    my $tx = $self->post_returns_414('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(414, 'test description');

=head2 post_returns_415

The post_returns_415 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 415.

    my $tx = $self->post_returns_415('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(415, 'test description');

=head2 post_returns_416

The post_returns_416 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 416.

    my $tx = $self->post_returns_416('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(416, 'test description');

=head2 post_returns_417

The post_returns_417 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 417.

    my $tx = $self->post_returns_417('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(417, 'test description');

=head2 post_returns_500

The post_returns_500 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 500.

    my $tx = $self->post_returns_500('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(500, 'test description');

=head2 post_returns_501

The post_returns_501 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 501.

    my $tx = $self->post_returns_501('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(501, 'test description');

=head2 post_returns_502

The post_returns_502 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 502.

    my $tx = $self->post_returns_502('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(502, 'test description');

=head2 post_returns_503

The post_returns_503 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 503.

    my $tx = $self->post_returns_503('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(503, 'test description');

=head2 post_returns_504

The post_returns_504 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 504.

    my $tx = $self->post_returns_504('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(504, 'test description');

=head2 post_returns_505

The post_returns_505 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 505.

    my $tx = $self->post_returns_505('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('post', '/path/to/resource');
    $tx->status_is(505, 'test description');

=head2 put_returns_100

The put_returns_100 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 100.

    my $tx = $self->put_returns_100('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(100, 'test description');

=head2 put_returns_101

The put_returns_101 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 101.

    my $tx = $self->put_returns_101('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(101, 'test description');

=head2 put_returns_200

The put_returns_200 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 200.

    my $tx = $self->put_returns_200('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 put_returns_201

The put_returns_201 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 201.

    my $tx = $self->put_returns_201('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(201, 'test description');

=head2 put_returns_202

The put_returns_202 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 202.

    my $tx = $self->put_returns_202('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(202, 'test description');

=head2 put_returns_203

The put_returns_203 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 203.

    my $tx = $self->put_returns_203('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(203, 'test description');

=head2 put_returns_204

The put_returns_204 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 204.

    my $tx = $self->put_returns_204('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(204, 'test description');

=head2 put_returns_205

The put_returns_205 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 205.

    my $tx = $self->put_returns_205('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(205, 'test description');

=head2 put_returns_206

The put_returns_206 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 206.

    my $tx = $self->put_returns_206('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(206, 'test description');

=head2 put_returns_300

The put_returns_300 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 300.

    my $tx = $self->put_returns_300('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(300, 'test description');

=head2 put_returns_301

The put_returns_301 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 301.

    my $tx = $self->put_returns_301('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(301, 'test description');

=head2 put_returns_302

The put_returns_302 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 302.

    my $tx = $self->put_returns_302('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(302, 'test description');

=head2 put_returns_303

The put_returns_303 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 303.

    my $tx = $self->put_returns_303('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(303, 'test description');

=head2 put_returns_304

The put_returns_304 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 304.

    my $tx = $self->put_returns_304('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(304, 'test description');

=head2 put_returns_305

The put_returns_305 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 305.

    my $tx = $self->put_returns_305('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(305, 'test description');

=head2 put_returns_306

The put_returns_306 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 306.

    my $tx = $self->put_returns_306('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(306, 'test description');

=head2 put_returns_307

The put_returns_307 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 307.

    my $tx = $self->put_returns_307('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(307, 'test description');

=head2 put_returns_308

The put_returns_308 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 308.

    my $tx = $self->put_returns_308('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(308, 'test description');

=head2 put_returns_400

The put_returns_400 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 400.

    my $tx = $self->put_returns_400('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(400, 'test description');

=head2 put_returns_401

The put_returns_401 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 401.

    my $tx = $self->put_returns_401('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(401, 'test description');

=head2 put_returns_402

The put_returns_402 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 402.

    my $tx = $self->put_returns_402('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(402, 'test description');

=head2 put_returns_403

The put_returns_403 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 403.

    my $tx = $self->put_returns_403('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(403, 'test description');

=head2 put_returns_404

The put_returns_404 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 404.

    my $tx = $self->put_returns_404('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(404, 'test description');

=head2 put_returns_405

The put_returns_405 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 405.

    my $tx = $self->put_returns_405('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(405, 'test description');

=head2 put_returns_406

The put_returns_406 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 406.

    my $tx = $self->put_returns_406('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(406, 'test description');

=head2 put_returns_407

The put_returns_407 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 407.

    my $tx = $self->put_returns_407('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(407, 'test description');

=head2 put_returns_408

The put_returns_408 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 408.

    my $tx = $self->put_returns_408('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(408, 'test description');

=head2 put_returns_409

The put_returns_409 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 409.

    my $tx = $self->put_returns_409('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(409, 'test description');

=head2 put_returns_410

The put_returns_410 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 410.

    my $tx = $self->put_returns_410('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(410, 'test description');

=head2 put_returns_411

The put_returns_411 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 411.

    my $tx = $self->put_returns_411('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(411, 'test description');

=head2 put_returns_412

The put_returns_412 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 412.

    my $tx = $self->put_returns_412('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(412, 'test description');

=head2 put_returns_413

The put_returns_413 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 413.

    my $tx = $self->put_returns_413('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(413, 'test description');

=head2 put_returns_414

The put_returns_414 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 414.

    my $tx = $self->put_returns_414('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(414, 'test description');

=head2 put_returns_415

The put_returns_415 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 415.

    my $tx = $self->put_returns_415('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(415, 'test description');

=head2 put_returns_416

The put_returns_416 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 416.

    my $tx = $self->put_returns_416('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(416, 'test description');

=head2 put_returns_417

The put_returns_417 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 417.

    my $tx = $self->put_returns_417('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(417, 'test description');

=head2 put_returns_500

The put_returns_500 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 500.

    my $tx = $self->put_returns_500('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(500, 'test description');

=head2 put_returns_501

The put_returns_501 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 501.

    my $tx = $self->put_returns_501('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(501, 'test description');

=head2 put_returns_502

The put_returns_502 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 502.

    my $tx = $self->put_returns_502('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(502, 'test description');

=head2 put_returns_503

The put_returns_503 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 503.

    my $tx = $self->put_returns_503('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(503, 'test description');

=head2 put_returns_504

The put_returns_504 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 504.

    my $tx = $self->put_returns_504('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(504, 'test description');

=head2 put_returns_505

The put_returns_505 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 505.

    my $tx = $self->put_returns_505('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('put', '/path/to/resource');
    $tx->status_is(505, 'test description');

=head2 trace_returns_100

The trace_returns_100 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 100.

    my $tx = $self->trace_returns_100('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(100, 'test description');

=head2 trace_returns_101

The trace_returns_101 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 101.

    my $tx = $self->trace_returns_101('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(101, 'test description');

=head2 trace_returns_200

The trace_returns_200 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 200.

    my $tx = $self->trace_returns_200('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(200, 'test description');

=head2 trace_returns_201

The trace_returns_201 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 201.

    my $tx = $self->trace_returns_201('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(201, 'test description');

=head2 trace_returns_202

The trace_returns_202 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 202.

    my $tx = $self->trace_returns_202('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(202, 'test description');

=head2 trace_returns_203

The trace_returns_203 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 203.

    my $tx = $self->trace_returns_203('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(203, 'test description');

=head2 trace_returns_204

The trace_returns_204 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 204.

    my $tx = $self->trace_returns_204('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(204, 'test description');

=head2 trace_returns_205

The trace_returns_205 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 205.

    my $tx = $self->trace_returns_205('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(205, 'test description');

=head2 trace_returns_206

The trace_returns_206 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 206.

    my $tx = $self->trace_returns_206('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(206, 'test description');

=head2 trace_returns_300

The trace_returns_300 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 300.

    my $tx = $self->trace_returns_300('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(300, 'test description');

=head2 trace_returns_301

The trace_returns_301 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 301.

    my $tx = $self->trace_returns_301('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(301, 'test description');

=head2 trace_returns_302

The trace_returns_302 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 302.

    my $tx = $self->trace_returns_302('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(302, 'test description');

=head2 trace_returns_303

The trace_returns_303 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 303.

    my $tx = $self->trace_returns_303('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(303, 'test description');

=head2 trace_returns_304

The trace_returns_304 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 304.

    my $tx = $self->trace_returns_304('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(304, 'test description');

=head2 trace_returns_305

The trace_returns_305 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 305.

    my $tx = $self->trace_returns_305('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(305, 'test description');

=head2 trace_returns_306

The trace_returns_306 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 306.

    my $tx = $self->trace_returns_306('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(306, 'test description');

=head2 trace_returns_307

The trace_returns_307 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 307.

    my $tx = $self->trace_returns_307('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(307, 'test description');

=head2 trace_returns_308

The trace_returns_308 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 308.

    my $tx = $self->trace_returns_308('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(308, 'test description');

=head2 trace_returns_400

The trace_returns_400 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 400.

    my $tx = $self->trace_returns_400('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(400, 'test description');

=head2 trace_returns_401

The trace_returns_401 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 401.

    my $tx = $self->trace_returns_401('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(401, 'test description');

=head2 trace_returns_402

The trace_returns_402 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 402.

    my $tx = $self->trace_returns_402('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(402, 'test description');

=head2 trace_returns_403

The trace_returns_403 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 403.

    my $tx = $self->trace_returns_403('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(403, 'test description');

=head2 trace_returns_404

The trace_returns_404 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 404.

    my $tx = $self->trace_returns_404('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(404, 'test description');

=head2 trace_returns_405

The trace_returns_405 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 405.

    my $tx = $self->trace_returns_405('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(405, 'test description');

=head2 trace_returns_406

The trace_returns_406 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 406.

    my $tx = $self->trace_returns_406('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(406, 'test description');

=head2 trace_returns_407

The trace_returns_407 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 407.

    my $tx = $self->trace_returns_407('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(407, 'test description');

=head2 trace_returns_408

The trace_returns_408 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 408.

    my $tx = $self->trace_returns_408('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(408, 'test description');

=head2 trace_returns_409

The trace_returns_409 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 409.

    my $tx = $self->trace_returns_409('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(409, 'test description');

=head2 trace_returns_410

The trace_returns_410 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 410.

    my $tx = $self->trace_returns_410('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(410, 'test description');

=head2 trace_returns_411

The trace_returns_411 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 411.

    my $tx = $self->trace_returns_411('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(411, 'test description');

=head2 trace_returns_412

The trace_returns_412 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 412.

    my $tx = $self->trace_returns_412('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(412, 'test description');

=head2 trace_returns_413

The trace_returns_413 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 413.

    my $tx = $self->trace_returns_413('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(413, 'test description');

=head2 trace_returns_414

The trace_returns_414 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 414.

    my $tx = $self->trace_returns_414('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(414, 'test description');

=head2 trace_returns_415

The trace_returns_415 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 415.

    my $tx = $self->trace_returns_415('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(415, 'test description');

=head2 trace_returns_416

The trace_returns_416 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 416.

    my $tx = $self->trace_returns_416('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(416, 'test description');

=head2 trace_returns_417

The trace_returns_417 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 417.

    my $tx = $self->trace_returns_417('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(417, 'test description');

=head2 trace_returns_500

The trace_returns_500 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 500.

    my $tx = $self->trace_returns_500('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(500, 'test description');

=head2 trace_returns_501

The trace_returns_501 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 501.

    my $tx = $self->trace_returns_501('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(501, 'test description');

=head2 trace_returns_502

The trace_returns_502 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 502.

    my $tx = $self->trace_returns_502('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(502, 'test description');

=head2 trace_returns_503

The trace_returns_503 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 503.

    my $tx = $self->trace_returns_503('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(503, 'test description');

=head2 trace_returns_504

The trace_returns_504 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 504.

    my $tx = $self->trace_returns_504('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(504, 'test description');

=head2 trace_returns_505

The trace_returns_505 method is a shorthand method for returning a
transaction object much like the transaction method except the the actual HTTP
request is made and the server's HTTP response code is tested to ensure it
returns a 505.

    my $tx = $self->trace_returns_505('/path/to/resource', 'test description');

    # shorthand for
    my $tx = $self->transaction('trace', '/path/to/resource');
    $tx->status_is(505, 'test description');

=head1 AUTHOR

Al Newkirk <anewkirk@ana.io>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Al Newkirk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
