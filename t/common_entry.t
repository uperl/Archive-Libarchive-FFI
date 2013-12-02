use strict;
use warnings;
use Test::More tests => 8;
use Archive::Libarchive::FFI qw( :all );

my $r;

my $e = archive_entry_new();
ok $e, 'archive_entry_new';

is archive_entry_pathname($e), undef, 'archive_entry_pathname = undef';

$r = archive_entry_set_pathname($e, 'hi.txt');
is $r, ARCHIVE_OK, 'archive_entry_set_pathname';

is archive_entry_pathname($e), 'hi.txt', 'archive_entry_pathname = hi.txt';

is eval { archive_entry_mode($e) }, 0, 'archive_entry_mode (0)';
diag $@ if $@;

$r = eval { archive_entry_set_mode($e, 0644) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_set_mode';

is eval { archive_entry_mode($e) }, 0644, 'archive_entry_mode (0644)';
diag $@ if $@;

$r = archive_entry_free($e);
is $r, ARCHIVE_OK, 'archive_entry_free';
