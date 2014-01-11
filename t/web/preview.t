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

        subtest 'POST /preview' => sub {
            subtest 'create memo' => sub {
                my %post_data = (
                    title => 'title',
                    body  => 'body',
                );

                my $req = POST('http://localhost/preview',
                    Content_Type => 'form-data',
                    Content      => +[%post_data],
                );

                my $res = $cb->($req);


                is($res->code, 200, '200 ok');
                cmp_deeply(decode_json($res->content), +{ 
                    id         => is_number,
                    title      => is_string,
                    html       => is_string,
                    str_cnt    => is_number,
                    created_at => is_string,
                    updated_at => is_string,
                }, 'memo data');
                ok(c->db->single('memo'), 'there is memo-data');
            };
            subtest 'update memo' => sub {
                my $row_memo = create_memo();
                sleep 1;
                my $post_data = {
                    id    => $row_memo->id,
                    title => 'updated_title',
                    body  => 'updated_body',
                };

                my $req = POST('http://localhost/preview',
                    Content_Type => 'form-data',
                    Content      => +[%$post_data],
                );

                my $res = $cb->($req);


                is($res->code, 200, '200 ok');
                my $data = decode_json($res->content);

                subtest 'updated return data ?' => sub {
                    is $data->{title},$post_data->{title},'title';
                    is $data->{html},'<p>'.$post_data->{body}."</p>\n",'body';
                };

                subtest 'updated db data ?' => sub {
                    my $new_memo = $row_memo->refetch;

                    isnt $row_memo->title, $new_memo->title,'title';
                    isnt $row_memo->body, $new_memo->body,'body';
                    isnt $row_memo->updated_on, $new_memo->updated_on,'updated_on';
                };
            };
        };
    };

done_testing;
