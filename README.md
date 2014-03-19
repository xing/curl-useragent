# NAME

WWW::Curl::UserAgent - UserAgent based on libcurl

# USAGE

see [meta::cpan](https://metacpan.org/module/WWW::Curl::UserAgent)

# INSTALLATION

This module is built with [Dist::Zilla](https://metacpan.org/module/Dist::Zilla).
Ensure to have it installed before proceed.

A workflow for installing the latest Version could be

    git clone https://github.com/xing/curl-useragent.git
    cd curl-useragent
    dzil listdeps --missing | cpanm
    dzil install

# CHANGELOG

see [CHANGES](https://github.com/xing/curl-useragent/blob/master/CHANGES)

# BENCHMARK

A test with the tools/benchmark.pl script against loadbalanced webserver
performing a get requests to a simple echo API on an Intel i5 M 520 with
Fedora 19 gave the following results:

    500 requests (sequentially, 500 iterations):
    +-------------------------------+-----------+------+------+------------+------------+
    |          User Agent           | Wallclock |  CPU |  CPU |  Requests  | Iterations |
    |                               |  seconds  |  usr |  sys | per second | per second |
    +-------------------------------+-----------+------+------+------------+------------+
    | LWP::UserAgent 6.05           |    21     | 1.10 | 0.20 |    23.8    |    384.6   |
    +-------------------------------+-----------+------+------+------------+------------+
    | LWP::Parallel::UserAgent 2.61 |    20     | 1.13 | 0.22 |    25.0    |    370.4   |
    +-------------------------------+-----------+------+------+------------+------------+
    | WWW::Curl::Simple 0.100191    |    95     | 0.66 | 0.27 |     5.3    |    537.6   |
    +-------------------------------+-----------+------+------+------------+------------+
    | Mojo::UserAgent 4.83          |    10     | 1.19 | 0.08 |    50.0    |    393.7   |
    +-------------------------------+-----------+------+------+------------+------------+
    | WWW::Curl::UserAgent 0.9.6    |    10     | 0.55 | 0.06 |    50.0    |    819.7   |
    +-------------------------------+-----------+------+------+------------+------------+

    500 requests (5 in parallel, 100 iterations):
    +-------------------------------+-----------+--------+--------+------------+------------+
    |          User Agent           | Wallclock |   CPU  |   CPU  |  Requests  | Iterations |
    |                               |  seconds  |   usr  |   sys  | per second | per second |
    +-------------------------------+-----------+--------+--------+------------+------------+
    | LWP::Parallel::UserAgent 2.61 |     10    |   1.26 |   0.26 |     50.0   |     65.8   |
    +-------------------------------+-----------+--------+--------+------------+------------+
    | WWW::Curl::Simple 0.100191    |    815    | 270.16 | 191.76 |      0.6   |      0.2   |
    +-------------------------------+-----------+--------+--------+------------+------------+
    | Mojo::UserAgent 4.83          |      3    |   1.03 |   0.04 |    166.7   |     93.5   |
    +-------------------------------+-----------+--------+--------+------------+------------+
    | WWW::Curl::UserAgent 0.9.6    |      3    |   0.42 |   0.06 |    166.7   |    208.3   |
    +-------------------------------+-----------+--------+--------+------------+------------+

# AUTHORS

- Julian Knocke
- Othello Maurer

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by XING AG.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
