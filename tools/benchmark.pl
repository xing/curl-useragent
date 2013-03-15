#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark;
use HTTP::Request;
use LWP::Parallel::UserAgent;
use LWP::UserAgent;
use Text::Table;
use WWW::Curl::Simple;
use WWW::Curl::UserAgent;

my $url = $ARGV[0];
my $request_count = $ARGV[1] || 1_000;

my $lwp_parallel_useragent = LWP::Parallel::UserAgent->new;
my $lwp_useragent          = LWP::UserAgent->new;
my $www_curl_simple        = WWW::Curl::Simple->new;
my $www_curl_useragent     = WWW::Curl::UserAgent->new;

# single requests
sub lwp_parallel_useragent_single {
    $lwp_parallel_useragent->request( HTTP::Request->new( GET => $url ) );
}

sub lwp_useragent_single {
    $lwp_useragent->get($url);
}

sub www_curl_simple_single {
    $www_curl_simple->get($url);
}

sub www_curl_useragent_single {
    $www_curl_useragent->request( HTTP::Request->new( GET => $url ) );
}

# 5 requests in parallel
sub lwp_parallel_useragent_multi {
    $lwp_parallel_useragent->register( HTTP::Request->new( GET => $url ) )
      for ( 1 .. 5 );
    $lwp_parallel_useragent->wait;
}

sub www_curl_simple_multi {
    # due a misleading behaviour the added requests have to get removed after performing
    my @requests = map { HTTP::Request->new( GET => $url ) } ( 1 .. 5 );
    $www_curl_simple->add_request($_) for @requests;
    $www_curl_simple->perform;
    $www_curl_simple->delete_request($_) for @requests;
}

sub www_curl_useragent_multi {
    $www_curl_useragent->add_request(
        request    => HTTP::Request->new( GET => $url ),
        on_success => sub { },
        on_failure => sub { },
    ) for ( 1 .. 5 );
    $www_curl_useragent->perform;
}

sub print_request_results {
    my ( $results, $parallel_requests ) = @_;

    my $tb = Text::Table->new(
        \'| ',
        {
            title       => "User Agent",
            align_title => 'center',
        },
        \' | ',
        {
            title       => "Wallclock\nseconds",
            align_title => 'center',
        },
        \' | ',
        {
            title       => "CPU\nusr",
            align_title => 'center',
        },
        \' | ',
        {
            title       => "CPU\nsys",
            align_title => 'center',
        },
        \' | ',
        {
            title       => "Requests\nper second",
            align_title => 'center',
        },
        \' | ',
        {
            title       => "Iterations\nper second",
            align_title => 'center',
        },
        \' |',
    );

    foreach my $ua ( keys %$results ) {
        my ( $wallclock, $cpu_usr, $cpu_sys, undef, undef, $iter ) =
          @{ $results->{$ua} };
        $tb->add(
            $ua,
            $wallclock,
            sprintf( "%.2f", $cpu_usr ),
            sprintf( "%.2f", $cpu_sys ),
            sprintf( "%.1f", ( $iter * $parallel_requests ) / $wallclock ),
            sprintf( "%.1f", $iter / ( $cpu_usr + $cpu_sys ) ),
        );
    }

    my $rule = $tb->rule(qw/- +/);
    my @arr  = $tb->body;
    print $rule, $tb->title, $rule;
    for (@arr) {
      print $_ . $rule;
    }
}

print "$request_count requests (sequentially, $request_count iterations):\n";
print_request_results(
    Benchmark::timethese(
        $request_count,
        {
            'LWP::Parallel::UserAgent' => \&lwp_parallel_useragent_single,
            'LWP::UserAgent'           => \&lwp_useragent_single,
            'WWW::Curl::Simple'        => \&www_curl_simple_single,
            'WWW::Curl::UserAgent'     => \&www_curl_useragent_single,
        },
        'none'
    ),
    1
);

print "\n$request_count requests (5 in parallel, @{[int( $request_count / 5 )]} iterations):\n";
print_request_results(
    Benchmark::timethese(
        int( $request_count / 5 ),
        {
            'LWP::Parallel::UserAgent' => \&lwp_parallel_useragent_multi,
            'WWW::Curl::Simple'        => \&www_curl_simple_multi,
            'WWW::Curl::UserAgent'     => \&www_curl_useragent_multi,
        },
        'none'
    ),
    5
);
