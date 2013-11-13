package Archive::Libarchive::FFI;

use strict;
use warnings;
use Alien::Libarchive;
use FFI::Sweet qw( ffi_lib attach_function :types );
use base qw( Exporter );

# ABSTRACT: Perl bindings to libarchive via FFI
# VERSION

our %EXPORT_TAGS = ( all => [], const => [], func => [] );

require Archive::Libarchive::FFI::constants;

@{ $EXPORT_TAGS{func} } = qw(
  archive_read_new
  archive_read_support_filter_all
  archive_read_support_format_all
  archive_read_open_filename
  archive_read_free
  archive_error_string  
  archive_read_next_header
  archive_entry_pathname
  archive_read_data_skip
);

our @EXPORT_OK = (map { @{ $EXPORT_TAGS{$_} } } qw( const func ));
$EXPORT_TAGS{all} = \@EXPORT_OK;

ffi_lib \$_ for map { print "$_\n" if 0; $_ } DynaLoader::dl_findfile(split /\s+/, Alien::Libarchive->new->libs);

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
