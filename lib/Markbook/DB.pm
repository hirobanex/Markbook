package Markbook::DB;
use strict;
use warnings;
use utf8;
use parent qw(Teng);
use Smart::Args;
use Markbook::Util;

__PACKAGE__->load_plugin('Count');
__PACKAGE__->load_plugin('Replace');
__PACKAGE__->load_plugin('Pager');

sub fetch_memo {
    args my $self,
         my $id    => 'Int';

    my $row = $self->single('memo',{ id => $id }) or return;

    return +{
        str_cnt => Markbook::Util->str_cnt($row->body),
        html    => Markbook::Util->to_html($row->body),
        %{$row->get_columns},
    };
}

sub insert_or_update_and_fetch_res {
    args my $self,
         my $id    => { optional => 1},
         my $title => { optional => 1},
         my $body  => { optional => 1};

    my $now = time();

    my $memo_data = +{
        title      => $title,
        body       => $body,
        updated_on => $now,
    };

    my $row = ($id)
        ? do {
            $self->update('memo',$memo_data,{ id => $id });

            $self->single('memo',{ id => $id });
        }
        : do {
            $self->single('memo',$memo_data) || do {
                $memo_data->{created_on} = $now;

                $self->insert('memo',$memo_data);
            }
        }
    ;

    return +{
        id         => $row->id,
        title      => $row->title,
        html       => Markbook::Util->to_html($row->body),
        str_cnt    => Markbook::Util->str_cnt($row->body),
        created_at => $row->created_on->datetime,
        updated_at => $row->updated_on->datetime,
    };
}

1;
