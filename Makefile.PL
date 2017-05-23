use inc::Module::Install;

RTx     'RT-Extension-CustomiseMenus';
license 'gplv2';
repository 'https://github.com/wheldom01/rt-extension-customisemenus';

requires_rt '4.4.0';
rt_too_new '4.6.0';

use Config;

my ($lp) = ($INC{'RT.pm'} =~ /^(.*)[\\\/]/);
my $lib_path = join( ' ', "$RT::LocalPath/lib", $lp );
my $secure_perl_path = $Config{perlpath};
if ($^O ne 'VMS') {
    $secure_perl_path .= $Config{_exe}
        unless $secure_perl_path =~ m/$Config{_exe}$/i;
}

substitute(
    {
        RT_LIB_PATH  => $lib_path,
        PERL         => $ENV{PERL} || $secure_perl_path,
    },
    {
        sufix => '.in'
    },
    'lib/RT/Extension/CustomiseMenus/Test.pm',
);

auto_install();
sign;
WriteAll;
