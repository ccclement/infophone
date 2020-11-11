use Modern::Perl;
use Mojo::DOM;
use Mojo::UserAgent;
use Digest::MD5 qw(md5_hex);
use JSON qw(decode_json to_json);
use YAML;
use List::Util qw( uniq );
use Text::CSV_XS qw( csv );
use IO::All;
use Getopt::Long::Descriptive;
use File::Slurp qw( write_file );
use Data::Printer;

my $DEBUG = 0;

#  description options
my ($opt, $usage) = describe_options(
  'perl %c %o <some-arg>',
  [],
  [ 'number|n=s' , "Phone number ex: +33699999999"   ],
  [ 'input|i=s'  , "File containing the numbers. One number per line." ],
  [],
  [ 'output|o=s' , "Output file. STDOUT if omitted"  ],
  [ 'type|t=s'   , "output format (json,yaml) default: YAML", {default => 'yaml'}],
  [],
  [ 'help|h'     , "Affiche cette aide", { shortcircuit => 1 } ],
);

# test options
print($usage->text), exit if $opt->help;
if ( not defined $opt->{number} and not defined $opt->{input} )
{
    say "--number ... or --input ... not found.";
    print($usage->text);
    exit 0;
}
p $opt if $DEBUG ;

# list numbers
my @lst_nu = ();
push @lst_nu, $opt->{number} if defined $opt->{number};
if ( defined $opt->{input} )
{
    if ( -r $opt->{input} )
    {
        push @lst_nu, (io->file($opt->{input})->chomp->slurp);
    }
    else
    {
        say "input file error read. (".$opt->{input}.")";
        exit 0 if (scalar(@lst_nu) == 0);
    }
}
p @lst_nu if $DEBUG;

# get api key
my $ua = Mojo::UserAgent->new;
my $url_base = 'https://numverify.com';
my $html = $ua->get($url_base => {Accept => '*/*'})
              ->result
              ->body;
my $dom = Mojo::DOM->new($html);
my $api_key = $dom->find( 'input[name="scl_request_secret"]')
                  ->map(attr => 'value')
                  ->[0];
p $api_key if $DEBUG;

# get infos phonenumbers
my %info_phones = ();

foreach my $i (uniq @lst_nu)
{
   $i =~ s{[_\W+]}{}g;
   my $secret_key = md5_hex($i.$api_key);
   my $url_final = $url_base
              . '/php_helper_scripts/phone_api.php?secret_key='
              . $secret_key
              . '&number='
              . $i
              ;
   my $req = $ua->get($url_final => {Accept => '*/*'})
              ->result
              ->body;
   my $r = decode_json $req;
   $info_phones{$i} = $r;
}
p %info_phones if $DEBUG;

# return data
my $return = ();
if ($opt->{type} =~ /json/i)
{
    $return = to_json( \%info_phones );
}
else
{ # default YAML
    $return = Dump( %info_phones );
}

if ( defined $opt->{output} )
{
    write_file( $opt->{output}, $return );
}
else
{
    say $return;
}

exit 0;

__END__
