port module Main exposing (Message, Model, init, subscriptions, update, view)

{-

   Update Api

   npx elm-graphql https://us-central1-clavision.cloudfunctions.net/api --base Api --output source/source

-}

import Api.Enum.Time
import Api.Enum.Week
import Api.Mutation
import Api.Scalar
import Api.ScalarCodecs
import Browser
import Css
import Css.Animations
import Data
import Graphql.Http
import Html
import Html.Styled as S
import Html.Styled.Attributes as A
import Html.Styled.Events
import Svg.Styled
import Svg.Styled.Attributes
import Url


port jumpPage : String -> Cmd msg


apiUrl : String
apiUrl =
    "https://us-central1-clavision.cloudfunctions.net/api"


main : Program (Maybe String) Model Message
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Model
    = Model
        { result : Maybe (Result String Url.Url)
        , menu : Menu
        , floorMapSelectedBuildingNumber : BuildingNumber
        , timeTableSelectedWeekday : Api.Enum.Week.Week
        , dictionary : Maybe Data.Dictionary
        , loginModel : LoginModel
        }


type LoginModel
    = Guest
    | WaitLogInUrl
    | WaitUserData String
    | LoggedIn { accessToken : String, user : Data.User }


type Menu
    = FloorMap { beforeSelected : BuildingNumber }
    | TimeTable TimeTableModel


type TimeTableModel
    = TimeTableView { beforeSelected : Api.Enum.Week.Week }
    | TimeTableEdit Data.WeekAndTime


type BuildingNumber
    = Building1
    | Building2
    | Building3
    | Building4
    | Building5


buildingNumberAll : List BuildingNumber
buildingNumberAll =
    [ Building1
    , Building2
    , Building3
    , Building4
    , Building5
    ]


buildingNumberToString : BuildingNumber -> String
buildingNumberToString buildingNumber =
    case buildingNumber of
        Building1 ->
            "1号館"

        Building2 ->
            "2号館"

        Building3 ->
            "3号館"

        Building4 ->
            "4号館"

        Building5 ->
            "5号館"


init : Maybe String -> ( Model, Cmd Message )
init accessTokenMaybe =
    ( Model
        { result = Nothing
        , menu = FloorMap { beforeSelected = Building1 }
        , floorMapSelectedBuildingNumber = Building1
        , timeTableSelectedWeekday = Api.Enum.Week.Monday
        , dictionary = Nothing
        , loginModel =
            case accessTokenMaybe of
                Just accessToken ->
                    WaitUserData accessToken

                Nothing ->
                    Guest
        }
    , Cmd.batch
        ([ Graphql.Http.queryRequest apiUrl Data.dictionaryQuery
            |> Graphql.Http.send ResponseClassDictAndRoomDict
         ]
            ++ (case accessTokenMaybe of
                    Just accessToken ->
                        [ Graphql.Http.queryRequest apiUrl (Data.userQuery accessToken)
                            |> Graphql.Http.send ResponseUser
                        ]

                    Nothing ->
                        []
               )
        )
    )


type Message
    = RequestLineLogInUrl
    | ResponseLineLogInUrl (Result (Graphql.Http.Error Api.ScalarCodecs.Url) Api.ScalarCodecs.Url)
    | ResponseClassDictAndRoomDict (Result (Graphql.Http.Error Data.Dictionary) Data.Dictionary)
    | ResponseUser (Result (Graphql.Http.Error Data.User) Data.User)
    | SelectFloorMap
    | SelectTimeTable
    | SelectFloorMapBuildingNumber BuildingNumber
    | SelectTimeTableWeekday Api.Enum.Week.Week
    | ToEditClass Data.WeekAndTime
    | SetClass { weekAndTime : Data.WeekAndTime, classId : Maybe Data.ClassId }
    | ResponseSetClass { weekAndTime : Data.WeekAndTime, result : Result (Graphql.Http.Error ()) () }
    | BackToTimeTableView


