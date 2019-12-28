port module Main exposing (Model, Msg, init, subscriptions, update, view)

import Browser
import Html
import Html.Events
import Http
import Json.Decode
import Url


port jumpPage : String -> Cmd msg


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Model
    = Model { result : Maybe (Result Http.Error Url.Url) }


init : () -> ( Model, Cmd Msg )
init () =
    ( Model { result = Nothing }, Cmd.none )


type Msg
    = RequestLineLogInUrl
    | ResponseLineLogInUrl (Result Http.Error Url.Url)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestLineLogInUrl ->
            ( model, Http.get { url = "api/lineLogInUrl", expect = Http.expectJson ResponseLineLogInUrl urlDecoder } )

        ResponseLineLogInUrl result ->
            case result of
                Ok url ->
                    ( Model { result = Just result }, jumpPage (Url.toString url) )

                Err _ ->
                    ( Model { result = Just result }, Cmd.none )


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


view : Model -> Browser.Document Msg
view (Model record) =
    { title = "Document Title"
    , body =
        [ Html.div []
            [ Html.button
                [ Html.Events.onClick RequestLineLogInUrl ]
                [ Html.text "LINE でログイン" ]
            ]
        ]
            ++ (case record.result of
                    Just (Ok url) ->
                        [ Html.text (Url.toString url) ]

                    Just (Err (Http.BadUrl url)) ->
                        [ Html.text ("urlが悪かった" ++ url) ]

                    Just (Err Http.Timeout) ->
                        [ Html.text "タイムアウトした" ]

                    Just (Err Http.NetworkError) ->
                        [ Html.text "ネットワークでエラーが発生しました" ]

                    Just (Err (Http.BadStatus number)) ->
                        [ Html.text ("エラーが発生しました" ++ String.fromInt number) ]

                    Just (Err (Http.BadBody message)) ->
                        [ Html.text ("レスポンスのデコードでエラーが発生しました " ++ message) ]

                    Nothing ->
                        []
               )
    }
