package Archive::Libarchive::FFI::functions;

use strict;
use warnings;
use Alien::Libarchive;
use FFI::Sweet qw( ffi_lib attach_function :types );

# VERSION

sub _int64  { FFI::Raw::int64() }
sub _uint64 { FFI::Raw::uint64() }

ffi_lib \$_ for map { print "$_\n" if 0; $_ } DynaLoader::dl_findfile(split /\s+/, Alien::Libarchive->new->libs);

attach_function 'archive_read_next_header', [ _ptr, _ptr ], _int;
attach_function 'archive_read_open_memory', [ _ptr, _ptr, _int ], _int; # FIXME: third argument is actually a size_t
attach_function 'archive_read_data',        [ _ptr, _ptr, _int ], _int; # FIXME: third argument is actually a size_t
attach_function 'archive_error_string',     [ _ptr ], _str;
attach_function 'archive_write_data',       [ _ptr, _ptr, _int ], _int; # FIXME: third argument is actually a size_t
attach_function 'archive_read_data_block',  [ _ptr, _ptr, _ptr, _ptr ], _int;
attach_function 'archive_write_data_block', [ _ptr, _ptr, _int, _int64 ], _int; # FIXME third argument is actually a size_t

1;
