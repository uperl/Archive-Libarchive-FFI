package Archive::Libarchive::FFI;

use strict;
use warnings;
use Alien::Libarchive;
use FFI::Raw ();
use FFI::Raw::PtrPtr;
use FFI::Sweet qw( ffi_lib :types );
use base qw( Exporter );

sub _int64  { FFI::Raw::int64() }
sub _uint64 { FFI::Raw::uint64() }

# ABSTRACT: Perl bindings to libarchive via FFI
# VERSION

ffi_lib \$_ for DynaLoader::dl_findfile(split /\s+/, Alien::Libarchive->new->libs);

our %EXPORT_TAGS = ( all => [], const => [], func => [] );

require Archive::Libarchive::FFI::constants;
require Archive::Libarchive::FFI::functions;

sub attach_function ($$$)
{
  my ( $name, $arg, $rv ) = @_;
  push @{ $EXPORT_TAGS{func} }, $name;
  eval { FFI::Sweet::attach_function($name, $arg, $rv) };
}

attach_function 'archive_version_number',                        undef, _int;
attach_function 'archive_version_string',                        undef, _str;
attach_function 'archive_clear_error',                           [ _ptr ], _void;
attach_function 'archive_copy_error',                            [ _ptr ], _int;
attach_function 'archive_errno',                                 [ _ptr ], _int;
attach_function 'archive_file_count',                            [ _ptr ], _int;
attach_function 'archive_format',                                [ _ptr ], _int;
attach_function 'archive_format_name',                           [ _ptr ], _str;

attach_function 'archive_read_new',                              undef, _ptr;
attach_function 'archive_read_support_filter_all',               [ _ptr ], _int;
attach_function 'archive_read_support_format_all',               [ _ptr ], _int;
attach_function 'archive_read_open_filename',                    [ _ptr, _str, _int ], _int;
attach_function 'archive_read_free',                             [ _ptr ], _int;
attach_function 'archive_read_data_skip',                        [ _ptr ], _int;
attach_function 'archive_read_close',                            [ _ptr ], _int;
attach_function 'archive_read_support_filter_program',           [ _ptr, _str ], _int;
attach_function 'archive_read_support_format_by_code',           [ _ptr, _int ], _int;

attach_function 'archive_filter_code',                           [ _ptr, _int ], _int;
attach_function 'archive_filter_count',                          [ _ptr ], _int;
attach_function 'archive_filter_name',                           [ _ptr, _int ], _str;

attach_function 'archive_write_new',                             undef, _ptr;
attach_function 'archive_write_free',                            [ _ptr ], _int;
attach_function 'archive_write_add_filter',                      [ _ptr, _int ], _int;
attach_function 'archive_write_add_filter_by_name',              [ _ptr, _str ], _int;
attach_function 'archive_write_add_filter_program',              [ _ptr, _str ], _int;
attach_function 'archive_write_set_format',                      [ _ptr, _int ], _int;
attach_function 'archive_write_set_format_by_name',              [ _ptr, _str ], _int;
attach_function 'archive_write_open_filename',                   [ _ptr, _str ], _int;
attach_function 'archive_write_header',                          [ _ptr, _ptr ], _int;
attach_function 'archive_write_close',                           [ _ptr ], _int;
attach_function 'archive_write_disk_new',                        undef, _ptr;
attach_function 'archive_write_disk_set_options',                [ _ptr, _int ], _int;
attach_function 'archive_write_finish_entry',                    [ _ptr ], _int;
attach_function 'archive_write_disk_set_standard_lookup',        [ _ptr ], _int;
attach_function 'archive_write_zip_set_compression_deflate',     [ _ptr ], _int;
attach_function 'archive_write_zip_set_compression_store',       [ _ptr ], _int;

attach_function 'archive_entry_clear',                           [ _ptr ], _void;
attach_function 'archive_entry_clone',                           [ _ptr ], _ptr;
attach_function 'archive_entry_free',                            [ _ptr ], _void;
attach_function 'archive_entry_new',                             undef, _ptr;
attach_function 'archive_entry_new2',                            [ _ptr ], _ptr;
attach_function 'archive_entry_size',                            [ _ptr ], _int64;
attach_function 'archive_entry_pathname',                        [ _ptr ], _str;
attach_function 'archive_entry_set_pathname',                    [ _ptr, _str ], _void;
attach_function 'archive_entry_set_size',                        [ _ptr, _int64 ], _void;
attach_function 'archive_entry_set_perm',                        [ _ptr, _int ], _void;
attach_function 'archive_entry_set_filetype',                    [ _ptr, _int ], _void;
attach_function 'archive_entry_set_mtime',                       [ _ptr, _int, _int ], _void; # FIXME: actually args are (archive_entry *, time_t, long)

