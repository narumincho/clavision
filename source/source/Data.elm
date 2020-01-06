module Data exposing
    ( Area
    , ClassData
    , ClassId
    , ClassOfDay
    , ClassOfWeek
    , ClassSelect(..)
    , Dictionary
    , Floor
    , RoomData
    , RoomId
    , User
    , WeekAndTime
    , building1_1
    , classIdToString
    , classOfDayGetClassSelect
    , classOfWeekGetClassOfDay
    , classSelectGetAfter
    , classSelectGetBefore
    , clockTimeRangeToString
    , dictionaryQuery
    , getClass
    , getClassFromWeekAndTime
    , setClassQuery
    , timeToClockTimeRange
    , timeToInt
    , userGetImageUrl
    , userGetName
    , userGetTimeTableClass
    , userMapTimeTableClass
    , userQuery
    , weekAndTimeToString
    , weekToString
    )

import Api.Enum.Time
import Api.Enum.Week
import Api.Mutation
import Api.Object
import Api.Object.Class
import Api.Object.ClassOfDay
import Api.Object.ClassOfWeek
import Api.Object.Room
import Api.Object.User
import Api.Object.WeekAndTime
import Api.Query
import Api.Scalar
import Clock
import Dict
import Graphql.Operation
import Graphql.OptionalArgument
import Graphql.SelectionSet
import Time


type ClassId
    = ClassId String


classIdToString : ClassId -> String
classIdToString (ClassId string) =
    string


type RoomId
    = RoomId String


type Dictionary
    = Dictionary
        { class :
            Dict.Dict String { name : String, teacher : String, room : RoomId, weekAndTime : WeekAndTime }
        , room :
            Dict.Dict String { name : String }
        }


type alias ClassData =
    { id : ClassId
    , name : String
    , teacher : String
    , room : RoomData
    , weekAndTime : WeekAndTime
    }


type alias WeekAndTime =
    { week : Api.Enum.Week.Week
    , time : Api.Enum.Time.Time
    }


type alias RoomData =
    { id : RoomId
    , name : String
    }


type User
    = User
        { name : String
        , imageFileHash : String
        , classInTimeTable : ClassOfWeek
        }


type ClassOfWeek
    = ClassOfWeek
        { monday : ClassOfDay
        , tuesday : ClassOfDay
        , wednesday : ClassOfDay
        , thursday : ClassOfDay
        , friday : ClassOfDay
        , saturday : ClassOfDay
        }


classOfWeekGetClassOfDay : Api.Enum.Week.Week -> ClassOfWeek -> ClassOfDay
classOfWeekGetClassOfDay week (ClassOfWeek record) =
    case week of
        Api.Enum.Week.Monday ->
            record.monday

        Api.Enum.Week.Tuesday ->
            record.tuesday

        Api.Enum.Week.Wednesday ->
            record.wednesday

        Api.Enum.Week.Thursday ->
            record.thursday

        Api.Enum.Week.Friday ->
            record.friday

        Api.Enum.Week.Saturday ->
            record.saturday


classOfWeekMap : Api.Enum.Week.Week -> (ClassOfDay -> ClassOfDay) -> ClassOfWeek -> ClassOfWeek
classOfWeekMap week function (ClassOfWeek record) =
    ClassOfWeek
        (case week of
            Api.Enum.Week.Monday ->
                { record | monday = function record.monday }

            Api.Enum.Week.Tuesday ->
                { record | tuesday = function record.tuesday }

            Api.Enum.Week.Wednesday ->
                { record | wednesday = function record.wednesday }

            Api.Enum.Week.Thursday ->
                { record | thursday = function record.thursday }

            Api.Enum.Week.Friday ->
                { record | friday = function record.friday }

            Api.Enum.Week.Saturday ->
                { record | saturday = function record.saturday }
        )


type ClassOfDay
    = ClassOfDay
        { class1 : ClassSelect
        , class2 : ClassSelect
        , class3 : ClassSelect
        , class4 : ClassSelect
        , class5 : ClassSelect
        }


