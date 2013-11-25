use strict;
use warnings;
use Test::More;
use File::Temp qw( tempdir );
use File::Spec;
use Archive::Libarchive::FFI qw( :all );

plan skip_all => 'requires archive_write_open'
  unless Archive::Libarchive::FFI->can('archive_write_open');
plan tests => 10;

my %data = (
  foo => 'one',
  bar => 'two',
  baz => 'three',
);

my $expected = '';

my $r;
my $dir = tempdir( CLEANUP => 1 );
my $fn  = File::Spec->catfile($dir, "foo.tar.gz");

my $a = eval { archive_write_new() };
ok $a, 'archive_write_new';

SKIP: {
  skip 'archive_write_add_filter_gzip function not available', 1 unless Archive::Libarchive::FFI->can('archive_write_add_filter_gzip');
  $r = eval { archive_write_add_filter_gzip($a) };
  is $r, ARCHIVE_OK, 'archive_write_add_filter_gzip';
};

$r = eval { archive_write_set_format_pax_restricted($a) };
is $r, ARCHIVE_OK, 'archive_write_set_format_pax_restricted';

$r = eval { archive_write_open($a, { filename => $fn }, \&myopen, \&mywrite, \&myclose) };
is $r, ARCHIVE_OK, 'archive_write_open';

foreach my $name (qw( foo bar baz ))
{
  $expected .= "$name=$data{$name}\n";

  subtest $name => sub {
    plan tests => 8;
  
    my $entry = eval { archive_entry_new() };
    ok $entry, 'archive_entry_new';
  
    eval { archive_entry_set_pathname($entry, $name) };
    is $@, '', 'archive_entry_set_pathname';

    eval { archive_entry_set_size($entry, length($data{$name})) };
    is $@, '', 'archive_entry_set_size';

    eval { archive_entry_set_filetype($entry, AE_IFREG) };
    is $@, '', 'archive_entry_set_filetype';

    eval { archive_entry_set_perm($entry, 0644) };
    is $@, '', 'archive_entry_set_perm';

    $r = eval { archive_write_header($a, $entry) };
    is $r, ARCHIVE_OK, 'archive_write_header';

    my $len = eval { archive_write_data($a, $data{$name}) };
    is $len, length($data{$name}), 'archive_write_data';;
  
    $r = eval { archive_entry_free($entry); };
    is $@, '', 'archive_entry_free';
  };
}

$r = eval { archive_write_close($a) };
is $r, ARCHIVE_OK, 'archive_write_close';
diag 'archive_error_string = ', archive_error_string($a) unless ARCHIVE_OK;

$r = eval { archive_write_free($a) };
is $r, ARCHIVE_OK, 'archive_write_free';

do {
  my $actual = '';
  my $a = archive_read_new();
  archive_read_support_filter_all($a);
  archive_read_support_format_all($a);
  archive_read_open_filename($a, $fn, 512);
  while(archive_read_next_header($a, my $entry) == ARCHIVE_OK)
  {
    my $name = archive_entry_pathname($entry);
    archive_read_data($a, my $buff, 32);
    $actual .= "$name=$buff\n";
  }

  is $actual, $expected, "output matches";
};

sub myopen
{
  my($archive, $data) = @_;
  $DB::single = 1;
  note "myopen: ", $data->{filename};
  open my $fh, '>', $data->{filename};
  $data->{fh} = $fh;
  ARCHIVE_OK;
}

sub mywrite
{
  my($archive, $data, $buffer) = @_;
  $DB::single = 1;
  note "mywrite: ", length $buffer;
  my $fh = $data->{fh};
  print $fh $buffer;
  length($buffer);
}

sub myclose
{
  my($archive, $data) = @_;
  $DB::single = 1;
  note "myclose: ()";
  my $fh = $data->{fh};
  close $fh;
  ARCHIVE_OK;
}