update : Message -> Model -> ( Model, Cmd Message )
update msg (Model record) =
    case msg of
        RequestLineLogInUrl ->
            ( Model { record | loginModel = WaitLogInUrl }
            , Graphql.Http.mutationRequest apiUrl
                Api.Mutation.getLineLoginUrl
                |> Graphql.Http.send ResponseLineLogInUrl
            )

        ResponseLineLogInUrl result ->
            case result of
                Ok (Api.Scalar.Url url) ->
                    ( Model record
                    , jumpPage url
                    )

                Err _ ->
                    ( Model record
                    , Cmd.none
                    )

        ResponseClassDictAndRoomDict result ->
            case result of
                Ok dictionary ->
                    ( Model { record | dictionary = Just dictionary }
                    , Cmd.none
                    )

                Err _ ->
                    ( Model record
                    , Cmd.none
                    )

        ResponseUser result ->
            case ( result, record.loginModel ) of
                ( Ok user, WaitUserData accessToken ) ->
                    ( Model
                        { record
                            | loginModel =
                                LoggedIn
                                    { accessToken = accessToken
                                    , user = user
                                    }
                        }
                    , Cmd.none
                    )

                ( _, _ ) ->
                    ( Model record
                    , Cmd.none
                    )

        SelectFloorMap ->
            ( Model
                { record
                    | menu =
                        FloorMap
                            { beforeSelected = record.floorMapSelectedBuildingNumber }
                }
            , Cmd.none
            )

        SelectTimeTable ->
            ( Model
                { record
                    | menu =
                        TimeTable
                            (TimeTableView { beforeSelected = record.timeTableSelectedWeekday })
                }
            , Cmd.none
            )

        SelectFloorMapBuildingNumber buildingNumber ->
            ( Model
                { record
                    | floorMapSelectedBuildingNumber = buildingNumber
                    , menu = FloorMap { beforeSelected = record.floorMapSelectedBuildingNumber }
                }
            , Cmd.none
            )

        SelectTimeTableWeekday weekday ->
            ( Model
                { record
                    | timeTableSelectedWeekday = weekday
                    , menu = TimeTable (TimeTableView { beforeSelected = record.timeTableSelectedWeekday })
                }
            , Cmd.none
            )

        ToEditClass weekAndTime ->
            ( Model
                { record
                    | menu = TimeTable (TimeTableEdit weekAndTime)
                }
            , Cmd.none
            )

        SetClass { weekAndTime, classId } ->
            case record.loginModel of
                LoggedIn { user, accessToken } ->
                    let
                        setClassResult =
                            setClass weekAndTime classId user accessToken
                    in
                    ( Model
                        { record
                            | menu = TimeTable setClassResult.timeTableModel
                            , loginModel = setClassResult.logInModel
                        }
                    , setClassResult.cmd
                    )

                _ ->
                    ( Model record
                    , Cmd.none
                    )

        ResponseSetClass { weekAndTime, result } ->
            case record.loginModel of
                LoggedIn loginRecord ->
                    ( Model
                        { record
                            | loginModel =
                                LoggedIn
                                    { loginRecord
                                        | user =
                                            setClassResponse weekAndTime result loginRecord.user
                                    }
                        }
                    , Cmd.none
                    )

                _ ->
                    ( Model record
                    , Cmd.none
                    )

        BackToTimeTableView ->
            ( Model
                { record
                    | menu =
                        TimeTable
                            (TimeTableView { beforeSelected = record.timeTableSelectedWeekday })
                }
            , Cmd.none
            )


setClass : Data.WeekAndTime -> Maybe Data.ClassId -> Data.User -> String -> { logInModel : LoginModel, timeTableModel : TimeTableModel, cmd : Cmd.Cmd Message }
setClass weekAndTime classIdMaybe user accessToken =
    let
        beforeClassSelect =
            user
                |> Data.userGetTimeTableClass
                |> Data.classOfWeekGetClassOfDay weekAndTime.week
                |> Data.classOfDayGetClassSelect weekAndTime.time
    in
    case beforeClassSelect of
        Data.ClassNoSending before ->
            { logInModel =
                LoggedIn
                    { user =
                        user
                            |> Data.userMapTimeTableClass weekAndTime
                                (always (Data.ClassSending { before = before, after = classIdMaybe }))
                    , accessToken = accessToken
                    }
            , timeTableModel = TimeTableView { beforeSelected = weekAndTime.week }
            , cmd =
                Graphql.Http.mutationRequest
                    apiUrl
                    (Data.setClassQuery accessToken weekAndTime classIdMaybe)
                    |> Graphql.Http.send
                        (\result ->
                            ResponseSetClass { weekAndTime = weekAndTime, result = result }
                        )
            }

        Data.ClassSending _ ->
            { logInModel =
                LoggedIn
                    { user = user
                    , accessToken = accessToken
                    }
            , timeTableModel = TimeTableView { beforeSelected = weekAndTime.week }
            , cmd = Cmd.none
            }


