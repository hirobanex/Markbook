use strict;
use warnings;
use utf8;
use t::Util;
use Plack::Test;
use Plack::Util;
use Test::More;

TODO: {
local $TODO = '未実装';

my $app = Plack::Util::load_psgi 'script/markbook-server';
test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        subtest 'view with static or websocket' => sub {
            my $req = HTTP::Request->new(GET => 'http://localhost/view');
            my $res = $cb->($req);
            is $res->code, 200;
            diag $res->content if $res->code != 200;
        };
    };

}
done_testing;