type ClassSelect
    = ClassNoSending (Maybe ClassId)
    | ClassSending { before : Maybe ClassId, after : Maybe ClassId }


classSelectGetBefore : ClassSelect -> Maybe ClassId
classSelectGetBefore classSelect =
    case classSelect of
        ClassNoSending classId ->
            classId

        ClassSending { before } ->
            before


classSelectGetAfter : ClassSelect -> Maybe ClassId
classSelectGetAfter classSelect =
    case classSelect of
        ClassNoSending classId ->
            classId

        ClassSending { after } ->
            after


classOfDayGetClassSelect : Api.Enum.Time.Time -> ClassOfDay -> ClassSelect
classOfDayGetClassSelect time (ClassOfDay record) =
    case time of
        Api.Enum.Time.Class1 ->
            record.class1

        Api.Enum.Time.Class2 ->
            record.class2

        Api.Enum.Time.Class3 ->
            record.class3

        Api.Enum.Time.Class4 ->
            record.class4

        Api.Enum.Time.Class5 ->
            record.class5


classOfDayMap : Api.Enum.Time.Time -> (ClassSelect -> ClassSelect) -> ClassOfDay -> ClassOfDay
classOfDayMap time function (ClassOfDay record) =
    ClassOfDay
        (case time of
            Api.Enum.Time.Class1 ->
                { record | class1 = function record.class1 }

            Api.Enum.Time.Class2 ->
                { record | class2 = function record.class3 }

            Api.Enum.Time.Class3 ->
                { record | class3 = function record.class3 }

            Api.Enum.Time.Class4 ->
                { record | class4 = function record.class4 }

            Api.Enum.Time.Class5 ->
                { record | class5 = function record.class5 }
        )


userGetName : User -> String
userGetName (User { name }) =
    name


userGetImageUrl : User -> String
userGetImageUrl (User { imageFileHash }) =
    "https://us-central1-clavision.cloudfunctions.net/file/" ++ imageFileHash


userGetTimeTableClass : User -> ClassOfWeek
userGetTimeTableClass (User { classInTimeTable }) =
    classInTimeTable


