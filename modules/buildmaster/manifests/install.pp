# this class simply invokes the resource type with the production version
class buildmaster::install {
    anchor {
        'buildmaster::install::begin': ;
        'buildmaster::install::end': ;
    }

    # TODO: include the package::python classes required here

    Anchor['buildmaster::install::begin'] ->
    buildmaster::install::version {
        # and the most recent version, kept around for posterity and as
        # a reminder to ensure it's absent when there's a *new* most recent
        # version.
        #"0.8.4-pre-moz1":
        #    active => false;

        "0.8.4-pre-moz2":
            active => true;
    } -> Anchor['buildmaster::install::end']
}
