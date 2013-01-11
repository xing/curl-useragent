#!/usr/bin/env perl

use strict;
use warnings;

# use FindBin;
# use lib "$FindBin::Bin/../WWW-Curl-UserAgent-0.9.2/lib";

use HTTP::Request;
use WWW::Curl::UserAgent;

my $ua  = WWW::Curl::UserAgent->new;
my $res = $ua->request( HTTP::Request->new( GET => $ARGV[0] ) );

print $res->content;