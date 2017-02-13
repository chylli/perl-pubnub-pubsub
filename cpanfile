requires 'Mojolicious', '5.40';

on configure => sub {
    requires 'ExtUtils::MakeMaker';
};

on build => sub {
    requires 'ExtUtils::MakeMaker';
};

on test => sub {
    requires 'Test::More', '0.96';
};

on develop => sub {
    requires 'Dist::Milla', 'v1.0.8';
    requires 'Test::Pod', '1.41';
};
