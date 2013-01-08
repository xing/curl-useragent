use strict;
use warnings;

use Test::More tests => 13;

use HTTP::Request;
use Sub::Override;
use Test::MockObject;

use WWW::Curl::Easy;

BEGIN {
    use_ok('WWW::Curl::UserAgent');
}

{
    note 'perform without active handles';

    my $ua = Test::MockObject->new;
    $ua->set_series( _drain_handler_queue => (0) );

    WWW::Curl::UserAgent::perform($ua);

    ok !$ua->called('_wait_for_response'), 'not waited for response';
    ok !$ua->called('_perform_callbacks'), 'no callback performed';
}

{
    note 'perform with active handle';

    my $ua = Test::MockObject->new;
    $ua->set_series( _drain_handler_queue => ( 1, 0 ) );
    $ua->set_true( '_wait_for_response', '_perform_callbacks' );

    WWW::Curl::UserAgent::perform($ua);

    ok $ua->called('_wait_for_response'), 'waited for response';
    ok $ua->called('_perform_callbacks'), 'callback performed';
}

{
    note 'drain no handler';

    my $ua = get_activating_ua();

    is $ua->_drain_handler_queue, 0, 'no handler activation';
    is $ua->request_queue_size,   0, 'no handler left to activate';
}

{
    note 'drain a single handler';

    my $handler = Test::MockObject->new;
    $handler->set_isa('WWW::Curl::UserAgent::Handler');

    my $ua = get_activating_ua();
    $ua->add_handler($handler);

    is $ua->_drain_handler_queue, 1, 'activated one handler';
    is $ua->request_queue_size,   0, 'no handler left to activate';
}

{
    note 'drain 5 handler';

    my $ua = get_activating_ua();
    for ( 1 .. 5 ) {
        my $handler = Test::MockObject->new;
        $handler->set_isa('WWW::Curl::UserAgent::Handler');
        $ua->add_handler($handler);
    }

    is $ua->_drain_handler_queue, 5, 'activated 5 handlers';
    is $ua->request_queue_size,   0, 'no handler left to activate';
}

{
    note 'drain 6 handler';

    my $ua = get_activating_ua();
    for ( 1 .. 6 ) {
        my $handler = Test::MockObject->new;
        $handler->set_isa('WWW::Curl::UserAgent::Handler');
        $ua->add_handler($handler);
    }

    is $ua->_drain_handler_queue, 5, 'activated 5 handlers';
    is $ua->request_queue_size,   1, 'one handler left to activate';
}

# TODO: _perform_callbacks, _activate_handler, _build_http_response

sub get_activating_ua {
    my $ua = WWW::Curl::UserAgent->new;

    my $i = 1;
    push @{ $ua->{overrides} }, Sub::Override->new(
        'WWW::Curl::UserAgent::_activate_handler' => sub {
            my ( $self, $handler ) = @_;
            $self->_set_active_handler( $i++ => $handler );
        }
    );

    return $ua;
}
