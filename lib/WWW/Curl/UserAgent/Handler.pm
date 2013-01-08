package WWW::Curl::UserAgent::Handler;

use Moose;

has request => (
    is       => 'ro',
    isa      => 'WWW::Curl::UserAgent::Request',
    required => 1,
);

has on_success => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
);

has on_failure => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;
1;
