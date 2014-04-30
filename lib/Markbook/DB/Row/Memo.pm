package Markbook::DB::Row::Memo;
use strict;
use warnings;
use utf8;
use parent 'Teng::Row';
use Text::Markdown::Hoedown;

sub body_cnt {
    my ($self) = @_;

    (my $body = $self->body) =~ s/(\n|\r)//gs;

    return length($body);
}

sub body_to_html {
    my ($self) = @_;

    (my $html = markdown($self->body, extensions => HOEDOWN_EXT_TABLES )) =~ s/<pre>/<pre class\=\"prettyprint\">/g;

    return $html;
}


1;

