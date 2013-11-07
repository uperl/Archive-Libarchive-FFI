use strict;
use warnings;
use lib '../lib';
use Archive::Libarchive::FFI qw( :all );

use FFI::Sweet qw( attach_function ffi_lib :types );
ffi_lib \'./libdumb.so';
attach_function 'malloc', [ _int ], _ptr;
attach_function 'free', [ _ptr ], _void;
attach_function 'deref', [ _ptr ], _ptr;

my $a = archive_read_new();
archive_read_support_filter_all($a);
archive_read_support_format_all($a);

my $r = archive_read_open_filename($a, "archive.tar", 10240);
if($r != ARCHIVE_OK)
{
  print "r = $r\n";
  die "error opening archive.tar: ", archive_error_string($a);
}

my $entry = malloc(8);
while (archive_read_next_header($a, $entry) == ARCHIVE_OK) {
  print archive_entry_pathname(deref($entry)), "\n";
  archive_read_data_skip($a); 
}
free($entry);

$r = archive_read_free($a);
if($r != ARCHIVE_OK)
{
  die "error freeing archive";
}
