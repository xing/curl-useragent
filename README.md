# NAME

WWW::Curl::UserAgent - UserAgent based on libcurl

# VERSION

version 0.9.1

# SYNOPSIS

    use HTTP::Request;
    use WWW::Curl::UserAgent;

    my $ua = WWW::Curl::UserAgent->new(
        timeout         => 10,
        connect_timeout => 1,
    );

    $ua->add_request(
        request    => HTTP::Request->new('http://search.cpan.org/'),
        on_success => sub {
            my ( $request, $response ) = @_;
            if ($response->is_success) {
                print $response->content;
            }
            else {
                die $response->status_line;
            }
        },
        on_failue  => sub {
            my ( $request, $error_msg, $error_desc ) = @_;
            die "$error_msg: $error_desc";
        },
    );
    $ua->perform;

# DESCRIPTION

`WWW::Curl::UserAgent` is a web user agent based on libcurl. It can be used
easily with `HTTP::Request` and `HTTP::Response` objects and handler
callbacks. For an easier interface there is also a method to map a single
request to a response.

`WWW::Curl` is used for the power of libcurl, which e.g. handles connection
keep-alive, parallel requests, asynchronous callbacks and much more. This
package was written, because `WWW::Curl::Simple` does not handle keep-alive
correctly and also does not consider PUT, HEAD and other request methods like
DELETE.

There is a simpler interface too, which just returns a `HTTP::Response` for a
given `HTTP::Request`, named request(). The normal approach to use this
library is to add as many requests with callbacks as your code allows to do and
run `perform` afterwards. Then the callbacks will be excecuted sequentially
when the responses arrive beginning with the first received response. The
simple method request() does not support this of course, because there are no
callbacks defined.

# CONSTRUCTOR METHODS

The following constructor methods are available:

- $ua = WWW::Curl::UserAgent->new( %options )

    This method constructs a new `WWW::Curl::UserAgent` object and returns it.
    Key/value pair arguments may be provided to set up the initial state.
    The default values should be based on the default values of libcurl.
    The following options correspond to attribute methods described below:

        KEY                     DEFAULT
        -----------             --------------------
        user_agent_string       www.curl.useragent/$VERSION
        connect_timeout         300
        timeout                 0
        parallel_requests       5
        keep_alive              1

# ATTRIBUTES

- $ua->connect\_timeout / $ua->connect\_timeout($connect\_timeout)

    Get/set the timeout in milliseconds waiting for the response to be received. If the
    response is not received within the timeout the on\_failure handler is called.

- $ua->timeout / $ua->timeout($timeout)

    Get/set the timeout in milliseconds waiting for the response to be received. If the
    response is not received within the timeout the on\_failure handler is called.

- $ua->parallel\_requests / $ua->parallel\_requests($parallel\_requests)

    Get/set the number of the maximum of requests performed in parallel. libcurl
    itself may use less requests than this number but not more.

- $ua->keep\_alive / $ua->keep\_alive($boolean)

    Get/set if TCP connections should be reused with keep-alive. Therefor the
    TCP connection is forced to be closed after receiving the response and the
    corresponding header "Connection: close" is set. If keep-alive is enabled
    (default) libcurl will handle the connections.

- $ua->user\_agent\_string / $ua->user\_agent\_string($user\_agent)

    Get/set the user agent submitted in each request.

- $ua->request\_queue\_size

    Get the size of the not performed requests.

- $ua->request( $request, %args )

    Perform immediately a single `HTTP::Request`. Parameters can be submitted
    optionally, which will override the user agents settings for this single
    request. Possible options are:

        connect_timeout
        timeout
        keep_alive

    Some examples for a request

        my $request = HTTP::Request->new('http://search.cpan.org/');

        $response = $ua->request($request);
        $response = $ua->request($request,
            timeout    => 30,
            keep_alive => 0,
        );

    If there is an error e.g. like a timeout the corresponding `HTTP::Response`
    object will have the statuscode 500, the short error description as message
    and a longer message description as content. It runs perform() internally, so
    queued requests will be performed, too.

- $ua->add\_request(%args)

    Adds a request with some callback handler on receiving messages. The on\_success
    callback will be called for every successful read response, even those
    containing error codes. The on\_failure handler will be called when libcurl
    reports errors, e.g. timeouts or bad curl settings. The parameters
    `request`, `on_success` and `on_failure` are mandatory. Optional are
    `timeout`, `connect_timeout` and `keep_alive`.

        $ua->add_request(
            request    => HTTP::Request->new('http://search.cpan.org/'),
            on_success => sub {
                my ( $request, $response, $easy ) = @_;
                print $request->as_string;
                print $response->as_string;
            },
            on_failure => sub {
                my ( $request, $err_msg, $err_desc, $easy ) = @_;
                # error handling
            }
        );

    The callbacks provide as last parameter a `WWW:Curl::Easy` object which was
    used to perform the request. This can be used to obtain some informations like
    statistical data about the request.

    Chaining of `add_request` calls is a feature of this module. If you add a
    request within an `on_success` handler it will be immediately executed when
    the callback is executed. This can be useful to immediately react on a
    response:

        $ua->add_request(
            request    => HTTP::Request->new( POST => 'http://search.cpan.org/', [], $form ),
            on_failure => sub { die },
            on_success => sub {
                my ( $request, $response ) = @_;

                my $target_url = get_target_from($response);
                $ua->add_request(
                    request    => HTTP::Request->new( GET => $target_url ),
                    on_failure => sub { die },
                    on_success => sub {
                        my ( $request, $response ) = @_;
                        # actually do sth.
                    }
                );
            },
        );
        $ua->perform; # executes both requests

- $ua->add\_handler($handler)

    To have more control over the handler you can add a `WWW::Curl::UserAgent::Handler`
    by yourself. The `WWW::Curl::UserAgent::Request` inside of the handler needs
    all parameters provided to libcurl as mandatory to prevent defining duplicates of
    default values. Within the `WWW::Curl::UserAgent::Request` is the possiblity to
    modify the `WWW::Curl::Easy` object before it gets performed.

        my $handler = WWW::Curl::UserAgent::Handler->new(
            on_success => sub {
                my ( $request, $response, $easy ) = @_;
                print $request->as_string;
                print $response->as_string;
            },
            on_failure => sub {
                my ( $request, $err_msg, $err_desc, $easy ) = @_;
                # error handling
            }
            request    => WWW::Curl::UserAgent::Request->new(
                http_request    => HTTP::Request->new('http://search.cpan.org/'),
                connect_timeout => $ua->connect_timeout,
                timeout         => $ua->timeout,
                keep_alive      => $ua->keep_alive,
            ),
        );

        $handler->request->curl_easy->setopt( ... );

        $ua->add_handler($handler);

- $ua->perform

    Perform all queued requests. This method will return after all responses have
    been received and handler have been processed.

# SEE ALSO

See [HTTP::Request](http://search.cpan.org/perldoc?HTTP::Request) and [HTTP::Response](http://search.cpan.org/perldoc?HTTP::Response) for a description of the
message objects dispatched and received.  See [HTTP::Request::Common](http://search.cpan.org/perldoc?HTTP::Request::Common)
and [HTML::Form](http://search.cpan.org/perldoc?HTML::Form) for other ways to build request objects.

See [WWW::Curl](http://search.cpan.org/perldoc?WWW::Curl) for a description of the settings and options possible
on libcurl.

# AUTHORS

- Julian Knocke
- Othello Maurer

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by XING AG.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
