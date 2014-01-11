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

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;

        subtest 'delete memo' => sub {
            subtest 'success case' => sub {
                my $row_memo = create_memo();

                my %post_data = (
                    id => $row_memo->id,
                );

                my $req = POST('http://localhost/delete',
                    Content_Type => 'form-data',
                    Content      => +[%post_data],
                );

                my $res = $cb->($req);

                is($res->code, 200, '200 ok');
                is($res->content, '{}', 'no error message');
                ok(!c->db->single('memo',{ id => $row_memo->id}), 'there is no memo-data');
            };

            subtest 'fail case - no set id' => sub {
                my $row_memo = create_memo();

                my %post_data = ();

                my $req = POST('http://localhost/delete',
                    Content_Type => 'form-data',
                    Content      => +[%post_data],
                );

                my $res = $cb->($req);

                is($res->code, 200, '200 ok');
                cmp_deeply(decode_json($res->content), +{ alert => +[+{message => 'idが見つかりません',       }]}, 'error message');
                ok(c->db->single('memo',{ id => $row_memo->id}), 'there is memo-data');
            };

            subtest 'fail case - no set id' => sub {
                my $row_memo = create_memo();

                my %post_data = ( id => 'a' );

                my $req = POST('http://localhost/delete',
                    Content_Type => 'form-data',
                    Content      => +[%post_data],
                );

                my $res = $cb->($req);

                is($res->code, 200, '200 ok');
                is_deeply(decode_json($res->content), +{ alert => +[+{message => '削除対象のIDがありません', }]}, 'error message');
                ok(c->db->single('memo',{ id => $row_memo->id}), 'there is memo-data');
            };
        };
    };

done_testing;
