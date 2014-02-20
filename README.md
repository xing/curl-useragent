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
Fedora 18 gave the following results:

    500 requests (sequentially, 500 iterations):
    +--------------------------+-----------+------+------+------------+------------+
    |        User Agent        | Wallclock |  CPU |  CPU |  Requests  | Iterations |
    |                          |  seconds  |  usr |  sys | per second | per second |
    +--------------------------+-----------+------+------+------------+------------+
    | LWP::Parallel::UserAgent |    14     | 0.91 | 0.30 |    35.7    |    413.2   |
    +--------------------------+-----------+------+------+------------+------------+
    | LWP::UserAgent           |    15     | 1.00 | 0.30 |    33.3    |    384.6   |
    +--------------------------+-----------+------+------+------------+------------+
    | WWW::Curl::Simple        |    15     | 0.68 | 0.35 |    33.3    |    485.4   |
    +--------------------------+-----------+------+------+------------+------------+
    | WWW::Curl::UserAgent     |     8     | 0.52 | 0.06 |    62.5    |    862.1   |
    +--------------------------+-----------+------+------+------------+------------+

    500 requests (5 in parallel, 100 iterations):
    +--------------------------+-----------+-------+-------+------------+------------+
    |        User Agent        | Wallclock |  CPU  |  CPU  |  Requests  | Iterations |
    |                          |  seconds  |  usr  |  sys  | per second | per second |
    +--------------------------+-----------+-------+-------+------------+------------+
    | LWP::Parallel::UserAgent |      9    |  1.37 |  0.34 |     55.6   |     58.5   |
    +--------------------------+-----------+-------+-------+------------+------------+
    | WWW::Curl::Simple        |    135    | 57.61 | 19.85 |      3.7   |      1.3   |
    +--------------------------+-----------+-------+-------+------------+------------+
    | WWW::Curl::UserAgent     |      2    |  0.40 |  0.09 |    250.0   |    204.1   |
    +--------------------------+-----------+-------+-------+------------+------------+

# AUTHORS

- Julian Knocke
- Othello Maurer

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by XING AG.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
