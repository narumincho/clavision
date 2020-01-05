port module Main exposing (Message, Model, init, subscriptions, update, view)

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
import Json.Decode
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
        , classDict : Maybe Data.ClassDict
        , roomDict : Maybe Data.RoomDict
        , loginModel : LoginModel
        }


type LoginModel
    = Guest
    | WaitUserData String
    | LoggedIn { accessToken : String, user : Data.User }


type Menu
    = FloorMap { beforeSelected : BuildingNumber }
    | TimeTable { beforeSelected : Api.Enum.Week.Week }


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
        , classDict = Nothing
        , roomDict = Nothing
        , loginModel =
            case accessTokenMaybe of
                Just accessToken ->
                    WaitUserData accessToken

                Nothing ->
                    Guest
        }
    , Cmd.batch
        ([ Graphql.Http.queryRequest apiUrl Data.classDictQuery
            |> Graphql.Http.send ResponseClassDict
         , Graphql.Http.queryRequest apiUrl Data.roomDictQuery
            |> Graphql.Http.send ResponseRoomDict
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
    | ResponseClassDict (Result (Graphql.Http.Error Data.ClassDict) Data.ClassDict)
    | ResponseRoomDict (Result (Graphql.Http.Error Data.RoomDict) Data.RoomDict)
    | ResponseUser (Result (Graphql.Http.Error Data.User) Data.User)
    | SelectFloorMap
    | SelectTimeTable
    | SelectFloorMapBuildingNumber BuildingNumber
    | SelectTimeTableWeekday Api.Enum.Week.Week


update : Message -> Model -> ( Model, Cmd Message )
update msg (Model record) =
    case msg of
        RequestLineLogInUrl ->
            ( Model record
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

        ResponseClassDict result ->
            case result of
                Ok classDict ->
                    ( Model { record | classDict = Just classDict }
                    , Cmd.none
                    )

                Err _ ->
                    ( Model record
                    , Cmd.none
                    )

        ResponseRoomDict result ->
            case result of
                Ok roomDict ->
                    ( Model { record | roomDict = Just roomDict }
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
                            { beforeSelected = record.timeTableSelectedWeekday }
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
                    , menu = TimeTable { beforeSelected = record.timeTableSelectedWeekday }
                }
            , Cmd.none
            )


urlDecoder : Json.Decode.Decoder Url.Url
urlDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\string ->
                case Url.fromString string of
                    Just url ->
                        Json.Decode.succeed url

                    Nothing ->
                        Json.Decode.fail "URL format error"
            )


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none


view : Model -> Html.Html Message
view (Model record) =
    S.div
        [ A.css
            [ displayGrid
            , gridCellHeightList [ "64px", "1fr", "64px" ]
            , Css.height (Css.pct 100)
            ]
        ]
        [ header
        , case record.menu of
            FloorMap { beforeSelected } ->
                floorMap beforeSelected record.floorMapSelectedBuildingNumber

            TimeTable { beforeSelected } ->
                timeTable record.loginModel beforeSelected record.timeTableSelectedWeekday
        , menuView record.menu
        ]
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
            ]
        ]
        [ S.text "クラビジョン" ]


floorMap : BuildingNumber -> BuildingNumber -> S.Html Message
floorMap beforeSelected buildingNumber =
    S.div
        [ A.css [ displayGrid, gridCellHeightList [ "48px", "1fr" ] ]
        ]
        [ buildingNumberTab beforeSelected buildingNumber
        , S.text (buildingNumberToString buildingNumber)
        ]


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
            , gridCellX 0 count
            , gridCellY 0 1
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
                , gridCellX index 1
                , gridCellY 0 1
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
                , gridCellX index 1
                , gridCellY 0 1
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


timeTable : LoginModel -> Api.Enum.Week.Week -> Api.Enum.Week.Week -> S.Html Message
timeTable logInModel beforeSelected selected =
    case logInModel of
        Guest ->
            S.div
                []
                [ S.text "時間割表を使うにはLINEでログインが必要です"
                , lineLogInButton
                ]

        WaitUserData _ ->
            S.div
                []
                [ S.text "ユーザーの情報を取得中…" ]

        LoggedIn { user } ->
            S.div
                [ A.css [ displayGrid, gridCellHeightList [ "32px", "48px", "1fr" ] ]
                ]
                [ userView user
                , weekdayTab beforeSelected selected
                ]


lineLogInButton : S.Html Message
lineLogInButton =
    S.button
        [ A.css
            [ Css.backgroundColor (Css.rgb 0 195 0)
            , Css.border2 Css.zero Css.none
            , Css.borderRadius (Css.px 8)
            , Css.padding Css.zero
            , Css.width (Css.pct 100)
            , Css.height (Css.px 64)
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
                , A.href "LINEのロゴ"
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
        [ A.css [ displayGrid, Css.justifyContent Css.center, Css.height (Css.px 32) ] ]
        [ S.img
            [ A.href (Data.userGetImageUrl user)
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


menuView : Menu -> S.Html Message
menuView tab =
    S.div
        [ A.css [ Css.backgroundColor themeColor, displayGrid ]
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


themeColor : Css.Color
themeColor =
    Css.rgb 88 29 116


displayGrid : Css.Style
displayGrid =
    Css.property "display" "grid"


gridCellHeightList : List String -> Css.Style
gridCellHeightList list =
    Css.property "grid-template-rows" (list |> String.join " ")


gridCellWidthList : List String -> Css.Style
gridCellWidthList list =
    Css.property "grid-template-columns" (list |> String.join " ")


gridCellY : Int -> Int -> Css.Style
gridCellY y height =
    Css.property
        "grid-row"
        (String.fromInt (1 + y) ++ " / " ++ String.fromInt (1 + y + height))


gridCellX : Int -> Int -> Css.Style
gridCellX x width =
    Css.property
        "grid-column"
        (String.fromInt (1 + x) ++ " / " ++ String.fromInt (1 + x + width))


userSelectNone : Css.Style
userSelectNone =
    Css.property "user-select" "none"
