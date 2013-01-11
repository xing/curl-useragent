#!/usr/bin/env perl

use strict;
use warnings;

use Pod::Markdown;
use IO::File;

my $mmcontent    = $ARGV[0];

my $parser       = Pod::Markdown->new;
my $input_handle = IO::File->new($mmcontent);
$parser->parse_from_filehandle($input_handle);
my $content = $parser->as_markdown;

print STDERR "used incomplete POD for markdown generation"
    if $content !~ /AUTHORS/;

print $content;
