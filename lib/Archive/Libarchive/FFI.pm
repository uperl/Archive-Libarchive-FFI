package Archive::Libarchive::FFI;

use strict;
use warnings;
use Alien::Libarchive;
use FFI::Raw ();
use FFI::Sweet;
use FFI::Util qw( deref_to_ptr deref_to_uint64 deref_to_uint buffer_to_scalar scalar_to_buffer );
use Exporter::Tidy ();

# ABSTRACT: Perl bindings to libarchive via FFI
# VERSION

ffi_lib(Alien::Libarchive->new);

require Archive::Libarchive::FFI::Constant;
require Archive::Libarchive::FFI::Callback;

sub _attach ($$$)
{
  my($name, $arg, $ret) = @_;
  if($ret == _void)
  {
    attach_function $name, $arg, $ret, sub {
      my $code = shift;
      $code->(@_);
      ARCHIVE_OK();
    };
  }
  else
  {
    attach_function $name, $arg, $ret;
  }
}

_attach 'archive_version_number',                        undef, _int;
_attach 'archive_version_string',                        undef, _str;
_attach 'archive_clear_error',                           [ _ptr ], _void;
_attach 'archive_copy_error',                            [ _ptr ], _int;
_attach 'archive_errno',                                 [ _ptr ], _int;
_attach 'archive_file_count',                            [ _ptr ], _int;
_attach 'archive_format',                                [ _ptr ], _int;
_attach 'archive_format_name',                           [ _ptr ], _str;
_attach 'archive_seek_data',                             [ _ptr, _int64, _int ], _int64;

_attach 'archive_read_new',                              undef, _ptr;
_attach 'archive_read_support_filter_all',               [ _ptr ], _int;
_attach 'archive_read_support_format_all',               [ _ptr ], _int;
_attach 'archive_read_open1',                            [ _ptr ], _int;
_attach 'archive_read_open_filename',                    [ _ptr, _str, _int ], _int;
_attach 'archive_read_data_skip',                        [ _ptr ], _int;
_attach 'archive_read_close',                            [ _ptr ], _int;
_attach 'archive_read_support_filter_program',           [ _ptr, _str ], _int;
_attach 'archive_read_support_format_by_code',           [ _ptr, _int ], _int;
_attach 'archive_read_header_position',                  [ _ptr ], _int64;
_attach 'archive_read_set_filter_option',                [ _ptr, _str, _str, _str ], _int;
_attach 'archive_read_set_format_option',                [ _ptr, _str, _str, _str ], _int;
_attach 'archive_read_set_option',                       [ _ptr, _str, _str, _str ], _int;
_attach 'archive_read_set_options',                      [ _ptr, _str ], _int;
_attach 'archive_read_set_format',                       [ _ptr, _str, _str, _str ], _int;
_attach 'archive_read_next_header2',                     [ _ptr, _ptr ], _int;

_attach 'archive_filter_code',                           [ _ptr, _int ], _int;
_attach 'archive_filter_count',                          [ _ptr ], _int;
_attach 'archive_filter_name',                           [ _ptr, _int ], _str;

_attach 'archive_write_new',                             undef, _ptr;
_attach 'archive_write_add_filter',                      [ _ptr, _int ], _int;
_attach 'archive_write_add_filter_by_name',              [ _ptr, _str ], _int;
_attach 'archive_write_add_filter_program',              [ _ptr, _str ], _int;
_attach 'archive_write_set_format',                      [ _ptr, _int ], _int;
_attach 'archive_write_set_format_by_name',              [ _ptr, _str ], _int;
_attach 'archive_write_open_filename',                   [ _ptr, _str ], _int;
_attach 'archive_write_header',                          [ _ptr, _ptr ], _int;
_attach 'archive_write_close',                           [ _ptr ], _int;
_attach 'archive_write_disk_new',                        undef, _ptr;
_attach 'archive_write_disk_set_options',                [ _ptr, _int ], _int;
_attach 'archive_write_finish_entry',                    [ _ptr ], _int;
_attach 'archive_write_disk_set_standard_lookup',        [ _ptr ], _int;
_attach 'archive_write_zip_set_compression_deflate',     [ _ptr ], _int;
_attach 'archive_write_zip_set_compression_store',       [ _ptr ], _int;
_attach 'archive_write_set_filter_option',               [ _ptr, _str, _str, _str ], _int;
_attach 'archive_write_set_format_option',               [ _ptr, _str, _str, _str ], _int;
_attach 'archive_write_set_option',                      [ _ptr, _str, _str, _str ], _int;
_attach 'archive_write_set_options',                     [ _ptr, _str ], _int;
_attach 'archive_write_set_skip_file',                   [ _ptr, _int64, _int64 ], _int;
_attach 'archive_write_disk_gid',                        [ _ptr, _str, _int64 ], _int64;
_attach 'archive_write_disk_set_skip_file',              [ _ptr, _int64, _int64 ], _int;
_attach 'archive_write_disk_uid',                        [ _ptr, _str, _int64 ], _int64;
_attach 'archive_write_fail',                            [ _ptr ], _int;
_attach 'archive_write_get_bytes_in_last_block',         [ _ptr ], _int;
_attach 'archive_write_get_bytes_per_block',             [ _ptr ], _int;
_attach 'archive_write_set_bytes_in_last_block',         [ _ptr, _int ], _int;
_attach 'archive_write_set_bytes_per_block',             [ _ptr, _int ], _int;

