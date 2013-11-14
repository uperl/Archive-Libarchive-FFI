package Archive::Libarchive::FFI;

use strict;
use warnings;
use Alien::Libarchive;
use FFI::Raw::PtrPtr;
use FFI::Sweet qw( ffi_lib :types );
use base qw( Exporter );

# ABSTRACT: Perl bindings to libarchive via FFI
# VERSION

ffi_lib \$_ for map { print "$_\n" if 0; $_ } DynaLoader::dl_findfile(split /\s+/, Alien::Libarchive->new->libs);

our %EXPORT_TAGS = ( all => [], const => [], func => [] );

require Archive::Libarchive::FFI::constants;
require Archive::Libarchive::FFI::functions;

sub attach_function ($$$)
{
  my ( $name, $arg, $rv ) = @_;
  push @{ $EXPORT_TAGS{func} }, $name;
  FFI::Sweet::attach_function($name, $arg, $rv);
}

attach_function 'archive_read_new',                    undef, _ptr;
attach_function 'archive_read_support_filter_all',     [ _ptr ], _int;
attach_function 'archive_read_support_format_all',     [ _ptr ], _int;
attach_function 'archive_read_open_filename',          [ _ptr, _str, _int ], _int;
attach_function 'archive_read_free',                   [ _ptr ], _int;
attach_function 'archive_entry_pathname',              [ _ptr ], _str;
attach_function 'archive_read_data_skip',              [ _ptr ], _int;
attach_function 'archive_clear_error',                 [ _ptr ], _void;
attach_function 'archive_copy_error',                  [ _ptr ], _int;
attach_function 'archive_filter_code',                 [ _ptr, _int ], _int;
attach_function 'archive_filter_count',                [ _ptr ], _int;
attach_function 'archive_filter_name',                 [ _ptr, _int ], _str;
attach_function 'archive_errno',                       [ _ptr ], _int;
attach_function 'archive_file_count',                  [ _ptr ], _int;
attach_function 'archive_format',                      [ _ptr ], _int;
attach_function 'archive_format_name',                 [ _ptr ], _str;
attach_function 'archive_read_support_filter_program', [ _ptr, _str ], _int;
attach_function 'archive_read_support_format_by_code', [ _ptr, _int ], _int;
attach_function 'archive_version_number',              undef, _int;
attach_function 'archive_version_string',              undef, _str;

attach_function "archive_read_support_filter_$_",  [ _ptr ], _int for qw( bzip2 compress gzip grzip lrzip lzip lzma lzop none );
attach_function "archive_read_support_format_$_",  [ _ptr ], _int for qw( 7zip ar cab cpio empty gnutar iso9660 lha mtree rar raw tar xar zip );

push @{ $EXPORT_TAGS{func} }, qw(
  archive_read_next_header
  archive_read_open_memory
  archive_read_data
  archive_error_string
);

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

=head2 archive_clear_error($archive)

Clears any error information left over from a previous call Not
generally used in client code.  Does not return a value.

=head2 archive_copy_error($archive1, $archive2)

Copies error information from one archive to another.

=head2 archive_entry_pathname($entry)

Retrieve the pathname of the entry.

Returns a string value.

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

TODO: add bindings for archive_position

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

=head2 archive_read_data($archive, $buffer, $max_size)

Read data associated with the header just read.  Internally, this is a
convenience function that calls C<archive_read_data_block> and fills
any gaps with nulls so that callers see a single continuous stream of
data.  Returns the actual number of bytes read, 0 on end of data and
a negative value on error.

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
any of the functions documented here with an <$archive> argument.

TODO: handle the unusual circumstance when this would return C NULL pointer.

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

TODO: a NULL filename represents standard input.

=head2 archive_read_open_memory($archive, $buffer)

Like C<archive_read_open>, except that it uses a Perl scalar that holds the content of the
archive.  This function does not make a copy of the data stored in C<$buffer>, so you should
not modify the buffer until you have free the archive using C<archive_read_free>.

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

TODO: also support archive_read_support_filter_program_signature

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

=item ARCHIVE_WARN

=back

