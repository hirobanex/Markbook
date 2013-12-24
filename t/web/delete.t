use strict;
use warnings;
use utf8;
use t::Util;
use Plack::Test;
use Plack::Util;
use Test::More;
use HTTP::Request::Common;
use JSON::XS;
use Test::Deep;
use Test::Deep::Matcher;

my $app = Plack::Util::load_psgi 'script/markbook-server';

my $row_memo = create_memo();

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;

        subtest 'delete memo' => sub {
            my %post_data = (
                id => $row_memo->id,
            );

            my $req = POST('http://localhost/delete',
                Content_Type => 'form-data',
                Content      => +[%post_data],
            );

            my $res = $cb->($req);

            is($res->code, 200, '200 ok');
            is($res->content, '{}', 'location url exsist');
        };

    };

done_testing;
