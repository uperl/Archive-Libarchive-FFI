use strict;
use warnings;
use utf8;
use Test::More tests => 2;
use Archive::Libarchive::FFI qw( :all );

my $e = archive_entry_new();

TODO: {
  local $TODO = "need unicode support";

  my $r = archive_entry_set_pathname($e, "привет.txt");
  is $r, ARCHIVE_OK, 'archive_entry_set_pathname';

  is archive_entry_pathname($e), "привет.txt", 'archive_entry_pathname';
  
};