setClassResponse : Data.WeekAndTime -> Result (Graphql.Http.Error ()) () -> Data.User -> Data.User
setClassResponse weekAndTime result user =
    Data.userMapTimeTableClass weekAndTime
        (always
            (Data.ClassNoSending
                (user
                    |> Data.userGetTimeTableClass
                    |> Data.classOfWeekGetClassOfDay weekAndTime.week
                    |> Data.classOfDayGetClassSelect weekAndTime.time
                    |> (case result of
                            Ok _ ->
                                Data.classSelectGetAfter

                            Err _ ->
                                Data.classSelectGetBefore
                       )
                )
            )
        )
        user


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none


view : Model -> Html.Html Message
view (Model record) =
    S.div
        [ A.css
            [ displayGrid
            , gridCellHeightList [ "64px", "1fr", "max-content" ]
            , Css.height (Css.pct 100)
            , Css.overflowWrap Css.breakWord
            ]
        ]
        (header
            :: (case record.menu of
                    FloorMap { beforeSelected } ->
                        [ floorMapView beforeSelected record.floorMapSelectedBuildingNumber
                        , menuView record.menu
                        ]

                    TimeTable (TimeTableView { beforeSelected }) ->
                        [ timeTableView
                            record.dictionary
                            record.loginModel
                            beforeSelected
                            record.timeTableSelectedWeekday
                        , menuView record.menu
                        ]

                    TimeTable (TimeTableEdit weekAndTime) ->
                        [ timeTableEdit
                            record.dictionary
                            record.loginModel
                            weekAndTime
                        ]
               )
        )
        |> S.toUnstyled


header : S.Html message
header =
    S.div
        [ A.css
            [ Css.backgroundColor themeColor
            , Css.color (Css.rgb 255 255 255)
            , displayGrid
            , Css.justifyContent Css.center
            , Css.alignItems Css.center
            , Css.fontSize (Css.rem 1.5)
            , boxShadow
            , Css.zIndex (Css.int 2)
            ]
        ]
        [ S.text "クラビジョン" ]


floorMapView : BuildingNumber -> BuildingNumber -> S.Html Message
floorMapView beforeSelected buildingNumber =
    S.div
        [ A.css
            [ displayGrid
            , gridCellHeightList [ "48px", "1fr" ]
            , gridCellWidthList [ "1fr" ]
            , Css.overflow Css.auto
            ]
        ]
        [ buildingNumberTab beforeSelected buildingNumber
        , floorList buildingNumber
        ]


floorList : BuildingNumber -> S.Html Message
floorList buildingNumber =
    S.div
        [ A.css
            [ Css.overflow Css.auto
            , gridCell { x = 0, y = 1, width = 1, height = 1 }
            ]
        ]
        ((case buildingNumber of
            Building1 ->
                [ ( 1, Data.building1_1 ) ]

            _ ->
                []
         )
            |> List.map
                (\( floor, floorMap ) ->
                    S.div
                        []
                        [ S.text (String.fromInt floor ++ "階")
                        , floorMapToSvg floorMap
                        ]
                )
        )


buildingNumberTab : BuildingNumber -> BuildingNumber -> S.Html Message
buildingNumberTab beforeSelected buildingNumber =
    tabView
        beforeSelected
        buildingNumber
        SelectFloorMapBuildingNumber
        buildingNumberToString
        buildingNumberAll


tabView : a -> a -> (a -> msg) -> (a -> String) -> List a -> S.Html msg
tabView beforeSelected selected messageFunction textFunction all =
    let
        count =
            List.length all
    in
    S.div
        [ A.css
            [ displayGrid
            , gridCellWidthList (List.repeat count "1fr")
            , boxShadow
            , Css.zIndex (Css.int 2)
            ]
        ]
        ((all |> List.indexedMap (tabItem selected messageFunction textFunction))
            ++ [ tabSelectedBar count (elementIndex all beforeSelected) (elementIndex all selected) ]
        )


