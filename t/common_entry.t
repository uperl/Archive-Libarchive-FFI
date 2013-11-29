use strict;
use warnings;
use Test::More tests => 5;
use Archive::Libarchive::FFI qw( :all );

my $r;

my $e = archive_entry_new();
ok $e, 'archive_entry_new';

is archive_entry_pathname($e), undef, 'archive_entry_pathname = undef';

$r = archive_entry_set_pathname($e, 'hi.txt');
is $r, ARCHIVE_OK, 'archive_entry_set_pathname';

is archive_entry_pathname($e), 'hi.txt', 'archive_entry_pathname = hi.txt';

$r = archive_entry_free($e);
is $r, ARCHIVE_OK, 'archive_entry_free';
