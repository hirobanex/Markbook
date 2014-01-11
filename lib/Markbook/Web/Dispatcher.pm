package Markbook::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use JSON::XS;
use Encode;

get '/' => sub {
    my ($c) = @_;

    my $params = $c->req->parameters->mixed;

    my $page = delete $params->{page} || 1;
    my $rows = delete $params->{rows} || 100; 

    my ($memos, $pager) = $c->db->search_with_pager('memo', +{} , {
        page       => $page,
        rows       => $rows,
        order_by   => 'updated_on DESC',
    });

    return $c->render('index.tx',{
        memos => $memos,
        pager => $pager,
    });
};

get '/by_one_screen' => sub {
    my ($c) = @_;

    my $params = $c->req->parameters->mixed;

    my $id = delete $params->{id}
        or return $c->render('by_one_screen.tx');

    my $row = $c->db->single('memo',{ id => $id })
        or return $c->res_404();

    return $c->render('by_one_screen.tx',{ memo => $row });
};

#一番最初にデータがインサートされていないうちにまたインサートしてしまう問題
post '/preview' => sub {
    my ($c) = @_;

    my $id      = $c->req->param('id')    || '';
    my $title   = $c->req->param('title') || '';
    my $body    = $c->req->param('body')  || '';

    (!$title and !$body) and return $c->render_json(+{});

    my $res = $c->db->insert_or_update_and_fetch_res(
        id         => $id,
        title      => $title,
        body       => $body,
    );

    return $c->render_json($res);
};

post '/delete' => sub {
    my ($c) = @_;

    my $id = $c->req->param('id')
        or return $c->render_json(+{ alert => +[+{message => 'idが見つかりません',       }] });

    $c->db->delete('memo',{ id => $id })
        or return $c->render_json(+{ alert => +[+{message => '削除対象のIDがありません', }] });

    return $c->render_json(+{});
};

get '/edit' => sub {
    my ($c) = @_;
    
    my $id = $c->req->param('id')
        or return $c->render('edit.tx');

    my $row = $c->db->single('memo',{ id => $id })
        or return $c->res_404();

    return $c->render('edit.tx',{ memo => $row });
};

get '/view' => sub {
    my ($c) = @_;

    my $id = $c->req->param('id')
        or return $c->render('view.tx');

    my $row = $c->db->single('memo',{ id => $id })
        or return $c->res_404();

    return $c->render('view.tx',{ memo => $row });
};

my $clients = {};
use Digest::SHA1;
any '/preview_by_websocket' => sub {
    my ($c) = @_;
    my $id = Digest::SHA1::sha1_hex(rand() . $$ . {} . time);

    $c->websocket(sub {
        my $ws = shift;
        $clients->{$id} = $ws;

        $ws->on_receive_message(sub {
            my ($c, $json) = @_;

            $json =~ /\{/ or return; 
           
             my $data = JSON::XS->new->decode($json);

            my $id      = $data->{id}    || '';
            my $title   = $data->{title} || '';
            my $body    = $data->{body}  || '';

            (!$title and !$body) and return;

            my $res = $c->db->insert_or_update_and_fetch_res(
                id         => $id,
                title      => $title,
                body       => $body,
            );

            for (keys %$clients) {
                $clients->{$_}->send_message(encode_json($res));
            }
        });
        $ws->on_eof(sub {
            my ($c) = @_;
            delete $clients->{$id};
        });
        $ws->on_error(sub {
            my ($c) = @_;
            delete $clients->{$id};
        });
    });
};

1;
