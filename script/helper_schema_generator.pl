#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use DBI;
use Teng::Schema::Dumper;
use lib "t";
use t::Util;

my $inflate_conf = +{};
for my $table (qw/memo/) {
    $inflate_conf->{$table} = q|
        inflate qr/.+_on/ => sub {
            Time::Piece->new(+shift);
        };
    |;
}

my $dbh = DBI->connect(@{c->config->{'DBI'}}) or die;
my $schema = Teng::Schema::Dumper->dump(
    dbh       => $dbh,
    namespace => 'Markbook::DB',
    inflate   => $inflate_conf,
);

$schema =~ s!Teng\:\:Schema\:\:Declare\;!Teng\:\:Schema\:\:Declare\;\nuse Time::Piece\;!;

print $schema;

