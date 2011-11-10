use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'CollectiveIntelligence::Similarity',
    AUTHOR              => q{Steven  William Hirsch <nexxus.six@gmail,com>},
    VERSION_FROM        => 'lib/CollectiveIntelligence/Similarity.pm',
    ABSTRACT_FROM       => 'lib/CollectiveIntelligence/Similarity.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'CollectiveIntelligence-Similarity-*' },
);
