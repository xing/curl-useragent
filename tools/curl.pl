#!/usr/bin/env perl

use strict;
use warnings;

use HTTP::Request;
use WWW::Curl::UserAgent;

my $ua  = WWW::Curl::UserAgent->new;
my $res = $ua->request( HTTP::Request->new( GET => $ARGV[0] ) );

print $res->content;