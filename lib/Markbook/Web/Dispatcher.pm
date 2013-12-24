package Markbook::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use Text::MultiMarkdown;
use Encode 'encode_utf8';

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

    my $now = time();

    my $memo_data = +{
        title      => $title,
        body       => $body,
        updated_on => $now,
    };

    my $row = ($id) 
        ? do {
            $c->db->update('memo',$memo_data,{ id => $id });
            
            $c->db->single('memo',{ id => $id });
        }
        : do {
            $c->db->single('memo',$memo_data) || do {
                $memo_data->{created_on} = $now;

                $c->db->insert('memo',$memo_data);
            }
        }
    ;

    (my $html = Text::MultiMarkdown::markdown($body)) =~ s/<pre>/<pre class\=\"prettyprint\">/;

    return $c->render_json(+{ 
        id         => $row->id,
        title      => $title,
        html       => $html, 
        str_cnt    => str_cnt($body),
        created_at => $row->created_on->datetime,
        updated_at => $row->updated_on->datetime,
    });
};

sub str_cnt {
    my ($body) = @_;

    $body =~ s/(\n|\r)//gs; 

    return length($body);
}

1;