elementIndex : List a -> a -> Int
elementIndex list a =
    case list of
        x :: xs ->
            if x == a then
                0

            else
                1 + elementIndex xs a

        [] ->
            0


tabSelectedBar : Int -> Int -> Int -> S.Html message
tabSelectedBar count beforeSelected index =
    S.div
        [ A.css
            [ Css.position Css.relative
            , Css.pointerEvents Css.none
            , gridCell { x = 0, y = 0, width = count, height = 1 }
            , Css.alignSelf Css.end
            , Css.height (Css.px 4)
            ]
        ]
        [ S.div
            [ A.css
                [ Css.backgroundColor themeColor
                , Css.height (Css.pct 100)
                , Css.animationName
                    (Css.Animations.keyframes
                        [ ( 0
                          , [ Css.Animations.transform
                                [ Css.translateX (Css.pct (toFloat beforeSelected * 100)) ]
                            ]
                          )
                        , ( 100
                          , [ Css.Animations.transform
                                [ Css.translateX (Css.pct (toFloat index * 100)) ]
                            ]
                          )
                        ]
                    )
                , Css.animationDuration (Css.ms 200)
                , Css.property "animation-fill-mode" "forwards"
                , Css.property "width" ("calc( 100% / " ++ String.fromInt count ++ ")")
                ]
            ]
            []
        ]


tabItem : a -> (a -> msg) -> (a -> String) -> Int -> a -> S.Html msg
tabItem selected messageFunction textFunction index element =
    if selected == element then
        S.div
            [ A.css
                [ displayGrid
                , Css.justifyContent Css.center
                , Css.alignItems Css.center
                , Css.color themeColor
                , Css.backgroundColor (Css.rgb 244 244 244)
                , userSelectNone
                , gridCell { x = index, y = 0, width = 1, height = 1 }
                , Css.fontWeight Css.bold
                , Css.border2 Css.zero Css.none
                , Css.fontSize (Css.rem 1)
                ]
            ]
            [ S.text (textFunction element) ]

    else
        S.button
            [ Html.Styled.Events.onClick (messageFunction element)
            , A.css
                [ displayGrid
                , Css.justifyContent Css.center
                , Css.alignItems Css.center
                , Css.color (Css.rgb 85 85 85)
                , Css.backgroundColor (Css.rgb 244 244 244)
                , userSelectNone
                , gridCell { x = index, y = 0, width = 1, height = 1 }
                , Css.cursor Css.pointer
                , Css.hover
                    [ Css.backgroundColor (Css.rgb 221 221 221)
                    , Css.color themeColor
                    ]
                , Css.border2 Css.zero Css.none
                , Css.fontSize (Css.rem 1)
                ]
            ]
            [ S.text (textFunction element) ]


timeTableView : Maybe Data.Dictionary -> LoginModel -> Api.Enum.Week.Week -> Api.Enum.Week.Week -> S.Html Message
timeTableView dictionaryMaybe logInModel beforeSelected selected =
    S.div
        [ A.css [ displayGrid, gridCellHeightList [ "32px", "48px", "1fr" ], Css.overflow Css.auto ]
        ]
        (case logInModel of
            Guest ->
                [ S.text "時間割表を使うにはLINEでログインが必要です"
                , lineLogInButton
                ]

            WaitLogInUrl ->
                [ S.text "LINEへのURLを発行中" ]

            WaitUserData _ ->
                [ S.text "ユーザーの情報を取得中…" ]

            LoggedIn { user } ->
                [ userView user
                , weekdayTab beforeSelected selected
                , timeTableBody dictionaryMaybe
                    (Data.userGetTimeTableClass user
                        |> Data.classOfWeekGetClassOfDay selected
                    )
                    |> S.map (\e -> ToEditClass { week = selected, time = e })
                ]
        )


