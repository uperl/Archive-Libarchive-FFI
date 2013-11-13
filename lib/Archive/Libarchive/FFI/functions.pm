package Archive::Libarchive::FFI::functions;

use strict;
use warnings;
use Alien::Libarchive;
use FFI::Sweet qw( ffi_lib attach_function :types );

ffi_lib \$_ for map { print "$_\n" if 0; $_ } DynaLoader::dl_findfile(split /\s+/, Alien::Libarchive->new->libs);

attach_function 'archive_read_next_header', [ _ptr, _ptr ], _int;

1;
