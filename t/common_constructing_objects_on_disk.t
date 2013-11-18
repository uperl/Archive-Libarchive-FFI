use strict;
use warnings;
use Test::More tests => 14;
use File::Temp qw( tempdir );
use File::Spec;
use Archive::Libarchive::FFI qw( :all );

my $dir = tempdir( CLEANUP => 1 );
my $filename = File::Spec->catfile($dir, "my_file.txt");
my $r;

my $a = archive_write_disk_new();
ok $a, 'archive_write_disk_new';

$r = archive_write_disk_set_options($a, ARCHIVE_EXTRACT_TIME);
is $r, ARCHIVE_OK, 'archive_write_disk_set_options';


my $entry = archive_entry_new();
ok $entry, 'archive_entry_new';

eval { archive_entry_set_pathname($entry, $filename) };
is $@, '', 'archive_entry_set_pathname';

eval { archive_entry_set_filetype($entry, AE_IFREG) };
is $@, '', 'archive_entry_set_filetype';

eval { archive_entry_set_size($entry, 5) };
is $@, '', 'archive_entry_set_size';

eval { archive_entry_set_mtime($entry, 123456789, 0) };
is $@, '', 'archive_entry_set_mtime';

eval { archive_entry_set_perm($entry, 0644) };
is $@, '', 'archive_entry_set_perm';

$r = archive_write_header($a, $entry);
is $r, ARCHIVE_OK, 'archive_write_header';

$r = archive_write_data($a, "abcde");
is $r, 5, 'archive_write_data';

$r = archive_write_finish_entry($a);
is $r, ARCHIVE_OK, 'archive_write_finish_entry';

$r = archive_write_free($a);
is $r, ARCHIVE_OK, 'archive_write_free';

eval { archive_entry_free($entry) };
is $@, '', 'archive_entry_free';

open my $fh, '<', $filename;
my $data = do { local $/; <$fh> };
close $fh;

is $data, 'abcde', 'data = abcde';