lineLogInButton : S.Html Message
lineLogInButton =
    S.button
        [ A.css
            [ Css.backgroundColor (Css.rgb 0 195 0)
            , Css.border2 Css.zero Css.none
            , Css.borderRadius (Css.px 8)
            , Css.padding Css.zero
            , Css.width (Css.pct 100)
            , Css.height (Css.px 96)
            , Css.cursor Css.pointer
            ]
        , Html.Styled.Events.onClick RequestLineLogInUrl
        ]
        [ S.div
            [ A.css
                [ Css.property "display" "grid"
                , Css.property "grid-auto-flow" "column"
                , Css.property "grid-template-columns" "max-content 1fr"
                , Css.alignItems Css.center
                ]
            ]
            [ S.img
                [ A.src "/assets/line_icon120.png"
                , A.alt "LINEのロゴ"
                , A.css
                    [ Css.width (Css.px 97)
                    , Css.height (Css.px 96)
                    , Css.boxSizing Css.borderBox
                    , Css.borderRight3 (Css.px 1) Css.solid (Css.rgb 0 179 0)
                    ]
                ]
                []
            , S.div
                [ A.css
                    [ Css.color (Css.rgb 255 255 255)
                    , Css.padding (Css.px 8)
                    , Css.fontSize (Css.rem 1.5)
                    ]
                ]
                [ S.text "LINEでログイン" ]
            ]
        ]


userView : Data.User -> S.Html message
userView user =
    S.div
        [ A.css
            [ displayGrid
            , Css.alignItems Css.center
            , Css.height (Css.px 32)
            , gridCellWidthList [ "32px", "1fr" ]
            ]
        ]
        [ S.img
            [ A.src (Data.userGetImageUrl user)
            , A.alt (Data.userGetName user ++ "さんのプロフィール画像")
            , A.css
                [ Css.borderRadius (Css.pct 50)
                , Css.property "object-fit" "cover"
                , Css.width (Css.px 32)
                , Css.height (Css.px 32)
                ]
            ]
            []
        , S.text (Data.userGetName user)
        ]


weekdayTab : Api.Enum.Week.Week -> Api.Enum.Week.Week -> S.Html Message
weekdayTab beforeSelected selected =
    tabView
        beforeSelected
        selected
        SelectTimeTableWeekday
        Data.weekToString
        Api.Enum.Week.list


timeTableBody : Maybe Data.Dictionary -> Data.ClassOfDay -> S.Html Api.Enum.Time.Time
timeTableBody dictionaryMaybe classOfDay =
    S.div
        [ A.css [ displayGrid ] ]
        (Api.Enum.Time.list
            |> List.map (\time -> timeTableClass dictionaryMaybe (classOfDay |> Data.classOfDayGetClassSelect time) time)
        )


timeTableClass : Maybe Data.Dictionary -> Data.ClassSelect -> Api.Enum.Time.Time -> S.Html Api.Enum.Time.Time
timeTableClass dictionaryMaybe classSelect time =
    S.button
        [ A.css
            [ Css.backgroundColor (Css.rgb 255 255 255)
            , Css.border2 Css.zero Css.none
            , Css.cursor Css.pointer
            , Css.padding (Css.px 16)
            , Css.textAlign Css.left
            ]
        , if changeableClass dictionaryMaybe classSelect then
            Html.Styled.Events.onClick time

          else
            A.disabled True
        ]
        [ S.div
            [ A.css
                [ displayGrid
                , gridCellWidthList [ "32px", "1fr" ]
                , gridCellHeightList [ "max-content", "max-content" ]
                , Css.fontSize (Css.rem 1)
                ]
            ]
            [ S.div
                [ A.css
                    [ gridCell { x = 0, y = 0, width = 1, height = 2 }
                    , Css.fontSize (Css.rem 3)
                    ]
                ]
                [ S.text (time |> Data.timeToInt |> String.fromInt) ]
            , S.div
                [ A.css [ gridCell { x = 1, y = 0, width = 1, height = 1 } ] ]
                [ S.text (time |> Data.timeToClockTimeRange |> Data.clockTimeRangeToString) ]
            , S.div
                [ A.css [ gridCell { x = 1, y = 1, width = 1, height = 1 } ]
                ]
                (case ( dictionaryMaybe, classSelect ) of
                    ( Just dictionary, Data.ClassNoSending (Just classId) ) ->
                        case dictionary |> Data.getClass classId of
                            Just class ->
                                [ S.div [ A.css [ Css.fontSize (Css.rem 2) ] ] [ S.text class.name ]
                                , S.div [] [ S.text class.teacher ]
                                , S.div [] [ S.text class.room.name ]
                                ]

                            Nothing ->
                                [ S.div [] [ S.text "存在しない授業を登録している" ] ]

                    ( Just dictionary, Data.ClassSending { before, after } ) ->
                        [ S.text
                            (getClassName before dictionary
                                ++ "→"
                                ++ getClassName after dictionary
                                ++ "に変更中…"
                            )
                        ]

                    ( Nothing, Data.ClassNoSending (Just classId) ) ->
                        [ S.div []
                            [ S.text
                                ("id=" ++ Data.classIdToString classId)
                            ]
                        ]

                    ( Nothing, Data.ClassSending { after, before } ) ->
                        [ S.div []
                            [ S.text
                                ("id="
                                    ++ getClassNameWithoutDictionary before
                                    ++ "→"
                                    ++ getClassNameWithoutDictionary after
                                )
                            ]
                        ]

                    ( _, Data.ClassNoSending Nothing ) ->
                        [ S.div [] [ S.text "なし" ] ]
                )
            ]
        ]


