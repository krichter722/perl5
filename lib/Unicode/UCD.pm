package Unicode::UCD;

use strict;
use warnings;
no warnings 'surrogate';    # surrogates can be inputs to this
use charnames ();
use Unicode::Normalize qw(getCombinClass NFD);

our $VERSION = '0.37';

use Storable qw(dclone);

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(charinfo
		    charblock charscript
		    charblocks charscripts
		    charinrange
		    general_categories bidi_types
		    compexcl
		    casefold casespec
		    namedseq
                    num
                    prop_aliases
                    prop_value_aliases
                    prop_invlist
                    MAX_CP
                );

use Carp;

=head1 NAME

Unicode::UCD - Unicode character database

=head1 SYNOPSIS

    use Unicode::UCD 'charinfo';
    my $charinfo   = charinfo($codepoint);

    use Unicode::UCD 'casefold';
    my $casefold = casefold(0xFB00);

    use Unicode::UCD 'casespec';
    my $casespec = casespec(0xFB00);

    use Unicode::UCD 'charblock';
    my $charblock  = charblock($codepoint);

    use Unicode::UCD 'charscript';
    my $charscript = charscript($codepoint);

    use Unicode::UCD 'charblocks';
    my $charblocks = charblocks();

    use Unicode::UCD 'charscripts';
    my $charscripts = charscripts();

    use Unicode::UCD qw(charscript charinrange);
    my $range = charscript($script);
    print "looks like $script\n" if charinrange($range, $codepoint);

    use Unicode::UCD qw(general_categories bidi_types);
    my $categories = general_categories();
    my $types = bidi_types();

    use Unicode::UCD 'prop_aliases';
    my @space_names = prop_aliases("space");

    use Unicode::UCD 'prop_value_aliases';
    my @gc_punct_names = prop_value_aliases("Gc", "Punct");

    use Unicode::UCD 'prop_invlist';
    my @puncts = prop_invlist("gc=punctuation");

    use Unicode::UCD 'compexcl';
    my $compexcl = compexcl($codepoint);

    use Unicode::UCD 'namedseq';
    my $namedseq = namedseq($named_sequence_name);

    my $unicode_version = Unicode::UCD::UnicodeVersion();

    my $convert_to_numeric =
              Unicode::UCD::num("\N{RUMI DIGIT ONE}\N{RUMI DIGIT TWO}");

=head1 DESCRIPTION

The Unicode::UCD module offers a series of functions that
provide a simple interface to the Unicode
Character Database.

=head2 code point argument

Some of the functions are called with a I<code point argument>, which is either
a decimal or a hexadecimal scalar designating a Unicode code point, or C<U+>
followed by hexadecimals designating a Unicode code point.  In other words, if
you want a code point to be interpreted as a hexadecimal number, you must
prefix it with either C<0x> or C<U+>, because a string like e.g. C<123> will be
interpreted as a decimal code point.  Note that the largest code point in
Unicode is U+10FFFF.
=cut

my $BLOCKSFH;
my $VERSIONFH;
my $CASEFOLDFH;
my $CASESPECFH;
my $NAMEDSEQFH;

sub openunicode {
    my ($rfh, @path) = @_;
    my $f;
    unless (defined $$rfh) {
	for my $d (@INC) {
	    use File::Spec;
	    $f = File::Spec->catfile($d, "unicore", @path);
	    last if open($$rfh, $f);
	    undef $f;
	}
	croak __PACKAGE__, ": failed to find ",
              File::Spec->catfile(@path), " in @INC"
	    unless defined $f;
    }
    return $f;
}

=head2 B<charinfo()>

    use Unicode::UCD 'charinfo';

    my $charinfo = charinfo(0x41);

This returns information about the input L</code point argument>
as a reference to a hash of fields as defined by the Unicode
standard.  If the L</code point argument> is not assigned in the standard
(i.e., has the general category C<Cn> meaning C<Unassigned>)
or is a non-character (meaning it is guaranteed to never be assigned in
the standard),
C<undef> is returned.

Fields that aren't applicable to the particular code point argument exist in the
returned hash, and are empty. 

The keys in the hash with the meanings of their values are:

=over

=item B<code>

the input L</code point argument> expressed in hexadecimal, with leading zeros
added if necessary to make it contain at least four hexdigits

=item B<name>

name of I<code>, all IN UPPER CASE.
Some control-type code points do not have names.
This field will be empty for C<Surrogate> and C<Private Use> code points,
and for the others without a name,
it will contain a description enclosed in angle brackets, like
C<E<lt>controlE<gt>>.


=item B<category>

The short name of the general category of I<code>.
This will match one of the keys in the hash returned by L</general_categories()>.

The L</prop_value_aliases()> function can be used to get all the synonyms
of the category name.

=item B<combining>

the combining class number for I<code> used in the Canonical Ordering Algorithm.
For Unicode 5.1, this is described in Section 3.11 C<Canonical Ordering Behavior>
available at
L<http://www.unicode.org/versions/Unicode5.1.0/>

The L</prop_value_aliases()> function can be used to get all the synonyms
of the combining class number.

=item B<bidi>

bidirectional type of I<code>.
This will match one of the keys in the hash returned by L</bidi_types()>.

The L</prop_value_aliases()> function can be used to get all the synonyms
of the bidi type name.

=item B<decomposition>

is empty if I<code> has no decomposition; or is one or more codes
(separated by spaces) that, taken in order, represent a decomposition for
I<code>.  Each has at least four hexdigits.
The codes may be preceded by a word enclosed in angle brackets then a space,
like C<E<lt>compatE<gt> >, giving the type of decomposition

This decomposition may be an intermediate one whose components are also
decomposable.  Use L<Unicode::Normalize> to get the final decomposition.

=item B<decimal>

if I<code> is a decimal digit this is its integer numeric value

=item B<digit>

if I<code> represents some other digit-like number, this is its integer
numeric value

=item B<numeric>

if I<code> represents a whole or rational number, this is its numeric value.
Rational values are expressed as a string like C<1/4>.

=item B<mirrored>

C<Y> or C<N> designating if I<code> is mirrored in bidirectional text

=item B<unicode10>

name of I<code> in the Unicode 1.0 standard if one
existed for this code point and is different from the current name

=item B<comment>

As of Unicode 6.0, this is always empty.

=item B<upper>

is empty if there is no single code point uppercase mapping for I<code>
(its uppercase mapping is itself);
otherwise it is that mapping expressed as at least four hexdigits.
(L</casespec()> should be used in addition to B<charinfo()>
for case mappings when the calling program can cope with multiple code point
mappings.)

=item B<lower>

is empty if there is no single code point lowercase mapping for I<code>
(its lowercase mapping is itself);
otherwise it is that mapping expressed as at least four hexdigits.
(L</casespec()> should be used in addition to B<charinfo()>
for case mappings when the calling program can cope with multiple code point
mappings.)

=item B<title>

is empty if there is no single code point titlecase mapping for I<code>
(its titlecase mapping is itself);
otherwise it is that mapping expressed as at least four hexdigits.
(L</casespec()> should be used in addition to B<charinfo()>
for case mappings when the calling program can cope with multiple code point
mappings.)

=item B<block>

the block I<code> belongs to (used in C<\p{Blk=...}>).
See L</Blocks versus Scripts>.


=item B<script>

the script I<code> belongs to.
See L</Blocks versus Scripts>.

=back

Note that you cannot do (de)composition and casing based solely on the
I<decomposition>, I<combining>, I<lower>, I<upper>, and I<title> fields;
you will need also the L</compexcl()>, and L</casespec()> functions.

=cut

# NB: This function is nearly duplicated in charnames.pm
sub _getcode {
    my $arg = shift;

    if ($arg =~ /^[1-9]\d*$/) {
	return $arg;
    } elsif ($arg =~ /^(?:[Uu]\+|0[xX])?([[:xdigit:]]+)$/) {
	return hex($1);
    }

    return;
}

# Populated by _num.  Converts real number back to input rational
my %real_to_rational;

# To store the contents of files found on disk.
my @BIDIS;
my @CATEGORIES;
my @DECOMPOSITIONS;
my @NUMERIC_TYPES;
my %SIMPLE_LOWER;
my %SIMPLE_TITLE;
my %SIMPLE_UPPER;
my %UNICODE_1_NAMES;

sub _charinfo_case {

    # Returns the value to set into one of the case fields in the charinfo
    # structure.
    #   $char is the character,
    #   $cased is the case-changed character
    #   $file is the file in lib/unicore/To/$file that contains the data
    #       needed for this, in the form that _search() understands.
    #   $hash_ref points to the hash holding the contents of $file.  It will
    #       be populated if empty.
    # By using the 'uc', etc. functions, we avoid loading more files into
    # memory except for those rare cases where the simple casing (which has
    # been what charinfo() has always returned, is different than the full
    # casing.
    my ($char, $cased, $file, $hash_ref) = @_;

    return "" if $cased eq $char;

    return sprintf("%04X", ord $cased) if length($cased) == 1;

    %$hash_ref =_read_table("unicore/To/$file", 'use_hash') unless %$hash_ref;
    return $hash_ref->{ord $char} // "";
}

