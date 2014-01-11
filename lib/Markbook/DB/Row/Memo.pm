package Markbook::DB::Row::Memo;
use strict;
use warnings;
use utf8;
use parent 'Teng::Row';
use Text::MultiMarkdown;

sub body_cnt {
    my ($self) = @_;

    (my $body = $self->body) =~ s/(\n|\r)//gs;

    return length($body);
}

sub body_to_html {
    my ($self) = @_;

    (my $html = Text::MultiMarkdown::markdown($self->body)) =~ s/<pre>/<pre class\=\"prettyprint\">/;

    return $html;
}


1;

