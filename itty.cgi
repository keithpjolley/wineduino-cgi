#!/usr/local/bin/perl -w

use v5.10;
use strict;
use CGI;
use DBI;
use Data::Dumper;
use File::Basename;

my $bin = basename $0;
my $q   = CGI->new;

my $js  =<<EOF1;
<script language="javascript">
//the page will be refreshed every 60 seconds..
//the function refresh is called every 60 secs set
Timeout('refresh()', 60000) 

function refresh() {
    //this line does the actual reloading of the page
    window.location.reload();
} </script> 
EOF1
my $favico = "images/" . "wino.ico";

# start sending data to let the client know we are alive
say $q->header(-expire=>'now'),
    $q->start_html(
          -title=>"Wineduino",
          -head=>[ $q->Link({-rel=>"icon", -type=>"image/png", -href=>"$favico"}),]
        ),
    $js;

my $db    = "dbi:mysql:sensormatic";
my $user  = "sensormatic";
my $table = "wino";
my $pw    = "password";
my $dbh   = DBI->connect($db, $user, $pw)
  or die "ERROR: Connection error: $DBI::errstr\n";
my $sql   = "SELECT thetime FROM $table ORDER BY thetime DESC LIMIT 1";
my $sth   = $dbh->prepare($sql);
$sth->execute
     or die "ERROR: SQL error: $DBI::errstr\n";
my $last  = ($sth->fetchrow_array)[0];

my $height= 750;
my $width = 1250;
my $image = ($q->keywords)[0];

if (! defined $image) {
  say $q->blockquote("ERROR: $bin: Image file not defined. Died");
} elsif (! -r $image) {
  say $q->blockquote("ERROR: $bin: Can't read image file: $image. Died");
} else {
  say $q->img({src=>"$image", alt=>"picture of wineduino stats: $image", height=>"$height", width=>"$width"}),
      $q->blockquote("last updated: $last");
}
say $q->end_html();

exit;
