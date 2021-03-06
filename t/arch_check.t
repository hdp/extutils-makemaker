#!/usr/bin/perl -w

use strict;
use lib 't/lib';

use TieOut;
use Test::More 'no_plan';

use Config;
use ExtUtils::MakeMaker;

ok( my $stdout = tie *STDOUT, 'TieOut' );    

# Create a normalized MM object to test with
my $mm = bless {}, "MM";
$mm->{PERL_SRC} = 0;
$mm->{UNINSTALLED_PERL} = 0;

my $rel2abs = sub { $mm->rel2abs($mm->catfile(@_)) };

ok $mm->arch_check(
    $rel2abs->(qw(. t testdata reallylongdirectoryname arch1 Config.pm)),
    $rel2abs->(qw(. t testdata reallylongdirectoryname arch1 Config.pm)),
);


# Different architecures.
{
    ok !$mm->arch_check(
        $rel2abs->(qw(. t testdata reallylongdirectoryname arch1 Config.pm)),
        $rel2abs->(qw(. t testdata reallylongdirectoryname arch2 Config.pm)),
    );

    like $stdout->read, qr{\Q
Your perl and your Config.pm seem to have different ideas about the 
architecture they are running on.
Perl thinks: [arch1]
Config says: [$Config{archname}]
This may or may not cause problems. Please check your installation of perl 
if you have problems building this extension.
};

}


# PERL_SRC is set, no check is done
{
    local $mm->{PERL_SRC} = 1;
    ok $mm->arch_check(
      $rel2abs->(qw(. t testdata reallylongdirectoryname arch1 Config.pm)),
      $rel2abs->(qw(. t testdata reallylongdirectoryname arch2 Config.pm)),
    );

    is $stdout->read, '';
}


# UNINSTALLED_PERL is set, no message is sent
{
    local $mm->{UNINSTALLED_PERL} = 1;
    ok !$mm->arch_check(
      $rel2abs->(qw(. t testdata reallylongdirectoryname arch1 Config.pm)),
      $rel2abs->(qw(. t testdata reallylongdirectoryname arch2 Config.pm)),
    );

    like $stdout->read, qr{^Have .*\nWant .*$};
}
