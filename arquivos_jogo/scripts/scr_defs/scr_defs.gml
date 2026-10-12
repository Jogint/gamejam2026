enum GAME_STATE {
    map,
    card,
    run_end,
}

enum STAT {
    strength,
    perception,
    technique,
    count,
}

enum FACTION {
    faction_1,
    faction_2,
    faction_3,
    faction_4,
    count,
}

enum CARD_TYPE {
    event,
    hostile,
    friendly,
}

enum CARD_ORIGIN {
    neutral,
    faction_1,
    faction_2,
    faction_3,
    faction_4,
}

enum CARD_CHOICE {
    first,
    second,
    third,
    skip,
    count,
}