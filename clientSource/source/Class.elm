module Class exposing (Class)


type Class
    = Class
        { id : ClassId
        , name : String
        , teacher : String
        , location : Location
        }


type ClassId
    = ClassId String


type Location
    = Location
        { id : String
        , name : String
        }


type LocationId
    = LocationId String
