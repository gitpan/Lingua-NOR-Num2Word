# For Emacs: -*- mode:cperl; mode:folding -*-

package Lingua::NOR::Num2Word;
# ABSTRACT: This module is based on and inspired by Roman Vasicek module Lingua::CS::Num2Word. Lingua::NOR::Num2Word is a module for converting whole numbers into their norwegian textual representation. Converts numbers from 0 up to 999 999 999.

# {{{ use block

use strict;
use warnings;

# }}}
# {{{ variables declaration

my($ver)      = ('$Rev: 440 $' =~ m{(\d+)}xms);
our $VERSION = $ver / 10_000;



my %group1 = qw(  0 null         1 en           2 to
                  3 tre          4 fire         5 fem
                  6 seks         7 sju          8 åtte
                  9 ni          10 ti          11 ellve
                 12 tolv        13 tretten     14 fjorten
                 15 femten      16 seksten     17 sytten
                 18 atten       19 nitten
               );
my %group2 = qw( 20 tjue        30 tretti      40 førti
                 50 femti       60 seksti      70 sytti
                 80 åtti        90 nitti
               );
my %group3 = (  100, 'ett hundre',  200, 'to hundre',     300, 'tre hundre',
                400, 'fire hundre', 500, 'fem hundre',    600, 'seks hundre',
                700, 'sju hundre',  800, 'åtte hundre',   900, 'ni hundre'
             );

my $singleton;

# }}}

# {{{ new

sub new
{
    my $invocant = shift;

    my $class = ref ( $invocant ) || $invocant;
    $singleton ||= bless {}, $class;

    return $singleton;
}

# }}}
# {{{ num2no_cardinal

sub num2no_cardinal
{
    my $self = shift;

    my $result = '';
    my $number = shift // return $result;
    #print "$number -> "; 

    # check if number has decimals > 0, allowing whole numbers written as 2.00
    $number =~ /(\d+)\.(\d+)/;

    # numbers less than 0 are not supported and numbers containg decimals greater than 0 
    return $result if ( $number < 0 || ( defined $2 && $2 > 0 ) );

    my $reminder = 0;

    if ( $number < 20 )
    {
      $result = $group1{$number};
    }

    elsif ( $number < 100 )
    {
      $reminder = $number % 10;
      if ( $reminder == 0 )
      {
        $result = $group2{$number};
      }
      else
      {
        $result = $group2{$number - $reminder} . ' ' . $self->num2no_cardinal( $reminder );
      }
    }

    elsif ($number < 1000)
    {
      $reminder = $number % 100;
      if ( $reminder == 0 )
      {
        $result = $group3{$number};
      }
      else
      {
        $result = $group3{$number - $reminder} . ' og ' . $self->num2no_cardinal( $reminder );
      }
    }

    elsif ( $number < 1000000 )
    {
      $reminder = $number % 1000;

      my $tmp1 = ( $reminder != 0 ) ? ' '.$self->num2no_cardinal($reminder) : '';
      my $tmp2 = substr( $number, 0, length( $number ) - 3 );
      my $tmp3 = $tmp2 % 10;

      my $space = '';
      $space = ' og' if ( $reminder < 100 && $reminder != 0 );

      if ( $tmp3 == 1 && $tmp2 == 1 )
      {
          $tmp2 = 'ett tusen';
      } 
      else 
      {
          $tmp2 = $self->num2no_cardinal($tmp2) . ' tusen';
      }

      $result = $tmp2 . $space . $tmp1;
    }

    elsif ( $number < 1000000000 ) 
    {
      $reminder = $number % 1000000;

      my $tmp1 = ( $reminder != 0 ) ? ' ' . $self->num2no_cardinal($reminder) : '';
      my $tmp2 = substr( $number, 0, length( $number ) - 6 );
      my $tmp3 = $tmp2 % 10;

      my $space = '';
      $space = ' og' if ( $reminder < 100000 && $reminder != 0 );

      if ( $tmp3 == 1 && $tmp2 == 1 )
      {
         $tmp2 = 'en million';
      }
      else
      {
        $tmp2 = $self->num2no_cardinal( $tmp2 ) . ' millioner';
      }

      $result = $tmp2 . $space . $tmp1;

    }
    else
    {
      # >= 1 000 000 000 unsupported
    }

    return $result;
}

# }}}

1;

__END__

=head1 NAME

Lingua::NOR::Num2Word - convert whole number to norwegian text. Output text is in utf-8 encoding.

=head1 SYNOPSIS

 use Lingua::NOR::Num2Word;

 my $no_num2word = Lingua::NOR::Num2Word->new();

 my $text = $no_num2word->num2no_cardinal( 1000000 );

 print $text || "Sorry, can't convert this number into norwegian.";

=head1 DESCRIPTION

This module is based on and inspired by Roman Vasicek module Lingua::CS::Num2Word. Lingua::NOR::Num2Word is a module for converting whole numbers into their norwegian textual representation. Converts numbers from 0 up to 999 999 999.

=head1 METHODS

The following methods are provided by the Lingua::NOR::Num2Word class.

=over 2

=item B<new>

Create a singleton object.

 my $no_num2word = Lingua::NOR::Num2Word->new();

=item B<num2no_cardinal>

Converts a whole number to norwegian language.

  my $text = $no_num2word->num2no_cardinal( 1000000 );



=back

=head1 HISTORY

 * [16.06.2004] Version 0.011 released.
 * [13.06.2004] Version 0.01 released.

=head1 VERSION

This is version 0.011

=head1 AUTHOR

Kjetil Fikkan (kjetil@fikkan.org)

Maintenance
PetaMem <info@petamem.com>

=head1 COPYRIGHT

 Copyright (c) 2004 Kjetil Fikkan

 This module is free software. It may be used, redistributed
 and/or modified under the same terms as Perl itself.
