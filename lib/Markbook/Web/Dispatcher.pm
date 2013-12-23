package Markbook::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use Text::MultiMarkdown;
use Encode 'encode_utf8';

#記事一覧を表示する
get '/' => sub {
    my ($c) = @_;

    return $c->render('index.tx',{ });
};

#paramaterを渡して既存の記事の編集ができるように
get '/edit' => sub {
    my ($c) = @_;

    return $c->render('edit.tx');
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

    my $row;
    if ($id) {
        $c->db->update('memo',$memo_data,{ id => $id });
        
        $row = $c->db->single('memo',{ id => $id });
    }else{
        $memo_data->{created_on} = $now;

        $row = $c->db->insert('memo',$memo_data);
    }

    my $str_cnt = str_cnt($body);
    my $html = Text::MultiMarkdown::markdown($body);

    return $c->render_json(+{ 
        id         => $row->id,
        title      => $title,
        html       => $html, 
        str_cnt    => $str_cnt,
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