sub charinfo {

    # This function has traditionally mimicked what is in UnicodeData.txt,
    # warts and all.  This is a re-write that avoids UnicodeData.txt so that
    # it can be removed to save disk space.  Instead, this assembles
    # information gotten by other methods that get data from various other
    # files.  It uses charnames to get the character name; and various
    # mktables tables.

    use feature 'unicode_strings';

    my $arg  = shift;
    my $code = _getcode($arg);
    croak __PACKAGE__, "::charinfo: unknown code '$arg'" unless defined $code;

    # Non-unicode implies undef.
    return if $code > 0x10FFFF;

    my %prop;
    my $char = chr($code);

    @CATEGORIES =_read_table("unicore/To/Gc.pl") unless @CATEGORIES;
    $prop{'category'} = _search(\@CATEGORIES, 0, $#CATEGORIES, $code)
                        // $utf8::SwashInfo{'ToGc'}{'missing'};

    return if $prop{'category'} eq 'Cn';    # Unassigned code points are undef

    $prop{'code'} = sprintf "%04X", $code;
    $prop{'name'} = ($char =~ /\p{Cntrl}/) ? '<control>'
                                           : (charnames::viacode($code) // "");

    $prop{'combining'} = getCombinClass($code);

    @BIDIS =_read_table("unicore/To/Bc.pl") unless @BIDIS;
    $prop{'bidi'} = _search(\@BIDIS, 0, $#BIDIS, $code)
                    // $utf8::SwashInfo{'ToBc'}{'missing'};

    # For most code points, we can just read in "unicore/Decomposition.pl", as
    # its contents are exactly what should be output.  But that file doesn't
    # contain the data for the Hangul syllable decompositions, which can be
    # algorithmically computed, and NFD() does that, so we call NFD() for
    # those.  We can't use NFD() for everything, as it does a complete
    # recursive decomposition, and what this function has always done is to
    # return what's in UnicodeData.txt which doesn't show that recursiveness.
    # Fortunately, the NFD() of the Hanguls doesn't have any recursion
    # issues.
    # Having no decomposition implies an empty field; otherwise, all but
    # "Canonical" imply a compatible decomposition, and the type is prefixed
    # to that, as it is in UnicodeData.txt
    if ($char =~ /\p{Block=Hangul_Syllables}/) {
        # The code points of the decomposition are output in standard Unicode
        # hex format, separated by blanks.
        $prop{'decomposition'} = join " ", map { sprintf("%04X", $_)}
                                           unpack "U*", NFD($char);
    }
    else {
        @DECOMPOSITIONS = _read_table("unicore/Decomposition.pl")
                          unless @DECOMPOSITIONS;
        $prop{'decomposition'} = _search(\@DECOMPOSITIONS, 0, $#DECOMPOSITIONS,
                                                                $code) // "";
    }

    # Can use num() to get the numeric values, if any.
    if (! defined (my $value = num($char))) {
        $prop{'decimal'} = $prop{'digit'} = $prop{'numeric'} = "";
    }
    else {
        if ($char =~ /\d/) {
            $prop{'decimal'} = $prop{'digit'} = $prop{'numeric'} = $value;
        }
        else {

            # For non-decimal-digits, we have to read in the Numeric type
            # to distinguish them.  It is not just a matter of integer vs.
            # rational, as some whole number values are not considered digits,
            # e.g., TAMIL NUMBER TEN.
            $prop{'decimal'} = "";

            @NUMERIC_TYPES =_read_table("unicore/To/Nt.pl")
                                unless @NUMERIC_TYPES;
            if ((_search(\@NUMERIC_TYPES, 0, $#NUMERIC_TYPES, $code) // "")
                eq 'Digit')
            {
                $prop{'digit'} = $prop{'numeric'} = $value;
            }
            else {
                $prop{'digit'} = "";
                $prop{'numeric'} = $real_to_rational{$value} // $value;
            }
        }
    }

    $prop{'mirrored'} = ($char =~ /\p{Bidi_Mirrored}/) ? 'Y' : 'N';

    %UNICODE_1_NAMES =_read_table("unicore/To/Na1.pl", "use_hash") unless %UNICODE_1_NAMES;
    $prop{'unicode10'} = $UNICODE_1_NAMES{$code} // "";

    # This is true starting in 6.0, but, num() also requires 6.0, so
    # don't need to test for version again here.
    $prop{'comment'} = "";

    $prop{'upper'} = _charinfo_case($char, uc $char, '_suc.pl', \%SIMPLE_UPPER);
    $prop{'lower'} = _charinfo_case($char, lc $char, '_slc.pl', \%SIMPLE_LOWER);
    $prop{'title'} = _charinfo_case($char, ucfirst $char, '_stc.pl',
                                                                \%SIMPLE_TITLE);

    $prop{block}  = charblock($code);
    $prop{script} = charscript($code);
    return \%prop;
}

sub _search { # Binary search in a [[lo,hi,prop],[...],...] table.
    my ($table, $lo, $hi, $code) = @_;

    return if $lo > $hi;

    my $mid = int(($lo+$hi) / 2);

    if ($table->[$mid]->[0] < $code) {
	if ($table->[$mid]->[1] >= $code) {
	    return $table->[$mid]->[2];
	} else {
	    _search($table, $mid + 1, $hi, $code);
	}
    } elsif ($table->[$mid]->[0] > $code) {
	_search($table, $lo, $mid - 1, $code);
    } else {
	return $table->[$mid]->[2];
    }
}

sub _read_table ($;$) {

    # Returns the contents of the mktables generated table file located at $1
    # in the form of either an array of arrays or a hash, depending on if the
    # optional second parameter is true (for hash return) or not.  In the case
    # of a hash return, each key is a code point, and its corresponding value
    # is what the table gives as the code point's corresponding value.  In the
    # case of an array return, each outer array denotes a range with [0] the
    # start point of that range; [1] the end point; and [2] the value that
    # every code point in the range has.  The hash return is useful for fast
    # lookup when the table contains only single code point ranges.  The array
    # return takes much less memory when there are large ranges.
    #
    # This function has the side effect of setting
    # $utf8::SwashInfo{$property}{'format'} to be the mktables format of the
    #                                       table; and
    # $utf8::SwashInfo{$property}{'missing'} to be the value for all entries
    #                                        not listed in the table.
    # where $property is the Unicode property name, preceded by 'To' for map
    # properties., e.g., 'ToSc'.
    #
    # Table entries look like one of:
    # 0000	0040	Common	# [65]
    # 00AA		Latin

    my $table = shift;
    my $return_hash = shift;
    $return_hash = 0 unless defined $return_hash;
    my @return;
    my %return;
    local $_;

    for (split /^/m, do $table) {
        my ($start, $end, $value) = / ^ (.+?) \t (.*?) \t (.+?)
                                        \s* ( \# .* )?  # Optional comment
                                        $ /x;
        my $decimal_start = hex $start;
        my $decimal_end = ($end eq "") ? $decimal_start : hex $end;
        if ($return_hash) {
            foreach my $i ($decimal_start .. $decimal_end) {
                $return{$i} = $value;
            }
        }
        elsif (@return &&
               $return[-1][1] == $decimal_start - 1
               && $return[-1][2] eq $value)
        {
            # If this is merely extending the previous range, do just that.
            $return[-1]->[1] = $decimal_end;
        }
        else {
            push @return, [ $decimal_start, $decimal_end, $value ];
        }
    }
    return ($return_hash) ? %return : @return;
}

sub charinrange {
    my ($range, $arg) = @_;
    my $code = _getcode($arg);
    croak __PACKAGE__, "::charinrange: unknown code '$arg'"
	unless defined $code;
    _search($range, 0, $#$range, $code);
}

=head2 B<charblock()>

    use Unicode::UCD 'charblock';

    my $charblock = charblock(0x41);
    my $charblock = charblock(1234);
    my $charblock = charblock(0x263a);
    my $charblock = charblock("U+263a");

    my $range     = charblock('Armenian');

With a L</code point argument> charblock() returns the I<block> the code point
belongs to, e.g.  C<Basic Latin>.  The old-style block name is returned (see
L</Old-style versus new-style block names>).
If the code point is unassigned, this returns the block it would belong to if
it were assigned.

See also L</Blocks versus Scripts>.

If supplied with an argument that can't be a code point, charblock() tries to
do the opposite and interpret the argument as an old-style block name. The
return value
is a I<range set> with one range: an anonymous list with a single element that
consists of another anonymous list whose first element is the first code point
in the block, and whose second (and final) element is the final code point in
the block.  (The extra list consisting of just one element is so that the same
program logic can be used to handle both this return, and the return from
L</charscript()> which can have multiple ranges.) You can test whether a code
point is in a range using the L</charinrange()> function.  If the argument is
not a known block, C<undef> is returned.

=cut

my @BLOCKS;
my %BLOCKS;

sub _charblocks {

    # Can't read from the mktables table because it loses the hyphens in the
    # original.
    unless (@BLOCKS) {
	if (openunicode(\$BLOCKSFH, "Blocks.txt")) {
	    local $_;
	    while (<$BLOCKSFH>) {
		if (/^([0-9A-F]+)\.\.([0-9A-F]+);\s+(.+)/) {
		    my ($lo, $hi) = (hex($1), hex($2));
		    my $subrange = [ $lo, $hi, $3 ];
		    push @BLOCKS, $subrange;
		    push @{$BLOCKS{$3}}, $subrange;
		}
	    }
	    close($BLOCKSFH);
	}
    }
}

sub charblock {
    my $arg = shift;

    _charblocks() unless @BLOCKS;

    my $code = _getcode($arg);

    if (defined $code) {
	my $result = _search(\@BLOCKS, 0, $#BLOCKS, $code);
        return $result if defined $result;
        return 'No_Block';
    }
    elsif (exists $BLOCKS{$arg}) {
        return dclone $BLOCKS{$arg};
    }
}

=head2 B<charscript()>

    use Unicode::UCD 'charscript';

    my $charscript = charscript(0x41);
    my $charscript = charscript(1234);
    my $charscript = charscript("U+263a");

    my $range      = charscript('Thai');

With a L</code point argument> charscript() returns the I<script> the
code point belongs to, e.g.  C<Latin>, C<Greek>, C<Han>.
If the code point is unassigned, it returns C<"Unknown">.

If supplied with an argument that can't be a code point, charscript() tries
to do the opposite and interpret the argument as a script name. The
return value is a I<range set>: an anonymous list of lists that contain
I<start-of-range>, I<end-of-range> code point pairs. You can test whether a
code point is in a range set using the L</charinrange()> function. If the
argument is not a known script, C<undef> is returned.

See also L</Blocks versus Scripts>.

=cut

my @SCRIPTS;
my %SCRIPTS;

sub _charscripts {
    @SCRIPTS =_read_table("unicore/To/Sc.pl") unless @SCRIPTS;
    foreach my $entry (@SCRIPTS) {
        $entry->[2] =~ s/(_\w)/\L$1/g;  # Preserve old-style casing
        push @{$SCRIPTS{$entry->[2]}}, $entry;
    }
}

sub charscript {
    my $arg = shift;

    _charscripts() unless @SCRIPTS;

    my $code = _getcode($arg);

    if (defined $code) {
	my $result = _search(\@SCRIPTS, 0, $#SCRIPTS, $code);
        return $result if defined $result;
        return $utf8::SwashInfo{'ToSc'}{'missing'};
    } elsif (exists $SCRIPTS{$arg}) {
        return dclone $SCRIPTS{$arg};
    }

    return;
}

=head2 B<charblocks()>

    use Unicode::UCD 'charblocks';

    my $charblocks = charblocks();

charblocks() returns a reference to a hash with the known block names
as the keys, and the code point ranges (see L</charblock()>) as the values.

The names are in the old-style (see L</Old-style versus new-style block
names>).

See also L</Blocks versus Scripts>.

=cut

sub charblocks {
    _charblocks() unless %BLOCKS;
    return dclone \%BLOCKS;
}

=head2 B<charscripts()>

    use Unicode::UCD 'charscripts';

    my $charscripts = charscripts();

charscripts() returns a reference to a hash with the known script
names as the keys, and the code point ranges (see L</charscript()>) as
the values.

See also L</Blocks versus Scripts>.

=cut

sub charscripts {
    _charscripts() unless %SCRIPTS;
    return dclone \%SCRIPTS;
}

=head2 B<charinrange()>

In addition to using the C<\p{Blk=...}> and C<\P{Blk=...}> constructs, you
can also test whether a code point is in the I<range> as returned by
L</charblock()> and L</charscript()> or as the values of the hash returned
by L</charblocks()> and L</charscripts()> by using charinrange():

    use Unicode::UCD qw(charscript charinrange);

    $range = charscript('Hiragana');
    print "looks like hiragana\n" if charinrange($range, $codepoint);

=cut

my %GENERAL_CATEGORIES =
 (
    'L'  =>         'Letter',
    'LC' =>         'CasedLetter',
    'Lu' =>         'UppercaseLetter',
    'Ll' =>         'LowercaseLetter',
    'Lt' =>         'TitlecaseLetter',
    'Lm' =>         'ModifierLetter',
    'Lo' =>         'OtherLetter',
    'M'  =>         'Mark',
    'Mn' =>         'NonspacingMark',
    'Mc' =>         'SpacingMark',
    'Me' =>         'EnclosingMark',
    'N'  =>         'Number',
    'Nd' =>         'DecimalNumber',
    'Nl' =>         'LetterNumber',
    'No' =>         'OtherNumber',
    'P'  =>         'Punctuation',
    'Pc' =>         'ConnectorPunctuation',
    'Pd' =>         'DashPunctuation',
    'Ps' =>         'OpenPunctuation',
    'Pe' =>         'ClosePunctuation',
    'Pi' =>         'InitialPunctuation',
    'Pf' =>         'FinalPunctuation',
    'Po' =>         'OtherPunctuation',
    'S'  =>         'Symbol',
    'Sm' =>         'MathSymbol',
    'Sc' =>         'CurrencySymbol',
    'Sk' =>         'ModifierSymbol',
    'So' =>         'OtherSymbol',
    'Z'  =>         'Separator',
    'Zs' =>         'SpaceSeparator',
    'Zl' =>         'LineSeparator',
    'Zp' =>         'ParagraphSeparator',
    'C'  =>         'Other',
    'Cc' =>         'Control',
    'Cf' =>         'Format',
    'Cs' =>         'Surrogate',
    'Co' =>         'PrivateUse',
    'Cn' =>         'Unassigned',
 );

sub general_categories {
    return dclone \%GENERAL_CATEGORIES;
}

=head2 B<general_categories()>

    use Unicode::UCD 'general_categories';

    my $categories = general_categories();

This returns a reference to a hash which has short
general category names (such as C<Lu>, C<Nd>, C<Zs>, C<S>) as keys and long
names (such as C<UppercaseLetter>, C<DecimalNumber>, C<SpaceSeparator>,
C<Symbol>) as values.  The hash is reversible in case you need to go
from the long names to the short names.  The general category is the
one returned from
L</charinfo()> under the C<category> key.

The L</prop_value_aliases()> function can be used to get all the synonyms of
the category name.

=cut

my %BIDI_TYPES =
 (
   'L'   => 'Left-to-Right',
   'LRE' => 'Left-to-Right Embedding',
   'LRO' => 'Left-to-Right Override',
   'R'   => 'Right-to-Left',
   'AL'  => 'Right-to-Left Arabic',
   'RLE' => 'Right-to-Left Embedding',
   'RLO' => 'Right-to-Left Override',
   'PDF' => 'Pop Directional Format',
   'EN'  => 'European Number',
   'ES'  => 'European Number Separator',
   'ET'  => 'European Number Terminator',
   'AN'  => 'Arabic Number',
   'CS'  => 'Common Number Separator',
   'NSM' => 'Non-Spacing Mark',
   'BN'  => 'Boundary Neutral',
   'B'   => 'Paragraph Separator',
   'S'   => 'Segment Separator',
   'WS'  => 'Whitespace',
   'ON'  => 'Other Neutrals',
 ); 

=head2 B<bidi_types()>

    use Unicode::UCD 'bidi_types';

    my $categories = bidi_types();

This returns a reference to a hash which has the short
bidi (bidirectional) type names (such as C<L>, C<R>) as keys and long
names (such as C<Left-to-Right>, C<Right-to-Left>) as values.  The
hash is reversible in case you need to go from the long names to the
short names.  The bidi type is the one returned from
L</charinfo()>
under the C<bidi> key.  For the exact meaning of the various bidi classes
the Unicode TR9 is recommended reading:
L<http://www.unicode.org/reports/tr9/>
(as of Unicode 5.0.0)

The L</prop_value_aliases()> function can be used to get all the synonyms of
the bidi type name.

=cut

sub bidi_types {
    return dclone \%BIDI_TYPES;
}

=head2 B<compexcl()>

    use Unicode::UCD 'compexcl';

    my $compexcl = compexcl(0x09dc);

This routine is included for backwards compatibility, but as of Perl 5.12, for
most purposes it is probably more convenient to use one of the following
instead:

    my $compexcl = chr(0x09dc) =~ /\p{Comp_Ex};
    my $compexcl = chr(0x09dc) =~ /\p{Full_Composition_Exclusion};

or even

    my $compexcl = chr(0x09dc) =~ /\p{CE};
    my $compexcl = chr(0x09dc) =~ /\p{Composition_Exclusion};

The first two forms return B<true> if the L</code point argument> should not
be produced by composition normalization.  For the final two forms to return
B<true>, it is additionally required that this fact not otherwise be
determinable from the Unicode data base.

This routine behaves identically to the final two forms.  That is,
it does not return B<true> if the code point has a decomposition
consisting of another single code point, nor if its decomposition starts
with a code point whose combining class is non-zero.  Code points that meet
either of these conditions should also not be produced by composition
normalization, which is probably why you should use the
C<Full_Composition_Exclusion> property instead, as shown above.

The routine returns B<false> otherwise.

=cut

sub compexcl {
    my $arg  = shift;
    my $code = _getcode($arg);
    croak __PACKAGE__, "::compexcl: unknown code '$arg'"
	unless defined $code;

    no warnings "non_unicode";     # So works on non-Unicode code points
    return chr($code) =~ /\p{Composition_Exclusion}/;
}

=head2 B<casefold()>

    use Unicode::UCD 'casefold';

    my $casefold = casefold(0xDF);
    if (defined $casefold) {
        my @full_fold_hex = split / /, $casefold->{'full'};
        my $full_fold_string =
                    join "", map {chr(hex($_))} @full_fold_hex;
        my @turkic_fold_hex =
                        split / /, ($casefold->{'turkic'} ne "")
                                        ? $casefold->{'turkic'}
                                        : $casefold->{'full'};
        my $turkic_fold_string =
                        join "", map {chr(hex($_))} @turkic_fold_hex;
    }
    if (defined $casefold && $casefold->{'simple'} ne "") {
        my $simple_fold_hex = $casefold->{'simple'};
        my $simple_fold_string = chr(hex($simple_fold_hex));
    }

This returns the (almost) locale-independent case folding of the
character specified by the L</code point argument>.

If there is no case folding for that code point, C<undef> is returned.

If there is a case folding for that code point, a reference to a hash
with the following fields is returned:

=over

=item B<code>

the input L</code point argument> expressed in hexadecimal, with leading zeros
added if necessary to make it contain at least four hexdigits

=item B<full>

one or more codes (separated by spaces) that, taken in order, give the
code points for the case folding for I<code>.
Each has at least four hexdigits.

=item B<simple>

is empty, or is exactly one code with at least four hexdigits which can be used
as an alternative case folding when the calling program cannot cope with the
fold being a sequence of multiple code points.  If I<full> is just one code
point, then I<simple> equals I<full>.  If there is no single code point folding
defined for I<code>, then I<simple> is the empty string.  Otherwise, it is an
inferior, but still better-than-nothing alternative folding to I<full>.

=item B<mapping>

is the same as I<simple> if I<simple> is not empty, and it is the same as I<full>
otherwise.  It can be considered to be the simplest possible folding for
I<code>.  It is defined primarily for backwards compatibility.

=item B<status>

is C<C> (for C<common>) if the best possible fold is a single code point
(I<simple> equals I<full> equals I<mapping>).  It is C<S> if there are distinct
folds, I<simple> and I<full> (I<mapping> equals I<simple>).  And it is C<F> if
there is only a I<full> fold (I<mapping> equals I<full>; I<simple> is empty).
Note that this
describes the contents of I<mapping>.  It is defined primarily for backwards
compatibility.

On versions 3.1 and earlier of Unicode, I<status> can also be
C<I> which is the same as C<C> but is a special case for dotted uppercase I and
dotless lowercase i:

=over

=item B<*> If you use this C<I> mapping

the result is case-insensitive,
but dotless and dotted I's are not distinguished

=item B<*> If you exclude this C<I> mapping

the result is not fully case-insensitive, but
dotless and dotted I's are distinguished

=back

=item B<turkic>

contains any special folding for Turkic languages.  For versions of Unicode
starting with 3.2, this field is empty unless I<code> has a different folding
in Turkic languages, in which case it is one or more codes (separated by
spaces) that, taken in order, give the code points for the case folding for
I<code> in those languages.
Each code has at least four hexdigits.
Note that this folding does not maintain canonical equivalence without
additional processing.

For versions of Unicode 3.1 and earlier, this field is empty unless there is a
special folding for Turkic languages, in which case I<status> is C<I>, and
I<mapping>, I<full>, I<simple>, and I<turkic> are all equal.  

=back

Programs that want complete generality and the best folding results should use
the folding contained in the I<full> field.  But note that the fold for some
code points will be a sequence of multiple code points.

Programs that can't cope with the fold mapping being multiple code points can
use the folding contained in the I<simple> field, with the loss of some
generality.  In Unicode 5.1, about 7% of the defined foldings have no single
code point folding.

The I<mapping> and I<status> fields are provided for backwards compatibility for
existing programs.  They contain the same values as in previous versions of
this function.

Locale is not completely independent.  The I<turkic> field contains results to
use when the locale is a Turkic language.

For more information about case mappings see
L<http://www.unicode.org/unicode/reports/tr21>

=cut

my %CASEFOLD;

sub _casefold {
    unless (%CASEFOLD) {
	if (openunicode(\$CASEFOLDFH, "CaseFolding.txt")) {
	    local $_;
	    while (<$CASEFOLDFH>) {
		if (/^([0-9A-F]+); ([CFIST]); ([0-9A-F]+(?: [0-9A-F]+)*);/) {
		    my $code = hex($1);
		    $CASEFOLD{$code}{'code'} = $1;
		    $CASEFOLD{$code}{'turkic'} = "" unless
					    defined $CASEFOLD{$code}{'turkic'};
		    if ($2 eq 'C' || $2 eq 'I') {	# 'I' is only on 3.1 and
							# earlier Unicodes
							# Both entries there (I
							# only checked 3.1) are
							# the same as C, and
							# there are no other
							# entries for those
							# codepoints, so treat
							# as if C, but override
							# the turkic one for
							# 'I'.
			$CASEFOLD{$code}{'status'} = $2;
			$CASEFOLD{$code}{'full'} = $CASEFOLD{$code}{'simple'} =
			$CASEFOLD{$code}{'mapping'} = $3;
			$CASEFOLD{$code}{'turkic'} = $3 if $2 eq 'I';
		    } elsif ($2 eq 'F') {
			$CASEFOLD{$code}{'full'} = $3;
			unless (defined $CASEFOLD{$code}{'simple'}) {
				$CASEFOLD{$code}{'simple'} = "";
				$CASEFOLD{$code}{'mapping'} = $3;
				$CASEFOLD{$code}{'status'} = $2;
			}
		    } elsif ($2 eq 'S') {


			# There can't be a simple without a full, and simple
			# overrides all but full

			$CASEFOLD{$code}{'simple'} = $3;
			$CASEFOLD{$code}{'mapping'} = $3;
			$CASEFOLD{$code}{'status'} = $2;
		    } elsif ($2 eq 'T') {
			$CASEFOLD{$code}{'turkic'} = $3;
		    } # else can't happen because only [CIFST] are possible
		}
	    }
	    close($CASEFOLDFH);
	}
    }
}

sub casefold {
    my $arg  = shift;
    my $code = _getcode($arg);
    croak __PACKAGE__, "::casefold: unknown code '$arg'"
	unless defined $code;

    _casefold() unless %CASEFOLD;

    return $CASEFOLD{$code};
}

=head2 B<casespec()>

    use Unicode::UCD 'casespec';

    my $casespec = casespec(0xFB00);

This returns the potentially locale-dependent case mappings of the L</code point
argument>.  The mappings may be longer than a single code point (which the basic
Unicode case mappings as returned by L</charinfo()> never are).

If there are no case mappings for the L</code point argument>, or if all three
possible mappings (I<lower>, I<title> and I<upper>) result in single code
points and are locale independent and unconditional, C<undef> is returned
(which means that the case mappings, if any, for the code point are those
returned by L</charinfo()>).

Otherwise, a reference to a hash giving the mappings (or a reference to a hash
of such hashes, explained below) is returned with the following keys and their
meanings:

The keys in the bottom layer hash with the meanings of their values are:

=over

=item B<code>

the input L</code point argument> expressed in hexadecimal, with leading zeros
added if necessary to make it contain at least four hexdigits

=item B<lower>

one or more codes (separated by spaces) that, taken in order, give the
code points for the lower case of I<code>.
Each has at least four hexdigits.

=item B<title>

one or more codes (separated by spaces) that, taken in order, give the
code points for the title case of I<code>.
Each has at least four hexdigits.

=item B<upper>

one or more codes (separated by spaces) that, taken in order, give the
code points for the upper case of I<code>.
Each has at least four hexdigits.

=item B<condition>

the conditions for the mappings to be valid.
If C<undef>, the mappings are always valid.
When defined, this field is a list of conditions,
all of which must be true for the mappings to be valid.
The list consists of one or more
I<locales> (see below)
and/or I<contexts> (explained in the next paragraph),
separated by spaces.
(Other than as used to separate elements, spaces are to be ignored.)
Case distinctions in the condition list are not significant.
Conditions preceded by "NON_" represent the negation of the condition.

A I<context> is one of those defined in the Unicode standard.
For Unicode 5.1, they are defined in Section 3.13 C<Default Case Operations>
available at
L<http://www.unicode.org/versions/Unicode5.1.0/>.
These are for context-sensitive casing.

=back

The hash described above is returned for locale-independent casing, where
at least one of the mappings has length longer than one.  If C<undef> is
returned, the code point may have mappings, but if so, all are length one,
and are returned by L</charinfo()>.
Note that when this function does return a value, it will be for the complete
set of mappings for a code point, even those whose length is one.

If there are additional casing rules that apply only in certain locales,
an additional key for each will be defined in the returned hash.  Each such key
will be its locale name, defined as a 2-letter ISO 3166 country code, possibly
followed by a "_" and a 2-letter ISO language code (possibly followed by a "_"
and a variant code).  You can find the lists of all possible locales, see
L<Locale::Country> and L<Locale::Language>.
(In Unicode 6.0, the only locales returned by this function
are C<lt>, C<tr>, and C<az>.)

Each locale key is a reference to a hash that has the form above, and gives
the casing rules for that particular locale, which take precedence over the
locale-independent ones when in that locale.

If the only casing for a code point is locale-dependent, then the returned
hash will not have any of the base keys, like C<code>, C<upper>, etc., but
will contain only locale keys.

For more information about case mappings see
L<http://www.unicode.org/unicode/reports/tr21/>

=cut

my %CASESPEC;

sub _casespec {
    unless (%CASESPEC) {
	if (openunicode(\$CASESPECFH, "SpecialCasing.txt")) {
	    local $_;
	    while (<$CASESPECFH>) {
		if (/^([0-9A-F]+); ([0-9A-F]+(?: [0-9A-F]+)*)?; ([0-9A-F]+(?: [0-9A-F]+)*)?; ([0-9A-F]+(?: [0-9A-F]+)*)?; (\w+(?: \w+)*)?/) {
		    my ($hexcode, $lower, $title, $upper, $condition) =
			($1, $2, $3, $4, $5);
		    my $code = hex($hexcode);
		    if (exists $CASESPEC{$code}) {
			if (exists $CASESPEC{$code}->{code}) {
			    my ($oldlower,
				$oldtitle,
				$oldupper,
				$oldcondition) =
				    @{$CASESPEC{$code}}{qw(lower
							   title
							   upper
							   condition)};
			    if (defined $oldcondition) {
				my ($oldlocale) =
				($oldcondition =~ /^([a-z][a-z](?:_\S+)?)/);
				delete $CASESPEC{$code};
				$CASESPEC{$code}->{$oldlocale} =
				{ code      => $hexcode,
				  lower     => $oldlower,
				  title     => $oldtitle,
				  upper     => $oldupper,
				  condition => $oldcondition };
			    }
			}
			my ($locale) =
			    ($condition =~ /^([a-z][a-z](?:_\S+)?)/);
			$CASESPEC{$code}->{$locale} =
			{ code      => $hexcode,
			  lower     => $lower,
			  title     => $title,
			  upper     => $upper,
			  condition => $condition };
		    } else {
			$CASESPEC{$code} =
			{ code      => $hexcode,
			  lower     => $lower,
			  title     => $title,
			  upper     => $upper,
			  condition => $condition };
		    }
		}
	    }
	    close($CASESPECFH);
	}
    }
}

sub casespec {
    my $arg  = shift;
    my $code = _getcode($arg);
    croak __PACKAGE__, "::casespec: unknown code '$arg'"
	unless defined $code;

    _casespec() unless %CASESPEC;

    return ref $CASESPEC{$code} ? dclone $CASESPEC{$code} : $CASESPEC{$code};
}

=head2 B<namedseq()>

    use Unicode::UCD 'namedseq';

    my $namedseq = namedseq("KATAKANA LETTER AINU P");
    my @namedseq = namedseq("KATAKANA LETTER AINU P");
    my %namedseq = namedseq();

If used with a single argument in a scalar context, returns the string
consisting of the code points of the named sequence, or C<undef> if no
named sequence by that name exists.  If used with a single argument in
a list context, it returns the list of the ordinals of the code points.  If used
with no
arguments in a list context, returns a hash with the names of the
named sequences as the keys and the named sequences as strings as
the values.  Otherwise, it returns C<undef> or an empty list depending
on the context.

This function only operates on officially approved (not provisional) named
sequences.

Note that as of Perl 5.14, C<\N{KATAKANA LETTER AINU P}> will insert the named
sequence into double-quoted strings, and C<charnames::string_vianame("KATAKANA
LETTER AINU P")> will return the same string this function does, but will also
operate on character names that aren't named sequences, without you having to
know which are which.  See L<charnames>.

=cut

my %NAMEDSEQ;

sub _namedseq {
    unless (%NAMEDSEQ) {
	if (openunicode(\$NAMEDSEQFH, "Name.pl")) {
	    local $_;
	    while (<$NAMEDSEQFH>) {
		if (/^ [0-9A-F]+ \  /x) {
                    chomp;
                    my ($sequence, $name) = split /\t/;
		    my @s = map { chr(hex($_)) } split(' ', $sequence);
		    $NAMEDSEQ{$name} = join("", @s);
		}
	    }
	    close($NAMEDSEQFH);
	}
    }
}

sub namedseq {

    # Use charnames::string_vianame() which now returns this information,
    # unless the caller wants the hash returned, in which case we read it in,
    # and thereafter use it instead of calling charnames, as it is faster.

    my $wantarray = wantarray();
    if (defined $wantarray) {
	if ($wantarray) {
	    if (@_ == 0) {
                _namedseq() unless %NAMEDSEQ;
		return %NAMEDSEQ;
	    } elsif (@_ == 1) {
		my $s;
                if (%NAMEDSEQ) {
                    $s = $NAMEDSEQ{ $_[0] };
                }
                else {
                    $s = charnames::string_vianame($_[0]);
                }
		return defined $s ? map { ord($_) } split('', $s) : ();
	    }
	} elsif (@_ == 1) {
            return $NAMEDSEQ{ $_[0] } if %NAMEDSEQ;
            return charnames::string_vianame($_[0]);
	}
    }
    return;
}

my %NUMERIC;

sub _numeric {

    # Unicode 6.0 instituted the rule that only digits in a consecutive
    # block of 10 would be considered decimal digits.  Before that, the only
    # problematic code point that I'm (khw) aware of is U+019DA, NEW TAI LUE
    # THAM DIGIT ONE, which is an alternate form of U+019D1, NEW TAI LUE DIGIT
    # ONE.  The code could be modified to handle that, but not bothering, as
    # in TUS 6.0, U+19DA was changed to Nt=Di.
    if ((pack "C*", split /\./, UnicodeVersion()) lt 6.0.0) {
	croak __PACKAGE__, "::num requires Unicode 6.0 or greater"
    }
    my @numbers = _read_table("unicore/To/Nv.pl");
    foreach my $entry (@numbers) {
        my ($start, $end, $value) = @$entry;

        # If value contains a slash, convert to decimal, add a reverse hash
        # used by charinfo.
        if ((my @rational = split /\//, $value) == 2) {
            my $real = $rational[0] / $rational[1];
            $real_to_rational{$real} = $value;
            $value = $real;
        }

        for my $i ($start .. $end) {
            $NUMERIC{$i} = $value;
        }
    }

    # Decided unsafe to use these that aren't officially part of the Unicode
    # standard.
    #use Math::Trig;
    #my $pi = acos(-1.0);
    #$NUMERIC{0x03C0} = $pi;

    # Euler's constant, not to be confused with Euler's number
    #$NUMERIC{0x2107} = 0.57721566490153286060651209008240243104215933593992;

    # Euler's number
    #$NUMERIC{0x212F} = 2.7182818284590452353602874713526624977572;

    return;
}

=pod

=head2 B<num()>

    use Unicode::UCD 'num';

    my $val = num("123");
    my $one_quarter = num("\N{VULGAR FRACTION 1/4}");

C<num> returns the numeric value of the input Unicode string; or C<undef> if it
doesn't think the entire string has a completely valid, safe numeric value.

If the string is just one character in length, the Unicode numeric value
is returned if it has one, or C<undef> otherwise.  Note that this need
not be a whole number.  C<num("\N{TIBETAN DIGIT HALF ZERO}")>, for
example returns -0.5.

=cut

#A few characters to which Unicode doesn't officially
#assign a numeric value are considered numeric by C<num>.
#These are:

# EULER CONSTANT             0.5772...  (this is NOT Euler's number)
# SCRIPT SMALL E             2.71828... (this IS Euler's number)
# GREEK SMALL LETTER PI      3.14159...

=pod

If the string is more than one character, C<undef> is returned unless
all its characters are decimal digits (that is, they would match C<\d+>),
from the same script.  For example if you have an ASCII '0' and a Bengali
'3', mixed together, they aren't considered a valid number, and C<undef>
is returned.  A further restriction is that the digits all have to be of
the same form.  A half-width digit mixed with a full-width one will
return C<undef>.  The Arabic script has two sets of digits;  C<num> will
return C<undef> unless all the digits in the string come from the same
set.

C<num> errs on the side of safety, and there may be valid strings of
decimal digits that it doesn't recognize.  Note that Unicode defines
a number of "digit" characters that aren't "decimal digit" characters.
"Decimal digits" have the property that they have a positional value, i.e.,
there is a units position, a 10's position, a 100's, etc, AND they are
arranged in Unicode in blocks of 10 contiguous code points.  The Chinese
digits, for example, are not in such a contiguous block, and so Unicode
doesn't view them as decimal digits, but merely digits, and so C<\d> will not
match them.  A single-character string containing one of these digits will
have its decimal value returned by C<num>, but any longer string containing
only these digits will return C<undef>.

Strings of multiple sub- and superscripts are not recognized as numbers.  You
can use either of the compatibility decompositions in Unicode::Normalize to
change these into digits, and then call C<num> on the result.

=cut

# To handle sub, superscripts, this could if called in list context,
# consider those, and return the <decomposition> type in the second
# array element.

sub num {
    my $string = $_[0];

    _numeric unless %NUMERIC;

    my $length = length($string);
    return $NUMERIC{ord($string)} if $length == 1;
    return if $string =~ /\D/;
    my $first_ord = ord(substr($string, 0, 1));
    my $value = $NUMERIC{$first_ord};
    my $zero_ord = $first_ord - $value;

    for my $i (1 .. $length -1) {
        my $ord = ord(substr($string, $i, 1));
        my $digit = $ord - $zero_ord;
        return unless $digit >= 0 && $digit <= 9;
        $value = $value * 10 + $digit;
    }
    return $value;
}

=pod

=head2 B<prop_aliases()>

    use Unicode::UCD 'prop_aliases';

    my ($short_name, $full_name, @other_names) = prop_aliases("space");
    my $same_full_name = prop_aliases("Space");     # Scalar context
    my ($same_short_name) = prop_aliases("Space");  # gets 0th element
    print "The full name is $full_name\n";
    print "The short name is $short_name\n";
    print "The other aliases are: ", join(", ", @other_names), "\n";

    prints:
    The full name is White_Space
    The short name is WSpace
    The other aliases are: Space

Most Unicode properties have several synonymous names.  Typically, there is at
least a short name, convenient to type, and a long name that more fully
describes the property, and hence is more easily understood.

If you know one name for a Unicode property, you can use C<prop_aliases> to find
either the long name (when called in scalar context), or a list of all of the
names, somewhat ordered so that the short name is in the 0th element, the long
name in the next element, and any other synonyms are in the remaining
elements, in no particular order.

The long name is returned in a form nicely capitalized, suitable for printing.

The input parameter name is loosely matched, which means that white space,
hyphens, and underscores are ignored (except for the trailing underscore in
the old_form grandfathered-in C<"L_">, which is better written as C<"LC">, and
both of which mean C<General_Category=Cased Letter>).

If the name is unknown, C<undef> is returned (or an empty list in list
context).  Note that Perl typically recognizes property names in regular
expressions with an optional C<"Is_>" (with or without the underscore)
prefixed to them, such as C<\p{isgc=punct}>.  This function does not recognize
those in the input, returning C<undef>.  Nor are they included in the output
as possible synonyms.

C<prop_aliases> does know about the Perl extensions to Unicode properties,
such as C<Any> and C<XPosixAlpha>, and the single form equivalents to Unicode
properties such as C<XDigit>, C<Greek>, C<In_Greek>, and C<Is_Greek>.  The
final example demonstrates that the C<"Is_"> prefix is recognized for these
extensions; it is needed to resolve ambiguities.  For example,
C<prop_aliases('lc')> returns the list C<(lc, Lowercase_Mapping)>, but
C<prop_aliases('islc')> returns C<(Is_LC, Cased_Letter)>.  This is
because C<islc> is a Perl extension which is short for
C<General_Category=Cased Letter>.  The lists returned for the Perl extensions
will not include the C<"Is_"> prefix (whether or not the input had it) unless
needed to resolve ambiguities, as shown in the C<"islc"> example, where the
returned list had one element containing C<"Is_">, and the other without.

It is also possible for the reverse to happen:  C<prop_aliases('isc')> returns
the list C<(isc, ISO_Comment)>; whereas C<prop_aliases('c')> returns
C<(C, Other)> (the latter being a Perl extension meaning
C<General_Category=Other>.  L<perluniprops> lists the available forms,
including which ones are discouraged from use.

Those discouraged forms are accepted as input to C<prop_aliases>, but are not
returned in the lists.  C<prop_aliases('isL&')> and C<prop_aliases('isL_')>,
which are old synonyms for C<"Is_LC"> and should not be used in new code, are
examples of this.  These both return C<(Is_LC, Cased_Letter)>.  Thus this
function allows you to take a discourarged form, and find its acceptable
alternatives.  The same goes with single-form Block property equivalences.
Only the forms that begin with C<"In_"> are not discouraged; if you pass
C<prop_aliases> a discouraged form, you will get back the equivalent ones that
begin with C<"In_">.  It will otherwise look like a new-style block name (see.
L</Old-style versus new-style block names>).

C<prop_aliases> does not know about any user-defined properties, and will
return C<undef> if called with one of those.  Likewise for Perl internal
properties, with the exception of "Perl_Decimal_Digit" which it does know
about (and which is documented below in L</prop_invmap()>).

=cut

# It may be that there are use cases where the discouraged forms should be
# returned.  If that comes up, an optional boolean second parameter to the
# function could be created, for example.

# These are created by mktables for this routine and stored in unicore/UCD.pl
# where their structures are described.
our %string_property_loose_to_name;
our %ambiguous_names;
our %loose_perlprop_to_name;
our %prop_aliases;

sub prop_aliases ($) {
    my $prop = $_[0];
    return unless defined $prop;

    require "unicore/UCD.pl";
    require "unicore/Heavy.pl";
    require "utf8_heavy.pl";

    # The property name may be loosely or strictly matched; we don't know yet.
    # But both types use lower-case.
    $prop = lc $prop;

    # It is loosely matched if its lower case isn't known to be strict.
    my $list_ref;
    if (! exists $utf8::stricter_to_file_of{$prop}) {
        my $loose = utf8::_loose_name($prop);

        # There is a hash that converts from any loose name to its standard
        # form, mapping all synonyms for a  name to one name that can be used
        # as a key into another hash.  The whole concept is for memory
        # savings, as the second hash doesn't have to have all the
        # combinations.  Actually, there are two hashes that do the
        # converstion.  One is used in utf8_heavy.pl (stored in Heavy.pl) for
        # looking up properties matchable in regexes.  This function needs to
        # access string properties, which aren't available in regexes, so a
        # second conversion hash is made for them (stored in UCD.pl).  Look in
        # the string one now, as the rest can have an optional 'is' prefix,
        # which these don't.
        if (exists $string_property_loose_to_name{$loose}) {

            # Convert to its standard loose name.
            $prop = $string_property_loose_to_name{$loose};
        }
        else {
            my $retrying = 0;   # bool.  ? Has an initial 'is' been stripped
        RETRY:
            if (exists $utf8::loose_property_name_of{$loose}
                && (! $retrying
                    || ! exists $ambiguous_names{$loose}))
            {
                # Found an entry giving the standard form.  We don't get here
                # (in the test above) when we've stripped off an
                # 'is' and the result is an ambiguous name.  That is because
                # these are official Unicode properties (though Perl can have
                # an optional 'is' prefix meaning the official property), and
                # all ambiguous cases involve a Perl single-form extension
                # for the gc, script, or block properties, and the stripped
                # 'is' means that they mean one of those, and not one of
                # these
                $prop = $utf8::loose_property_name_of{$loose};
            }
            elsif (exists $loose_perlprop_to_name{$loose}) {

                # This hash is specifically for this function to list Perl
                # extensions that aren't in the earlier hashes.  If there is
                # only one element, the short and long names are identical.
                # Otherwise the form is already in the same form as
                # %prop_aliases, which is handled at the end of the function.
                $list_ref = $loose_perlprop_to_name{$loose};
                if (@$list_ref == 1) {
                    my @list = ($list_ref->[0], $list_ref->[0]);
                    $list_ref = \@list;
                }
            }
            elsif (! exists $utf8::loose_to_file_of{$loose}) {

                # loose_to_file_of is a complete list of loose names.  If not
                # there, the input is unknown.
                return;
            }
            else {

                # Here we found the name but not its aliases, so it has to
                # exist.  This means it must be one of the Perl single-form
                # extensions.  First see if it is for a property-value
                # combination in one of the following properties.
                my @list;
                foreach my $property ("gc", "script") {
                    @list = prop_value_aliases($property, $loose);
                    last if @list;
                }
                if (@list) {

                    # Here, it is one of those property-value combination
                    # single-form synonyms.  There are ambiguities with some
                    # of these.  Check against the list for these, and adjust
                    # if necessary.
                    for my $i (0 .. @list -1) {
                        if (exists $ambiguous_names
                                   {utf8::_loose_name(lc $list[$i])})
                        {
                            # The ambiguity is resolved by toggling whether or
                            # not it has an 'is' prefix
                            $list[$i] =~ s/^Is_// or $list[$i] =~ s/^/Is_/;
                        }
                    }
                    return @list;
                }

                # Here, it wasn't one of the gc or script single-form
                # extensions.  It could be a block property single-form
                # extension.  An 'in' prefix definitely means that, and should
                # be looked up without the prefix.
                my $began_with_in = $loose =~ s/^in//;
                @list = prop_value_aliases("block", $loose);
                if (@list) {
                    map { $_ =~ s/^/In_/ } @list;
                    return @list;
                }

                # Here still haven't found it.  The last opportunity for it
                # being valid is only if it began with 'is'.  We retry without
                # the 'is', setting a flag to that effect so that we don't
                # accept things that begin with 'isis...'
                if (! $retrying && ! $began_with_in && $loose =~ s/^is//) {
                    $retrying = 1;
                    goto RETRY;
                }

                # Here, didn't find it.  Since it was in %loose_to_file_of, we
                # should have been able to find it.
                carp __PACKAGE__, "::prop_aliases: Unexpectedly could not find '$prop'.  Send bug report to perlbug\@perl.org";
                return;
            }
        }
    }

    if (! $list_ref) {
        # Here, we have set $prop to a standard form name of the input.  Look
        # it up in the structure created by mktables for this purpose, which
        # contains both strict and loosely matched properties.  Avoid
        # autovivifying.
        $list_ref = $prop_aliases{$prop} if exists $prop_aliases{$prop};
        return unless $list_ref;
    }

    # The full name is in element 1.
    return $list_ref->[1] unless wantarray;

    return @{dclone $list_ref};
}

=pod

=head2 B<prop_value_aliases()>

    use Unicode::UCD 'prop_value_aliases';

    my ($short_name, $full_name, @other_names)
                                   = prop_value_aliases("Gc", "Punct");
    my $same_full_name = prop_value_aliases("Gc", "P");   # Scalar cntxt
    my ($same_short_name) = prop_value_aliases("Gc", "P"); # gets 0th
                                                           # element
    print "The full name is $full_name\n";
    print "The short name is $short_name\n";
    print "The other aliases are: ", join(", ", @other_names), "\n";

    prints:
    The full name is Punctuation
    The short name is P
    The other aliases are: Punct

Some Unicode properties have a restricted set of legal values.  For example,
all binary properties are restricted to just C<true> or C<false>; and there
are only a few dozen possible General Categories.

For such properties, there are usually several synonyms for each possible
value.  For example, in binary properties, I<truth> can be represented by any of
the strings "Y", "Yes", "T", or "True"; and the General Category
"Punctuation" by that string, or "Punct", or simply "P".

Like property names, there is typically at least a short name for each such
property-value, and a long name.  If you know any name of the property-value,
you can use C<prop_value_aliases>() to get the long name (when called in
scalar context), or a list of all the names, with the short name in the 0th
element, the long name in the next element, and any other synonyms in the
remaining elements, in no particular order, except that any all-numeric
synonyms will be last.

The long name is returned in a form nicely capitalized, suitable for printing.

Case, white space, hyphens, and underscores are ignored in the input parameters
(except for the trailing underscore in the old-form grandfathered-in general
category property value C<"L_">, which is better written as C<"LC">).

If either name is unknown, C<undef> is returned.  Note that Perl typically
recognizes property names in regular expressions with an optional C<"Is_>"
(with or without the underscore) prefixed to them, such as C<\p{isgc=punct}>.
This function does not recognize those in the property parameter, returning
C<undef>.

If called with a property that doesn't have synonyms for its values, it
returns the input value, possibly normalized with capitalization and
underscores.

For the block property, new-style block names are returned (see
L</Old-style versus new-style block names>).

To find the synonyms for single-forms, such as C<\p{Any}>, use
L</prop_aliases()> instead.

C<prop_value_aliases> does not know about any user-defined properties, and
will return C<undef> if called with one of those.

=cut

# These are created by mktables for this routine and stored in unicore/UCD.pl
# where their structures are described.
our %loose_to_standard_value;
our %prop_value_aliases;

sub prop_value_aliases ($$) {
    my ($prop, $value) = @_;
    return unless defined $prop && defined $value;

    require "unicore/UCD.pl";
    require "utf8_heavy.pl";

    # Find the property name synonym that's used as the key in other hashes,
    # which is element 0 in the returned list.
    ($prop) = prop_aliases($prop);
    return if ! $prop;
    $prop = utf8::_loose_name(lc $prop);

    # Here is a legal property, but the hash below (created by mktables for
    # this purpose) only knows about the properties that have a very finite
    # number of potential values, that is not ones whose value could be
    # anything, like most (if not all) string properties.  These don't have
    # synonyms anyway.  Simply return the input.  For example, there is no
    # synonym for ('Uppercase_Mapping', A').
    return $value if ! exists $prop_value_aliases{$prop};

    # The value name may be loosely or strictly matched; we don't know yet.
    # But both types use lower-case.
    $value = lc $value;

    # If the name isn't found under loose matching, it certainly won't be
    # found under strict
    my $loose_value = utf8::_loose_name($value);
    return unless exists $loose_to_standard_value{"$prop=$loose_value"};

    # Similarly if the combination under loose matching doesn't exist, it
    # won't exist under strict.
    my $standard_value = $loose_to_standard_value{"$prop=$loose_value"};
    return unless exists $prop_value_aliases{$prop}{$standard_value};

    # Here we did find a combination under loose matching rules.  But it could
    # be that is a strict property match that shouldn't have matched.
    # %prop_value_aliases is set up so that the strict matches will appear as
    # if they were in loose form.  Thus, if the non-loose version is legal,
    # we're ok, can skip the further check.
    if (! exists $utf8::stricter_to_file_of{"$prop=$value"}

        # We're also ok and skip the further check if value loosely matches.
        # mktables has verified that no strict name under loose rules maps to
        # an existing loose name.  This code relies on the very limited
        # circumstances that strict names can be here.  Strict name matching
        # happens under two conditions:
        # 1) when the name begins with an underscore.  But this function
        #    doesn't accept those, and %prop_value_aliases doesn't have
        #    them.
        # 2) When the values are numeric, in which case we need to look
        #    further, but their squeezed-out loose values will be in
        #    %stricter_to_file_of
        && exists $utf8::stricter_to_file_of{"$prop=$loose_value"})
    {
        # The only thing that's legal loosely under strict is that can have an
        # underscore between digit pairs XXX
        while ($value =~ s/(\d)_(\d)/$1$2/g) {}
        return unless exists $utf8::stricter_to_file_of{"$prop=$value"};
    }

    # Here, we know that the combination exists.  Return it.
    my $list_ref = $prop_value_aliases{$prop}{$standard_value};
    if (@$list_ref > 1) {
        # The full name is in element 1.
        return $list_ref->[1] unless wantarray;

        return @{dclone $list_ref};
    }

    return $list_ref->[0] unless wantarray;

    # Only 1 element means that it repeats
    return ( $list_ref->[0], $list_ref->[0] );
}

# All 1 bits is the largest possible UV.
$Unicode::UCD::MAX_CP = ~0;

=pod

=head2 B<prop_invlist()>

C<prop_invlist> returns an inversion list (described below) that defines all the
code points for the binary Unicode property (or "property=value" pair) given
by the input parameter string:

 use feature 'say';
 use Unicode::UCD 'prop_invlist';
 say join ", ", prop_invlist("Any");

 prints:
 0, 1114112

An empty list is returned if the input is unknown; the number of elements in
the list is returned if called in scalar context.

L<perluniprops|perluniprops/Properties accessible through \p{} and \P{}> gives
the list of properties that this function accepts, as well as all the possible
forms for them (including with the optional "Is_" prefixes).  (Except this
function doesn't accept any Perl-internal properties, some of which are listed
there.) This function uses the same loose or tighter matching rules for
resolving the input property's name as is done for regular expressions.  These
are also specified in L<perluniprops|perluniprops/Properties accessible
through \p{} and \P{}>.  Examples of using the "property=value" form are:

 say join ", ", prop_invlist("Script=Shavian");

 prints:
 66640, 66688

 say join ", ", prop_invlist("ASCII_Hex_Digit=No");

 prints:
 0, 48, 58, 65, 71, 97, 103

 say join ", ", prop_invlist("ASCII_Hex_Digit=Yes");

 prints:
 48, 58, 65, 71, 97, 103

Inversion lists are a compact way of specifying Unicode property-value
definitions.  The 0th item in the list is the lowest code point that has the
property-value.  The next item (item [1]) is the lowest code point beyond that
one that does NOT have the property-value.  And the next item beyond that
([2]) is the lowest code point beyond that one that does have the
property-value, and so on.  Put another way, each element in the list gives
the beginning of a range that has the property-value (for even numbered
elements), or doesn't have the property-value (for odd numbered elements).
The name for this data structure stems from the fact that each element in the
list toggles (or inverts) whether the corresponding range is or isn't on the
list.

In the final example above, the first ASCII Hex digit is code point 48, the
character "0", and all code points from it through 57 (a "9") are ASCII hex
digits.  Code points 58 through 64 aren't, but 65 (an "A") through 70 (an "F")
are, as are 97 ("a") through 102 ("f").  103 starts a range of code points
that aren't ASCII hex digits.  That range extends to infinity, which on your
computer can be found in the variable C<$Unicode::UCD::MAX_CP>.  (This
variable is as close to infinity as Perl can get on your platform, and may be
too high for some operations to work; you may wish to use a smaller number for
your purposes.)

Note that the inversion lists returned by this function can possibly include
non-Unicode code points, that is anything above 0x10FFFF.  This is in
contrast to Perl regular expression matches on those code points, in which a
non-Unicode code point always fails to match.  For example, both of these have
the same result:

 chr(0x110000) =~ \p{ASCII_Hex_Digit=True}      # Fails.
 chr(0x110000) =~ \p{ASCII_Hex_Digit=False}     # Fails!

And both raise a warning that a Unicode property is being used on a
non-Unicode code point.  It is arguable as to which is the correct thing to do
here.  This function has chosen the way opposite to the Perl regular
expression behavior.  This allows you to easily flip to to the Perl regular
expression way (for you to go in the other direction would be far harder).
Simply add 0x110000 at the end of the non-empty returned list if it isn't
already that value; and pop that value if it is; like:

 my @list = prop_invlist("foo");
 if (@list) {
     if ($list[-1] == 0x110000) {
         pop @list;  # Defeat the turning on for above Unicode
     }
     else {
         push @list, 0x110000; # Turn off for above Unicode
     }
 }

It is a simple matter to expand out an inversion list to a full list of all
code points that have the property-value:

 my @invlist = prop_invlist($property_name);
 die "empty" unless @invlist;
 my @full_list;
 for (my $i = 0; $i < @invlist; $i += 2) {
    my $upper = ($i + 1) < @invlist
                ? $invlist[$i+1] - 1      # In range
                : $Unicode::UCD::MAX_CP;  # To infinity.  You may want
                                          # to stop much much earlier;
                                          # going this high may expose
                                          # perl deficiencies with very
                                          # large numbers.
    for my $j ($invlist[$i] .. $upper) {
        push @full_list, $j;
    }
 }

C<prop_invlist> does not know about any user-defined nor Perl internal-only
properties, and will return C<undef> if called with one of those.

=cut

# User-defined properties could be handled with some changes to utf8_heavy.pl;
# and implementing here of dealing with EXTRAS.  If done, consideration should
# be given to the fact that the user subroutine could return different results
# with each call; security issues need to be thought about.

# These are created by mktables for this routine and stored in unicore/UCD.pl
# where their structures are described.
our %loose_defaults;
our $MAX_UNICODE_CODEPOINT;

sub prop_invlist ($) {
    my $prop = $_[0];
    return if ! defined $prop;

    require "utf8_heavy.pl";

    # Warnings for these are only for regexes, so not applicable to us
    no warnings 'deprecated';

    # Get the swash definition of the property-value.
    my $swash = utf8::SWASHNEW(__PACKAGE__, $prop, undef, 1, 0);

    # Fail if not found, or isn't a boolean property-value, or is a
    # user-defined property, or is internal-only.
    return if ! $swash
              || ref $swash eq ""
              || $swash->{'BITS'} != 1
              || $swash->{'USER_DEFINED'}
              || $prop =~ /^\s*_/;

    if ($swash->{'EXTRAS'}) {
        carp __PACKAGE__, "::prop_invlist: swash returned for $prop unexpectedly has EXTRAS magic";
        return;
    }
    if ($swash->{'SPECIALS'}) {
        carp __PACKAGE__, "::prop_invlist: swash returned for $prop unexpectedly has SPECIALS magic";
        return;
    }

    my @invlist;

    # The input lines look like:
    # 0041\t005A   # [26]
    # 005F

    # Split into lines, stripped of trailing comments
    foreach my $range (split "\n",
                            $swash->{'LIST'} =~ s/ \s* (?: \# .* )? $ //xmgr)
    {
        # And find the beginning and end of the range on the line
        my ($hex_begin, $hex_end) = split "\t", $range;
        my $begin = hex $hex_begin;

        # Add the beginning of the range
        push @invlist, $begin;

        if (defined $hex_end) { # The next item starts with the code point 1
                                # beyond the end of the range.
            push @invlist, hex($hex_end) + 1;
        }
        else {  # No end of range, is a single code point.
            push @invlist, $begin + 1;
        }
    }

    require "unicore/UCD.pl";
    my $FIRST_NON_UNICODE = $MAX_UNICODE_CODEPOINT + 1;

    # Could need to be inverted: add or subtract a 0 at the beginning of the
    # list.  And to keep it from matching non-Unicode, add or subtract the
    # first non-unicode code point.
    if ($swash->{'INVERT_IT'}) {
        if (@invlist && $invlist[0] == 0) {
            shift @invlist;
        }
        else {
            unshift @invlist, 0;
        }
        if (@invlist && $invlist[-1] == $FIRST_NON_UNICODE) {
            pop @invlist;
        }
        else {
            push @invlist, $FIRST_NON_UNICODE;
        }
    }

    # Here, the list is set up to include only Unicode code points.  But, if
    # the table is the default one for the property, it should contain all
    # non-Unicode code points.  First calculate the loose name for the
    # property.  This is done even for strict-name properties, as the data
    # structure that mktables generates for us is set up so that we don't have
    # to worry about that.  The property-value needs to be split if compound,
    # as the loose rules need to be independently calculated on each part.  We
    # know that it is syntactically valid, or SWASHNEW would have failed.

    $prop = lc $prop;
    my ($prop_only, $table) = split /\s*[:=]\s*/, $prop;
    if ($table) {

        # May have optional prefixed 'is'
        $prop = utf8::_loose_name($prop_only) =~ s/^is//r;
        $prop = $utf8::loose_property_name_of{$prop};
        $prop .= "=" . utf8::_loose_name($table);
    }
    else {
        $prop = utf8::_loose_name($prop);
    }
    if (exists $loose_defaults{$prop}) {

        # Here, is the default table.  If a range ended with 10ffff, instead
        # continue that range to infinity, by popping the 110000; otherwise,
        # add the range from 11000 to infinity
        if (! @invlist || $invlist[-1] != $FIRST_NON_UNICODE) {
            push @invlist, $FIRST_NON_UNICODE;
        }
        else {
            pop @invlist;
        }
    }

    return @invlist;
}

=head2 Unicode::UCD::UnicodeVersion

This returns the version of the Unicode Character Database, in other words, the
version of the Unicode standard the database implements.  The version is a
string of numbers delimited by dots (C<'.'>).

=cut

my $UNICODEVERSION;

sub UnicodeVersion {
    unless (defined $UNICODEVERSION) {
	openunicode(\$VERSIONFH, "version");
	chomp($UNICODEVERSION = <$VERSIONFH>);
	close($VERSIONFH);
	croak __PACKAGE__, "::VERSION: strange version '$UNICODEVERSION'"
	    unless $UNICODEVERSION =~ /^\d+(?:\.\d+)+$/;
    }
    return $UNICODEVERSION;
}

=head2 B<Blocks versus Scripts>

The difference between a block and a script is that scripts are closer
to the linguistic notion of a set of code points required to present
languages, while block is more of an artifact of the Unicode code point
numbering and separation into blocks of (mostly) 256 code points.

For example the Latin B<script> is spread over several B<blocks>, such
as C<Basic Latin>, C<Latin 1 Supplement>, C<Latin Extended-A>, and
C<Latin Extended-B>.  On the other hand, the Latin script does not
contain all the characters of the C<Basic Latin> block (also known as
ASCII): it includes only the letters, and not, for example, the digits
or the punctuation.

For blocks see L<http://www.unicode.org/Public/UNIDATA/Blocks.txt>

For scripts see UTR #24: L<http://www.unicode.org/unicode/reports/tr24/>

=head2 B<Matching Scripts and Blocks>

Scripts are matched with the regular-expression construct
C<\p{...}> (e.g. C<\p{Tibetan}> matches characters of the Tibetan script),
while C<\p{Blk=...}> is used for blocks (e.g. C<\p{Blk=Tibetan}> matches
any of the 256 code points in the Tibetan block).

=head2 Old-style versus new-style block names

Unicode publishes the names of blocks in two different styles, though the two
are equivalent under Unicode's loose matching rules.

The original style uses blanks and hyphens in the block names (except for
C<No_Block>), like so:

 Miscellaneous Mathematical Symbols-B

The newer style replaces these with underscores, like this:

 Miscellaneous_Mathematical_Symbols_B

This newer style is consistent with the values of other Unicode properties.
To preserve backward compatibility, all the functions in Unicode::UCD that
return block names (except one) return the old-style ones.  That one function,
L</prop_value_aliases()> can be used to convert from old-style to new-style:

 my $new_style = prop_values_aliases("block", $old_style);

Perl also has single-form extensions that refer to blocks, C<In_Cyrillic>,
meaning C<Block=Cyrillic>.  These have always been written in the new style.

To convert from new-style to old-style, follow this recipe:

 $old_style = charblock((prop_invlist("block=$new_style"))[0]);

(which finds the range of code points in the block using C<prop_invlist>,
gets the lower end of the range (0th element) and then looks up the old name
for its block using C<charblock>).

=head1 BUGS

Does not yet support EBCDIC platforms.

=head1 AUTHOR

Jarkko Hietaniemi.  Now maintained by perl5 porters.

=cut

1;