attach_function "archive_read_support_filter_$_",  [ _ptr ], _int
  for qw( bzip2 compress gzip grzip lrzip lzip lzma lzop none rpm uu xz );
attach_function "archive_read_support_format_$_",  [ _ptr ], _int
  for qw( 7zip ar cab cpio empty gnutar iso9660 lha mtree rar raw tar xar zip );
attach_function "archive_write_add_filter_$_", [ _ptr ], _int
  for qw( b64encode bzip2 compress grzip gzip lrzip lzip lzma lzop none uuencode xz );
attach_function "archive_write_set_format_$_", [ _ptr ], _int
  for qw( 7zip ar_bsd ar_svr4 cpio cpio_newc gnutar iso9660 mtree mtree_classic 
          pax pax_restricted shar shar_dump ustar v7tar xar zip);

push @{ $EXPORT_TAGS{func} }, qw(
  archive_read_next_header
  archive_read_open_memory
  archive_read_data
  archive_error_string
  archive_write_data
  archive_read_open_stdin
  archive_write_open_stdout
  archive_write_data_block
  archive_read_data_block
);

sub archive_read_open_stdin
{
  archive_read_open_filename($_[0], 0, $_[1]);
}

sub archive_write_open_stdout
{
  archive_write_open_filename($_[0], 0);
}

sub archive_read_next_header
{
  my $entry = FFI::Raw::PtrPtr->new;  
  my $ret = Archive::Libarchive::FFI::functions::archive_read_next_header($_[0], $entry);
  $_[1] = $entry->dereference;
  $ret;
}

sub archive_read_open_memory
{
  my($archive, $buffer) = @_;
  my $length = do { use bytes; length($buffer) }; # TODO: what is the "right" way to do this?
  my $ptr = FFI::Raw::PtrPtr->scalar_to_pointer($buffer);
  Archive::Libarchive::FFI::functions::archive_read_open_memory($archive, $ptr, $length);
}

sub archive_read_data
{
  # 0 archive 1 buffer 2 size
  my $buffer = FFI::Raw::MemPtr->new($_[2]);
  my $ret = Archive::Libarchive::FFI::functions::archive_read_data($_[0], $buffer, $_[2]);
  $_[1] = $buffer->tostr($ret);
  $ret;
}

sub archive_read_data_block
{
  # 0 archive 1 buffer 2 offset
  require Config;
  my $buffer = FFI::Raw::PtrPtr->new;
  my $size   = FFI::Raw::MemPtr->new($Config::Config{sizesize});  # size_t
  my $offset = FFI::Raw::MemPtr->new(8);                          # uint64_t
  my $ret    = Archive::Libarchive::FFI::functions::archive_read_data_block($_[0], $buffer, $size, $offset);
  my $pattern = $Config::Config{sizesize} == 8 ? "Q1" : "L1";
  $size   = unpack $pattern, $size->tostr($Config::Config{sizesize});
  $offset = unpack "q1", $offset->tostr(8);
  $buffer->copy_to_buffer($_[1], $size);
  $_[2]   = $offset;
  $ret;
}

sub archive_write_data
{
  my($archive, $buffer) = @_;
  my $length = do { use bytes; length($buffer) }; # TODO: what is the "right" way to do this?
  my $ptr = FFI::Raw::PtrPtr->scalar_to_pointer($buffer);
  Archive::Libarchive::FFI::functions::archive_write_data($archive, $ptr, $length);
}

sub archive_write_data_block
{
  my($archive, $buffer, $offset) = @_;
  my $length = do { use bytes; length($buffer) }; # TODO: what is the "right" way to do this?
  my $ptr = FFI::Raw::PtrPtr->scalar_to_pointer($buffer);
  Archive::Libarchive::FFI::functions::archive_write_data_block($archive, $ptr, $length, $offset);
}

sub archive_error_string
{
  my $str = Archive::Libarchive::FFI::functions::archive_error_string($_[0]);
  return '' unless defined $str;
  $str;
}

@{ $EXPORT_TAGS{func} } = sort @{ $EXPORT_TAGS{func} };

our @EXPORT_OK = (map { @{ $EXPORT_TAGS{$_} } } qw( const func ));
$EXPORT_TAGS{all} = \@EXPORT_OK;

1;

__END__

=head1 SYNOPSIS

 use Archive::Libarchive::FFI;

=head1 DESCRIPTION

This module provides a functional interface to C<libarchive>.  C<libarchive> is a
C library that can read and write archives in a variety of formats and with a 
variety of compression filters, optimized in a stream oriented way.  A familiarity
with the C<libarchive> documentation would be helpful, but may not be necessary
for simple tasks.

