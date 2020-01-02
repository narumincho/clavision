port module Main exposing (Message, Model, init, subscriptions, update, view)

import Browser
import Css
import Css.Animations
import Css.Transitions
import Html
import Html.Styled as S
import Html.Styled.Attributes as A
import Html.Styled.Events
import Html.Styled.Keyed
import Http
import Json.Decode
import Url


port jumpPage : String -> Cmd msg


main : Program () Model Message
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Model
    = Model
        { result : Maybe (Result Http.Error Url.Url)
        , menu : Menu
        , floorMapSelectedBuildingNumber : BuildingNumber
        , beforeSelectedBuildingNumber : BuildingNumber
        }


type Menu
    = FloorMap
    | TimeTable


menuAll : List Menu
menuAll =
    [ FloorMap, TimeTable ]


tabToString : Menu -> String
tabToString menu =
    case menu of
        FloorMap ->
            "フロアマップ"

        TimeTable ->
            "時間割"


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


init : () -> ( Model, Cmd Message )
init () =
    ( Model
        { result = Nothing
        , menu = FloorMap
        , floorMapSelectedBuildingNumber = Building1
        , beforeSelectedBuildingNumber = Building1
        }
    , Cmd.none
    )


type Message
    = RequestLineLogInUrl
    | ResponseLineLogInUrl (Result Http.Error Url.Url)
    | ChangeMenu Menu
    | SelectFloorMapBuildingNumber BuildingNumber


update : Message -> Model -> ( Model, Cmd Message )
update msg (Model record) =
    case msg of
        RequestLineLogInUrl ->
            ( Model record
            , Http.get
                { url = "api/lineLogInUrl"
                , expect = Http.expectJson ResponseLineLogInUrl urlDecoder
                }
            )

        ResponseLineLogInUrl result ->
            case result of
                Ok url ->
                    ( Model { record | result = Just result }
                    , jumpPage (Url.toString url)
                    )

                Err _ ->
                    ( Model { record | result = Just result }
                    , Cmd.none
                    )

        ChangeMenu tab ->
            ( Model { record | menu = tab }
            , Cmd.none
            )

        SelectFloorMapBuildingNumber buildingNumber ->
            ( Model
                { record
                    | floorMapSelectedBuildingNumber = buildingNumber
                    , beforeSelectedBuildingNumber = record.floorMapSelectedBuildingNumber
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
            ]
        ]
        [ header
        , case record.menu of
            FloorMap ->
                floorMap record.beforeSelectedBuildingNumber record.floorMapSelectedBuildingNumber

            TimeTable ->
                timeTable
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
    Html.Styled.Keyed.node
        "div"
        [ A.css [ displayGrid, gridCellHeightList [ "48px", "1fr" ] ]
        ]
        [ ( "tab", buildingNumberTab beforeSelected buildingNumber )
        , ( "body", S.text (buildingNumberToString buildingNumber) )
        ]


buildingNumberTab : BuildingNumber -> BuildingNumber -> S.Html Message
buildingNumberTab beforeSelected buildingNumber =
    tabView beforeSelected buildingNumber SelectFloorMapBuildingNumber buildingNumberToString buildingNumberAll


tabView : a -> a -> (a -> msg) -> (a -> String) -> List a -> S.Html msg
tabView beforeSelected selected messageFunction textFunction all =
    let
        count =
            List.length all
    in
    Html.Styled.Keyed.node
        "div"
        [ A.css
            [ displayGrid
            , gridCellWidthList (List.repeat count "1fr")
            ]
        ]
        ((all |> List.indexedMap (tabItem selected messageFunction textFunction))
            ++ [ ( "s", tabSelectedBar count (elementIndex all beforeSelected) (elementIndex all selected) ) ]
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
    Html.Styled.Keyed.node
        "div"
        [ A.css
            [ Css.position Css.relative
            , Css.pointerEvents Css.none
            , gridCellX 0 count
            , gridCellY 0 1
            , Css.alignSelf Css.end
            , Css.height (Css.px 4)
            ]
        ]
        [ ( "a"
          , S.div
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
          )
        ]


tabItem : a -> (a -> msg) -> (a -> String) -> Int -> a -> ( String, S.Html msg )
tabItem selected messageFunction textFunction index element =
    ( String.fromInt index
    , if selected == element then
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

            --, A.disabled False
            ]
            [ S.text (textFunction element) ]
    )


timeTable : S.Html Message
timeTable =
    S.div
        []
        [ S.text "時間割表" ]


menuView : Menu -> S.Html Message
menuView tab =
    S.div
        [ A.css [ Css.backgroundColor themeColor, displayGrid ]
        ]
        [ S.div
            [ A.css [ displayGrid, gridCellWidthList [ "1fr", "1fr" ] ] ]
            [ menuItem
                (case tab of
                    TimeTable ->
                        Just (ChangeMenu FloorMap)

                    FloorMap ->
                        Nothing
                )
                "フロアマップ"
            , menuItem
                (case tab of
                    FloorMap ->
                        Just (ChangeMenu TimeTable)

                    TimeTable ->
                        Nothing
                )
                "時間割表"
            ]
        ]


menuItem : Maybe message -> String -> S.Html message
menuItem messageMaybe text =
    S.div
        ([ A.css
            [ displayGrid
            , Css.justifyContent Css.center
            , Css.alignItems Css.center
            , Css.color
                (case messageMaybe of
                    Just _ ->
                        Css.rgb 150 150 150

                    Nothing ->
                        Css.rgb 255 255 255
                )
            ]
         ]
            ++ (case messageMaybe of
                    Just message ->
                        [ Html.Styled.Events.onClick message ]

                    Nothing ->
                        []
               )
        )
        [ S.text text ]


themeColor : Css.Color
themeColor =
    Css.rgb 144 62 166


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
