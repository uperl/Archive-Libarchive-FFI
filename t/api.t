use strict;
use warnings;
use Test::More;
use Archive::Libarchive::FFI;
BEGIN {
  plan skip_all => 'test requires YAML'
    unless eval q{ use YAML qw( Dump ); 1 };
  plan skip_all => 'test requires Archive::Libarchive::XS'
    unless eval q{ use Archive::Libarchive::XS; 1 };
  plan skip_all => 'test requires Test::Differences'
    unless eval q{ use Test::Differences; 1 };
};

plan tests => 2;

my @const = sort grep /^(ARCHIVE_|AE_)/, keys %Archive::Libarchive::XS::;
my @func  = sort grep /^archive_/, keys %Archive::Libarchive::XS::;

eq_or_diff(Dump($Archive::Libarchive::FFI::EXPORT_TAGS{const}), Dump(\@const), "same constants");
eq_or_diff(Dump($Archive::Libarchive::FFI::EXPORT_TAGS{func}),  Dump(\@func),  "same functions");

