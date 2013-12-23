package Markbook::DB::Schema;
use strict;
use warnings;
use Teng::Schema::Declare;
use Time::Piece;
table {
    name 'memo';
    pk 'id';
    columns (
        'id',
        'title',
        'body',
        'created_on',
        'updated_on',
    );

        inflate qr/.+_on/ => sub {
            Time::Piece->new(+shift);
        };
    };

1;
