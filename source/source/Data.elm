module Data exposing (Class, ClassId, Location, LocationId, Weekday(..), weekdayAll, weekdayToString)


type ClassId
    = ClassId String


type LocationId
    = LocationId String


type Class
    = Class
        { name : String
        , teacher : String
        , location : Location
        }


type Location
    = Location
        { name : String
        , points : List Int
        }


type Weekday
    = Monday
    | Tuesday
    | Wednesday
    | Thursday
    | Friday


weekdayAll : List Weekday
weekdayAll =
    [ Monday
    , Tuesday
    , Wednesday
    , Thursday
    , Friday
    ]


weekdayToString : Weekday -> String
weekdayToString weekday =
    case weekday of
        Monday ->
            "月"

        Tuesday ->
            "火"

        Wednesday ->
            "水"

        Thursday ->
            "木"

        Friday ->
            "金"
