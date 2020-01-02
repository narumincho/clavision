port module Main exposing (Model, Msg, init, subscriptions, update, view)

import Browser
import Css
import Html
import Html.Styled as S
import Html.Styled.Attributes as A
import Html.Styled.Events
import Http
import Json.Decode
import Url


port jumpPage : String -> Cmd msg


main : Program () Model Msg
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
        , tab : Tab
        }


type Tab
    = FloorMap
    | TimeTable


init : () -> ( Model, Cmd Msg )
init () =
    ( Model { result = Nothing, tab = FloorMap }, Cmd.none )


type Msg
    = RequestLineLogInUrl
    | ResponseLineLogInUrl (Result Http.Error Url.Url)
    | ChangeTab Tab


update : Msg -> Model -> ( Model, Cmd Msg )
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

        ChangeTab tab ->
            ( Model { record | tab = tab }
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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html.Html Msg
view (Model record) =
    S.div
        [ A.css
            [ displayGrid
            , gridTemplateRows [ "64px", "1fr", "64px" ]
            ]
        ]
        [ S.div
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
        , S.div
            []
            [ S.text "中身" ]
        , S.div
            [ A.css [ Css.backgroundColor themeColor, displayGrid ]
            ]
            [ S.div
                [ A.css [ displayGrid, gridTemplateColumns [ "1fr", "1fr" ] ] ]
                [ menuItem
                    (if record.tab == TimeTable then
                        Just (ChangeTab FloorMap)

                     else
                        Nothing
                    )
                    "フロアマップ"
                , menuItem
                    (if record.tab == FloorMap then
                        Just (ChangeTab TimeTable)

                     else
                        Nothing
                    )
                    "時間割表"
                ]
            ]
        ]
        |> S.toUnstyled


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


gridTemplateRows : List String -> Css.Style
gridTemplateRows list =
    Css.property "grid-template-rows" (list |> String.join " ")


gridTemplateColumns : List String -> Css.Style
gridTemplateColumns list =
    Css.property "grid-template-columns" (list |> String.join " ")
