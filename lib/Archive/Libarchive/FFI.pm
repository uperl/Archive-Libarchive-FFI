package Archive::Libarchive::FFI;

use strict;
use warnings;
use Alien::Libarchive;
use FFI::Sweet qw( ffi_lib attach_function :types );
use base qw( Exporter );

# ABSTRACT: Perl bindings to libarchive via FFI
# VERSION

our @EXPORT_OK = qw(
  archive_read_new
  archive_read_support_filter_all
  archive_read_support_format_all
  archive_read_open_filename
  archive_read_free
  archive_error_string
  
  archive_read_next_header
  archive_entry_pathname
  archive_read_data_skip
  
  ARCHIVE_OK
);

our %EXPORT_TAGS = ( all => \@EXPORT_OK );

ffi_lib \$_ for map { print "$_\n" if 0; $_ } DynaLoader::dl_findfile(split /\s+/, Alien::Libarchive->new->libs);

use constant {
  ARCHIVE_EOF    => 1,
  ARCHIVE_OK     => 0,
  ARCHIVE_RETRY  => -10,
  ARCHIVE_WARN   => -20,
  ARCHIVE_FAILED => -25,
  ARCHIVE_FATAL  => -30,
  
  ARCHIVE_FILTER_NONE     => 0,
  ARCHIVE_FILTER_GZIP     => 1,
  ARCHIVE_FILTER_BZIP2    => 2,
  ARCHIVE_FILTER_COMPRESS => 3,
  ARCHIVE_FILTER_PROGRAM  => 4,
  ARCHIVE_FILTER_LZMA     => 5,
  ARCHIVE_FILTER_XZ       => 6,
  ARCHIVE_FILTER_UU       => 7,
  ARCHIVE_FILTER_RPM      => 8,
  ARCHIVE_FILTER_LZIP     => 9,
  ARCHIVE_FILTER_LRZIP    => 10,
  ARCHIVE_FILTER_LZOP     => 11,
  ARCHIVE_FILTER_GRZIP    => 12,

};

attach_function 'archive_read_new', undef, _ptr;
attach_function 'archive_read_support_filter_all', [ _ptr ], _int;
attach_function 'archive_read_support_format_all', [ _ptr ], _int;
attach_function 'archive_read_open_filename', [ _ptr, _str, _int ], _int;
attach_function 'archive_read_free', [ _ptr ], _int;
attach_function 'archive_error_string', [ _ptr ], _str;

attach_function 'archive_read_next_header', [ _ptr, _ptr ], _int;
attach_function 'archive_entry_pathname', [ _ptr ], _str;
attach_function 'archive_read_data_skip', [ _ptr ], _int;

1;
