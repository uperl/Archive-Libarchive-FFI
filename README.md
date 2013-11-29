# Archive::Libarchive::FFI

Perl bindings to libarchive via FFI

# SYNOPSIS

list archive filenames

    use Archive::Libarchive::FFI qw( :all );
    
    my $archive = archive_read_new();
    archive_read_support_filter_all($archive);
    archive_read_support_format_all($archive);
    # example is a tar file, but any supported format should work
    # (zip, iso9660, etc.)
    archive_read_open_filename($archive, 'archive.tar', 10240);
    
    while(archive_read_next_header($archive, my $entry) == ARCHIVE_OK)
    {
      print archive_entry_pathname($entry), "\n";
      archive_read_data_skip($archive);
    }
    
    archive_read_free($archive);

extract archive

    use Archive::Libarchive::FFI qw( :all );
    
    my $archive = archive_read_new();
    archive_read_support_filter_all($archive);
    archive_read_support_format_all($archive);
    my $disk = archive_write_disk_new();
    archive_write_disk_set_options($disk, 
      ARCHIVE_EXTRACT_TIME   |
      ARCHIVE_EXTRACT_PERM   |
      ARCHIVE_EXTRACT_ACL    |
      ARCHIVE_EXTRACT_FFLAGS
    );
    archive_write_disk_set_standard_lookup($disk);
    archive_read_open_filename($archive, 'archive.tar', 10240);
    
    while(1)
    {
      my $r = archive_read_next_header($archive, my $entry);
      last if $r == ARCHIVE_EOF;
      
    archive_write_header($disk, $entry);
    
      while(1)
      {
        my $r = archive_read_data_block($archive, my $buffer, my $offset);
        last if $r == ARCHIVE_EOF;
        archive_write_data_block($disk, $buffer, $offset);
      }
    }
    
    archive_read_close($archive);
    archive_read_free($archive);
    archive_write_close($disk);
    archive_write_free($disk);

write archive

    use File::stat;
    use File::Slurp qw( read_file );
    use Archive::Libarchive::FFI qw( :all );
    
    my $archive = archive_write_new();
    # many other formats are supported ...
    archive_write_set_format_pax_restricted($archive);
    archive_write_open_filename($archive, 'archive.tar');
    
    foreach my $filename (@filenames)
    {
      my $entry = archive_entry_new();
      archive_entry_set_pathname($entry, $filename);
      archive_entry_set_size($entry, stat($filename)->size);
      archive_entry_set_filetype($entry, AE_IFREG);
      archive_entry_set_perm($entry, 0644);
      archive_write_header($archive, $entry);
      archive_write_data($archive, scalar read_file($filename));
      archive_entry_free($entry);
    }
    archive_write_close($archive);
    archive_write_free($archive);

# DESCRIPTION

This module provides a functional interface to libarchive.  libarchive is a
C library that can read and write archives in a variety of formats and with a 
variety of compression filters, optimized in a stream oriented way.  A familiarity
with the libarchive documentation would be helpful, but may not be necessary
for simple tasks.  The documentation for this module is split into four separate
documents:

- [Archive::Libarchive::FFI](https://metacpan.org/pod/Archive::Libarchive::FFI)

    This document, contains an overview and some examples.

- [Archive::Libarchive::FFI::Callback](https://metacpan.org/pod/Archive::Libarchive::FFI::Callback)

    Documents the callback interface, used for customizing input and output.

- [Archive::Libarchive::FFI::Constant](https://metacpan.org/pod/Archive::Libarchive::FFI::Constant)

    Documents the constants provided by this module.

- [Archive::Libarchive::FFI::Function](https://metacpan.org/pod/Archive::Libarchive::FFI::Function)

    The function reference, includes a list of all functions provided by this module.

If you are linking against an older version of libarchive, some functions
and constants may not be available.  You can use the `can` method to test if
a function or constant is available, for example:

    if(Archive::Libarchive::FFI->can('archive_read_support_filter_grzip')
    {
      # grzip filter is available.
    }
    
    if(Archive::Libarchive::FFI->can('ARCHIVE_OK'))
    {
      # ... although ARCHIVE_OK should always be available.
    }

# EXAMPLES

These examples are translated from equivalent C versions provided on the
libarchive website, and are annotated here with Perl specific details.
These examples are also included with the distribution.

## List contents of archive stored in file

    use strict;
    use warnings;
    use Archive::Libarchive::FFI qw( :all );
    
    # this is a translation to perl for this:
    #  https://github.com/libarchive/libarchive/wiki/Examples#wiki-List_contents_of_Archive_stored_in_File
    
    my $a = archive_read_new();
    archive_read_support_filter_all($a);
    archive_read_support_format_all($a);
    
    my $r = archive_read_open_filename($a, "archive.tar", 10240);
    if($r != ARCHIVE_OK)
    {
      die "error opening archive.tar: ", archive_error_string($a);
    }
    
    while (archive_read_next_header($a, my $entry) == ARCHIVE_OK)
    {
      print archive_entry_pathname($entry), "\n";
      archive_read_data_skip($a); 
    }
    
    $r = archive_read_free($a);
    if($r != ARCHIVE_OK)
    {
      die "error freeing archive";
    }

## List contents of archive stored in memory

    use strict;
    use warnings;
    use Archive::Libarchive::FFI qw( :all );
    
    # this is a translation to perl for this:
    #  https://github.com/libarchive/libarchive/wiki/Examples#wiki-List_contents_of_Archive_stored_in_Memory
    
    my $buff = do {
      open my $fh, '<', "archive.tar.gz";
      local $/;
      <$fh>
    };
    
    my $a = archive_read_new();
    archive_read_support_filter_gzip($a);
    archive_read_support_format_tar($a);
    my $r = archive_read_open_memory($a, $buff);
    if($r != ARCHIVE_OK)
    {
      print "r = $r\n";
      die "error opening archive.tar: ", archive_error_string($a);
    }
    
    while (archive_read_next_header($a, my $entry) == ARCHIVE_OK) {
      print archive_entry_pathname($entry), "\n";
      archive_read_data_skip($a); 
    }
    
    $r = archive_read_free($a);
    if($r != ARCHIVE_OK)
    {
      die "error freeing archive";
    }

## List contents of archive with custom read functions

    use strict;
    use warnings;
    use Archive::Libarchive::FFI qw( :all );
    
    list_archive(shift @ARGV);
    
    sub list_archive
    {
      my $name = shift;
      my %mydata;
      my $a = archive_read_new();
      $mydata{name} = $name;
      open $mydata{fh}, '<', $name;
      archive_read_support_filter_all($a);
      archive_read_support_format_all($a);
      archive_read_open($a, \%mydata, undef, \&myread, \&myclose);
      while(archive_read_next_header($a, my $entry) == ARCHIVE_OK)
      {
        print archive_entry_pathname($entry), "\n";
      }
      archive_read_free($a);
    }
    
    sub myread
    {
      my($archive, $mydata) = @_;
      my $br = read $mydata->{fh}, my $buffer, 10240;
      return (ARCHIVE_OK, $buffer);
    }
    
    sub myclose
    {
      my($archive, $mydata) = @_;
      close $mydata->{fh};
      %$mydata = ();
      return ARCHIVE_OK;
    }

## A universal decompressor

    use strict;
    use warnings;
    use Archive::Libarchive::FFI qw( :all );
    
    # this is a translation to perl for this:
    #  https://github.com/libarchive/libarchive/wiki/Examples#a-universal-decompressor
    
    my $r;
    
    my $a = archive_read_new();
    archive_read_support_filter_all($a);
    archive_read_support_format_raw($a);
    $r = archive_read_open_filename($a, "hello.txt.gz.uu", 16384);
    if($r != ARCHIVE_OK)
    {
      die archive_error_string($a);
    }
    
    $r = archive_read_next_header($a, my $ae);
    if($r != ARCHIVE_OK)
    {
      die archive_error_string($a);     
    }
    
    while(1)
    {
      my $size = archive_read_data($a, my $buff, 1024);
      if($size < 0)
      {
        die archive_error_string($a);
      }
      if($size == 0)
      {
        last;
      }
      print $buff;
    }
    
    archive_read_free($a);

## A basic write example

    use strict;
    use warnings;
    use autodie;
    use File::stat;
    use Archive::Libarchive::FFI qw( :all );
    
    # this is a translation to perl for this:
    #  https://github.com/libarchive/libarchive/wiki/Examples#wiki-A_Basic_Write_Example
    
    sub write_archive
    {
      my($outname, @filenames) = @_;
      
    my $a = archive_write_new();
    
    archive_write_add_filter_gzip($a);
    archive_write_set_format_pax_restricted($a);
    archive_write_open_filename($a, $outname);
    
    foreach my $filename (@filenames)
    {
      my $st = stat $filename;
      my $entry = archive_entry_new();
      archive_entry_set_pathname($entry, $filename);
      archive_entry_set_size($entry, $st->size);
      archive_entry_set_filetype($entry, AE_IFREG);
      archive_entry_set_perm($entry, 0644);
      archive_write_header($a, $entry);
      open my $fh, '<', $filename;
      my $len = read $fh, my $buff, 8192;
      while($len > 0)
      {
        archive_write_data($a, $buff);
        $len = read $fh, $buff, 8192;
      }
      close $fh;
      
        archive_entry_free($entry);
      }
      archive_write_close($a);
      archive_write_free($a);
    }
    
    unless(@ARGV > 0)
    {
      print "usage: perl basic_write.pl archive.tar.gz file1 [ file2 [ ... ] ]\n";
      exit 2;
    }
    
    unless(@ARGV > 1)
    {
      print "Cowardly refusing to create an empty archive\n";
      exit 2;
    }
    
    write_archive(@ARGV);

## Constructing objects on disk

    use strict;
    use warnings;
    use Archive::Libarchive::FFI qw( :all );
    
    # this is a translation to perl for this:
    #  https://github.com/libarchive/libarchive/wiki/Examples#wiki-Constructing_Objects_On_Disk
    
    my $a = archive_write_disk_new();
    archive_write_disk_set_options($a, ARCHIVE_EXTRACT_TIME);
    
    my $entry = archive_entry_new();
    archive_entry_set_pathname($entry, "my_file.txt");
    archive_entry_set_filetype($entry, AE_IFREG);
    archive_entry_set_size($entry, 5);
    archive_entry_set_mtime($entry, 123456789, 0);
    archive_entry_set_perm($entry, 0644);
    archive_write_header($a, $entry);
    archive_write_data($a, "abcde");
    archive_write_finish_entry($a);
    archive_write_free($a);
    archive_entry_free($entry);

## A complete extractor

    use strict;
    use warnings;
    use Archive::Libarchive::FFI qw( :all );
    
    # this is a translation to perl for this:
    #  https://github.com/libarchive/libarchive/wiki/Examples#wiki-A_Complete_Extractor
    
    my $filename = shift @ARGV;
    
    unless(defined $filename)
    {
      warn "reading archive from standard in";
    }
    
    my $r;
    
    my $flags = ARCHIVE_EXTRACT_TIME
              | ARCHIVE_EXTRACT_PERM
              | ARCHIVE_EXTRACT_ACL
              | ARCHIVE_EXTRACT_FFLAGS;
    
    my $a = archive_read_new();
    archive_read_support_filter_all($a);
    archive_read_support_format_all($a);
    my $ext = archive_write_disk_new();
    archive_write_disk_set_options($ext, $flags);
    archive_write_disk_set_standard_lookup($ext);
    
    $r = archive_read_open_filename($a, $filename, 10240);
    if($r != ARCHIVE_OK)
    {
      die "error opening $filename: ", archive_error_string($a);
    }
    
    while(1)
    {
      $r = archive_read_next_header($a, my $entry);
      if($r == ARCHIVE_EOF)
      {
        last;
      }
      if($r != ARCHIVE_OK)
      {
        print archive_error_string($a), "\n";
      }
      if($r < ARCHIVE_WARN)
      {
        exit 1;
      }
      $r = archive_write_header($ext, $entry);
      if($r != ARCHIVE_OK)
      {
        print archive_error_string($ext), "\n";
      }
      elsif(archive_entry_size($entry) > 0)
      {
        $r = copy_data($a, $ext);
      }
    }
    
    archive_read_close($a);
    archive_read_free($a);
    archive_write_close($ext);
    archive_write_free($ext);
    
    sub copy_data
    {
      my($ar, $aw) = @_;
      my $r;
      while(1)
      {
        $r = archive_read_data_block($ar, my $buff, my $offset);
        if($r == ARCHIVE_EOF)
        {
          return ARCHIVE_OK;
        }
        if($r != ARCHIVE_OK)
        {
          die archive_error_string($ar), "\n";
        }
        $r = archive_write_data_block($aw, $buff, $offset);
        if($r != ARCHIVE_OK)
        {
          die archive_error_string($aw), "\n";
        }
      }
    }

## Unicode

libarchive uses the character set and encoding defined by the currently
selected locale for pathnames and other string data.  If you have non
ASCII characters in your archives or filenames you need to use a UTF-8
locale.

    use strict;
    use warnings;
    use utf8;
    use Archive::Libarchive::FFI qw( :all );
    use POSIX qw( setlocale LC_ALL );
    
    # substitute en_US.utf8 for the correct UTF-8 locale for your region.
    setlocale(LC_ALL, "en_US.utf8"); # or 'export LANG=en_US.utf8' from your shell.
    
    my $entry = archive_entry_new();
    
    archive_entry_set_pathname($entry, "привет.txt");
    my $string = archive_entry_pathname($entry); # "привет.txt"
    
    archive_entry_free($entry);

Unfortunately locale names are not portable across systems, so you should
probably not hard code the locale as shown here unless you know the correct
locale name for all the platforms that your script will run.

If you are not using a UTF-8 locale then the set method for pathname style
entry fields should work, but the retrieval methods will return the raw
encoded values from libarchive (this is almost certainly not what you want
if you have non ASCII filenames in your archive).

These Perl bindings for libarchive provide a function
[archive_perl_utf8_mode](https://metacpan.org/pod/Archive::Libarchive::FFI::Function#archive_perl_utf8_mode)
which will return true if you are using a UTF-8 locale.

    use strict;
    use warnings;
    use utf8;
    use Archive::Libarchive::FFI qw( :all );
    
    my $entry = archive_entry_new();
    
    if(archive_perl_utf8_mode())
    {
      archive_entry_set_pathname($entry, "привет.txt");
      my $string = archive_entry_pathname($entry); # "привет.txt"
    }
    else
    {
      die "not using a UTF-8 locale";
    }
    
    archive_entry_free($entry);

These Perl bindings for libarchive also provides a function
[archive_perl_codeset](https://metacpan.org/pod/Archive::Libarchive::FFI::Function#archive_perl_codeset)
which can be used with [Text::Iconv](https://metacpan.org/pod/Text::Iconv) to convert strings (if possible; not all
encodings have legal mappings).

    use strict;
    use warnings;
    use utf8;
    use Archive::Libarchive::FFI qw( :all );
    use Text::Iconv;
    use Encoding qw( decode );
    
    my $entry = archive_entry_new();
    
    archive_entry_set_pathname($entry, "привет.txt");

    my $string = archive_entry_pathname($entry); # value depends on locale
    if(archive_perl_utf8_mode())
    {
      # $string = "привет.txt" (already)
    }
    else
    {
      my $iconv = Text::Iconv->new(archive_perl_codeset(), "UTF-8");
      $iconv->raise_error(1);
      $string = decode('UTF-8', $iconv->convert($string)); # $string = "привет.txt"
    }
    
    archive_entry_free($entry);

Note that the [Text::Iconv](https://metacpan.org/pod/Text::Iconv) method convert will throw an exception if the 
conversion is not possible (if, for example, the destination encoding does
not support the input characters).

# CAVEATS

Archive and entry objects are really pointers to opaque C structures
and need to be freed using one of 
[archive_read_free](https://metacpan.org/pod/Archive::Libarchive::FFI::Function#archive_read_free), 
[archive_write_free](https://metacpan.org/pod/Archive::Libarchive::FFI::Function#archive_write_free) or 
[archive_entry_free](https://metacpan.org/pod/Archive::Libarchive::FFI::Function#archive_entry_free), 
in order to free the resources associated with those objects.

Unicode pathnames in archives are only fully supported if you are using a
UTF-8 locale.  If you aren't then the archive entry set pathname functions
will convert Perl's internal representation to the current locale codeset
using libarchive itself.  The get methods, unfortunately only return strings
in the codeset for the current locale.  If you are using a UTF-8 locale,
this module will mark the Perl strings it returns as UTF-8, but if you aren't
then you need to convert the strings to do anything useful.  Two Perl only
functions 
[archive_perl_utf8_mode](https://metacpan.org/pod/Archive::Libarchive::FFI::Function#archive_perl_utf8_mode) and
[archive_perl_codeset](https://metacpan.org/pod/Archive::Libarchive::FFI::Function#archive_perl_codeset)
are provided to help, but there is probably a better way.  Patches to improve
this situation would be happily considered.

The documentation that comes with libarchive is not that great (by its own
admission), being somewhat incomplete, and containing a few subtle errors.
In writing the documentation for this distribution, I borrowed heavily (read:
stole wholesale) from the libarchive documentation, making changes where 
appropriate for use under Perl (changing `NULL` to `undef` for example, along 
with the interface change to make that work).  I may and probably have introduced 
additional subtle errors.  Patches to the documentation that match the
implementation, or fixes to the implementation so that it matches the
documentation (which ever is appropriate) would greatly appreciated.

# SEE ALSO

The intent of this module is to provide a low level fairly thin direct
interface to libarchive, on which a more Perlish OO layer could easily
be written.

- [Archive::Libarchive::XS](https://metacpan.org/pod/Archive::Libarchive::XS)
- [Archive::Libarchive::FFI](https://metacpan.org/pod/Archive::Libarchive::FFI)

    Both of these provide the same API to libarchive via [Alien::Libarchive](https://metacpan.org/pod/Alien::Libarchive),
    but the bindings are implemented in XS for one and via [FFI::Sweet](https://metacpan.org/pod/FFI::Sweet) for
    the other.

- [Archive::Libarchive::Any](https://metacpan.org/pod/Archive::Libarchive::Any)

    Offers whichever is available, either the XS or FFI version.  The
    actual algorithm as to which is picked is subject to change, depending
    on with version seems to be the most reliable.

- [Archive::Peek::Libarchive](https://metacpan.org/pod/Archive::Peek::Libarchive)
- [Archive::Extract::Libarchive](https://metacpan.org/pod/Archive::Extract::Libarchive)

    Both of these provide a higher level, less complete perlish interface
    to libarchive.

- [Archive::Tar](https://metacpan.org/pod/Archive::Tar)
- [Archive::Tar::Wrapper](https://metacpan.org/pod/Archive::Tar::Wrapper)

    Just some of the many modules on CPAN that will read/write tar archives.

- [Archive::Zip](https://metacpan.org/pod/Archive::Zip)

    Just one of the many modules on CPAN that will read/write zip archives.

- [Archive::Any](https://metacpan.org/pod/Archive::Any)

    A module attempts to read/write multiple formats using different methods
    depending on what perl modules are installed, and preferring pure perl
    modules.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