=head1 FUNCTIONS

Unless otherwise specified, each function will return an integer return code,
with one of the following values:

=over 4

=item ARCHIVE_OK

Operation was successful

=item ARCHIVE_EOF

Fond end of archive

=item ARCHIVE_RETRY

Retry might succeed

=item ARCHIVE_WARN

Partial success

=item ARCHIVE_FAILED

Current operation cannot complete

=item ARCHIVE_FATAL

No more operations are possible

=back

If you are linking against an older version of libarchive, some of these 
functions may not be available.  You can use the C<can> method to test if
a function or constant is available, for example:

 if(Archive::Libarchive::FFI->can('archive_read_support_filter_grzip')
 {
   # grzip filter is available.
 }

=head2 archive_clear_error($archive)

Clears any error information left over from a previous call Not
generally used in client code.  Does not return a value.

=head2 archive_copy_error($archive1, $archive2)

Copies error information from one archive to another.

=head2 archive_entry_clear

Erases the object, resetting all internal fields to the same state as a newly-created object.  This is provided
to allow you to quickly recycle objects without thrashing the heap.

=head2 archive_entry_clone

A deep copy operation; all text fields are duplicated.

=head2 archive_entry_free

Releases the struct archive_entry object.

=head2 archive_entry_new

Allocate and return a blank struct archive_entry object.

=head2 archive_entry_new2($archive)

This form of C<archive_entry_new2> will pull character-set
conversion information from the specified archive handle.  The
older C<archive_entry_new> form will result in the use of an internal
default character-set conversion.

=head2 archive_entry_pathname($entry)

Retrieve the pathname of the entry.

Returns a string value.

=head2 archive_entry_set_filetype($entry, $code)

Sets the filetype in the archive.  Code should be one of

=over 4

=item AE_IFMT

=item AE_IFREG

=item AE_IFLNK

=item AE_IFSOCK

=item AE_IFCHR

=item AE_IFBLK

=item AE_IFDIR

=item AE_IFIFO

=back

Does not return anything.

=head2 archive_entry_set_mtime($entry, $sec, $nanosec)

Set the mtime for the entry object.

Does not return a value.

=head2 archive_entry_set_pathname($entry, $name)

Sets the path in the archive as a string.

Does not return anything.

=head2 archive_entry_set_perm

Set the permission bits for the entry.  This is the usual UNIX octal permission thing.

Does not return anything.

=head2 archive_entry_set_size($entry, $size)

Sets the size of the file in the archive.

Does not return anything.

=head2 archive_entry_size($entry)

Returns the size of the entry in bytes.

=head2 archive_errno($archive)

Returns a numeric error code indicating the reason for the most
recent error return.

Return type is an errno integer value.

=head2 archive_error_string($archive)

Returns a textual error message suitable for display.  The error
message here is usually more specific than that obtained from
passing the result of C<archive_errno> to C<strerror>.

Return type is a string.

=head2 archive_file_count($archive)

Returns a count of the number of files processed by this archive object.  The count
is incremented by calls to C<archive_write_header> or C<archive_read_next_header>.

=head2 archive_filter_code

Returns a numeric code identifying the indicated filter.  See C<archive_filter_count>
for details of the numbering.

=head2 archive_filter_count

Returns the number of filters in the current pipeline. For read archive handles, these 
filters are added automatically by the automatic format detection. For write archive 
handles, these filters are added by calls to the various C<archive_write_add_filter_XXX>
functions. Filters in the resulting pipeline are numbered so that filter 0 is the filter 
closest to the format handler. As a convenience, functions that expect a filter number 
will accept -1 as a synonym for the highest-numbered filter. For example, when reading 
a uuencoded gzipped tar archive, there are three filters: filter 0 is the gunzip filter, 
filter 1 is the uudecode filter, and filter 2 is the pseudo-filter that wraps the archive 
read functions. In this case, requesting C<archive_position(a,(-1))> would be a synonym
for C<archive_position(a,(2))> which would return the number of bytes currently read from 
the archive, while C<archive_position(a,(1))> would return the number of bytes after
uudecoding, and C<archive_position(a,(0))> would return the number of bytes after decompression.

=head2 archive_filter_name

Returns a textual name identifying the indicated filter.  See L<#archive_filter_count> for
details of the numbering.

=head2 archive_format($archive)

Returns a numeric code indicating the format of the current archive
entry.  This value is set by a successful call to
C<archive_read_next_header>.  Note that it is common for this value
to change from entry to entry.  For example, a tar archive might
have several entries that utilize GNU tar extensions and several
entries that do not.  These entries will have different format
codes.

=head2 archive_format_name($archive)

A textual description of the format of the current entry.

=head2 archive_read_close($archive)

Complete the archive and invoke the close callback.

=head2 archive_read_data($archive, $buffer, $max_size)

Read data associated with the header just read.  Internally, this is a
convenience function that calls C<archive_read_data_block> and fills
any gaps with nulls so that callers see a single continuous stream of
data.  Returns the actual number of bytes read, 0 on end of data and
a negative value on error.

=head2 archive_read_data_block($archive, $buff, $offset)

Return the next available block of data for this entry.  Unlike
C<archive_read_data>, this function allows you to correctly
handle sparse files, as supported by some archive formats.  The
library guarantees that offsets will increase and that blocks
will not overlap.  Note that the blocks returned from this
function can be much larger than the block size read from disk,
due to compression and internal buffer optimizations.

=head2 archive_read_data_skip($archive)

A convenience function that repeatedly calls C<archive_read_data> to skip
all of the data for this archive entry.

=head2 archive_read_free($archive)

Invokes C<archive_read_close> if it was not invoked manually, then
release all resources.

=head2 archive_read_new

Allocates and initializes a archive object suitable for reading from an archive.
Returns an opaque archive which may be a perl style object, or a C pointer
(depending on the implementation), either way, it can be passed into
any of the read functions documented here with an <$archive> argument.

=head2 archive_read_next_header($archive, $entry)

Read the header for the next entry and return an entry object
Returns an opaque archive which may be a perl style object, or a C pointer
(depending on the implementation), either way, it can be passed into
any of the functions documented here with an <$entry> argument.

TODO: maybe use archive_read_next_header2

=head2 archive_read_open_filename($archive, $filename, $block_size)

Like C<archive_read_open>, except that it accepts a simple filename
and a block size.  This function is safe for use with tape drives
or other blocked devices.

=head2 archive_read_open_memory($archive, $buffer)

Like C<archive_read_open>, except that it uses a Perl scalar that holds the 
content of the archive.  This function does not make a copy of the data stored 
in C<$buffer>, so you should not modify the buffer until you have free the 
archive using C<archive_read_free>.

Bad things will happen if the buffer falls out of scope and is deallocated
before you free the archive, so make sure that there is a reference to the
buffer somewhere in your programmer until C<archive_read_free> is called.

=head2 archive_read_open_stdin($archive, $block_size)

This is just like C<archive_read_open_filename> except, read from
standard input instead of a file.

Note: this function does not exist in the C API, it is offered here
instead this C call, which does the same thing:

 archive_read_open_filename(archive, NULL, block_size);

=head2 archive_read_support_filter_all($archive)

Enable all available decompression filters.

=head2 archive_read_support_filter_bzip2($archive)

Enable bzip2 decompression filter.

=head2 archive_read_support_filter_compress($archive)

Enable compress decompression filter.

=head2 archive_read_support_filter_grzip($archive)

Enable grzip decompression filter.

=head2 archive_read_support_filter_gzip($archive)

Enable gzip decompression filter.

=head2 archive_read_support_filter_lrzip($archive)

Enable lrzip decompression filter.

=head2 archive_read_support_filter_lzip($archive)

Enable lzip decompression filter.

=head2 archive_read_support_filter_lzma($archive)

Enable lzma decompression filter.

=head2 archive_read_support_filter_lzop($archive)

Enable lzop decompression filter.

=head2 archive_read_support_filter_none($archive)

Enable none decompression filter.

=head2 archive_read_support_filter_program(archive, command)

Data is feed through the specified external program before being
dearchived.  Note that this disables automatic detection of the
compression format, so it makes no sense to specify this in
conjunction with any other decompression option.

=head2 archive_read_support_filter_rpm($archive)

Enable rpm decompression filter.

=head2 archive_read_support_filter_uu($archive)

Enable uu decompression filter.

=head2 archive_read_support_filter_xz($archive)

Enable xz decompression filter.

=head2 archive_read_support_format_7zip($archive)

Enable 7zip archive format.

=head2 archive_read_support_format_all($archive)

Enable all available archive formats.

=head2 archive_read_support_format_ar($archive)

Enable ar archive format.

=head2 archive_read_support_format_by_code($archive, $code)

Enables a single format specified by the format code.

=head2 archive_read_support_format_cab($archive)

Enable cab archive format.

=head2 archive_read_support_format_cpio($archive)

Enable cpio archive format.

=head2 archive_read_support_format_empty($archive)

Enable empty archive format.

=head2 archive_read_support_format_gnutar($archive)

Enable gnutar archive format.

=head2 archive_read_support_format_iso9660($archive)

Enable iso9660 archive format.

=head2 archive_read_support_format_lha($archive)

Enable lha archive format.

=head2 archive_read_support_format_mtree($archive)

Enable mtree archive format.

=head2 archive_read_support_format_rar($archive)

Enable rar archive format.

=head2 archive_read_support_format_raw($archive)

Enable raw archive format.

=head2 archive_read_support_format_tar($archive)

Enable tar archive format.

=head2 archive_read_support_format_xar($archive)

Enable xar archive format.

=head2 archive_read_support_format_zip($archive)

Enable zip archive format.

=head2 archive_version_number

Return the libarchive version as an integer.

=head2 archive_version_string

Return the libarchive as a version.

Returns a string value.

=head2 archive_write_add_filter($archive, $code)

A convenience function to set the filter based on the code.

=head2 archive_write_add_filter_b64encode($archive)

Add b64encode filter

=head2 archive_write_add_filter_by_name($archive, $name)

A convenience function to set the filter based on the name.

=head2 archive_write_add_filter_bzip2($archive)

Add bzip2 filter

=head2 archive_write_add_filter_compress($archive)

Add compress filter

=head2 archive_write_add_filter_grzip($archive)

Add grzip filter

=head2 archive_write_add_filter_gzip($archive)

Add gzip filter

=head2 archive_write_add_filter_lrzip($archive)

Add lrzip filter

=head2 archive_write_add_filter_lzip($archive)

Add lzip filter

=head2 archive_write_add_filter_lzma($archive)

Add lzma filter

=head2 archive_write_add_filter_lzop($archive)

Add lzop filter

=head2 archive_write_add_filter_none($archive)

Add none filter

=head2 archive_write_add_filter_program($archive, $cmd)

The archive will be fed into the specified compression program. 
The output of that program is blocked and written to the client
write callbacks.

=head2 archive_write_add_filter_uuencode($archive)

Add uuencode filter

=head2 archive_write_add_filter_xz($archive)

Add xz filter

=head2 archive_write_close(archive)

Complete the archive and invoke the close callback.

=head2 archive_write_data(archive, buffer)

Write data corresponding to the header just written.

This function returns the number of bytes actually written, or -1 on error.

=head2 archive_write_data_block($archive, $buff, $offset)

Writes the buffer to the current entry in the given archive
starting at the given offset.

=head2 archive_write_disk_new

Allocates and initializes a struct archive object suitable for
writing objects to disk.

Returns an opaque archive which may be a perl style object, or a C pointer
(Depending on the implementation), either way, it can be passed into
any of the write functions documented here with an C<$archive> argument.

=head2 archive_write_disk_set_options($archive, $flags)

The options field consists of a bitwise OR of one or more of the 
following values:

=over 4

=item ARCHIVE_EXTRACT_OWNER

=item ARCHIVE_EXTRACT_PERM

=item ARCHIVE_EXTRACT_TIME

=item ARCHIVE_EXTRACT_NO_OVERWRITE

=item ARCHIVE_EXTRACT_UNLINK

=item ARCHIVE_EXTRACT_ACL

=item ARCHIVE_EXTRACT_FFLAGS

=item ARCHIVE_EXTRACT_XATTR

=item ARCHIVE_EXTRACT_SECURE_SYMLINKS

=item ARCHIVE_EXTRACT_SECURE_NODOTDOT

=item ARCHIVE_EXTRACT_SPARSE

=back

=head2 archive_write_disk_set_standard_lookup($archive)

This convenience function installs a standard set of user and
group lookup functions.  These functions use C<getpwnam> and
C<getgrnam> to convert names to ids, defaulting to the ids
if the names cannot be looked up.  These functions also implement
a simple memory cache to reduce the number of calls to 
C<getpwnam> and C<getgrnam>.

=head2 archive_write_finish_entry($archive)

Close out the entry just written.  Ordinarily, 
clients never need to call this, as it is called 
automatically by C<archive_write_next_header> and 
C<archive_write_close> as needed.  However, some
file attributes are written to disk only after 
the file is closed, so this can be necessary 
if you need to work with the file on disk right away.

=head2 archive_write_free($archive)

Invokes C<archive_write_close> if it was not invoked manually, then
release all resources.

=head2 archive_write_header($archive, $entry)

Build and write a header using the data in the provided struct archive_entry structure.
You can use C<archive_entry_new> to create an C<$entry> object and populate it with
C<archive_entry_set*> functions.

=head2 archive_write_new

Allocates and initializes a archive object suitable for writing an new archive.
Returns an opaque archive which may be a perl style object, or a C pointer
(depending on the implementation), either way, it can be passed into
any of the write functions documented here with an C<$archive> argument.

=head2 archive_write_open_filename($archive, $filename)

A convenience form of C<archive_write_open> that accepts a filename.  If you have 
not invoked C<archive_write_set_bytes_in_last_block>, then 
C<archive_write_open_filename> will adjust the last-block padding depending on the 
file: it will enable padding when writing to standard output or to a character or 
block device node, it will disable padding otherwise.  You can override this by 
manually invoking C<archive_write_set_bytes_in_last_block> before C<calling 
archive_write_open>.  The C<archive_write_open_filename> function is safe for use 
with tape drives or other block-oriented devices.

=head2 archive_write_open_stdout($archive, $filename)

This is the same as C<archive_write_open_filename>, except a C NULL pointer is passed
in for the filename, which indicates stdout.

=head2 archive_write_set_filter_option($archive, $module, $option, $value)

Specifies an option that will be passed to currently-registered filters (including decompression filters).

TODO: translate undefs to NULL for $module, $option and $value

=head2 archive_write_set_format($archive, $code)

A convenience function to set the format based on the code.

=head2 archive_write_set_format_7zip($archive)

Set the archive format to 7zip

=head2 archive_write_set_format_ar_bsd($archive)

Set the archive format to ar_bsd

=head2 archive_write_set_format_ar_svr4($archive)

Set the archive format to ar_svr4

=head2 archive_write_set_format_by_name($archive, $name)

A convenience function to set the format based on the name.

=head2 archive_write_set_format_cpio($archive)

Set the archive format to cpio

=head2 archive_write_set_format_cpio_newc($archive)

Set the archive format to cpio_newc

=head2 archive_write_set_format_gnutar($archive)

Set the archive format to gnutar

=head2 archive_write_set_format_iso9660($archive)

Set the archive format to iso9660

=head2 archive_write_set_format_mtree($archive)

Set the archive format to mtree

=head2 archive_write_set_format_mtree_classic($archive)

Set the archive format to mtree_classic

=head2 archive_write_set_format_option($archive, $module, $option, $value)

Specifies an option that will be passed to currently-registered format readers.

TODO: translate undefs to NULL for $module, $option and $value

=head2 archive_write_set_format_pax($archive)

Set the archive format to pax

=head2 archive_write_set_format_pax_restricted($archive)

Set the archive format to pax_restricted

=head2 archive_write_set_format_shar($archive)

Set the archive format to shar

=head2 archive_write_set_format_shar_dump($archive)

Set the archive format to shar_dump

=head2 archive_write_set_format_ustar($archive)

Set the archive format to ustar

=head2 archive_write_set_format_v7tar($archive)

Set the archive format to v7tar

=head2 archive_write_set_format_xar($archive)

Set the archive format to xar

=head2 archive_write_set_format_zip($archive)

Set the archive format to zip

=head2 archive_write_set_option($archive, $module, $option, $value)

Calls C<archive_write_set_format_option>, then C<archive_write_set_filter_option>.
If either function returns C<ARCHIVE_FATAL>, C<ARCHIVE_FATAL> will be returned
immediately.  Otherwise, greater of the two values will be returned.

TODO: translate undefs to NULL for $module, $option and $value

=head2 archive_write_set_options($archive, $opts)

options is a comma-separated list of options.  If options is NULL or empty, ARCHIVE_OK will be returned immediately.

Individual options have one of the following forms:

=over 4

=item option=value

The option/value pair will be provided to every module.  Modules that do not accept an option with this name will ignore it.

=item option

The option will be provided to every module with a value of "1".

=item !option

The option will be provided to every module with a NULL value.

=item module:option=value, module:option, module:!option

As above, but the corresponding option and value will be provided only to modules whose name matches module.

=back

=head2 archive_write_set_skip_file($archive, $dev, $ino)

The dev/ino of a file that won't be archived.  This is used
to avoid recursively adding an archive to itself.

=head2 archive_write_zip_set_compression_deflate($archive)

Set the compression method for the zip archive to deflate.

=head2 archive_write_zip_set_compression_store($archive)

Set the compression method for the zip archive to store.

=head1 CONSTANTS

If provided by your libarchive library, these constants will be available and
exportable from the L<Archive::Libarchive::FFI> (you may import all available
constants using the C<:const> export tag).

=over 4

=item AE_IFBLK

=item AE_IFCHR

=item AE_IFDIR

=item AE_IFIFO

=item AE_IFLNK

=item AE_IFMT

=item AE_IFREG

=item AE_IFSOCK

=item ARCHIVE_API_FEATURE

=item ARCHIVE_API_VERSION

=item ARCHIVE_BYTES_PER_RECORD

=item ARCHIVE_COMPRESSION_BZIP2

=item ARCHIVE_COMPRESSION_COMPRESS

=item ARCHIVE_COMPRESSION_GZIP

=item ARCHIVE_COMPRESSION_LRZIP

=item ARCHIVE_COMPRESSION_LZIP

=item ARCHIVE_COMPRESSION_LZMA

=item ARCHIVE_COMPRESSION_NONE

=item ARCHIVE_COMPRESSION_PROGRAM

=item ARCHIVE_COMPRESSION_RPM

=item ARCHIVE_COMPRESSION_UU

=item ARCHIVE_COMPRESSION_XZ

=item ARCHIVE_DEFAULT_BYTES_PER_BLOCK

=item ARCHIVE_ENTRY_ACL_ADD_FILE

=item ARCHIVE_ENTRY_ACL_ADD_SUBDIRECTORY

=item ARCHIVE_ENTRY_ACL_APPEND_DATA

=item ARCHIVE_ENTRY_ACL_DELETE

=item ARCHIVE_ENTRY_ACL_DELETE_CHILD

=item ARCHIVE_ENTRY_ACL_ENTRY_DIRECTORY_INHERIT

=item ARCHIVE_ENTRY_ACL_ENTRY_FAILED_ACCESS

=item ARCHIVE_ENTRY_ACL_ENTRY_FILE_INHERIT

=item ARCHIVE_ENTRY_ACL_ENTRY_INHERIT_ONLY

=item ARCHIVE_ENTRY_ACL_ENTRY_NO_PROPAGATE_INHERIT

=item ARCHIVE_ENTRY_ACL_ENTRY_SUCCESSFUL_ACCESS

=item ARCHIVE_ENTRY_ACL_EVERYONE

=item ARCHIVE_ENTRY_ACL_EXECUTE

=item ARCHIVE_ENTRY_ACL_GROUP

=item ARCHIVE_ENTRY_ACL_GROUP_OBJ

=item ARCHIVE_ENTRY_ACL_INHERITANCE_NFS4

=item ARCHIVE_ENTRY_ACL_LIST_DIRECTORY

=item ARCHIVE_ENTRY_ACL_MASK

=item ARCHIVE_ENTRY_ACL_OTHER

=item ARCHIVE_ENTRY_ACL_PERMS_NFS4

=item ARCHIVE_ENTRY_ACL_PERMS_POSIX1E

=item ARCHIVE_ENTRY_ACL_READ

=item ARCHIVE_ENTRY_ACL_READ_ACL

=item ARCHIVE_ENTRY_ACL_READ_ATTRIBUTES

=item ARCHIVE_ENTRY_ACL_READ_DATA

=item ARCHIVE_ENTRY_ACL_READ_NAMED_ATTRS

=item ARCHIVE_ENTRY_ACL_STYLE_EXTRA_ID

=item ARCHIVE_ENTRY_ACL_STYLE_MARK_DEFAULT

=item ARCHIVE_ENTRY_ACL_SYNCHRONIZE

=item ARCHIVE_ENTRY_ACL_TYPE_ACCESS

=item ARCHIVE_ENTRY_ACL_TYPE_ALARM

=item ARCHIVE_ENTRY_ACL_TYPE_ALLOW

=item ARCHIVE_ENTRY_ACL_TYPE_AUDIT

=item ARCHIVE_ENTRY_ACL_TYPE_DEFAULT

=item ARCHIVE_ENTRY_ACL_TYPE_DENY

=item ARCHIVE_ENTRY_ACL_TYPE_NFS4

=item ARCHIVE_ENTRY_ACL_TYPE_POSIX1E

=item ARCHIVE_ENTRY_ACL_USER

=item ARCHIVE_ENTRY_ACL_USER_OBJ

=item ARCHIVE_ENTRY_ACL_WRITE

=item ARCHIVE_ENTRY_ACL_WRITE_ACL

=item ARCHIVE_ENTRY_ACL_WRITE_ATTRIBUTES

=item ARCHIVE_ENTRY_ACL_WRITE_DATA

=item ARCHIVE_ENTRY_ACL_WRITE_NAMED_ATTRS

=item ARCHIVE_ENTRY_ACL_WRITE_OWNER

=item ARCHIVE_EOF

=item ARCHIVE_EXTRACT_ACL

=item ARCHIVE_EXTRACT_FFLAGS

=item ARCHIVE_EXTRACT_HFS_COMPRESSION_FORCED

=item ARCHIVE_EXTRACT_MAC_METADATA

=item ARCHIVE_EXTRACT_NO_AUTODIR

=item ARCHIVE_EXTRACT_NO_HFS_COMPRESSION

=item ARCHIVE_EXTRACT_NO_OVERWRITE

=item ARCHIVE_EXTRACT_NO_OVERWRITE_NEWER

=item ARCHIVE_EXTRACT_OWNER

=item ARCHIVE_EXTRACT_PERM

=item ARCHIVE_EXTRACT_SECURE_NODOTDOT

=item ARCHIVE_EXTRACT_SECURE_SYMLINKS

=item ARCHIVE_EXTRACT_SPARSE

=item ARCHIVE_EXTRACT_TIME

=item ARCHIVE_EXTRACT_UNLINK

=item ARCHIVE_EXTRACT_XATTR

=item ARCHIVE_FAILED

=item ARCHIVE_FATAL

=item ARCHIVE_FILTER_BZIP2

=item ARCHIVE_FILTER_COMPRESS

=item ARCHIVE_FILTER_GRZIP

=item ARCHIVE_FILTER_GZIP

=item ARCHIVE_FILTER_LRZIP

=item ARCHIVE_FILTER_LZIP

=item ARCHIVE_FILTER_LZMA

=item ARCHIVE_FILTER_LZOP

=item ARCHIVE_FILTER_NONE

=item ARCHIVE_FILTER_PROGRAM

=item ARCHIVE_FILTER_RPM

=item ARCHIVE_FILTER_UU

=item ARCHIVE_FILTER_XZ

=item ARCHIVE_FORMAT_7ZIP

=item ARCHIVE_FORMAT_AR

=item ARCHIVE_FORMAT_AR_BSD

=item ARCHIVE_FORMAT_AR_GNU

=item ARCHIVE_FORMAT_BASE_MASK

=item ARCHIVE_FORMAT_CAB

=item ARCHIVE_FORMAT_CPIO

=item ARCHIVE_FORMAT_CPIO_AFIO_LARGE

=item ARCHIVE_FORMAT_CPIO_BIN_BE

=item ARCHIVE_FORMAT_CPIO_BIN_LE

=item ARCHIVE_FORMAT_CPIO_POSIX

=item ARCHIVE_FORMAT_CPIO_SVR4_CRC

=item ARCHIVE_FORMAT_CPIO_SVR4_NOCRC

=item ARCHIVE_FORMAT_EMPTY

=item ARCHIVE_FORMAT_ISO9660

=item ARCHIVE_FORMAT_ISO9660_ROCKRIDGE

=item ARCHIVE_FORMAT_LHA

=item ARCHIVE_FORMAT_MTREE

=item ARCHIVE_FORMAT_RAR

=item ARCHIVE_FORMAT_RAW

=item ARCHIVE_FORMAT_SHAR

=item ARCHIVE_FORMAT_SHAR_BASE

=item ARCHIVE_FORMAT_SHAR_DUMP

=item ARCHIVE_FORMAT_TAR

=item ARCHIVE_FORMAT_TAR_GNUTAR

=item ARCHIVE_FORMAT_TAR_PAX_INTERCHANGE

=item ARCHIVE_FORMAT_TAR_PAX_RESTRICTED

=item ARCHIVE_FORMAT_TAR_USTAR

=item ARCHIVE_FORMAT_XAR

=item ARCHIVE_FORMAT_ZIP

=item ARCHIVE_LIBRARY_VERSION

=item ARCHIVE_MATCH_CTIME

=item ARCHIVE_MATCH_EQUAL

=item ARCHIVE_MATCH_MTIME

=item ARCHIVE_MATCH_NEWER

=item ARCHIVE_MATCH_OLDER

=item ARCHIVE_OK

=item ARCHIVE_READDISK_HONOR_NODUMP

=item ARCHIVE_READDISK_MAC_COPYFILE

=item ARCHIVE_READDISK_NO_TRAVERSE_MOUNTS

=item ARCHIVE_READDISK_RESTORE_ATIME

=item ARCHIVE_RETRY

=item ARCHIVE_VERSION_NUMBER

=item ARCHIVE_VERSION_STAMP

=item ARCHIVE_WARN

=back

=head1 EXAMPLES

These examples are translated from equivalent C versions provided on the
libarchive website, and are annotated here with Perl specific details.
These examples are also included with the distribution.

=head2 List contents of archive stored in file

# EXAMPLE: example/list_contents_of_archive_stored_in_file.pl

=head2 List contents of archive stored in memory

# EXAMPLE: example/list_contents_of_archive_stored_in_memory.pl

=head2 List contents of archive with custom read functions

TODO

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

The documentation that comes with libarchive is not that great, but
is serviceable.  The documentation for this library is copied largely
from libarchive, with adjustments for Perl.

