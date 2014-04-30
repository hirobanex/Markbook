requires 'Amon2', '6.00';
requires 'DBD::SQLite', '1.33';
requires 'HTML::FillInForm::Lite', '1.11';
requires 'JSON', '2.50';
requires 'Module::Functions', '2';
requires 'Plack::Middleware::ReverseProxy', '0.09';
requires 'Router::Boom', '0.06';
requires 'Twiggy';
requires 'Teng', '0.18';
requires 'Text::Xslate', '2.0009';
requires 'Time::Piece', '1.20';
requires 'perl', '5.010_001';
requires 'Text::Markdown::Hoedown';
requires 'Digest::SHA1';
requires 'Smart::Args';
requires 'Protocol::WebSocket';

on configure => sub {
    requires 'Module::Build', '0.38';
    requires 'Module::CPANfile', '0.9010';
};

on test => sub {
    requires 'Test::More', '0.98';
    requires 'Test::WWW::Mechanize::PSGI';
    requires 'JSON::XS';
    requires 'Test::Deep';
    requires 'Test::Deep::Matcher';
};
