use strict;
use warnings;
use Archive::Libarchive::FFI qw( :all );
use Test::More tests => 8;
use FindBin ();
use File::Spec;

my $filename = File::Spec->catfile($FindBin::Bin, "foo.bogus");
my $r;
my $entry;
    
note "filename = $filename";

my $a = archive_read_new();

isa_ok $a, "Archive::Libarchive::FFI::archive";

$r = archive_read_support_filter_all($a);
is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_support_filter_all)";

$r = archive_read_support_format_all($a);
is $r, ARCHIVE_OK, "r = ARCHIVE_OK (archive_read_support_format_all)";

$r = archive_read_open_filename($a, $filename, 10240);
is $r, ARCHIVE_FATAL, "r = ARCHIVE_FATAL (archive_read_open_filename)";

# get something back... I don't really care what.
ok archive_errno($a), 'archive_errno($a) = ' . archive_errno($a);
ok archive_error_string($a), 'archive_error_string($a) = ' . archive_error_string($a);

archive_clear_error($a);

is archive_errno($a), 0, 'archive_errno($a) = 0';
ok !archive_error_string($a), 'archive_error_string($a) = ' . archive_error_string($a);
