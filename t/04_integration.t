use strict;
use warnings;

use HTTP::Request;
use Test::More tests => 28;

BEGIN {
    use_ok('WWW::Curl::UserAgent');
}

my $url = 'http://www.google.de/';

{
    note 'request methods';

    my $ua = WWW::Curl::UserAgent->new;

    foreach my $method (qw/GET HEAD/) {
        my $res = $ua->request( HTTP::Request->new( HEAD => $url ) );
        ok $res->is_success, "$method request to '$url'";
    }

    foreach my $method (qw/PUT POST DELETE/) {
        my $res = $ua->request( HTTP::Request->new( $method => $url ) );
        is $res->code, 405, "$method request to '$url'";
    }
}

{
    note 'parallel request methods';

    my $ua = WWW::Curl::UserAgent->new;

    foreach my $method (qw/GET HEAD/) {
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
    foreach my $method (qw/PUT POST DELETE/) {
        $ua->add_request(
            request    => HTTP::Request->new( $method => $url ),
            on_success => sub {
                my ( $req, $res ) = @_;
                is $res->code, 405, "$method request to '$url'";
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
