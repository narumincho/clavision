module Data exposing (Class, ClassDict, ClassId, Location, RoomId, classDictFromApi, classGet, locationGet, weekToString)

import Api.Enum.Week
import Api.Object
import Api.Object.Class
import Api.Object.Room
import Api.Query
import Dict
import Graphql.Operation
import Graphql.SelectionSet


type ClassId
    = ClassId String


type RoomId
    = RoomId String


type ClassDict
    = ClassDict (Dict.Dict String Class)


type Class
    = Class
        { name : String
        , teacher : String
        , room : RoomId
        }


type RoomDict
    = RoomDict (Dict.Dict String Location)


type Location
    = Location
        { name : String
        , points : List Int
        , a : Api.Object.Class
        }


weekToString : Api.Enum.Week.Week -> String
weekToString weekday =
    case weekday of
        Api.Enum.Week.Monday ->
            "月"

        Api.Enum.Week.Tuesday ->
            "火"

        Api.Enum.Week.Wednesday ->
            "水"

        Api.Enum.Week.Thursday ->
            "木"

        Api.Enum.Week.Friday ->
            "金"

        Api.Enum.Week.Saturday ->
            "土"


classGet : ClassId -> ClassDict -> Maybe Class
classGet (ClassId id) (ClassDict dict) =
    dict |> Dict.get id


locationGet : RoomId -> RoomDict -> Maybe Location
locationGet (RoomId id) (RoomDict dict) =
    dict |> Dict.get id


classDictFromApi : Graphql.SelectionSet.SelectionSet ClassDict Graphql.Operation.RootQuery
classDictFromApi =
    Api.Query.classAll
        (Graphql.SelectionSet.map4
            (\id name teacher room ->
                ( id
                , Class
                    { name = name
                    , teacher = teacher
                    , room = RoomId room
                    }
                )
            )
            Api.Object.Class.id
            Api.Object.Class.name
            Api.Object.Class.teacher
            (Api.Object.Class.room
                Api.Object.Room.id
            )
        )
        |> Graphql.SelectionSet.map
            (Dict.fromList >> ClassDict)