getClassName : Maybe Data.ClassId -> Data.Dictionary -> String
getClassName classIdMaybe dictionary =
    case classIdMaybe of
        Just classId ->
            dictionary |> Data.getClass classId |> Maybe.map .name |> Maybe.withDefault "???"

        Nothing ->
            "なし"


getClassNameWithoutDictionary : Maybe Data.ClassId -> String
getClassNameWithoutDictionary =
    Maybe.map Data.classIdToString >> Maybe.withDefault "なし"


changeableClass : Maybe Data.Dictionary -> Data.ClassSelect -> Bool
changeableClass dictionaryMaybe classSelect =
    case ( dictionaryMaybe, classSelect ) of
        ( Just _, Data.ClassNoSending _ ) ->
            True

        ( _, _ ) ->
            False


timeTableEdit : Maybe Data.Dictionary -> LoginModel -> Data.WeekAndTime -> S.Html Message
timeTableEdit dictionaryMaybe logInModel weekAndTime =
    S.div
        [ A.css
            [ Css.overflow Css.auto ]
        ]
        (case ( logInModel, dictionaryMaybe ) of
            ( LoggedIn { user }, Just dictionary ) ->
                [ S.div
                    []
                    [ S.button
                        [ A.css
                            [ Css.padding (Css.px 8)
                            , Css.fontSize (Css.rem 1.5)
                            ]
                        , Html.Styled.Events.onClick BackToTimeTableView
                        ]
                        [ S.text "←" ]
                    , S.text (Data.weekAndTimeToString weekAndTime ++ "にどの授業を取りますか?")
                    ]
                , timeTableEditList (dictionary |> Data.getClassFromWeekAndTime weekAndTime)
                    |> S.map (\classId -> SetClass { weekAndTime = weekAndTime, classId = classId })
                ]

            ( _, Nothing ) ->
                [ S.text "授業情報を読み込み中…" ]

            _ ->
                [ S.text "ログインしていないと、時間割表を編集することができません" ]
        )


timeTableEditList : List Data.ClassData -> S.Html (Maybe Data.ClassId)
timeTableEditList classDataList =
    S.div
        [ A.css [ displayGrid ] ]
        (S.button
            [ A.css
                [ timeTableEditItemStyle
                , Css.cursor Css.pointer
                , Css.fontSize (Css.rem 2)
                , Css.textAlign Css.left
                ]
            , Html.Styled.Events.onClick Nothing
            ]
            [ S.text "なし" ]
            :: (classDataList |> List.sortBy .name |> List.map (timeTableEditListItem >> S.map Just))
        )


timeTableEditListItem : Data.ClassData -> S.Html Data.ClassId
timeTableEditListItem classData =
    S.button
        [ A.css
            [ timeTableEditItemStyle
            , Css.cursor Css.pointer
            , Css.textAlign Css.left
            ]
        , Html.Styled.Events.onClick classData.id
        ]
        [ S.div [ A.css [ Css.fontSize (Css.rem 1.5) ] ] [ S.text classData.name ]
        , S.div [] [ S.text classData.teacher ]
        , S.div [] [ S.text classData.room.name ]
        ]


