use strict;
use warnings;
use Test::More tests => 1;

use_ok 'Archive::Libarchive::FFI';

# perl -MArchive::Libarchive::FFI    -E 'for(@Archive::Libarchive::FFI::EXPORT_OK) { say $_ unless Archive::Libarchive::FFI->can($_) }'

my $not_first = 0;

diag '';
diag '';

foreach my $const (@{ $Archive::Libarchive::FFI::EXPORT_TAGS{'const'} })
{
  unless(Archive::Libarchive::FFI->can($const))
  {
    diag "missing constants:" unless $not_first++;
    diag " - $const";
  }
}

diag '';
diag '';

$not_first = 0;

foreach my $func (@{ $Archive::Libarchive::FFI::EXPORT_TAGS{'func'} })
{
  unless(Archive::Libarchive::FFI->can($func))
  {
    diag "missing functions:" unless $not_first++;
    diag " - $func";
  }
}

diag '';
diag '';
