
use Test::More tests => 3;
use Data::Dumper;
use YAML::XS;

BEGIN {
    push @INC,"../lib";
    use_ok( 'CollectiveIntelligence::Similarity' ) || print "Bail out!
";
}

    require_ok( 'CollectiveIntelligence::Similarity' ) || print "Bail out!";
diag( "Testing CollectiveIntelligence::Similarity $CollectiveIntelligence::Similarity::VERSION, Perl $], $^X" );

my $test_name = "collective intelligence";
ok((open my $yml_fh, "<", "critics.yml" or die "cant open critic.yml for reading: $!"),'opened critics.yml for reading');
#ok((open my $yml_fh, "<", "critics.yml"),'opened critics.yml for reading');

my $stuff = YAML::XS::LoadFile($yml_fh);


my $ds = DataSource->new(name => "empty data source");
print Dumper($stuff);

my %seen;
my %get_comparison;
my @ds;
my $count = 0;
my @datasources;
for my $key (keys %$stuff) {
  print "key = $key and value = $stuff->{$key}\n";
  #my @movies = grep { defined ($stuff->{$key}->{movies}->{$_}) } keys %{$stuff->{$key_to_compare}->{'movies'}};
  #my %scores = map { $_ => $stuff->{$key}->{'movies'}->{$_} } @movies;
  #push @datasources,DataSource->new( data => \%scores, name => $key ); 
  
  for my $key_to_compare (keys %$stuff) {
    next if ($key_to_compare eq $key);
    next if ($seen{$key}{$key_to_compare} or $seen{$key_to_compare}{$key});
      my @contains_keys = grep { defined ($stuff->{$key}->{movies}->{$_}) } keys %{$stuff->{$key_to_compare}->{'movies'}};
      $get_comparison{$key}{$key_to_compare} = \@contains_keys;
      print Dumper($stuff->{$key_to_compare}->{'movies'});
      print "keys in common for $key and $key_to_compare are [@contains_keys]\n";
      $seen{$key}{$key_to_compare} = $seen{$key_to_compare}{$key} = 1;
      my %data = map { $_ => $stuff->{$key}->{'movies'}->{$_} } @contains_keys;
      push @ds,DataSource->new( data => \%data, name => $key ); 
      
      my %data2 = map { $_ => $stuff->{$key_to_compare}->{'movies'}->{$_} } @contains_keys;
      push @ds,DataSource->new( data => \%data2, name => $key_to_compare ); 
      $count++;
      
  }
}

for my $key (keys %get_comparison) {
  print "for $key, $get_comparison{$key} number of arrays = " . scalar (keys %{$get_comparison{$key}}) . "\n";
  
}


print "Total number of objects created = " . scalar(@ds) . "\n ";
for (my $i = 0;$i <= $#ds; $i+=2) {
  print "distance for  " . $ds[$i]->name . " and " . $ds[$i+1]->name . " is " . $ds[$i]->distance_score($ds[$i+1]) . "\n";
  print "pearson correlation coefficient  for  " . $ds[$i]->name . " and " . $ds[$i+1]->name . " is " . $ds[$i]->pearson_correlation($ds[$i+1]) . "\n";
  print "i = $i\n";
}

  print "pearson correlation coefficient  for  " . $ds->name . " and " . $ds->name . " is " . $ds->pearson_correlation($ds) . "\n";
  print "distance  for  " . $ds->name . " and " . $ds->name . " is " . $ds->distance_score($ds) . "\n";
my @datasources;
for my $key (keys %$stuff) {
  my %scores;
  print "key = $key and value = $stuff->{$key}\n";
  my @movies =  grep { defined $stuff->{'Toby'}->{'movies'}->{$_} } keys %{$stuff->{$key}->{'movies'}};
  print "movies = [@movies]\n";
  map { $scores{$_} = $stuff->{$key}->{'movies'}->{$_} } @movies;
  push @datasources,DataSource->new( data => \%scores, name => $key ); 
}
 
print "datasources array contains " . scalar (@datasources) . "datasources\n"; 

my $me = DataSource->new(data => $stuff->{'Toby'}->{'movies'}, name => 'Toby');

my @sorted_scores = $me->top_matches(\@datasources,"distance_score");
my @sorted_scores = $me->top_matches(\@datasources,"pearson_correlation");
#my @sorted_scores = $me->top_matches(\@datasources);

print "sorted scores = [@sorted_scores]\n";

my @datasources;
for my $key (keys %$stuff) {
  my %scores;
  print "key = $key and value = $stuff->{$key}\n";
  my @movies =   keys %{$stuff->{$key}->{'movies'}};
  print "movies = [@movies]\n";
  map { $scores{$_} = $stuff->{$key}->{'movies'}->{$_} } @movies;
  push @datasources,DataSource->new( data => \%scores, name => $key ); 
}

my %recommendations_distance = $me->get_recommendations(\@datasources,"distance_score");
my %recommendations_pearson = $me->get_recommendations(\@datasources,"pearson_correlation");

print "Pearson\n";
map { print "$recommendations_pearson{$_} => $_\n" } keys %recommendations_pearson;
print "Distance\n";
map { print "$recommendations_distance{$_} => $_\n" } keys %recommendations_distance;




