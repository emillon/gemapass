use strict;
use warnings;
use Test::More tests => 2;

sub launch {
  my $arg = shift;
  system "./gemapass $arg >/dev/null 2>&1";
}

is (0, &launch('--help'), '--help ends with no error');
isnt (0, &launch('--nosuchoption'), '--nosuchoption ends with no error');

