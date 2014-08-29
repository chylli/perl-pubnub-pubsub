package PubNub::PubSub;

use strict;
use 5.008_005;
our $VERSION = '0.01';

use Carp;
use Mojo::IOLoop;

sub new {
    my $class = shift;
    my %args  = @_ % 2 ? %{$_[0]} : @_;

    $args{pub_key} or croak "pub_key is required.";
    $args{sub_key} or croak "sub_key is required.";


    $args{host} ||= 'pubsub.pubnub.com';
    $args{port} ||= 80;
    $args{timeout} ||= 60;

    $args{callback} = sub {
        my ($res, $req) = @_;
    };

    return bless \%args, $class;
}

sub publish {
    my $self = shift;
    my %params = @_ % 2 ? %{$_[0]} : @_;

    my @msg = @{ $params{messages} };
    my $channel = $params{channel} || $self->{channel};
    $channel or croak "channel is required.";

    my $callback = $params{callback} || $self->{callback};

    # build request
    my @lines;
    foreach my $msg (@msg) {
        push @lines, "GET /publish/" . $self->{pub_key} . '/' . $self->{sub_key} . '/0/' . $self->{channel} . '/0/"' . $msg . '" HTTP/1.1';
        push @lines, 'Host: pubsub.pubnub.com';
        push @lines, ''; # for \r\n
    }
    my $r = join("\r\n", @lines) . "\r\n";

    my $id; $id = Mojo::IOLoop->client({
        address => $self->{host},
        port => $self->{port}
    } => sub {
        my ($loop, $err, $stream) = @_;

        $stream->on(read => sub {
            my ($stream, $bytes) = @_;

            ## parse bytes
            $callback->($bytes, shift @msg);

            Mojo::IOLoop->remove($id) unless @msg;
        });

        # Write request
        $stream->write($r);
    });

    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
}

sub subscribe {
    my $self = shift;
    my %params = @_ % 2 ? %{$_[0]} : @_;

    my $channel = $params{channel} || $self->{channel};
    $channel or croak "channel is required.";

    my $callback = $params{callback} or croak "callback is required.";
    my $timetoken = $params{timetoken} || '0';

    sub __r {
        my ($timetoken) = @_;

        return join("\r\n",
            'GET /subscribe/' . $self->{'sub_key'} . '/' . $channel . '/0/' . $timetoken . ' HTTP/1.1',
            'Host: pubsub.pubnub.com',
            ''
        ) . "\r\n";
    }

    my $id; $id = Mojo::IOLoop->client({
        address => $self->{host},
        port => $self->{port}
    } => sub {
        my ($loop, $err, $stream) = @_;

        $stream->on(read => sub {
            my ($stream, $bytes) = @_;

            print STDERR "-- $bytes --\n\n";

            ## parse bytes
            # $callback->($bytes, shift @msg);

            $stream->write(__r($timetoken)); # never end loop
        });

        # Write request
        print STDERR __r($timetoken) . "---\n";
        $stream->write(__r($timetoken));
    });

    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
}

1;
__END__

=encoding utf-8

=head1 NAME

PubNub::PubSub - Blah blah blah

=head1 SYNOPSIS

  use PubNub::PubSub;

=head1 DESCRIPTION

PubNub::PubSub is

=head1 AUTHOR

Binary.com E<lt>fayland@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2014- Binary.com

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
