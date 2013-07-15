#!/usr/local/bin/perl -w

use v5.10;
use strict;
use CGI;
use DBI;
use File::Basename;

my $bin = basename $0;
my $height=200;
my $width=1000;
my $images="images/";
my $q   = CGI->new;

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

$sql   = "SELECT thetime FROM $table ORDER BY thetime      LIMIT 1";
$sth   = $dbh->prepare($sql);
$sth->execute
     or die "ERROR: SQL error: $DBI::errstr\n";
my $first = ($sth->fetchrow_array)[0];

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
my $favico = "$images" . "wino.ico";

say $q->header(-expire=>'now'),
    $q->start_html(
          -title=>"Wineduino",
          -head=>[ $q->Link({-rel=>"icon", -type=>"image/png", -href=>"$favico"}),]
        ),
    $js,
    $q->blockquote("last updated: $last");

my $updater = "/Library/WebServer/Documents/wineduino/stuff/updategraphs.sh -h";
system ($updater) == 0
  or die "ERROR: \"$updater\" failed: $?";

for my $i ("1_hour", "1_day", "1_week", "1_month", "1_year", "all") {
    my $large = "$images" . "$i" . "_large.png";
    my $small = "$images" . "$i" . "_small.png";
    say
      $q->a({-href=>"itty.cgi?$large"}, $q->img({src=>"$small", alt=>"picture of wineduino stats: $i", height=>"$height", width=>"$width"})),
      $q->br;
}

say $q->blockquote("first updated: $first");
say $q->end_html();
