class buildmaster {
    anchor {
        'buildmaster::begin': ;
        'buildmaster::end': ;
    }

    Anchor['buildmaster::begin'] ->
    class {
        'buildmaster::install': ;
    } -> Anchor['buildmaster::end']

    Anchor['buildmaster::begin'] ->
    class {
        'buildmaster::startup': ;
    } -> Anchor['buildmaster::end']
}
