# Archive::Libarchive::FFI

Perl bindings to libarchive via FFI

# SYNOPSIS

    use Archive::Libarchive::FFI;

# DESCRIPTION

This module provides a functional interface to `libarchive`.  `libarchive` is a
C library that can read and write archives in a variety of formats and with a 
variety of compression filters, optimized in a stream oriented way.  A familiarity
with the `libarchive` documentation would be helpful, but may not be necessary
for simple tasks.

# FUNCTIONS

Unless otherwise specified, each function will return an integer return code,
with one of the following values:

- ARCHIVE\_OK

    Operation was successful

- ARCHIVE\_EOF

    Fond end of archive

- ARCHIVE\_RETRY

    Retry might succeed

- ARCHIVE\_WARN

    Partial success

- ARCHIVE\_FAILED

    Current operation cannot complete

- ARCHIVE\_FATAL

    No more operations are possible

## archive\_clear\_error($archive)

Clears any error information left over from a previous call Not
generally used in client code.  Does not return a value.

## archive\_copy\_error($archive1, $archive2)

Copies error information from one archive to another.

## archive\_entry\_pathname($entry)

Retrieve the pathname of the entry.

Returns a string value.

## archive\_errno($archive)

Returns a numeric error code indicating the reason for the most
recent error return.

Return type is an errno integer value.

## archive\_error\_string($archive)

Returns a textual error message suitable for display.  The error
message here is usually more specific than that obtained from
passing the result of `archive_errno` to `strerror`.

Return type is a string.

## archive\_file\_count($archive)

Returns a count of the number of files processed by this archive object.  The count
is incremented by calls to `archive_write_header` or `archive_read_next_header`.

## archive\_filter\_code

Returns a numeric code identifying the indicated filter.  See `archive_filter_count`
for details of the numbering.

## archive\_filter\_count

Returns the number of filters in the current pipeline. For read archive handles, these 
filters are added automatically by the automatic format detection. For write archive 
handles, these filters are added by calls to the various `archive_write_add_filter_XXX`
functions. Filters in the resulting pipeline are numbered so that filter 0 is the filter 
closest to the format handler. As a convenience, functions that expect a filter number 
will accept -1 as a synonym for the highest-numbered filter. For example, when reading 
a uuencoded gzipped tar archive, there are three filters: filter 0 is the gunzip filter, 
filter 1 is the uudecode filter, and filter 2 is the pseudo-filter that wraps the archive 
read functions. In this case, requesting `archive_position(a,(-1))` would be a synonym
for `archive_position(a,(2))` which would return the number of bytes currently read from 
the archive, while `archive_position(a,(1))` would return the number of bytes after
uudecoding, and `archive_position(a,(0))` would return the number of bytes after decompression.

TODO: add bindings for archive\_position

## archive\_filter\_name