timeTableEditItemStyle : Css.Style
timeTableEditItemStyle =
    Css.batch
        [ Css.backgroundColor gray
        , Css.border2 Css.zero Css.none
        , Css.padding (Css.px 8)
        ]


gray : Css.Color
gray =
    Css.rgb 223 223 223


menuView : Menu -> S.Html Message
menuView tab =
    S.div
        [ A.css [ Css.backgroundColor themeColor, displayGrid, Css.height (Css.px 64) ]
        ]
        [ S.div
            [ A.css [ displayGrid, gridCellWidthList [ "1fr", "1fr" ] ] ]
            [ menuItem
                (case tab of
                    TimeTable _ ->
                        Just SelectFloorMap

                    FloorMap _ ->
                        Nothing
                )
                "フロアマップ"
            , menuItem
                (case tab of
                    FloorMap _ ->
                        Just SelectTimeTable

                    TimeTable _ ->
                        Nothing
                )
                "時間割表"
            ]
        ]


menuItem : Maybe message -> String -> S.Html message
menuItem messageMaybe text =
    case messageMaybe of
        Just message ->
            S.button
                [ A.css
                    [ displayGrid
                    , Css.justifyContent Css.center
                    , Css.alignItems Css.center
                    , Css.color (Css.rgb 170 170 170)
                    , userSelectNone
                    , Css.backgroundColor themeColor
                    , Css.border2 Css.zero Css.none
                    , Css.fontSize (Css.rem 1)
                    , Css.cursor Css.pointer
                    ]
                , Html.Styled.Events.onClick message
                ]
                [ S.text text ]

        Nothing ->
            S.div
                [ A.css
                    [ displayGrid
                    , Css.justifyContent Css.center
                    , Css.alignItems Css.center
                    , Css.color (Css.rgb 255 255 255)
                    , userSelectNone
                    ]
                ]
                [ S.text text ]


floorMapToSvg : Data.FloorMap -> Svg.Styled.Svg message
floorMapToSvg floor =
    Svg.Styled.svg
        [ Svg.Styled.Attributes.viewBox
            ("0 0 "
                ++ String.fromInt floor.size.width
                ++ " "
                ++ String.fromInt floor.size.height
            )
        , Svg.Styled.Attributes.css
            [ objectFixContain
            , Css.width (Css.pct 100)
            , Css.height (Css.px 400)
            ]
        ]
        (floor.areaList |> List.map areaToSvg)


areaToSvg : Data.Area -> Svg.Styled.Svg message
areaToSvg area =
    Svg.Styled.polyline
        [ Svg.Styled.Attributes.points
            (area.points
                |> List.concatMap (\( a, b ) -> [ a, b ])
                |> List.map String.fromInt
                |> String.join " "
            )
        , Svg.Styled.Attributes.fill
            (if area.fill then
                "rgb(223, 223, 223)"

             else
                "none"
            )
        , Svg.Styled.Attributes.stroke "black"
        ]
        []


themeColor : Css.Color
themeColor =
    Css.rgb 88 29 116


displayGrid : Css.Style
displayGrid =
    Css.property "display" "grid"


gap : Int -> Css.Style
gap number =
    Css.property "gap" (String.fromInt number ++ "px")


gridCellHeightList : List String -> Css.Style
gridCellHeightList list =
    Css.property "grid-template-rows" (list |> String.join " ")


gridCellWidthList : List String -> Css.Style
gridCellWidthList list =
    Css.property "grid-template-columns" (list |> String.join " ")


gridCell : { x : Int, y : Int, width : Int, height : Int } -> Css.Style
gridCell { x, y, width, height } =
    Css.batch
        [ Css.property "grid-column"
            (String.fromInt (1 + x) ++ " / " ++ String.fromInt (1 + x + width))
        , Css.property "grid-row"
            (String.fromInt (1 + y) ++ " / " ++ String.fromInt (1 + y + height))
        ]


userSelectNone : Css.Style
userSelectNone =
    Css.property "user-select" "none"


objectFixContain : Css.Style
objectFixContain =
    Css.property "object-fit" "contain"


boxShadow : Css.Style
boxShadow =
    Css.boxShadow4 Css.zero (Css.px 2) (Css.px 4) (Css.rgba 0 0 0 0.18)
