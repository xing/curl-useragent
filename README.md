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
    | LWP::UserAgent 6.05           |    18     | 1.08 | 0.29 |    27.8    |    365.0   |
    +-------------------------------+-----------+------+------+------------+------------+
    | LWP::Parallel::UserAgent 2.61 |    19     | 1.11 | 0.30 |    26.3    |    354.6   |
    +-------------------------------+-----------+------+------+------------+------------+
    | WWW::Curl::Simple 0.100191    |    94     | 0.66 | 0.34 |     5.3    |    500.0   |
    +-------------------------------+-----------+------+------+------------+------------+
    | Mojo::UserAgent 4.83          |    10     | 1.31 | 0.08 |    50.0    |    359.7   |
    +-------------------------------+-----------+------+------+------------+------------+
    | WWW::Curl::UserAgent 0.9.6    |    10     | 0.61 | 0.05 |    50.0    |    757.6   |
    +-------------------------------+-----------+------+------+------------+------------+

    500 requests (5 in parallel, 100 iterations):
    +-------------------------------+-----------+--------+--------+------------+------------+
    |          User Agent           | Wallclock |   CPU  |   CPU  |  Requests  | Iterations |
    |                               |  seconds  |   usr  |   sys  | per second | per second |
    +-------------------------------+-----------+--------+--------+------------+------------+
    | LWP::Parallel::UserAgent 2.61 |      9    |   1.24 |   0.28 |     55.6   |     65.8   |
    +-------------------------------+-----------+--------+--------+------------+------------+
    | WWW::Curl::Simple 0.100191    |    860    | 256.47 | 217.15 |      0.6   |      0.2   |
    +-------------------------------+-----------+--------+--------+------------+------------+
    | Mojo::UserAgent 4.83          |    301    |   1.69 |   0.31 |      1.7   |     50.0   |
    +-------------------------------+-----------+--------+--------+------------+------------+
    | WWW::Curl::UserAgent 0.9.6    |      3    |   0.47 |   0.06 |    166.7   |    188.7   |
    +-------------------------------+-----------+--------+--------+------------+------------+

# AUTHORS

- Julian Knocke
- Othello Maurer

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by XING AG.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
