#!/usr/local/bin/perl -w

use v5.10;
use strict;
use Data::Dumper;
use DBI;
use File::Basename;
use XML::Simple;

my $bin = basename $0;
my $xmlfile = shift @ARGV;              # the file to parse

die "ERROR: $bin: usage: \"$bin file.xml\"\n" unless ($xmlfile and -f $xmlfile);

my $fh  = IO::File->new($xmlfile);
my $ref = XMLin($fh); 

#print Dumper $ref;
#say Dumper $ref->{current_observation};

my $co = qw(current_observation);

#for my $key (sort keys %{ $ref->{$co} }) {
#  my $value = $ref->{$co}->{$key};
#  say "\$ref->{$co}->{$key} => $value";
#}

# take off the "%" sign off the back of the humidity
$ref->{current_observation}->{relative_humidity} =~ s/%$//;

#(blorticus 619) $ ./xml2mysql.pl ~/Documents/weather/2013/07/09/20130709-0540.xml   | \egrep -v
#'http|HASH|windchill|\{(UV|((feelslike|dewpoint|heat_index)_f))|(observation_.*)|(station_id|icon|solarradiation|pressure_trend)|(local_t(z|ime)_.*)|(.*_(metric|string|mb|c|k(m|ph))\})' 
#$ref->{current_observation}->{local_epoch} => 1373373621
#$ref->{current_observation}->{precip_1hr_in} => 0.00
#$ref->{current_observation}->{precip_today_in} => -999.00
#$ref->{current_observation}->{pressure_in} => 29.93
#$ref->{current_observation}->{relative_humidity} => 90%
#$ref->{current_observation}->{temp_f} => 64
#$ref->{current_observation}->{visibility_mi} => 6.0
#$ref->{current_observation}->{weather} => Mostly Cloudy
#$ref->{current_observation}->{wind_degrees} => 0
#$ref->{current_observation}->{wind_dir} => North
#$ref->{current_observation}->{wind_gust_mph} => 0
#$ref->{current_observation}->{wind_mph} => 0
#$ref->{current_observation}->{station_id} => MSDJAM     (or KCAJAMUL7)

die "ERROR: $bin: didn't get observation." unless $ref->{current_observation}->{local_epoch};

my $dbname = "weathermatic";
my $db     = "DBI:mysql:" . $dbname;
my $table  = "lawsonvalley";
my $user   = "weathermatic";
my $passwd = "WenWei";
my $dbh    = DBI->connect($db, $user, $passwd) || die "Could not connect to database: $DBI::errstr";
my $sth = ();

$sth = $dbh->prepare(
  "SELECT UNIX_TIMESTAMP(local_epoch) AS last_entry FROM $table ORDER BY local_epoch DESC LIMIT 1"
);
$sth->execute();
my $result = $sth->fetchrow_hashref();

$result->{last_entry} = -1 unless defined ($result->{last_entry});

if ($result->{last_entry} == $ref->{current_observation}->{local_epoch}) {
  warn "WARNING: $bin: already have this observation in the database.\n";
  exit;
}

$sth = $dbh->prepare(
  "INSERT INTO $table (
    local_epoch, 
    precip_1hr_in,
    precip_today_in,
    pressure_in,
    relative_humidity,
    temp_f,
    visibility_mi,
    weather,
    wind_degrees,
    wind_dir,
    wind_gust_mph,
    wind_mph,
    station_id
  ) VALUES (
    FROM_UNIXTIME($ref->{current_observation}->{local_epoch}),
    $ref->{current_observation}->{precip_1hr_in},
    $ref->{current_observation}->{precip_today_in},
    $ref->{current_observation}->{pressure_in},
    $ref->{current_observation}->{relative_humidity},
    $ref->{current_observation}->{temp_f},
    $ref->{current_observation}->{visibility_mi},
    \'$ref->{current_observation}->{weather}\',
    $ref->{current_observation}->{wind_degrees},
    \'$ref->{current_observation}->{wind_dir}\',
    $ref->{current_observation}->{wind_gust_mph},
    $ref->{current_observation}->{wind_mph},
    \'$ref->{current_observation}->{station_id}\'
  )"
  );
$sth->execute();

#my $result = $sth->fetchrow_hashref();
#say "Value returned: $result->{val}";
$dbh->disconnect();
