package Markbook::Util;
use strict;
use warnings;
use utf8;
use Amon2::Declare;
use Text::Markdown::Hoedown;

sub to_html {
    my ($class,$text) = @_;

    ($text = Text::Markdown::Hoedown::markdown($text,
        extensions      => HOEDOWN_EXT_TABLES,
        toc_nesting_lvl => 0
    )) =~ s/<pre>/<pre class\=\"prettyprint\">/g;

    return $text;
}

sub str_cnt {
    my $class = shift;
    local $_ = shift;

    $_ =~ s/(\n|\r)//gs;

    return length($_);
}



1;

