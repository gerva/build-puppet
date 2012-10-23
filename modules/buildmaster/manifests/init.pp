# This module is responsible for installing and running buildbot-slave on all
# slaves.  Do not be confused by the name 'buildslave' - this applies to all
# slaves used in releng -- build, test, whatever.
#
# See:
#  - https://wiki.mozilla.org/ReleaseEngineering/Buildslave_Startup_Process
#  - https://wiki.mozilla.org/ReleaseEngineering/Buildslave_Versions
class buildslave {
    anchor {
        'buildslave::begin': ;
        'buildslave::end': ;
    }

    Anchor['buildslave::begin'] ->
    class {
        'buildslave::install': ;
    } -> Anchor['buildslave::end']

    Anchor['buildslave::begin'] ->
    class {
        'buildslave::startup': ;
    } -> Anchor['buildslave::end']
}
