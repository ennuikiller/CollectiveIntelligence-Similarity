package CollectiveIntelligence::Similarity;

use MooseX::Declare;
use warnings;
use strict;

=head1 NAME

CollectiveIntelligence::Similarity - The great new CollectiveIntelligence::Similarity!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use CollectiveIntelligence::Similarity;

    my $foo = CollectiveIntelligence::Similarity->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

class DataSource {
use List::Util qw(reduce sum);
use List::MoreUtils qw(pairwise);

  has 'data' => ( isa => 'HashRef[Num]', is => 'rw', );#init_arg => undef
  has 'name' => ( isa => 'Str', is => 'rw',); #init_arg => undef
  has 'coordinates' => ( isa => 'ArrayRef[Num]', is => 'rw',init_arg => undef );

#=pod
  sub BUILD {
      my ( $self, $params ) = @_;
      my @coordinates = map { $self->data->{$_} } sort keys %{$self->data || {} };
      $self->coordinates(\@coordinates);
  }
#=cut

  method distance_score (DataSource $data) {
    my @common = grep { defined $self->data->{$_} } sort keys %{$data->data || {}};
    return 0 unless (@common);

    my @self_coordinates = map {  $self->data->{$_}  } @common;
    my @data_coordinates = map {  $data->data->{$_}  } @common;

    return 0 unless (@data_coordinates && @self_coordinates);
    print "self data = " . ($self->data || "no data ") . "\n";
    print "datasource passed in = " . $data->data . "\n";
    map { print "$_ => " . $self->data->{$_} . "\n" } sort keys %{$self->data || {}};
    map { print "$_ => " . $data->data->{$_} . "\n" } sort keys %{$data->data || {}};

    #my @self_coordinates = values %{$self->data};
    #my @data_coordinates = values %{$data->data};


    print "self coordinates = [@self_coordinates]\n";
    print "data coordinates = [@data_coordinates]\n";

     ($#self_coordinates == $#data_coordinates) or die "dimensions must be equal!";

      #return sqrt(($self_coordinates[0] - $data_coordinates[0])**2 +  ($self_coordinates[1] - $data_coordinates[1])**2) 
      #if (scalar @self_coordinates == 2);

      my $sum = 0;
      
      for (my $i = 0; $i < scalar (@self_coordinates); $i++) {
        $sum += ($self->coordinates->[$i] - $data_coordinates[$i])**2;
        #$sum += ($self_coordinates[$i] - $data_coordinates[$i])**2;
      }
      #return sqrt($sum);
      return 1/(1+$sum);;
  } 
  method pearson_correlation (DataSource $data) {
      #print values %{$data->data}; 
    my @common = grep { defined $self->data->{$_} } sort keys %{$data->data || {}};
    return 0 unless (@common);

    my $sum_self = reduce { $a + $b } map { $self->data->{$_} } @common;
    my $sum_data = reduce { $a + $b } map {  $data->data->{$_}  } @common ;

    print "sum_self = $sum_self, and sum_data = $sum_data\n";

    my $sum_self_squares = sum map { $_**2 } map { $self->data->{$_} } @common;
    my $sum_data_squares = sum map { $_**2}  (map {  $data->data->{$_}  } @common) ;

    print "sum_self_squares = $sum_self_squares, and sum_data_squares = $sum_data_squares\n";

    my @data_coordinates = map {  $data->data->{$_}  } @common;
    my @self_coordinates = map {  $self->data->{$_}  } @common;
    #my @data_coordinates = map {  $data->data->{$_}  } sort keys %{$data->data || {}};

    print "common = [@common]\n";
    print "self->coordinates =  [@self_coordinates]    and data->coordinates =  [@data_coordinates]  for  $data->name \n";
    my $product_sum = sum pairwise { $a*$b } @self_coordinates , @data_coordinates;
    print "product_sum = $product_sum\n";

    my $num = $product_sum - ($sum_self*$sum_data/scalar @data_coordinates);
    my $den = sqrt(($sum_self_squares-($sum_self**2)/scalar @self_coordinates)*($sum_data_squares-($sum_data**2)/scalar @data_coordinates));
    return $num/$den if $den;
    return 0;
    
  }
  method top_matches (ArrayRef[DataSource] $datasources, Str $code) {
    my %scores;
    my @sorted_scores;
    #map { $scores{$_->name} = 1; print "name = " . $_->name . "\n"; } @$datasources;
    #map { $scores{$_->name} = ($self->pearson_correlation($_)); print "datasource = " . $_ . "\n"; } @$datasources;
=pod
    for my $datasource (@$datasources) {
      $scores{$datasource->name} = $self->pearson_correlation($datasource);
    }
=cut
    for my $datasource (@$datasources) {
      $scores{$datasource->name} = $self->$code($datasource);
    }
    print "keys for scores = " . (keys %scores) . "\n";
    print "datasources =   " . $$datasources[0]->data . "\n";
    #my @values = values  $datasources[0]->data;
    for my $movie (sort {$scores{$a} <=> $scores{$b}} keys %scores) {
      push @sorted_scores,"$scores{$movie},$movie";
    }

    print "sorted scores = [@sorted_scores]\n";
    return  @sorted_scores;
  
    
  }
  method get_recommendations(ArrayRef[DataSource] $datasources, Str $code) {
    my %totals;
    my %sim_sums;
    my %recommendations;

    print "number of datasources in get_recommendations = " . scalar (@$datasources) . "\n";

    for my $datasource (@$datasources) {
      next if ($datasource->name eq $self->name);
      my $sim = $self->$code($datasource);
      print "sim in get_recommendations = $sim\n";
      next if $sim == 0;
      for my $movie (keys %{$datasource->data}) {
        if ((not grep { $_ eq $movie } (keys %{$self->data})) or ($self->data->{$movie} == 0)) {
          print "IN IF ++++++++++++++++++++++\n";
          #$totals{$movie} = 0;
          $totals{$movie} += ($datasource->data->{$movie} * $sim);
          #print " TOTALS +++++++++++++ $totals{$movie}\n" ;
          #$sim_sums{$movie} = 0;
          $sim_sums{$movie} +=  $sim;
  
        }
        print "movie in get_recommendations = $movie\n";
      }
      print "sim = $sim\n";
    }

    print "KEYS:\n";
    print keys %totals;
    print "\n";
    for my $movie (keys %totals) {
          print " TOTALS +++++++++++++ $totals{$movie}\n" ;
          print " SIMSUMS +++++++++++++ $sim_sums{$movie}\n" ;
      $recommendations{$movie} = $totals{$movie}/$sim_sums{$movie};
      print "$recommendations{$movie} in get)recommendations\n";
    }

    return %recommendations;
  }

}
sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Steven  William Hirsch, C<< <nexxus.six at gmail,com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-collectiveintelligence-similarity at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CollectiveIntelligence-Similarity>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CollectiveIntelligence::Similarity


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=CollectiveIntelligence-Similarity>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/CollectiveIntelligence-Similarity>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/CollectiveIntelligence-Similarity>

=item * Search CPAN

L<http://search.cpan.org/dist/CollectiveIntelligence-Similarity/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Steven  William Hirsch.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of CollectiveIntelligence::Similarity