userMapTimeTableClass : WeekAndTime -> (ClassSelect -> ClassSelect) -> User -> User
userMapTimeTableClass weekAndTime function (User record) =
    User
        { record
            | classInTimeTable =
                classOfWeekMap
                    weekAndTime.week
                    (classOfDayMap weekAndTime.time function)
                    record.classInTimeTable
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


weekAndTimeToString : { week : Api.Enum.Week.Week, time : Api.Enum.Time.Time } -> String
weekAndTimeToString { week, time } =
    weekToString week ++ "曜日 " ++ (time |> timeToInt |> String.fromInt) ++ "限目"


timeToInt : Api.Enum.Time.Time -> Int
timeToInt time =
    case time of
        Api.Enum.Time.Class1 ->
            1

        Api.Enum.Time.Class2 ->
            2

        Api.Enum.Time.Class3 ->
            3

        Api.Enum.Time.Class4 ->
            4

        Api.Enum.Time.Class5 ->
            5


getClass : ClassId -> Dictionary -> Maybe ClassData
getClass (ClassId classId) (Dictionary dictionary) =
    let
        classMaybe =
            dictionary.class |> Dict.get classId
    in
    classMaybe
        |> Maybe.andThen
            (\class -> getClassDataFromDictionaryValue (ClassId classId) class dictionary.room)


getClassFromWeekAndTime : { week : Api.Enum.Week.Week, time : Api.Enum.Time.Time } -> Dictionary -> List ClassData
getClassFromWeekAndTime weekAndTime (Dictionary dictionary) =
    dictionary.class
        |> Dict.filter
            (\_ class ->
                class.weekAndTime == weekAndTime
            )
        |> Dict.toList
        |> List.filterMap
            (\( classId, class ) ->
                getClassDataFromDictionaryValue (ClassId classId) class dictionary.room
            )


getClassDataFromDictionaryValue : ClassId -> { name : String, teacher : String, room : RoomId, weekAndTime : WeekAndTime } -> Dict.Dict String { name : String } -> Maybe ClassData
getClassDataFromDictionaryValue classId class roomDictionary =
    let
        (RoomId roomId) =
            class.room
    in
    roomDictionary
        |> Dict.get roomId
        |> Maybe.map
            (\room ->
                { id = classId
                , name = class.name
                , teacher = class.teacher
                , room =
                    { id = RoomId roomId
                    , name = room.name
                    }
                , weekAndTime = class.weekAndTime
                }
            )


{-| 時間の範囲。 例: 9:20～11:00
-}
type ClockTimeRange
    = ClockTimeRange { start : Clock.Time, end : Clock.Time }


timeToClockTimeRange : Api.Enum.Time.Time -> ClockTimeRange
timeToClockTimeRange time =
    let
        start =
            (case time of
                Api.Enum.Time.Class1 ->
                    Clock.fromRawParts { hours = 9, minutes = 20, seconds = 0, milliseconds = 0 }

                Api.Enum.Time.Class2 ->
                    Clock.fromRawParts { hours = 11, minutes = 10, seconds = 0, milliseconds = 0 }

                Api.Enum.Time.Class3 ->
                    Clock.fromRawParts { hours = 13, minutes = 40, seconds = 0, milliseconds = 0 }

                Api.Enum.Time.Class4 ->
                    Clock.fromRawParts { hours = 15, minutes = 30, seconds = 0, milliseconds = 0 }

                Api.Enum.Time.Class5 ->
                    Clock.fromRawParts { hours = 17, minutes = 20, seconds = 0, milliseconds = 0 }
            )
                |> Maybe.withDefault (Clock.fromPosix (Time.millisToPosix 0))
    in
    ClockTimeRange
        { start = start
        , end = clockTimeIncrementMinutes 100 start
        }


clockTimeIncrementMinutes : Int -> Clock.Time -> Clock.Time
clockTimeIncrementMinutes rest =
    if rest <= 0 then
        identity

    else
        Clock.incrementMinutes >> Tuple.first


clockTimeRangeToString : ClockTimeRange -> String
clockTimeRangeToString (ClockTimeRange { start, end }) =
    clockTimeToString start ++ "～" ++ clockTimeToString end


clockTimeToString : Clock.Time -> String
clockTimeToString clockTime =
    String.fromInt (Clock.getHours clockTime)
        ++ ":"
        ++ String.fromInt (Clock.getMinutes clockTime)


type alias Area =
    { points : List ( Int, Int )
    , fill : Bool
    }


type alias Floor =
    { areaList : List Area
    , size : { width : Int, height : Int }
    }


building1_1 : Floor
building1_1 =
    { areaList =
        [ { points = [ ( 11, 16 ), ( 11, 664 ), ( 32, 664 ), ( 32, 840 ), ( 11, 840 ), ( 11, 998 ), ( 157, 998 ), ( 157, 971 ), ( 255, 971 ), ( 255, 998 ), ( 655, 998 ), ( 655, 745 ), ( 638, 745 ), ( 638, 719 ), ( 655, 719 ), ( 655, 16 ), ( 11, 16 ) ]
          , fill = False
          }
        , { points = [ ( 588, 918 ), ( 588, 998 ), ( 655, 998 ), ( 655, 918 ), ( 588, 918 ) ]
          , fill = True
          }
        ]
    , size = { width = 669, height = 1014 }
    }


dictionaryQuery : Graphql.SelectionSet.SelectionSet Dictionary Graphql.Operation.RootQuery
dictionaryQuery =
    Graphql.SelectionSet.map2
        (\classTupleList roomTupleList ->
            Dictionary
                { class = Dict.fromList classTupleList
                , room = Dict.fromList roomTupleList
                }
        )
        (Api.Query.classAll
            (Graphql.SelectionSet.map5
                (\id name teacher room weekAndTime ->
                    ( id
                    , { name = name
                      , teacher = teacher
                      , room = RoomId room
                      , weekAndTime = weekAndTime
                      }
                    )
                )
                Api.Object.Class.id
                Api.Object.Class.name
                Api.Object.Class.teacher
                (Api.Object.Class.room
                    Api.Object.Room.id
                )
                (Api.Object.Class.weekAndTime
                    (Graphql.SelectionSet.map2
                        (\week time ->
                            { week = week, time = time }
                        )
                        Api.Object.WeekAndTime.week
                        Api.Object.WeekAndTime.time
                    )
                )
            )
        )
        (Api.Query.roomAll
            (Graphql.SelectionSet.map2
                (\id name ->
                    ( id
                    , { name = name }
                    )
                )
                Api.Object.Room.id
                Api.Object.Room.name
            )
        )


userQuery : String -> Graphql.SelectionSet.SelectionSet User Graphql.Operation.RootQuery
userQuery accessToken =
    Api.Query.user { accessToken = accessToken }
        (Graphql.SelectionSet.map3
            (\name (Api.Scalar.FileHash imageFileHash) classOfWeek ->
                User
                    { name = name
                    , imageFileHash = imageFileHash
                    , classInTimeTable = classOfWeek
                    }
            )
            Api.Object.User.name
            Api.Object.User.imageFileHash
            (Api.Object.User.classInTimeTable
                (Graphql.SelectionSet.map6
                    (\monday tuesday wednesday thursday friday saturday ->
                        ClassOfWeek
                            { monday = monday
                            , tuesday = tuesday
                            , wednesday = wednesday
                            , thursday = thursday
                            , friday = friday
                            , saturday = saturday
                            }
                    )
                    (Api.Object.ClassOfWeek.monday classOfDayQuery)
                    (Api.Object.ClassOfWeek.tuesday classOfDayQuery)
                    (Api.Object.ClassOfWeek.wednesday classOfDayQuery)
                    (Api.Object.ClassOfWeek.thursday classOfDayQuery)
                    (Api.Object.ClassOfWeek.friday classOfDayQuery)
                    (Api.Object.ClassOfWeek.saturday classOfDayQuery)
                )
            )
        )


classOfDayQuery : Graphql.SelectionSet.SelectionSet ClassOfDay Api.Object.ClassOfDay
classOfDayQuery =
    Graphql.SelectionSet.map5
        (\c1 c2 c3 c4 c5 ->
            ClassOfDay
                { class1 = c1 |> Maybe.map ClassId |> ClassNoSending
                , class2 = c2 |> Maybe.map ClassId |> ClassNoSending
                , class3 = c3 |> Maybe.map ClassId |> ClassNoSending
                , class4 = c4 |> Maybe.map ClassId |> ClassNoSending
                , class5 = c5 |> Maybe.map ClassId |> ClassNoSending
                }
        )
        (Api.Object.ClassOfDay.class1 Api.Object.Class.id)
        (Api.Object.ClassOfDay.class2 Api.Object.Class.id)
        (Api.Object.ClassOfDay.class3 Api.Object.Class.id)
        (Api.Object.ClassOfDay.class4 Api.Object.Class.id)
        (Api.Object.ClassOfDay.class5 Api.Object.Class.id)


setClassQuery : String -> WeekAndTime -> Maybe ClassId -> Graphql.SelectionSet.SelectionSet () Graphql.Operation.RootMutation
setClassQuery accessToken weekAndTime classIdMaybe =
    Api.Mutation.setClass
        (case classIdMaybe of
            Just (ClassId classId) ->
                always { classId = Graphql.OptionalArgument.Present classId }

            Nothing ->
                identity
        )
        { accessToken = accessToken
        , week = weekAndTime.week
        , time = weekAndTime.time
        }
        Graphql.SelectionSet.empty
