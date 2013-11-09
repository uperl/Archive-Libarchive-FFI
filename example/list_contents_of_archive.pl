use strict;
use warnings;
use lib '../lib';
use Archive::Libarchive::FFI qw( :all );
use Config ();

# this is a translation to perl for this:
#  https://github.com/libarchive/libarchive/wiki/Examples#wiki-List_contents_of_Archive_stored_in_File

# It is incomplete because FFI::Raw is missing features
#  - need to be able to return $entry from archive_read_next_header
#    (in C it is passed in as a pointer to an entry struct,
#     entry struct being opaque)
#  - $entry cannot be itself a FFI::Raw::MemPtr because it will
#    automatically free its data, and libarchive is supposed to
#    manage memory for $entry
#  - Instead I'm using FFI::Raw::MemPtr to create a pointer to
#    the entry struct and dereferencing it in C (provided in
#    example directory, run make to build).

package FFI::Raw::MemPtr {
  use FFI::Sweet qw( attach_function ffi_lib :types );
  ffi_lib \'./libdumb.so';
  attach_function 'deref', [ _ptr ], _ptr;
}

my $a = archive_read_new();
archive_read_support_filter_all($a);
archive_read_support_format_all($a);

my $r = archive_read_open_filename($a, "archive.tar", 10240);
if($r != ARCHIVE_OK)
{
  print "r = $r\n";
  die "error opening archive.tar: ", archive_error_string($a);
}

my $entry = FFI::Raw::MemPtr->new($Config::Config{ptrsize});
while (archive_read_next_header($a, $entry) == ARCHIVE_OK) {
  print archive_entry_pathname($entry->deref), "\n";
  archive_read_data_skip($a); 
}

$r = archive_read_free($a);
if($r != ARCHIVE_OK)
{
  die "error freeing archive";
}