_attach 'archive_entry_clear',                           [ _ptr ], _void;
_attach 'archive_entry_clone',                           [ _ptr ], _ptr;
_attach 'archive_entry_free',                            [ _ptr ], _void;
_attach 'archive_entry_new',                             undef, _ptr;
_attach 'archive_entry_new2',                            [ _ptr ], _ptr;
_attach 'archive_entry_size',                            [ _ptr ], _int64;
_attach 'archive_entry_pathname',                        [ _ptr ], _str;
_attach 'archive_entry_set_pathname',                    [ _ptr, _str ], _void;
_attach 'archive_entry_set_size',                        [ _ptr, _int64 ], _void;
_attach 'archive_entry_set_perm',                        [ _ptr, _int ], _void;
_attach 'archive_entry_set_filetype',                    [ _ptr, _int ], _void;
_attach 'archive_entry_set_mtime',                       [ _ptr, _int, _int ], _void; # FIXME: actually args are (archive_entry *, time_t, long)
_attach 'archive_entry_atime_is_set',                    [ _ptr ], _int;
_attach 'archive_entry_atime',                           [ _ptr ], _int64; # FIXME actually a time_t
_attach 'archive_entry_atime_nsec',                      [ _ptr ], _long;
_attach 'archive_entry_birthtime_is_set',                [ _ptr ], _int;
_attach 'archive_entry_birthtime',                       [ _ptr ], _int64; # FIXME actually a time_t
_attach 'archive_entry_birthtime_nsec',                  [ _ptr ], _long;
_attach 'archive_entry_ctime_is_set',                    [ _ptr ], _int;
_attach 'archive_entry_ctime',                           [ _ptr ], _int64; # FIXME actually a time_t
_attach 'archive_entry_ctime_nsec',                      [ _ptr ], _long;
_attach 'archive_entry_dev_is_set',                      [ _ptr ], _int;
_attach 'archive_entry_dev',                             [ _ptr ], _int64; # FIXME actaully a dev_t
_attach 'archive_entry_devmajor',                        [ _ptr ], _int64; # FIXME actaully a dev_t
_attach 'archive_entry_devminor',                        [ _ptr ], _int64; # FIXME actaully a dev_t
_attach 'archive_entry_fflags_text',                     [ _ptr ], _str;
_attach 'archive_entry_gid',                             [ _ptr ], _int64;

_attach "archive_read_support_filter_$_",  [ _ptr ], _int
  for qw( bzip2 compress gzip grzip lrzip lzip lzma lzop none rpm uu xz );
_attach "archive_read_support_format_$_",  [ _ptr ], _int
  for qw( 7zip ar cab cpio empty gnutar iso9660 lha mtree rar raw tar xar zip );
_attach "archive_write_add_filter_$_", [ _ptr ], _int
  for qw( b64encode bzip2 compress grzip gzip lrzip lzip lzma lzop none uuencode xz );
_attach "archive_write_set_format_$_", [ _ptr ], _int
  for qw( 7zip ar_bsd ar_svr4 cpio cpio_newc gnutar iso9660 mtree mtree_classic 
          pax pax_restricted shar shar_dump ustar v7tar xar zip);

