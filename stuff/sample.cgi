#!/usr/local/bin/perl -w

use v5.10;
use strict;
use File::Basename;

use lib '/usr/local//Cellar/rrdtool/1.4.8/lib/perl/5.16.3';

use RRD::CGI::Image;
use CGI qw[Vars header h1 end_html];

my $bin = basename $0;
my $me  = $bin;$me =~ s/\..*//;
my $q   = CGI->new;

my $image = RRD::CGI::Image->new(
            rrd_base           => './rrd',
            error_img          => '../images/error.png',
            '--start'          => '-1d',
            '--end'            => 'now',
            '--height'         => 200,
            '--width'          => 600,
            '--imgformat'      => 'PNG',
            '--lower-limit'    => 0,
            '--title'          => 'title',
            '--vertical-label' => 'vertical-label',
);

say $q->header,
    $q->start_html(-title=>"$me"),
    $q->h1('hey'),
    $q->p("img start:"),
#    Vars(),
#    $image->print_graph( Vars() ),
    $q->p(":img end"),
    $q->end_html();

exit;