Returns a textual name identifying the indicated filter.  See [#archive_filter_count](https://metacpan.org/pod/#archive_filter_count) for
details of the numbering.

## archive\_format($archive)

Returns a numeric code indicating the format of the current archive
entry.  This value is set by a successful call to
`archive_read_next_header`.  Note that it is common for this value
to change from entry to entry.  For example, a tar archive might
have several entries that utilize GNU tar extensions and several
entries that do not.  These entries will have different format
codes.

## archive\_format\_name($archive)

A textual description of the format of the current entry.

## archive\_read\_data\_skip($archive)

A convenience function that repeatedly calls `archive_read_data` to skip
all of the data for this archive entry.

## archive\_read\_free($archive)

Invokes `archive_read_close` if it was not invoked manually, then
release all resources.

## archive\_read\_new

Allocates and initializes a archive object suitable for reading from an archive.
Returns an opaque archive which may be a perl style object, or a C pointer
(depending on the implementation), either way, it can be passed into
any of the functions documented here with an <$archive> argument.

TODO: handle the unusual circumstance when this would return C NULL pointer.

## archive\_read\_next\_header($archive, $entry)

Read the header for the next entry and return an entry object
Returns an opaque archive which may be a perl style object, or a C pointer
(depending on the implementation), either way, it can be passed into
any of the functions documented here with an <$entry> argument.

TODO: maybe use archive\_read\_next\_header2

## archive\_read\_open\_filename($archive, $filename, $block\_size)

Like `archive_read_open`, except that it accepts a simple filename
and a block size.  This function is safe for use with tape drives
or other blocked devices.

TODO: a NULL filename represents standard input.

## archive\_read\_open\_memory($archive, $buffer)

Like `archive_read_open`, except that it uses a Perl scalar that holds the content of the
archive.  This function does not make a copy of the data stored in `$buffer`, so you should
not modify the buffer until you have free the archive using `archive_read_free`.

## archive\_read\_support\_filter\_all($archive)

Enable all available decompression filters.

## archive\_read\_support\_filter\_bzip2($archive)

Enable bzip2 decompression filter.

## archive\_read\_support\_filter\_compress($archive)

Enable compress decompression filter.

## archive\_read\_support\_filter\_grzip($archive)

Enable grzip decompression filter.

## archive\_read\_support\_filter\_gzip($archive)

Enable gzip decompression filter.

## archive\_read\_support\_filter\_lrzip($archive)

Enable lrzip decompression filter.

## archive\_read\_support\_filter\_lzip($archive)

Enable lzip decompression filter.

## archive\_read\_support\_filter\_lzma($archive)

Enable lzma decompression filter.

## archive\_read\_support\_filter\_lzop($archive)

Enable lzop decompression filter.

## archive\_read\_support\_filter\_none($archive)

Enable none decompression filter.

## archive\_read\_support\_filter\_program(archive, command)

Data is feed through the specified external program before being
dearchived.  Note that this disables automatic detection of the
compression format, so it makes no sense to specify this in
conjunction with any other decompression option.

TODO: also support archive\_read\_support\_filter\_program\_signature

## archive\_read\_support\_format\_7zip($archive)

Enable 7zip archive format.

## archive\_read\_support\_format\_all($archive)

Enable all available archive formats.

## archive\_read\_support\_format\_ar($archive)

Enable ar archive format.

## archive\_read\_support\_format\_by\_code($archive, $code)

Enables a single format specified by the format code.

## archive\_read\_support\_format\_cab($archive)

Enable cab archive format.

## archive\_read\_support\_format\_cpio($archive)

Enable cpio archive format.

## archive\_read\_support\_format\_empty($archive)

Enable empty archive format.

## archive\_read\_support\_format\_gnutar($archive)

Enable gnutar archive format.

## archive\_read\_support\_format\_iso9660($archive)

Enable iso9660 archive format.

## archive\_read\_support\_format\_lha($archive)

Enable lha archive format.

## archive\_read\_support\_format\_mtree($archive)

Enable mtree archive format.

## archive\_read\_support\_format\_rar($archive)

Enable rar archive format.

## archive\_read\_support\_format\_raw($archive)

Enable raw archive format.

## archive\_read\_support\_format\_tar($archive)

Enable tar archive format.

## archive\_read\_support\_format\_xar($archive)

Enable xar archive format.

## archive\_read\_support\_format\_zip($archive)

Enable zip archive format.

## archive\_version\_number

Return the libarchive version as an integer.

## archive\_version\_string

Return the libarchive as a version.

Returns a string value.

# CONSTANTS

If provided by your libarchive library, these constants will be available and
exportable from the [Archive::Libarchive::FFI](https://metacpan.org/pod/Archive::Libarchive::FFI) (you may import all available
constants using the `:const` export tag).

- AE\_IFBLK
- AE\_IFCHR
- AE\_IFDIR
- AE\_IFIFO
- AE\_IFLNK
- AE\_IFMT
- AE\_IFREG
- AE\_IFSOCK
- ARCHIVE\_COMPRESSION\_BZIP2
- ARCHIVE\_COMPRESSION\_COMPRESS
- ARCHIVE\_COMPRESSION\_GZIP
- ARCHIVE\_COMPRESSION\_LRZIP
- ARCHIVE\_COMPRESSION\_LZIP
- ARCHIVE\_COMPRESSION\_LZMA
- ARCHIVE\_COMPRESSION\_NONE
- ARCHIVE\_COMPRESSION\_PROGRAM
- ARCHIVE\_COMPRESSION\_RPM
- ARCHIVE\_COMPRESSION\_UU
- ARCHIVE\_COMPRESSION\_XZ
- ARCHIVE\_ENTRY\_ACL\_ADD\_FILE
- ARCHIVE\_ENTRY\_ACL\_ADD\_SUBDIRECTORY
- ARCHIVE\_ENTRY\_ACL\_APPEND\_DATA
- ARCHIVE\_ENTRY\_ACL\_DELETE
- ARCHIVE\_ENTRY\_ACL\_DELETE\_CHILD
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_DIRECTORY\_INHERIT
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_FAILED\_ACCESS
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_FILE\_INHERIT
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_INHERIT\_ONLY
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_NO\_PROPAGATE\_INHERIT
- ARCHIVE\_ENTRY\_ACL\_ENTRY\_SUCCESSFUL\_ACCESS
- ARCHIVE\_ENTRY\_ACL\_EVERYONE
- ARCHIVE\_ENTRY\_ACL\_EXECUTE
- ARCHIVE\_ENTRY\_ACL\_GROUP
- ARCHIVE\_ENTRY\_ACL\_GROUP\_OBJ
- ARCHIVE\_ENTRY\_ACL\_INHERITANCE\_NFS4
- ARCHIVE\_ENTRY\_ACL\_LIST\_DIRECTORY
- ARCHIVE\_ENTRY\_ACL\_MASK
- ARCHIVE\_ENTRY\_ACL\_OTHER
- ARCHIVE\_ENTRY\_ACL\_PERMS\_NFS4
- ARCHIVE\_ENTRY\_ACL\_PERMS\_POSIX1E
- ARCHIVE\_ENTRY\_ACL\_READ
- ARCHIVE\_ENTRY\_ACL\_READ\_ACL
- ARCHIVE\_ENTRY\_ACL\_READ\_ATTRIBUTES
- ARCHIVE\_ENTRY\_ACL\_READ\_DATA
- ARCHIVE\_ENTRY\_ACL\_READ\_NAMED\_ATTRS
- ARCHIVE\_ENTRY\_ACL\_STYLE\_EXTRA\_ID
- ARCHIVE\_ENTRY\_ACL\_STYLE\_MARK\_DEFAULT
- ARCHIVE\_ENTRY\_ACL\_SYNCHRONIZE
- ARCHIVE\_ENTRY\_ACL\_TYPE\_ACCESS
- ARCHIVE\_ENTRY\_ACL\_TYPE\_ALARM
- ARCHIVE\_ENTRY\_ACL\_TYPE\_ALLOW
- ARCHIVE\_ENTRY\_ACL\_TYPE\_AUDIT
- ARCHIVE\_ENTRY\_ACL\_TYPE\_DEFAULT
- ARCHIVE\_ENTRY\_ACL\_TYPE\_DENY
- ARCHIVE\_ENTRY\_ACL\_TYPE\_NFS4
- ARCHIVE\_ENTRY\_ACL\_TYPE\_POSIX1E
- ARCHIVE\_ENTRY\_ACL\_USER
- ARCHIVE\_ENTRY\_ACL\_USER\_OBJ
- ARCHIVE\_ENTRY\_ACL\_WRITE
- ARCHIVE\_ENTRY\_ACL\_WRITE\_ACL
- ARCHIVE\_ENTRY\_ACL\_WRITE\_ATTRIBUTES
- ARCHIVE\_ENTRY\_ACL\_WRITE\_DATA
- ARCHIVE\_ENTRY\_ACL\_WRITE\_NAMED\_ATTRS
- ARCHIVE\_ENTRY\_ACL\_WRITE\_OWNER
- ARCHIVE\_EOF
- ARCHIVE\_EXTRACT\_ACL
- ARCHIVE\_EXTRACT\_FFLAGS
- ARCHIVE\_EXTRACT\_HFS\_COMPRESSION\_FORCED
- ARCHIVE\_EXTRACT\_MAC\_METADATA
- ARCHIVE\_EXTRACT\_NO\_AUTODIR
- ARCHIVE\_EXTRACT\_NO\_HFS\_COMPRESSION
- ARCHIVE\_EXTRACT\_NO\_OVERWRITE
- ARCHIVE\_EXTRACT\_NO\_OVERWRITE\_NEWER
- ARCHIVE\_EXTRACT\_OWNER
- ARCHIVE\_EXTRACT\_PERM
- ARCHIVE\_EXTRACT\_SECURE\_NODOTDOT
- ARCHIVE\_EXTRACT\_SECURE\_SYMLINKS
- ARCHIVE\_EXTRACT\_SPARSE
- ARCHIVE\_EXTRACT\_TIME
- ARCHIVE\_EXTRACT\_UNLINK
- ARCHIVE\_EXTRACT\_XATTR
- ARCHIVE\_FAILED
- ARCHIVE\_FATAL
- ARCHIVE\_FILTER\_BZIP2
- ARCHIVE\_FILTER\_COMPRESS
- ARCHIVE\_FILTER\_GRZIP
- ARCHIVE\_FILTER\_GZIP
- ARCHIVE\_FILTER\_LRZIP
- ARCHIVE\_FILTER\_LZIP
- ARCHIVE\_FILTER\_LZMA
- ARCHIVE\_FILTER\_LZOP
- ARCHIVE\_FILTER\_NONE
- ARCHIVE\_FILTER\_PROGRAM
- ARCHIVE\_FILTER\_RPM
- ARCHIVE\_FILTER\_UU
- ARCHIVE\_FILTER\_XZ
- ARCHIVE\_FORMAT\_7ZIP
- ARCHIVE\_FORMAT\_AR
- ARCHIVE\_FORMAT\_AR\_BSD
- ARCHIVE\_FORMAT\_AR\_GNU
- ARCHIVE\_FORMAT\_BASE\_MASK
- ARCHIVE\_FORMAT\_CAB
- ARCHIVE\_FORMAT\_CPIO
- ARCHIVE\_FORMAT\_CPIO\_AFIO\_LARGE
- ARCHIVE\_FORMAT\_CPIO\_BIN\_BE
- ARCHIVE\_FORMAT\_CPIO\_BIN\_LE
- ARCHIVE\_FORMAT\_CPIO\_POSIX
- ARCHIVE\_FORMAT\_CPIO\_SVR4\_CRC
- ARCHIVE\_FORMAT\_CPIO\_SVR4\_NOCRC
- ARCHIVE\_FORMAT\_EMPTY
- ARCHIVE\_FORMAT\_ISO9660
- ARCHIVE\_FORMAT\_ISO9660\_ROCKRIDGE
- ARCHIVE\_FORMAT\_LHA
- ARCHIVE\_FORMAT\_MTREE
- ARCHIVE\_FORMAT\_RAR
- ARCHIVE\_FORMAT\_RAW
- ARCHIVE\_FORMAT\_SHAR
- ARCHIVE\_FORMAT\_SHAR\_BASE
- ARCHIVE\_FORMAT\_SHAR\_DUMP
- ARCHIVE\_FORMAT\_TAR
- ARCHIVE\_FORMAT\_TAR\_GNUTAR
- ARCHIVE\_FORMAT\_TAR\_PAX\_INTERCHANGE
- ARCHIVE\_FORMAT\_TAR\_PAX\_RESTRICTED
- ARCHIVE\_FORMAT\_TAR\_USTAR
- ARCHIVE\_FORMAT\_XAR
- ARCHIVE\_FORMAT\_ZIP
- ARCHIVE\_MATCH\_CTIME
- ARCHIVE\_MATCH\_EQUAL
- ARCHIVE\_MATCH\_MTIME
- ARCHIVE\_MATCH\_NEWER
- ARCHIVE\_MATCH\_OLDER
- ARCHIVE\_OK
- ARCHIVE\_READDISK\_HONOR\_NODUMP
- ARCHIVE\_READDISK\_MAC\_COPYFILE
- ARCHIVE\_READDISK\_NO\_TRAVERSE\_MOUNTS
- ARCHIVE\_READDISK\_RESTORE\_ATIME
- ARCHIVE\_RETRY
- ARCHIVE\_VERSION\_NUMBER
- ARCHIVE\_WARN

# SEE ALSO

The intent of this module is to provide a low level fairly thin direct
interface to libarchive, on which a more Perlish OO layer could easily
be written.

- [Archive::Peek::Libarchive](https://metacpan.org/pod/Archive::Peek::Libarchive)
- [Archive::Extract::Libarchive](https://metacpan.org/pod/Archive::Extract::Libarchive)

    Both of these provide a higher level perlish interface to libarchive.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