attach_function 'archive_entry_fflags', [ _int64, _int64 ], _void, sub
{
  my $set   = FFI::Raw::MemPtr->new_from_ptr(0);
  my $clear = FFI::Raw::MemPtr->new_from_ptr(0);
  $_[0]->($_[1], $set, $clear);
  $_[2] = deref_to_int64($$set);
  $_[3] = deref_to_int64($$clear);
  return ARCHIVE_OK();
};

attach_function 'archive_read_next_header', [ _ptr, _ptr ], _int, sub
{
  my $entry = FFI::Raw::MemPtr->new_from_ptr(0);
  my $ret = $_[0]->($_[1], $entry);
  $_[2] = deref_to_ptr($$entry);
  $ret;
};

attach_function 'archive_read_data', [ _ptr, _ptr, _int ], _int, sub # FIXME: third argument is actually a size_t
{
  # 0 cb 1 archive 2 buffer 3 size
  my $buffer = FFI::Raw::MemPtr->new($_[3]);
  my $ret = $_[0]->($_[1], $buffer, $_[3]);
  $_[2] = $buffer->tostr($ret);
  $ret;
};

attach_function 'archive_read_data_block', [ _ptr, _ptr, _ptr, _ptr ], _int, sub
{
  # 0 cb 1 archive 2 buffer 3 offset
  my $buffer = FFI::Raw::MemPtr->new_from_ptr(0);
  my $size   = FFI::Raw::MemPtr->new_from_ptr(0);
  my $offset = FFI::Raw::MemPtr->new_from_ptr(0);
  my $ret    = $_[0]->($_[1], $buffer, $size, $offset);
  $size   = do { require Config; $Config::Config{sizesize} == 8 } ? deref_to_uint64($size) : deref_to_uint($size);  # FIXME: size_t
  $offset = deref_to_uint64($offset);
  $_[2]   = buffer_to_scalar(deref_to_ptr($$buffer), $size);
  $_[3]   = $offset;
  $ret;
};

attach_function 'archive_write_data', [ _ptr, _ptr, _int ], _int, sub # FIXME: third argument is actually a size_t
{
  my($cb, $archive, $buffer) = @_;
  my $size = do { use bytes; length($buffer) };
  my $ptr = FFI::Raw::MemPtr->new_from_buf($buffer, $size);
  $cb->($archive, $ptr, $size);
};

attach_function 'archive_write_data_block', [ _ptr, _ptr, _int, _int64 ], _int, sub # FIXME: third argument is actually a size_t
{
  my($cb, $archive, $buffer, $offset) = @_;
  my $size = do { use bytes; length($buffer) };
  my $ptr = FFI::Raw::MemPtr->new_from_buf($buffer, $size);
  $cb->($archive, $ptr, $size, $offset);
};

attach_function 'archive_error_string', [ _ptr ], _str, sub
{
  my $str = $_[0]->($_[1]);
  return '' unless defined $str;
  $str;
};

eval q{
  use Exporter::Tidy
    func  => [grep /^archive_/,       keys %Archive::Libarchive::FFI::],
    const => [grep /^(AE_|ARCHIVE_)/, keys %Archive::Libarchive::FFI::];
}; die $@ if $@;

1;

__END__

=head1 SYNOPSIS

list archive filenames

 use Archive::Libarchive::FFI qw( :all );
 
 my $archive = archive_read_new();
 archive_read_support_filter_all($archive);
 archive_read_support_format_all($archive);
 # example is a tar file, but any supported format should work
 # (zip, iso9660, etc.)
 archive_read_open_filename($archive, 'archive.tar', 10240);
 
 while(archive_read_next_header($archive, my $entry) == ARCHIVE_OK)
 {
   print archive_entry_pathname($entry), "\n";
   archive_read_data_skip($archive);
 }
 
 archive_read_free($archive);

