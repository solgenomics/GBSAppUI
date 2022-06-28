package MyApp::View::Mason;

use Moose;
use namespace::autoclean;

extends 'Catalyst::View::HTML::Mason';

__PACKAGE__->config(
    interp_args => {
        comp_root => MyApp->path_to('/gbsappui/mason/'),
        preamble => "use utf8; ",
    },
);

1;
