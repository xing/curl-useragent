use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib", "$FindBin::Bin/../lib";

use HTTP::Request;
use Test::More tests => 32;
use Test::Webserver;

BEGIN {
    use_ok('WWW::Curl::UserAgent');
}

Test::Webserver->start;

my $url = 'http://localhost:3000/code/204';

{
    note 'request methods';

    my $ua = WWW::Curl::UserAgent->new;

    foreach my $method (qw/GET HEAD PUT POST DELETE/) {
        my $res = $ua->request( HTTP::Request->new( $method => $url ) );
        ok $res->is_success, "$method request to '$url'";
    }
}

{
    note 'parallel request methods';

    my $ua = WWW::Curl::UserAgent->new;

    foreach my $method (qw/GET HEAD PUT POST DELETE/) {
        $ua->add_request(
            request    => HTTP::Request->new( $method => $url ),
            on_success => sub {
                my ( $req, $res ) = @_;
                ok $res->is_success, "$method request to '$url'";
            },
            on_failure => sub {
                my ( $req, $err, $err_desc ) = @_;
                fail "$err: $err_desc";
            }
        ) for ( 1 .. 2 );
    }
    $ua->perform;
}

{
    note 'chaining requests';

    my $ua = WWW::Curl::UserAgent->new;

    my $on_failure = sub {
        my ( $req, $err, $err_desc ) = @_;
        fail "$err: $err_desc";
    };

    $ua->add_request(
        request    => HTTP::Request->new( GET => $url ),
        on_success => sub {
            my ( $req, $res ) = @_;
            ok $res->is_success, "chained request to '$url'";
            $ua->add_request(
                request    => HTTP::Request->new( GET => $url ),
                on_success => sub {
                    my ( $req, $res ) = @_;
                    ok $res->is_success, "chained request to '$url'";
                },
                on_failure => $on_failure,
            );
        },
        on_failure => $on_failure,
    );
    $ua->perform;
}

{
    note 'failing request serves 500 code';

    my $ua  = WWW::Curl::UserAgent->new;
    my $res = $ua->request( HTTP::Request->new('/') );

    ok $res;
    is $res->code, 500;
}

{
    note 'failing request with handler';

    my $ua = WWW::Curl::UserAgent->new;
    $ua->add_request(
        request    => HTTP::Request->new('/'),
        on_success => sub { fail },
        on_failure => sub {
            my ( $req, $err, $err_desc ) = @_;
            isa_ok $req,  'HTTP::Request';
            ok $err,      "err: $err";
            ok $err_desc, "err_desc: $err_desc";
        }
    );
    $ua->perform;
}

{
    note 'request timeout';

    my $ua  = WWW::Curl::UserAgent->new;
    my $res = $ua->request(
        HTTP::Request->new( GET => $url ),
        connect_timeout => 1,
        timeout         => 1,
    );

    ok $res;
    is $res->code,    500;
    is $res->message, 'Timeout was reached';
}

{
    note 'add_request timeout';

    my $ua = WWW::Curl::UserAgent->new;
    $ua->add_request(
        timeout         => 1,
        connect_timeout => 1,
        request         => HTTP::Request->new( GET => $url ),
        on_success      => sub { fail },
        on_failure      => sub {
            my ( $req, $err, $err_desc ) = @_;
            is $err,      'Timeout was reached';
            ok $err_desc, $err_desc;
        }
    );
    $ua->perform;
}

{
    note 'test redirect disabled';

    my $ua = WWW::Curl::UserAgent->new;
    $ua->add_request(
        request         => HTTP::Request->new( GET => 'http://localhost:3000/redirect/1' ),
        on_failure      => sub { fail },
        on_success      => sub {
            my ( $req, $res ) = @_;
            is $res->code, 301, 'automatic redirect disabled';
        }
    );
    $ua->perform;
}

{
    note 'test redirect enabled';

    my $ua = WWW::Curl::UserAgent->new;
    $ua->add_request(
        followlocation  => 1,
        request         => HTTP::Request->new( GET => 'http://localhost:3000/redirect/1' ),
        on_failure      => sub { fail },
        on_success      => sub {
            my ( $req, $res ) = @_;
            is $res->code, 204, 'automatic redirect enabled';
        }
    );
    $ua->perform;
}

{
    note 'test redirect error';

    my $ua = WWW::Curl::UserAgent->new;
    $ua->add_request(
        followlocation  => 1,
        max_redirects   => 1,
        request         => HTTP::Request->new( GET => 'http://localhost:3000/redirect/10' ),
        on_success      => sub { fail },
        on_failure      => sub {
            my ( $req, $err, $err_desc ) = @_;
            is $err,      'Number of redirects hit maximum amount';
            ok $err_desc, $err_desc;
        },
    );
    $ua->perform;
}

Test::Webserver->stop