extract archive

 use Archive::Libarchive::FFI qw( :all );
 
 my $archive = archive_read_new();
 archive_read_support_filter_all($archive);
 archive_read_support_format_all($archive);
 my $disk = archive_write_disk_new();
 archive_write_disk_set_options($disk, 
   ARCHIVE_EXTRACT_TIME   |
   ARCHIVE_EXTRACT_PERM   |
   ARCHIVE_EXTRACT_ACL    |
   ARCHIVE_EXTRACT_FFLAGS
 );
 archive_write_disk_set_standard_lookup($disk);
 archive_read_open_filename($archive, 'archive.tar', 10240);
 
 while(1)
 {
   my $r = archive_read_next_header($archive, my $entry);
   last if $r == ARCHIVE_EOF;
   
   archive_write_header($disk, $entry);
   
   while(1)
   {
     my $r = archive_read_data_block($archive, my $buffer, my $offset);
     last if $r == ARCHIVE_EOF;
     archive_write_data_block($disk, $buffer, $offset);
   }
 }
 
 archive_read_close($archive);
 archive_read_free($archive);
 archive_write_close($disk);
 archive_write_free($disk);

write archive

 use File::stat;
 use File::Slurp qw( read_file );
 use Archive::Libarchive::FFI qw( :all );
 
 my $archive = archive_write_new();
 # many other formats are supported ...
 archive_write_set_format_pax_restricted($archive);
 archive_write_open_filename($archive, 'archive.tar');
 
 foreach my $filename (@filenames)
 {
   my $entry = archive_entry_new();
   archive_entry_set_pathname($entry, $filename);
   archive_entry_set_size($entry, stat($filename)->size);
   archive_entry_set_filetype($entry, AE_IFREG);
   archive_entry_set_perm($entry, 0644);
   archive_write_header($archive, $entry);
   archive_write_data($archive, scalar read_file($filename));
   archive_entry_free($entry);
 }
 archive_write_close($archive);
 archive_write_free($archive);

=head1 DESCRIPTION

This module provides a functional interface to C<libarchive>.  C<libarchive> is a
C library that can read and write archives in a variety of formats and with a 
variety of compression filters, optimized in a stream oriented way.  A familiarity
with the C<libarchive> documentation would be helpful, but may not be necessary
for simple tasks.  The documentation for this module is split into four separate
documents:

=over 4

=item L<Archive::Libarchive::FFI>

This document, contains an overview and some examples.

=item L<Archive::Libarchive::FFI::Callback>

Documents the callback interface, used for customizing input and output.

=item L<Archive::Libarchive::FFI::Constant>

Documents the constants provided by this module.

=item L<Archive::Libarchive::FFI::Function>

The function reference, includes a list of all functions provided by this module.

=back

If you are linking against an older version of libarchive, some functions
and constants may not be available.  You can use the C<can> method to test if
a function or constant is available, for example:

 if(Archive::Libarchive::FFI->can('archive_read_support_filter_grzip')
 {
   # grzip filter is available.
 }
 
 if(Archive::Libarchive::FFI->can('ARCHIVE_OK'))
 {
   # ... although ARCHIVE_OK should always be available.
 }

=head1 EXAMPLES

These examples are translated from equivalent C versions provided on the
libarchive website, and are annotated here with Perl specific details.
These examples are also included with the distribution.

=head2 List contents of archive stored in file

# EXAMPLE: example/list_contents_of_archive_stored_in_file.pl

=head2 List contents of archive stored in memory

# EXAMPLE: example/list_contents_of_archive_stored_in_memory.pl

=head2 List contents of archive with custom read functions

# EXAMPLE: example/list_contents_of_archive_with_custom_read_functions.pl

=head2 A universal decompressor

# EXAMPLE: example/universal_decompressor.pl

=head2 A basic write example

# EXAMPLE: example/basic_write.pl

=head2 Constructing objects on disk

# EXAMPLE: example/constructing_objects_on_disk.pl

=head2 A complete extractor

# EXAMPLE: example/complete_extractor.pl

=head1 CAVEATS

Archive and entry objects are really pointers to opaque C structures
and need to be freed using one of C<archive_read_free>, C<archive_write_free>
or C<archive_entry_free>, in order to free the resources associated
with those objects.

The documentation that comes with libarchive is not that great (by its own
admission), being somewhat incomplete, and containing a few subtle errors.
In writing the documentation for this distribution, I borrowed heavily (read:
stole wholesale) from the libarchive documentation, making changes where 
appropriate for use under Perl (changing C<NULL> to C<undef> for example, along 
with the interface change to make that work).  I may and probably have introduced 
additional subtle errors.  Patches to the documentation that match the
implementation, or fixes to the implementation so that it matches the
documentation (which ever is appropriate) would greatly appreciated.

=cut
