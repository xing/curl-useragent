package Test::Webserver;

use IO::Scalar;
use Dancer qw/any status params/;
use Daemon::Daemonize qw//;

any [ 'get', 'put', 'post', 'delete' ] => '/code/:code' => sub {
    status int params->{code};
};

my $pid = "$0.pid";

sub start {
    Daemon::Daemonize->daemonize(
        chdir => undef,
        run   => sub {
            Daemon::Daemonize->write_pidfile($pid);
            $SIG{TERM} = sub { Daemon::Daemonize->delete_pidfile($pid); exit };
            Dancer->dance;
        }
    );
}

sub stop {
    my $child_pid = Daemon::Daemonize->read_pidfile($pid);
    kill 15, $child_pid;
}

1;
